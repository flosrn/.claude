#!/usr/bin/env bash
# apex-step-done.sh — Detect apex step completion via PostToolUse(Bash)
#
# Triggered by PostToolUse Bash hook. Reads tool_input from stdin.
# If the command is update-progress.sh with "complete" status:
# 1. Sends instant Telegram notification (direct API)
# 2. Writes signal file for cron orchestrator to handle transition

set -euo pipefail

CHAT_ID="${NOTIFY_CHAT_ID:-}"
TMUX_SESSION="${NOTIFY_TMUX_SESSION:-}"
BOT_TOKEN="${NOTIFY_BOT_TOKEN:-}"

# No bot token = not launched from Gapibot with proper env
[ -z "$BOT_TOKEN" ] && exit 0

[ -z "$CHAT_ID" ] && exit 0

# Read PostToolUse input from stdin
INPUT=$(cat)

# Extract the bash command that was executed
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Only trigger on update-progress.sh with "complete" status
echo "$COMMAND" | grep -q "update-progress.sh" || exit 0
echo "$COMMAND" | grep -q '"complete"' || exit 0

# Extract step number and resolve worktree root (CWD may be a subdirectory)
STEP_NUM=$(echo "$COMMAND" | grep -oP '"\d{2}"' | head -1 | tr -d '"')
RAW_CWD=$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null)
CWD=$(git -C "$RAW_CWD" rev-parse --show-toplevel 2>/dev/null || echo "$RAW_CWD")
FEATURE=$(basename "$CWD" 2>/dev/null)

# 1. Send instant Telegram notification
MSG="✅ <b>Step ${STEP_NUM} terminé</b> — <code>${FEATURE}</code>
🔄 Transition en cours..."

curl -sf "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}" \
  --data-urlencode "text=${MSG}" \
  -d "parse_mode=HTML" \
  --connect-timeout 3 \
  --max-time 5 \
  >/dev/null 2>&1

# 2. Write transition signal file for cron orchestrator
mkdir -p "${CWD}/.claude" 2>/dev/null
echo "step=${STEP_NUM}|ts=$(date +%s)|tmux=${TMUX_SESSION}|chat=${CHAT_ID}|feature=${FEATURE}" \
  > "${CWD}/.claude/apex-transition-signal" 2>/dev/null

exit 0
