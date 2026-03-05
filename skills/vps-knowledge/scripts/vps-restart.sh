#!/bin/bash
# Redémarre le gateway OpenClaw et vérifie le healthcheck
set -euo pipefail

echo "=== Redémarrage du gateway ==="
cd /root/openclaw
docker compose restart openclaw-gateway

echo ""
echo "=== Attente healthcheck ==="
for i in $(seq 1 12); do
  if curl -sf http://127.0.0.1:18789/healthz -o /dev/null 2>/dev/null; then
    echo "Healthcheck OK après ${i} tentative(s)"
    docker ps --format "{{.Names}} {{.Status}}" --filter name=openclaw
    exit 0
  fi
  echo "Tentative $i/12 — en attente..."
  sleep 5
done

echo "ERREUR: healthcheck échoué après 60s"
docker ps --format "{{.Names}} {{.Status}}" --filter name=openclaw
docker compose logs --tail 20 openclaw-gateway
exit 1
