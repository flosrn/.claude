/**
 * claude-code.js — OpenClaw webhook transform for Claude Code hook events
 *
 * Receives POST from notify-openclaw.sh, transforms into a message
 * for Gapibot to process and forward to the originating Telegram chat.
 */

module.exports = function transform(payload, _headers) {
  const { event, feature, stop_reason, task_state, cwd, timestamp, session_id, chat_id } = payload;

  // Build human-readable event description
  const eventLabels = {
    'stop': '✅ Claude a terminé son tour',
    'task-completed': '☑️ Tâche complétée',
    'needs-attention': '🔔 Claude a besoin d\'attention',
    'subagent-done': '👥 Sub-agent terminé',
  };

  const label = eventLabels[event] || `📌 Event: ${event}`;

  const details = [];
  if (feature && feature !== 'unknown' && feature !== 'gapila') {
    details.push(`Feature: ${feature}`);
  }
  if (stop_reason) {
    details.push(`Reason: ${stop_reason}`);
  }
  if (task_state) {
    details.push(`State: ${task_state}`);
  }

  const contextLine = details.length > 0 ? `\n${details.join(' | ')}` : '';

  const message = `[Claude Code Hook] ${label}${contextLine}\nCWD: ${cwd}\nSession: ${session_id}\nTime: ${timestamp}${chat_id ? `\nChat: ${chat_id}` : ''}`;

  const result = {
    message,
    sessionKey: `hook:claude-code:${session_id || 'default'}`,
  };

  // Route notification to the originating chat
  if (chat_id) {
    result.to = chat_id;
  }

  return result;
};
