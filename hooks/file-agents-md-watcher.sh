#!/bin/bash
# FileChanged hook — OpenClaw workspace bootstrap file mutation watcher.
#
# Registered with matchers AGENTS.md, SOUL.md, IDENTITY.md in settings.json.
# Because FileChanged matcher is basename-only, this script filters by path
# to ensure it only triggers for files inside ~/Code/claude/<workspace>/
# (Flo's OpenClaw convention).
#
# Actions:
#   1. Audit log to ~/.claude/debug/workspace-mutations.log
#   2. Show a user-visible systemMessage reminder to run sync-vps
#
# Docs: https://code.claude.com/docs/en/hooks (FileChanged)

set -u

# Parse file_path from stdin JSON
FILE_PATH=$(/usr/bin/python3 -c 'import sys, json; print(json.load(sys.stdin).get("file_path", ""))' 2>/dev/null) || exit 0
[ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ] || exit 0

# Only trigger for workspaces inside ~/Code/claude/ (avoid matching random AGENTS.md
# files in unrelated projects — basename matcher is not path-aware)
case "$FILE_PATH" in
  "$HOME/Code/claude/"*) ;;
  *) exit 0 ;;
esac

# Extract workspace name (e.g. clawd, gapibot, shipmate-bot, shipmate-agent, openclaw-config)
REL_PATH="${FILE_PATH#"$HOME/Code/claude/"}"
WORKSPACE="${REL_PATH%%/*}"
BASENAME=$(basename "$FILE_PATH")

# Audit log
AUDIT_LOG="$HOME/.claude/debug/workspace-mutations.log"
mkdir -p "$(dirname "$AUDIT_LOG")"
printf '%s  %s/%s\n' "$(date -Iseconds)" "$WORKSPACE" "$BASENAME" >> "$AUDIT_LOG"

# User-visible reminder
/usr/bin/python3 -c "
import json, sys
msg = '[SYNC] ' + sys.argv[1] + '/' + sys.argv[2] + ' modifié — pense à lancer sync-vps pour répercuter sur le VPS.'
print(json.dumps({'systemMessage': msg}))
" "$WORKSPACE" "$BASENAME"

exit 0
