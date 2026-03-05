#!/bin/bash
# Sauvegarde une mémoire et reindex
# Usage: ./memory-save.sh "topic" "contenu"
set -euo pipefail

TOPIC="${1:?Usage: memory-save.sh \"topic\" \"contenu\"}"
CONTENT="${2:?Usage: memory-save.sh \"topic\" \"contenu\"}"
DATE=$(date +%Y-%m-%d)
FILENAME="/root/.openclaw/workspace/memory/${DATE}-${TOPIC// /-}.md"

cat > "$FILENAME" << EOF
# Session: $DATE (via Claude Code local)
## $TOPIC
$CONTENT

**Tags:** $TOPIC
EOF

echo "Mémoire sauvegardée: $FILENAME"

echo "Reindexation..."
cd /root/openclaw
docker compose exec -T openclaw-gateway node dist/index.js memory index
echo "Done."
