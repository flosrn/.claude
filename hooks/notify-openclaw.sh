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

# 1. Telegram notification — ONLY for needs-attention (skip task-completed entirely)
# task-completed fires for EVERY session (including sub-agents in team mode),
# causing spam "Tâche complétée" for each sub-agent. Step transitions are
# already notified by apex-step-done.sh with proper step numbers.
if [ "$EVENT_TYPE" = "task-completed" ]; then
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) SKIP_TG: task-completed notification suppressed (handled by apex-step-done.sh)" >> /tmp/apex-hook-debug.log 2>/dev/null
    exit 0
fi

MSG="${EMOJI} <b>${LABEL}</b>"
[ "$FEATURE_NAME" != "unknown" ] && [ "$FEATURE_NAME" != "gapila" ] && MSG="${MSG}
📦 <code>${FEATURE_NAME}</code>"

TG_RESPONSE=$(curl -sf "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}" \
  --data-urlencode "text=${MSG}" \
  -d "parse_mode=HTML" \
  --connect-timeout 3 \
  --max-time 5 2>&1) || true
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) TG_SEND: event=${EVENT_TYPE} feature=${FEATURE_NAME} msg='${MSG}' response='${TG_RESPONSE:0:200}'" >> /tmp/apex-hook-debug.log 2>/dev/null

# 2. Completion signal is now ONLY written by apex-step-done.sh (on step 09).
# notify-openclaw.sh NEVER writes it — because sub-agents (team mode) trigger
# TaskCompleted too, causing false "workflow done" signals.
# We only send the Telegram notification here (harmless for sub-agents).
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) NOTIFY_ONLY: no completion signal written (handled by apex-step-done.sh step 09)" >> /tmp/apex-hook-debug.log 2>/dev/null

exit 0
