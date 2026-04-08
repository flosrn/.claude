#!/bin/bash
# CwdChanged hook — direnv-style auto-load .env on directory change.
#
# Fires on every `cd` (CwdChanged has no matcher support).
# Loads the first of .env.local / .env.development / .env found in the new cwd,
# then persists exported vars to CLAUDE_ENV_FILE so subsequent Bash tool calls
# see them.
#
# Why: Claude Code doesn't natively source .env files per-project. With 6+
# repos in ~/Code/claude/ and others, having env vars auto-available when
# Claude cd's into a project is a big QoL win.
#
# Docs: https://code.claude.com/docs/en/hooks (CwdChanged)

set -u

# Bail early if no persistence file is provided
[ -n "${CLAUDE_ENV_FILE:-}" ] || exit 0

# Parse cwd from stdin JSON
CWD=$(/usr/bin/python3 -c 'import sys, json; print(json.load(sys.stdin).get("cwd", ""))' 2>/dev/null) || exit 0
[ -n "$CWD" ] && [ -d "$CWD" ] || exit 0

# Load first env file found (priority: .env.local > .env.development > .env)
for env_file in "$CWD/.env.local" "$CWD/.env.development" "$CWD/.env"; do
  if [ -f "$env_file" ]; then
    set -a
    # shellcheck source=/dev/null
    source "$env_file" 2>/dev/null || true
    set +a
    # Persist exported vars (exclude PS* shell vars per official example)
    export -p | grep -v "^declare -x PS" >> "$CLAUDE_ENV_FILE"
    break
  fi
done

exit 0
