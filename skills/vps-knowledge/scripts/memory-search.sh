#!/bin/bash
# Recherche dans la mémoire OpenClaw
# Usage: ./memory-search.sh "query"
set -euo pipefail

QUERY="${1:?Usage: memory-search.sh \"query\"}"

cd /root/openclaw
docker compose exec -T openclaw-gateway node dist/index.js memory search "$QUERY"
