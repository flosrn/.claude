#!/usr/bin/env bash
# apex-step-done.sh — Detect apex step completion and trigger orchestrator.
# Writes signal file, then delegates to watcher (primary) or fires hook directly (fallback).
# Watcher = primary (≤2s, 0 token). Hook = fallback if watcher dead (3s). Recovery = 60s.

set -euo pipefail

DEBUG_LOG="/tmp/apex-hook-debug.log"
echo "=== $(date -u +%Y-%m-%dT%H:%M:%SZ) ===" >> "$DEBUG_LOG"

CHAT_ID="${NOTIFY_CHAT_ID:-}"
TMUX_SESSION="${NOTIFY_TMUX_SESSION:-}"
BOT_TOKEN="${NOTIFY_BOT_TOKEN:-}"

# NOTE: BOT_TOKEN and CHAT_ID are no longer used for direct Telegram sends.
# All notifications go through the orchestrator cron (message tool).
# Do NOT exit early here — the signal file MUST be written regardless.
[ -z "$CHAT_ID" ] && { echo "WARN: no chat id — signal will still be written" >> "$DEBUG_LOG"; }

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

# ─── Trigger orchestrateur via webhook ───────────────────────────
# Strategy: delegate to watcher if alive (it polls every 2s, already saw the signal).
# Hook fires as fallback only if watcher is dead — avoids double-trigger waste.
MESSAGE_FILE="${CWD}/.claude/apex-cron-message.txt"
HOOKS_TOKEN=$(python3 -c "import json; c=json.load(open('/home/node/.openclaw/openclaw.json')); print(c.get('hooks',{}).get('token',''))" 2>/dev/null || echo "")
HOOKS_URL="http://127.0.0.1:18789/hooks/apex-watcher"

# Check if watcher process is alive
WATCHER_PID_FILE="${CWD}/.claude/apex-watcher-pid"
WATCHER_ALIVE=false
if [ -f "$WATCHER_PID_FILE" ]; then
    WATCHER_PID=$(cat "$WATCHER_PID_FILE" 2>/dev/null || echo "")
    [ -n "$WATCHER_PID" ] && kill -0 "$WATCHER_PID" 2>/dev/null && WATCHER_ALIVE=true
fi

if [ "$WATCHER_ALIVE" = "true" ]; then
    echo "HOOK: watcher alive (pid=$WATCHER_PID) — delegating trigger to watcher (≤2s)" >> "$DEBUG_LOG"
elif [ -n "$HOOKS_TOKEN" ] && [ -f "$MESSAGE_FILE" ]; then
    echo "HOOK: watcher dead — hook fires as fallback (3s)" >> "$DEBUG_LOG"
    (
      sleep 3  # laisser le temps au signal file d'être synced par le fs
      JSON=$(python3 -c "
import json
msg = open('$MESSAGE_FILE').read()
print(json.dumps({'message': msg, 'name': 'apex-$FEATURE', 'agentId': 'gapibot', 'wakeMode': 'now', 'deliver': False}))
" 2>/dev/null) || { echo "HOOK: json build failed — signal file is backup" >> "$DEBUG_LOG"; exit 0; }
      HTTP=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$HOOKS_URL" \
        -H "Authorization: Bearer $HOOKS_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$JSON" 2>/dev/null) || HTTP="000"
      echo "HOOK: webhook → HTTP $HTTP" >> "$DEBUG_LOG"
      # Signal file kept as backup if POST failed — apex-recovery.sh handles it within 60s
    ) &
else
    echo "HOOK: watcher dead + no token/message file — signal file only (recovery in ≤60s)" >> "$DEBUG_LOG"
fi

exit 0
