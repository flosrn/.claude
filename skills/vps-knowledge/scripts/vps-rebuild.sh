#!/bin/bash
# Rebuild complet de l'image OpenClaw + restart du gateway
# Usage: ./vps-rebuild.sh [--no-restart]
set -euo pipefail

NO_RESTART="${1:-}"

cd /root/openclaw

echo "=== Build de l'image openclaw:local ==="
echo "Dockerfile: Dockerfile.clawpro"
echo ""

BUILD_START=$(date +%s)
docker build -f Dockerfile.clawpro -t openclaw:local .
BUILD_END=$(date +%s)
BUILD_DURATION=$((BUILD_END - BUILD_START))

echo ""
echo "Build terminé en ${BUILD_DURATION}s"

if [ "$NO_RESTART" = "--no-restart" ]; then
  echo "Skip restart (--no-restart)"
  exit 0
fi

echo ""
echo "=== Arrêt du gateway ==="
docker compose stop openclaw-gateway

echo ""
echo "=== Démarrage avec la nouvelle image ==="
docker compose up -d openclaw-gateway

echo ""
echo "=== Attente healthcheck ==="
for i in $(seq 1 12); do
  if curl -sf http://127.0.0.1:18789/healthz -o /dev/null 2>/dev/null; then
    echo "Healthcheck OK après ${i} tentative(s)"
    echo ""
    echo "=== Nettoyage ==="
    docker image prune -f
    docker builder prune -f
    echo ""
    df -h / | tail -1
    exit 0
  fi
  echo "Tentative $i/12 — en attente..."
  sleep 5
done

echo "ERREUR: healthcheck échoué après 60s"
docker compose logs --tail 20 openclaw-gateway
exit 1
