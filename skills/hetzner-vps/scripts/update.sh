#!/bin/bash
# Update a Docker stack — pull new images and recreate
# Usage: /opt/docker/scripts/update.sh <stack-name> [--force]
set -euo pipefail

STACK="${1:-}"
FORCE="${2:-}"
BASE_DIR="/opt/docker"
NTFY_URL="${NTFY_URL:-http://localhost:8091/updates}"

if [ -z "$STACK" ]; then
  echo "Usage: $0 <stack-name> [--force]"
  echo ""
  echo "Available stacks:"
  for d in "$BASE_DIR"/*/; do
    [ -f "$d/compose.yml" ] && echo "  $(basename "$d")"
  done
  exit 1
fi

STACK_DIR="$BASE_DIR/$STACK"
if [ ! -f "$STACK_DIR/compose.yml" ]; then
  echo "Error: No compose.yml in $STACK_DIR"
  exit 1
fi

echo "=== Updating stack: $STACK ==="

cd "$STACK_DIR"

# Pull new images
echo "Pulling images..."
docker compose pull 2>&1

# Check if images changed
UPDATED=$(docker compose pull 2>&1 | grep -c "Pull complete" || true)

if [ "$UPDATED" -gt 0 ] || [ "$FORCE" = "--force" ]; then
  echo "Recreating containers..."
  docker compose up -d --remove-orphans
  echo "Cleaning old images..."
  docker image prune -f > /dev/null

  curl -sf -d "Stack '$STACK' updated successfully" "$NTFY_URL" > /dev/null 2>&1 || true
  echo "✅ Stack $STACK updated"
else
  echo "No changes detected. Use --force to recreate anyway."
fi
