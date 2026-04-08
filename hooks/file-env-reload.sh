#!/bin/bash
# FileChanged hook — reload .env* on disk change + audit log.
#
# Registered with multiple matchers in settings.json: .env, .env.local,
# .env.development. Fires natively via FSEvents (macOS) so detection is
# near-instant with zero polling overhead.
#
# Actions:
#   1. Audit log every .env* mutation to ~/.claude/debug/env-mutations.log
#      (helps spot accidental secret introduction — see Hetzner incident)
#   2. Reload the changed file into the session via CLAUDE_ENV_FILE so new
#      values are available without restarting Claude Code
#   3. Show a user-visible systemMessage reminder
#
# Docs: https://code.claude.com/docs/en/hooks (FileChanged)

set -u

[ -n "${CLAUDE_ENV_FILE:-}" ] || exit 0

# Parse file_path from stdin JSON
FILE_PATH=$(/usr/bin/python3 -c 'import sys, json; print(json.load(sys.stdin).get("file_path", ""))' 2>/dev/null) || exit 0
[ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ] || exit 0

# Audit log
AUDIT_LOG="$HOME/.claude/debug/env-mutations.log"
mkdir -p "$(dirname "$AUDIT_LOG")"
printf '%s  %s\n' "$(date -Iseconds)" "$FILE_PATH" >> "$AUDIT_LOG"

# Reload into session
set -a
# shellcheck source=/dev/null
source "$FILE_PATH" 2>/dev/null || true
set +a
export -p | grep -v "^declare -x PS" >> "$CLAUDE_ENV_FILE"

# User-visible reminder (systemMessage is the only output channel allowed)
BASENAME=$(basename "$FILE_PATH")
/usr/bin/python3 -c "
import json, sys
msg = '[ENV] ' + sys.argv[1] + ' modifié — rechargé dans la session. Vérifie qu\\'aucun secret n\\'a fuité.'
print(json.dumps({'systemMessage': msg}))
" "$BASENAME"

exit 0
