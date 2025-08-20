#!/bin/bash
# Auto-update date in CLAUDE.md on SessionStart
# Based on Reddit solution from https://www.reddit.com/r/ClaudeAI/comments/1mrr3nm/

CLAUDE_MD="$HOME/.claude/CLAUDE.md"
BACKUPS_DIR="$HOME/.claude/backups"
CURRENT_DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
NEW_DATE_LINE="- **Current date**: $CURRENT_DATE"

# Check if file exists
if [[ ! -f "$CLAUDE_MD" ]]; then
    echo "Error: CLAUDE.md not found at $CLAUDE_MD"
    exit 1
fi

# Create backups directory if it doesn't exist
mkdir -p "$BACKUPS_DIR"

# Create backup with timestamp in backups folder
cp "$CLAUDE_MD" "$BACKUPS_DIR/CLAUDE.md.backup.$TIMESTAMP"

# Update the first line containing "Current date" using sed
sed -i '' "/\*\*Current date\*\*/c\\
$NEW_DATE_LINE" "$CLAUDE_MD"

# Clean up backup files older than 7 days
find "$BACKUPS_DIR" -name "CLAUDE.md.backup.*" -mtime +7 -delete 2>/dev/null

echo "Updated CLAUDE.md date to: $CURRENT_DATE (backup saved to backups/)"