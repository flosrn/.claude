#!/bin/bash

# macOS Notification Script (optional)
# Requires terminal-notifier: brew install terminal-notifier

PROJECT_NAME="${PWD##*/}"

# Check if terminal-notifier is available
if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier \
    -title 'Claude Code' \
    -subtitle 'Session Complete' \
    -message "Finished working in $PROJECT_NAME" \
    -sound default \
    -timeout 10
else
  # Fallback to afplay if available
  if command -v afplay >/dev/null 2>&1 && [[ -f "$HOME/.claude/songs/finish.mp3" ]]; then
    afplay -v 0.1 "$HOME/.claude/songs/finish.mp3" &
  fi
  
  echo "✅ Claude session completed in $PROJECT_NAME"
fi