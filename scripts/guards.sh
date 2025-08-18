#!/bin/bash

# Claude Code Setup Guards Script
# Checks prerequisites and creates required directories/files

set -e

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

# macOS detection
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "WARNING: This setup is optimized for macOS" >&2
fi

# Check Bun availability
if ! command -v bun >/dev/null 2>&1; then
  echo "ERROR: Bun is required but not found in PATH" >&2
  echo "Install with: curl -fsSL https://bun.sh/install | bash" >&2
  exit 1
fi

# Create logs directory if it doesn't exist
mkdir -p "$CLAUDE_HOME/logs"

# Create security.log if it doesn't exist
if [[ ! -f "$CLAUDE_HOME/logs/security.log" ]]; then
  touch "$CLAUDE_HOME/logs/security.log"
  echo "Created security.log"
fi

# Create songs directory for notifications
mkdir -p "$CLAUDE_HOME/songs"

echo "Guards check passed. Bun version: $(bun --version)"