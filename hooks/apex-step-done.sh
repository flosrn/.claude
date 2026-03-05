#!/usr/bin/env bash
# apex-step-done.sh — Detect apex step completion via PostToolUse(Bash)
#
# Triggered by PostToolUse Bash hook. Reads tool_input from stdin.
# Detects step completion via TWO patterns:
#   1. session-boundary.sh (preferred — consolidates all boundary logic)
#   2. update-progress.sh with "complete" status (legacy / direct calls)
#
# When triggered:
# 1. Sends instant Telegram notification (direct API)
# 2. Writes signal file for cron orchestrator to handle transition

set -euo pipefail

# ─── DEBUG LOG ───────────────────────────────────────────────────
DEBUG_LOG="/tmp/apex-hook-debug.log"
echo "=== $(date -u +%Y-%m-%dT%H:%M:%SZ) ===" >> "$DEBUG_LOG"
echo "ENV: NOTIFY_CHAT_ID=${NOTIFY_CHAT_ID:-UNSET} NOTIFY_BOT_TOKEN=${NOTIFY_BOT_TOKEN:+SET}" >> "$DEBUG_LOG"

CHAT_ID="${NOTIFY_CHAT_ID:-}"
TMUX_SESSION="${NOTIFY_TMUX_SESSION:-}"
BOT_TOKEN="${NOTIFY_BOT_TOKEN:-}"

# No bot token = not launched from Gapibot with proper env
[ -z "$BOT_TOKEN" ] && { echo "EXIT: no bot token" >> "$DEBUG_LOG"; exit 0; }
[ -z "$CHAT_ID" ] && { echo "EXIT: no chat id" >> "$DEBUG_LOG"; exit 0; }

# Read PostToolUse input from stdin
INPUT=$(cat)
echo "INPUT_LENGTH=${#INPUT}" >> "$DEBUG_LOG"
echo "INPUT_FIRST_200=${INPUT:0:200}" >> "$DEBUG_LOG"

# Extract the bash command that was executed
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)
echo "COMMAND=${COMMAND:0:300}" >> "$DEBUG_LOG"

# ─── Pattern 1: session-boundary.sh ──────────────────────────────
# Called as: bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "{step_num}" "{step_name}" ...
# step_num is the 2nd argument after session-boundary.sh
if echo "$COMMAND" | grep -q "session-boundary.sh"; then
    # Extract step number (2nd quoted arg after session-boundary.sh)
    STEP_NUM=$(echo "$COMMAND" | grep -oP 'session-boundary\.sh\s+"[^"]+"\s+"?\K\d{2}' || true)
    # Fallback: try unquoted args
    [ -z "$STEP_NUM" ] && STEP_NUM=$(echo "$COMMAND" | grep -oP 'session-boundary\.sh\s+\S+\s+(\d{2})' | grep -oP '\d{2}$' || true)
    echo "MATCH: session-boundary.sh, STEP_NUM=$STEP_NUM" >> "$DEBUG_LOG"

# ─── Pattern 2: update-progress.sh with "complete" (legacy) ──────
elif echo "$COMMAND" | grep -q "update-progress.sh" && echo "$COMMAND" | grep -q '"complete"'; then
    STEP_NUM=$(echo "$COMMAND" | grep -oP 'update-progress\.sh\s+\S+\s+"?\K\d{2}' || true)
    echo "MATCH: update-progress.sh complete, STEP_NUM=$STEP_NUM" >> "$DEBUG_LOG"

# ─── No match ────────────────────────────────────────────────────
else
    echo "EXIT: no session-boundary or update-progress match" >> "$DEBUG_LOG"
    exit 0
fi

# Resolve worktree root from CWD
RAW_CWD=$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null)
CWD=$(git -C "$RAW_CWD" rev-parse --show-toplevel 2>/dev/null || echo "$RAW_CWD")
FEATURE=$(basename "$CWD" 2>/dev/null)

echo "CWD=$CWD FEATURE=$FEATURE" >> "$DEBUG_LOG"

# 1. Send instant Telegram notification
MSG="✅ <b>Step ${STEP_NUM:-??} terminé</b> — <code>${FEATURE}</code>
🔄 Transition en cours..."

curl -sf "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}" \
  --data-urlencode "text=${MSG}" \
  -d "parse_mode=HTML" \
  --connect-timeout 3 \
  --max-time 5 \
  >/dev/null 2>&1 || true

# 2. Write transition signal file for cron orchestrator
mkdir -p "${CWD}/.claude" 2>/dev/null || true
echo "step=${STEP_NUM:-00}|ts=$(date +%s)|tmux=${TMUX_SESSION}|chat=${CHAT_ID}|feature=${FEATURE}" \
  > "${CWD}/.claude/apex-transition-signal" 2>/dev/null

echo "SIGNAL_WRITTEN: ${CWD}/.claude/apex-transition-signal" >> "$DEBUG_LOG"
exit 0
