# CCNotify - Desktop Notifications

**Source**: https://github.com/dazuiba/CCNotify  
**Purpose**: Desktop notifications for Claude Code task completion and waiting input

## Installation

```bash
# Dependencies installed
brew install terminal-notifier

# Script copied to
~/.claude/ccnotify/ccnotify.py

# Hooks configured in settings.json
- UserPromptSubmit: Track when prompts are submitted
- Stop: Notify when tasks complete with duration
- Notification: Alert when Claude waits for input
```

## Features

### 📋 Task Tracking
- **SQLite Database**: Tracks all prompts and completion times
- **Job Numbering**: Sequential job numbers per session
- **Duration Calculation**: Shows exact task duration (e.g., "2m30s")

### 🔔 Notifications
- **Task Completion**: "job#X done, duration: Xm" with project name
- **Waiting Input**: "Waiting for input" when Claude needs user response
- **VS Code Integration**: Click notification to open project in VS Code

### 📊 Notification Details
- **Title**: Project folder name (e.g., ".claude")
- **Subtitle**: Job status and duration
- **Sound**: Default macOS notification sound
- **Timestamp**: Current date and time
- **Action**: Opens project directory in VS Code

## Database Schema

```sql
-- ~/.claude/ccnotify/ccnotify.db
CREATE TABLE prompt (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    prompt TEXT,
    cwd TEXT,
    seq INTEGER,           -- Auto-incremented job number
    stoped_at DATETIME,    -- Task completion time
    lastWaitUserAt DATETIME -- Last "waiting for input" time
);
```

## Logs

- **Location**: `~/.claude/ccnotify/ccnotify.log`
- **Rotation**: Daily with 1-day retention
- **Content**: Prompt records, completions, notifications sent

## Hook Integration

### UserPromptSubmit
- **Triggers**: When user submits a prompt
- **Action**: Records new task in database
- **Data**: session_id, prompt text, working directory

### Stop
- **Triggers**: When Claude finishes a task
- **Action**: Updates completion time, calculates duration, sends notification
- **Notification**: "job#X done, duration: Xm"

### Notification
- **Triggers**: When Claude sends notifications (e.g., waiting for input)
- **Action**: Sends desktop notification for user attention
- **Filter**: Only processes "waiting for your input" messages

## Configuration

All configuration is automatic via the Python script:
- Database auto-created on first run
- Logs rotate automatically
- VS Code path: `/usr/local/bin/code` (configurable in script)

## Troubleshooting

### No notifications appearing
```bash
# Test terminal-notifier directly
terminal-notifier -title "Test" -message "Hello" -sound default

# Check if ccnotify script works
python3 ~/.claude/ccnotify/ccnotify.py

# Check logs for errors
tail ~/.claude/ccnotify/ccnotify.log
```

### Database issues
```bash
# Database location
ls -la ~/.claude/ccnotify/ccnotify.db

# Check database content
sqlite3 ~/.claude/ccnotify/ccnotify.db "SELECT * FROM prompt ORDER BY created_at DESC LIMIT 5;"
```

### Hook not triggering
- Verify hooks are configured in `~/.claude/settings.json`
- Restart Claude Code after configuration changes
- Check security logs: `tail ~/.claude/logs/security.log`

## Example Notifications

**Task Completion**:
```
Title: .claude
Subtitle: job#3 done, duration: 1m45s
         August 16, 2025 at 16:15
Action: Opens ~/.claude in VS Code
```

**Waiting for Input**:
```
Title: my-project
Subtitle: Waiting for input
         August 16, 2025 at 16:20
Action: Opens ~/my-project in VS Code
```

## Privacy & Security

- **Local only**: All data stays on your machine
- **No network**: No external communication
- **Gitignored**: Database and logs excluded from git
- **Minimal data**: Only session IDs, prompts, and timestamps

## Compatibility

- **Platform**: macOS only (uses terminal-notifier)
- **Python**: Requires Python 3.x
- **VS Code**: Optional, removes VS Code integration if not installed
- **Claude Code**: Works with latest Claude Code versions