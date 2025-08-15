#!/bin/bash
# Simple linting pour Claude Code

set -e

files="$CLAUDE_FILE_PATHS"
if [[ -z "$files" ]]; then
    exit 0
fi

# Prettier + ESLint si disponibles
while read -r file; do
    if [[ -f "$file" ]]; then
        # Format
        if command -v prettier >/dev/null; then
            prettier --write "$file" 2>/dev/null || true
        fi
        
        # Lint
        if command -v eslint >/dev/null; then
            eslint --fix "$file" 2>/dev/null || true
        fi
    fi
done <<< "$files"