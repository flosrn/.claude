#!/bin/bash
# project-status.sh
# Shows full status of detected Makerkit project
#
# Usage: ./project-status.sh [directory]

set -e

DIR="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect project
PROJECT=$("$SCRIPT_DIR/detect-project.sh" "$DIR")

if [ "$PROJECT" = "unknown" ]; then
    echo "Not in a Makerkit project"
    exit 0
fi

# Get project root
if [ "$PROJECT" = "gapila" ]; then
    PROJECT_ROOT="/Users/flo/Code/nextjs/gapila"
elif [ "$PROJECT" = "lasdelaroute" ]; then
    PROJECT_ROOT="/Users/flo/Code/nextjs/lasdelaroute"
fi

cd "$PROJECT_ROOT"

# Get version from package.json
VERSION=$(cat package.json | grep '"version"' | head -1 | sed 's/.*: "\(.*\)".*/\1/')

# Get current branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# Check if upstream is configured
UPSTREAM=$(git remote -v 2>/dev/null | grep upstream | head -1 | awk '{print $2}' || echo "not configured")

# Get last commit date
LAST_COMMIT=$(git log -1 --format="%ci" 2>/dev/null | cut -d' ' -f1 || echo "unknown")

# Check for uncommitted changes
if git diff --quiet 2>/dev/null && git diff --staged --quiet 2>/dev/null; then
    STATUS="clean"
else
    STATUS="uncommitted changes"
fi

# Output
echo "==================================="
echo "Makerkit Project: $PROJECT"
echo "==================================="
echo "Version:    $VERSION"
echo "Branch:     $BRANCH"
echo "Status:     $STATUS"
echo "Upstream:   $UPSTREAM"
echo "Last commit: $LAST_COMMIT"
echo "==================================="
