#!/usr/bin/env bash
# notify-openclaw.sh — Claude Code hook → Telegram notification + completion signal
#
# Usage: $HOME/.claude/hooks/notify-openclaw.sh <event-type>
# Events: task-completed, needs-attention
#
# Sends:
# 1. Telegram notification (direct API, instant)
# 2. Completion signal file (for task-completed → cron orchestrator)

set -euo pipefail

EVENT_TYPE="${1:-unknown}"
CHAT_ID="${NOTIFY_CHAT_ID:-}"
BOT_TOKEN="${NOTIFY_BOT_TOKEN:-}"

# No bot token = not launched from Gapibot with proper env
[ -z "$BOT_TOKEN" ] && exit 0
TMUX_SESSION="${NOTIFY_TMUX_SESSION:-}"

# No chat ID = not launched from Gapibot
[ -z "$CHAT_ID" ] && exit 0

# Read hook input from stdin
INPUT=$(cat)
RAW_CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"' 2>/dev/null)
CWD=$(git -C "$RAW_CWD" rev-parse --show-toplevel 2>/dev/null || echo "$RAW_CWD")
FEATURE_NAME=$(basename "$CWD" 2>/dev/null || echo "unknown")

# Build label
case "$EVENT_TYPE" in
  task-completed)  EMOJI="☑️"; LABEL="Tâche complétée" ;;
  needs-attention) EMOJI="🔔"; LABEL="Claude a besoin d'attention" ;;
  *)               EMOJI="📌"; LABEL="Event: $EVENT_TYPE" ;;
esac

# 1. Telegram notification
MSG="${EMOJI} <b>${LABEL}</b>"
[ "$FEATURE_NAME" != "unknown" ] && [ "$FEATURE_NAME" != "gapila" ] && MSG="${MSG}
📦 <code>${FEATURE_NAME}</code>"

curl -sf "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}" \
  --data-urlencode "text=${MSG}" \
  -d "parse_mode=HTML" \
  --connect-timeout 3 \
  --max-time 5 \
  >/dev/null 2>&1

# 2. Write completion signal for task-completed (cron orchestrator picks this up)
if [ "$EVENT_TYPE" = "task-completed" ] && [ "$CWD" != "unknown" ]; then
  mkdir -p "${CWD}/.claude" 2>/dev/null
  echo "event=task-completed|ts=$(date +%s)|tmux=${TMUX_SESSION}|chat=${CHAT_ID}|feature=${FEATURE_NAME}" \
    > "${CWD}/.claude/apex-completion-signal" 2>/dev/null
fi

exit 0
