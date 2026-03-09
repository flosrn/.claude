#!/usr/bin/env bash
# apex-step-done.sh — Detect apex step completion
# SIMPLE: write signal file + kill tmux. That's it.
# All orchestration (notify, relaunch) handled by cron.

set -euo pipefail

DEBUG_LOG="/tmp/apex-hook-debug.log"
echo "=== $(date -u +%Y-%m-%dT%H:%M:%SZ) ===" >> "$DEBUG_LOG"

CHAT_ID="${NOTIFY_CHAT_ID:-}"
TMUX_SESSION="${NOTIFY_TMUX_SESSION:-}"
BOT_TOKEN="${NOTIFY_BOT_TOKEN:-}"

[ -z "$BOT_TOKEN" ] && { echo "EXIT: no bot token" >> "$DEBUG_LOG"; exit 0; }
[ -z "$CHAT_ID" ] && { echo "EXIT: no chat id" >> "$DEBUG_LOG"; exit 0; }

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null | tr '\n' ' ' | tr -s ' ')
echo "COMMAND=${COMMAND:0:300}" >> "$DEBUG_LOG"

# ─── Pattern 1: session-boundary.sh (steps 01-08) ────────────────
# session-boundary.sh handles both progress update AND state snapshot
# in a single command, so the hook fires AFTER state is fully written.
if echo "$COMMAND" | grep -q "session-boundary.sh"; then
    STEP_NUM=$(echo "$COMMAND" | grep -oP '"\K\d{2}(?=")' | head -1 || true)
    echo "MATCH: session-boundary.sh, STEP_NUM=$STEP_NUM" >> "$DEBUG_LOG"

# ─── Pattern 2: update-progress.sh "XX" "name" "complete" ────────
# Economy mode (-e) doesn't call session-boundary.sh between steps.
# It calls update-progress.sh directly when a step completes.
# Handle ALL steps here: step 09 → completion signal, others → transition.
elif echo "$COMMAND" | grep -q 'update-progress.sh' && echo "$COMMAND" | grep -q '"complete"'; then
    STEP_NUM=$(echo "$COMMAND" | grep -oP '"\K\d{2}(?=")' | head -1 || true)
    echo "MATCH: update-progress.sh step $STEP_NUM complete" >> "$DEBUG_LOG"

# ─── No match ────────────────────────────────────────────────────
else
    exit 0
fi

# Resolve worktree root
RAW_CWD=$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null)
CWD=$(git -C "$RAW_CWD" rev-parse --show-toplevel 2>/dev/null || echo "$RAW_CWD")
FEATURE=$(basename "$CWD" 2>/dev/null)
mkdir -p "${CWD}/.claude" 2>/dev/null || true

echo "CWD=$CWD FEATURE=$FEATURE STEP=$STEP_NUM" >> "$DEBUG_LOG"

# ─── Write signal ────────────────────────────────────────────────
if [ "${STEP_NUM}" = "09" ]; then
    # Step 09 = COMPLETION
    echo "event=task-completed|ts=$(date +%s)|tmux=${TMUX_SESSION}|chat=${CHAT_ID}|feature=${FEATURE}|step=${STEP_NUM}" \
      > "${CWD}/.claude/apex-completion-signal"
    echo "WROTE: apex-completion-signal" >> "$DEBUG_LOG"
else
    # Steps 01-08 = TRANSITION
    echo "step=${STEP_NUM:-00}|ts=$(date +%s)|tmux=${TMUX_SESSION}|chat=${CHAT_ID}|feature=${FEATURE}" \
      > "${CWD}/.claude/apex-transition-signal"
    echo "WROTE: apex-transition-signal step=${STEP_NUM}" >> "$DEBUG_LOG"
fi

sync 2>/dev/null || true

# ─── Kill tmux (2s grace) ────────────────────────────────────────
if [ -n "$TMUX_SESSION" ]; then
    echo "KILL: tmux ${TMUX_SESSION} in 2s" >> "$DEBUG_LOG"
    (sleep 2 && tmux kill-session -t "$TMUX_SESSION" 2>/dev/null) &
fi

# ─── Trigger cron immédiatement (event-driven) ───────────────────
CRON_ID_FILE="${CWD}/.claude/apex-cron-job-id"
if [ -f "$CRON_ID_FILE" ]; then
    CRON_ID=$(cat "$CRON_ID_FILE" 2>/dev/null || echo "")
    if [ -n "$CRON_ID" ]; then
        echo "TRIGGER: cron run $CRON_ID" >> "$DEBUG_LOG"
        (sleep 3 && node /app/dist/index.js cron run "$CRON_ID" >> "$DEBUG_LOG" 2>&1) &
    fi
fi

exit 0
