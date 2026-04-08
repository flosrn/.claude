#!/bin/bash
# Sync Claude Code OAuth credentials from macOS Keychain to file fallback.
#
# Why: macOS Keychain ACL blocks read access from non-GUI sessions (SSH/Mosh),
# so Claude Code over Mosh shows "Not logged in" even when credentials are valid.
# Claude Code falls back to ~/.claude/.credentials.json — but only if it contains
# the claudeAiOauth entry. This script keeps that file in sync with the Keychain.
#
# Wired as a SessionStart hook in ~/.claude/settings.json. Runs on every CC start
# locally on the Mac (where keychain is unlocked) and silently no-ops over Mosh.

set -u

CRED_FILE="$HOME/.claude/.credentials.json"
SERVICE="Claude Code-credentials"

# Try to read from keychain. Redirect stderr to silence the "user interaction
# required" error that fires from non-GUI sessions.
KEYCHAIN_DATA=$(security find-generic-password -a "$USER" -s "$SERVICE" -w 2>/dev/null) || exit 0

# Sanity check: must contain a real claudeAiOauth.accessToken before we overwrite.
if [ -z "$KEYCHAIN_DATA" ] || ! echo "$KEYCHAIN_DATA" | grep -q '"claudeAiOauth"'; then
  exit 0
fi

# Only write if file content actually differs (avoids needless disk writes).
if [ -f "$CRED_FILE" ] && [ "$KEYCHAIN_DATA" = "$(cat "$CRED_FILE" 2>/dev/null)" ]; then
  exit 0
fi

# Atomic write via temp file in same dir, then chmod, then move.
TMP_FILE="${CRED_FILE}.tmp.$$"
printf '%s' "$KEYCHAIN_DATA" > "$TMP_FILE" || exit 0
chmod 600 "$TMP_FILE"
mv "$TMP_FILE" "$CRED_FILE"

exit 0
