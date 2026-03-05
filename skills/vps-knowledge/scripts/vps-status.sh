#!/bin/bash
# Affiche l'état complet du VPS (conteneurs, RAM, disque, services)
set -euo pipefail

echo "=== Conteneurs Docker ==="
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "=== Ressources ==="
echo "RAM:"
free -h | grep -E "total|Mem|Swap"
echo ""
echo "Disque:"
df -h / | tail -1
echo ""
echo "Docker:"
docker system df

echo ""
echo "=== Healthcheck Gateway ==="
if curl -sf http://127.0.0.1:18789/healthz -o /dev/null -w "HTTP %{http_code}" 2>/dev/null; then
  echo " — OK"
else
  echo " — FAILED"
fi

echo ""
echo "=== Services critiques ==="
for svc in docker cloudflared-openclaw tailscaled cron; do
  STATUS=$(systemctl is-active "$svc" 2>/dev/null || echo "not found")
  printf "%-30s %s\n" "$svc" "$STATUS"
done

echo ""
echo "=== Cron jobs ==="
crontab -l 2>/dev/null || echo "Aucun crontab"

echo ""
echo "=== Git (OpenClaw) ==="
cd /root/openclaw
echo "Branche: $(git branch --show-current 2>/dev/null || echo 'detached')"
echo "Commit:  $(git log --oneline -1)"
git fetch origin 2>/dev/null
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main 2>/dev/null || echo "unknown")
if [ "$LOCAL" = "$REMOTE" ]; then
  echo "Status:  à jour"
else
  BEHIND=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo "?")
  echo "Status:  $BEHIND commits en retard"
fi
