#!/usr/bin/env python3
"""
Claude Code Notify
"""

import os
import sys
import json
import sqlite3
import subprocess
import logging
import fcntl
import time
import tempfile
from logging.handlers import TimedRotatingFileHandler
from datetime import datetime, timezone


class NotificationDeduplicator:
    """Prevents duplicate notifications using file locking and cooldown"""
    
    def __init__(self, cooldown_seconds=8):
        """Initialize with configurable cooldown period"""
        self.cooldown_seconds = cooldown_seconds
        self.temp_dir = tempfile.gettempdir()
        
    def should_send_notification(self, session_id, event_type):
        """
        Check if notification should be sent based on:
        1. File locking to prevent simultaneous notifications
        2. Cooldown period to prevent rapid notifications
        3. Priority system (Stop > Notification)
        
        Returns tuple: (should_send: bool, reason: str)
        """
        lock_file_path = os.path.join(self.temp_dir, f"claude_notify_{session_id}.lock")
        
        try:
            # Try to acquire lock
            with open(lock_file_path, 'w') as lock_file:
                try:
                    # Non-blocking lock attempt
                    fcntl.flock(lock_file.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
                    
                    # Check if there was a recent notification
                    last_notification_info = self._get_last_notification_info(session_id)
                    
                    if last_notification_info:
                        last_time, last_event_type = last_notification_info
                        time_since_last = time.time() - last_time
                        
                        # If within cooldown period
                        if time_since_last < self.cooldown_seconds:
                            # Priority: Stop notifications are more important than Notification
                            if event_type == 'Notification' and last_event_type == 'Stop':
                                return False, f"Suppressed {event_type} - Stop notification sent {time_since_last:.1f}s ago"
                            elif event_type == 'Stop' and last_event_type == 'Notification':
                                # Allow Stop to override Notification, but update the record
                                self._record_notification(session_id, event_type)
                                return True, f"Stop overrides previous Notification"
                            elif event_type == last_event_type:
                                return False, f"Duplicate {event_type} suppressed - sent {time_since_last:.1f}s ago"
                    
                    # Record this notification
                    self._record_notification(session_id, event_type)
                    return True, f"Notification approved for {event_type}"
                    
                except IOError:
                    # Lock is held by another process
                    return False, "Another notification process is active"
                    
        except Exception as e:
            logging.warning(f"Deduplication check failed: {e}")
            # In case of error, allow notification to go through
            return True, f"Deduplication failed, allowing notification: {e}"
    
    def _get_last_notification_info(self, session_id):
        """Get timestamp and type of last notification for session"""
        info_file = os.path.join(self.temp_dir, f"claude_notify_info_{session_id}.json")
        
        try:
            if os.path.exists(info_file):
                with open(info_file, 'r') as f:
                    data = json.load(f)
                    return data.get('timestamp'), data.get('event_type')
        except Exception as e:
            logging.debug(f"Could not read notification info: {e}")
        
        return None
    
    def _record_notification(self, session_id, event_type):
        """Record notification timestamp and type"""
        info_file = os.path.join(self.temp_dir, f"claude_notify_info_{session_id}.json")
        
        try:
            with open(info_file, 'w') as f:
                json.dump({
                    'timestamp': time.time(),
                    'event_type': event_type,
                    'session_id': session_id
                }, f)
        except Exception as e:
            logging.debug(f"Could not record notification info: {e}")
    
    def cleanup_old_files(self):
        """Clean up old lock and info files (older than 1 hour)"""
        try:
            current_time = time.time()
            for filename in os.listdir(self.temp_dir):
                if filename.startswith('claude_notify_'):
                    filepath = os.path.join(self.temp_dir, filename)
                    try:
                        if current_time - os.path.getmtime(filepath) > 3600:  # 1 hour
                            os.remove(filepath)
                    except OSError:
                        pass  # File might be in use or already deleted
        except Exception as e:
            logging.debug(f"Cleanup failed: {e}")


class ClaudePromptTracker:
    def __init__(self):
        """Initialize the prompt tracker with database setup"""
        script_dir = os.path.dirname(os.path.abspath(__file__))
        self.db_path = os.path.join(script_dir, "ccnotify.db")
        self.setup_logging()
        self.init_database()
        # Initialize notification deduplicator with 15-second cooldown  
        self.deduplicator = NotificationDeduplicator(cooldown_seconds=15)
        # Clean up old temporary files
        self.deduplicator.cleanup_old_files()
    
    def setup_logging(self):
        """Setup logging to file with daily rotation"""
        
        script_dir = os.path.dirname(os.path.abspath(__file__))
        log_path = os.path.join(script_dir, "ccnotify.log")
        
        # Create a timed rotating file handler
        handler = TimedRotatingFileHandler(
            log_path,
            when='midnight',  # Rotate at midnight
            interval=1,       # Every 1 day
            backupCount=1,   # Keep 1 days of logs
            encoding='utf-8'
        )
        
        # Set the log format
        formatter = logging.Formatter(
            '%(asctime)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        handler.setFormatter(formatter)
        
        # Configure the root logger
        logger = logging.getLogger()
        logger.setLevel(logging.INFO)
        logger.addHandler(handler)
    
    def init_database(self):
        """Create tables and triggers if they don't exist"""
        with sqlite3.connect(self.db_path) as conn:
            # Create main table
            conn.execute("""
                CREATE TABLE IF NOT EXISTS prompt (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    session_id TEXT NOT NULL,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                    prompt TEXT,
                    cwd TEXT,
                    seq INTEGER,
                    stoped_at DATETIME,
                    lastWaitUserAt DATETIME
                )
            """)
            
            # Create trigger for auto-incrementing seq
            conn.execute("""
                CREATE TRIGGER IF NOT EXISTS auto_increment_seq
                AFTER INSERT ON prompt
                FOR EACH ROW
                BEGIN
                    UPDATE prompt 
                    SET seq = (
                        SELECT COALESCE(MAX(seq), 0) + 1 
                        FROM prompt 
                        WHERE session_id = NEW.session_id
                    )
                    WHERE id = NEW.id;
                END
            """)
            
            conn.commit()
    
    def handle_user_prompt_submit(self, data):
        """Handle UserPromptSubmit event - insert new prompt record"""
        session_id = data.get('session_id')
        prompt = data.get('prompt', '')
        cwd = data.get('cwd', '')
        
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                INSERT INTO prompt (session_id, prompt, cwd)
                VALUES (?, ?, ?)
            """, (session_id, prompt, cwd))
            conn.commit()
        
        logging.info(f"Recorded prompt for session {session_id}")
    
    def handle_stop(self, data):
        """Handle Stop event - update completion time and send notification"""
        session_id = data.get('session_id')
        
        # Check if notification should be sent
        should_send, reason = self.deduplicator.should_send_notification(session_id, 'Stop')
        logging.info(f"Stop notification check for session {session_id}: {reason}")
        
        if not should_send:
            logging.info(f"Stop notification suppressed for session {session_id}: {reason}")
            return
        
        # Try to get the last Claude message from transcript
        last_claude_message = self.get_last_claude_message(data)
        
        with sqlite3.connect(self.db_path) as conn:
            # Find the latest unfinished record for this session
            cursor = conn.execute("""
                SELECT id, created_at, cwd
                FROM prompt 
                WHERE session_id = ? AND stoped_at IS NULL
                ORDER BY created_at DESC
                LIMIT 1
            """, (session_id,))
            
            row = cursor.fetchone()
            if row:
                record_id, created_at, cwd = row
                
                # Update completion time
                conn.execute("""
                    UPDATE prompt 
                    SET stoped_at = CURRENT_TIMESTAMP
                    WHERE id = ?
                """, (record_id,))
                conn.commit()
                
                # Get seq number and calculate duration
                cursor = conn.execute("SELECT seq FROM prompt WHERE id = ?", (record_id,))
                seq_row = cursor.fetchone()
                seq = seq_row[0] if seq_row else 1
                
                duration = self.calculate_duration_from_db(record_id)
                
                # Create prettier notification with Claude's message
                pretty_title = f"✨ {os.path.basename(cwd) if cwd else 'Claude'}"
                
                if last_claude_message:
                    # First 80 chars of Claude's response + duration
                    preview = last_claude_message[:80] + "..." if len(last_claude_message) > 80 else last_claude_message
                    subtitle = f"🎉 Task #{seq} complete! ({duration})\n💬 {preview}"
                else:
                    subtitle = f"🎉 Task #{seq} completed in {duration} ⚡"
                
                self.send_notification(
                    title=pretty_title,
                    subtitle=subtitle,
                    cwd=cwd
                )
                
                logging.info(f"Task completed for session {session_id}, job#{seq}, duration: {duration}")
    
    def handle_notification(self, data):
        """Handle Notification event - check for waiting input and send notification"""
        session_id = data.get('session_id')
        message = data.get('message', '')
        
        if 'waiting for your input' in message.lower():
            # Check if notification should be sent
            should_send, reason = self.deduplicator.should_send_notification(session_id, 'Notification')
            logging.info(f"Notification check for session {session_id}: {reason}")
            
            if not should_send:
                logging.info(f"Notification suppressed for session {session_id}: {reason}")
                return
            
            cwd = data.get('cwd', '')
            
            with sqlite3.connect(self.db_path) as conn:
                # Update lastWaitUserAt for the latest record
                conn.execute("""
                    UPDATE prompt 
                    SET lastWaitUserAt = CURRENT_TIMESTAMP
                    WHERE id = (
                        SELECT id FROM prompt 
                        WHERE session_id = ? 
                        ORDER BY created_at DESC 
                        LIMIT 1
                    )
                """, (session_id,))
                conn.commit()
            
            pretty_title = f"🤔 {os.path.basename(cwd) if cwd else 'Claude'}"
            self.send_notification(
                title=pretty_title,
                subtitle="⏱ Waiting for your input...",
                cwd=cwd
            )
            
            logging.info(f"Waiting notification sent for session {session_id}")
    
    def get_last_claude_message(self, data):
        """Extract the last Claude message from transcript if available"""
        try:
            # Try to get transcript path from data
            transcript_path = data.get('transcript_path')
            if not transcript_path or not os.path.exists(transcript_path):
                return None
            
            # Read the last few lines of the JSONL transcript
            with open(transcript_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            # Look for the last Claude message (assistant role)
            for line in reversed(lines[-10:]):  # Check last 10 entries
                try:
                    entry = json.loads(line.strip())
                    if entry.get('role') == 'assistant' and entry.get('content'):
                        content = entry['content']
                        if isinstance(content, list) and content:
                            # Extract text from content blocks
                            text_parts = [block.get('text', '') for block in content if block.get('type') == 'text']
                            return ' '.join(text_parts).strip()
                        elif isinstance(content, str):
                            return content.strip()
                except (json.JSONDecodeError, KeyError):
                    continue
            
            return None
        except Exception as e:
            logging.debug(f"Could not extract Claude message: {e}")
            return None
    
    def calculate_duration_from_db(self, record_id):
        """Calculate duration for a completed record"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute("""
                SELECT created_at, stoped_at
                FROM prompt
                WHERE id = ?
            """, (record_id,))
            
            row = cursor.fetchone()
            if row and row[1]:
                return self.calculate_duration(row[0], row[1])
        
        return "Unknown"
    
    def calculate_duration(self, start_time, end_time):
        """Calculate human-readable duration between two timestamps"""
        try:
            if isinstance(start_time, str):
                start_dt = datetime.fromisoformat(start_time.replace('Z', '+00:00'))
            else:
                start_dt = datetime.fromisoformat(start_time)
            
            if isinstance(end_time, str):
                end_dt = datetime.fromisoformat(end_time.replace('Z', '+00:00'))
            else:
                end_dt = datetime.fromisoformat(end_time)
            
            duration = end_dt - start_dt
            total_seconds = int(duration.total_seconds())
            
            if total_seconds < 60:
                return f"{total_seconds}s"
            elif total_seconds < 3600:
                minutes = total_seconds // 60
                seconds = total_seconds % 60
                if seconds > 0:
                    return f"{minutes}m{seconds}s"
                else:
                    return f"{minutes}m"
            else:
                hours = total_seconds // 3600
                minutes = (total_seconds % 3600) // 60
                if minutes > 0:
                    return f"{hours}h{minutes}m"
                else:
                    return f"{hours}h"
        except Exception as e:
            logging.error(f"Error calculating duration: {e}")
            return "Unknown"
    
    def send_notification(self, title, subtitle, cwd=None):
        """Send macOS notification using terminal-notifier"""
        from datetime import datetime
        current_time = datetime.now().strftime("%B %d, %Y at %H:%M")
        
        try:
            cmd = [
                'terminal-notifier',
                '-sound', 'default',
                '-title', title,
                '-subtitle', f"{subtitle}\n{current_time}"
            ]
            
            if cwd:
                cmd.extend(['-execute', 'osascript -e "tell application \\"Ghostty\\" to activate"'])
            
            subprocess.run(cmd, check=False, capture_output=True)
            logging.info(f"Notification sent: {title} - {subtitle}")
        except FileNotFoundError:
            logging.warning("terminal-notifier not found, notification skipped")
        except Exception as e:
            logging.error(f"Error sending notification: {e}")


def validate_input_data(data, expected_event_name):
    """Validate input data matches design specification"""
    required_fields = {
        'UserPromptSubmit': ['session_id', 'prompt', 'cwd', 'hook_event_name'],
        'Stop': ['session_id', 'hook_event_name'],
        'Notification': ['session_id', 'message', 'hook_event_name']
    }
    
    if expected_event_name not in required_fields:
        raise ValueError(f"Unknown event type: {expected_event_name}")
    
    # Check hook_event_name matches expected
    if data.get('hook_event_name') != expected_event_name:
        raise ValueError(f"Event name mismatch: expected {expected_event_name}, got {data.get('hook_event_name')}")
    
    # Check required fields
    missing_fields = []
    for field in required_fields[expected_event_name]:
        if field not in data or data[field] is None:
            missing_fields.append(field)
    
    if missing_fields:
        raise ValueError(f"Missing required fields for {expected_event_name}: {missing_fields}")
    
    return True


def main():
    """Main entry point - read JSON from stdin and process event"""
    try:
        # Check if hook type is provided as command line argument
        if len(sys.argv) < 2:
            print("ok")
            return
        
        expected_event_name = sys.argv[1]
        valid_events = ['UserPromptSubmit', 'Stop', 'Notification']
        
        if expected_event_name not in valid_events:
            logging.error(f"Invalid hook type: {expected_event_name}")
            logging.error(f"Valid hook types: {', '.join(valid_events)}")
            sys.exit(1)
        
        # Read JSON data from stdin
        input_data = sys.stdin.read().strip()
        if not input_data:
            logging.warning("No input data received")
            return
        
        data = json.loads(input_data)
        
        # Validate input data
        validate_input_data(data, expected_event_name)
        
        tracker = ClaudePromptTracker()
        
        if expected_event_name == 'UserPromptSubmit':
            tracker.handle_user_prompt_submit(data)
        elif expected_event_name == 'Stop':
            tracker.handle_stop(data)
        elif expected_event_name == 'Notification':
            tracker.handle_notification(data)
    
    except json.JSONDecodeError as e:
        logging.error(f"JSON decode error: {e}")
        sys.exit(1)
    except ValueError as e:
        logging.error(f"Validation error: {e}")
        sys.exit(1)
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()