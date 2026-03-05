#!/bin/bash
# Affiche les logs récents du gateway et de l'auto-updater
# Usage: ./vps-logs.sh [gateway|updater|all] [N lignes]
set -euo pipefail

TARGET="${1:-all}"
LINES="${2:-50}"

if [ "$TARGET" = "gateway" ] || [ "$TARGET" = "all" ]; then
  echo "=== Logs Gateway (dernières $LINES lignes) ==="
  docker compose -f /root/openclaw/docker-compose.yml logs --tail "$LINES" --no-log-prefix openclaw-gateway 2>/dev/null || echo "Conteneur non trouvé"
  echo ""
fi

if [ "$TARGET" = "updater" ] || [ "$TARGET" = "all" ]; then
  echo "=== Logs Auto-Updater (dernières $LINES lignes) ==="
  tail -"$LINES" /var/log/openclaw-update.log 2>/dev/null || echo "Pas de logs auto-updater"
fi
