#!/bin/bash
# Diagnostic complet du VPS OpenClaw
# Usage: ssh vps 'bash -s' < vps-doctor.sh [--quick]
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

ok()     { echo -e "  ${GREEN}✓${NC} $*"; }
warn()   { echo -e "  ${YELLOW}⚠${NC} $*"; }
fail()   { echo -e "  ${RED}✗${NC} $*"; }
header() { echo -e "\n${BOLD}${BLUE}=== $* ===${NC}"; }

QUICK="${1:-}"
CONTAINER="openclaw-openclaw-gateway-1"
OPENCLAW_CMD="docker exec $CONTAINER node dist/index.js"
COMPOSE_DIR="/root/openclaw"
OK_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

count_ok()   { OK_COUNT=$((OK_COUNT + 1)); ok "$@"; }
count_warn() { WARN_COUNT=$((WARN_COUNT + 1)); warn "$@"; }
count_fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); fail "$@"; }

echo -e "${BOLD}VPS Doctor — Diagnostic complet${NC}"
echo -e "Date: $(date '+%Y-%m-%d %H:%M:%S %Z')"

# 1. Conteneur
header "1. Conteneur"
if docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' | grep -q "$CONTAINER"; then
  CONTAINER_INFO=$(docker ps --format '{{.Names}}  {{.Image}}  {{.Status}}' --filter "name=$CONTAINER")
  count_ok "$CONTAINER_INFO"

  # Uptime
  STARTED=$(docker inspect --format '{{.State.StartedAt}}' "$CONTAINER" 2>/dev/null || echo "")
  if [ -n "$STARTED" ]; then
    ok "Démarré: $STARTED"
  fi
else
  count_fail "Conteneur $CONTAINER non trouvé"
  echo -e "\n${RED}Le conteneur n'est pas en cours d'exécution. Diagnostic interrompu.${NC}"
  echo -e "  Essayer: ${BOLD}docker compose -f $COMPOSE_DIR/docker-compose.yml up -d openclaw-gateway${NC}"
  exit 1
fi

# 2. Healthcheck
header "2. Healthcheck"
HC_START=$(date +%s%N)
if HC_RESULT=$(curl -sf http://127.0.0.1:18789/healthz -w "\n%{http_code}" 2>/dev/null); then
  HC_END=$(date +%s%N)
  HC_TIME=$(( (HC_END - HC_START) / 1000000 ))
  HC_CODE=$(echo "$HC_RESULT" | tail -1)
  count_ok "HTTP $HC_CODE — ${HC_TIME}ms"
else
  count_fail "Healthcheck échoué"
fi

# 3. OpenClaw Status
header "3. OpenClaw Status"
STATUS_OUTPUT=$($OPENCLAW_CMD status --all 2>/dev/null || echo "FAILED")
if [ "$STATUS_OUTPUT" != "FAILED" ]; then
  echo "$STATUS_OUTPUT" | head -20
  count_ok "Status récupéré"
else
  count_fail "Impossible de récupérer le status"
fi

# 4. OpenClaw Doctor
header "4. OpenClaw Doctor"
DOCTOR_OUTPUT=$($OPENCLAW_CMD doctor 2>/dev/null || echo "FAILED")
if [ "$DOCTOR_OUTPUT" != "FAILED" ]; then
  echo "$DOCTOR_OUTPUT" | head -30
  count_ok "Doctor OK"
else
  count_warn "Commande doctor non disponible ou échouée"
fi

# 5. Modèles & Auth
header "5. Modèles & Auth"
MODELS_OUTPUT=$($OPENCLAW_CMD models status 2>/dev/null || echo "FAILED")
if [ "$MODELS_OUTPUT" != "FAILED" ]; then
  echo "$MODELS_OUTPUT" | head -15
  count_ok "Models status récupéré"
else
  count_warn "Commande models status non disponible"
fi

# 6. Health Probes (skip si --quick)
if [ "$QUICK" != "--quick" ]; then
  header "6. Health Probes"
  HEALTH_OUTPUT=$($OPENCLAW_CMD health --verbose 2>/dev/null || echo "FAILED")
  if [ "$HEALTH_OUTPUT" != "FAILED" ]; then
    echo "$HEALTH_OUTPUT" | head -20
    count_ok "Health probes OK"
  else
    count_warn "Commande health non disponible"
  fi
else
  header "6. Health Probes (skip — mode quick)"
  ok "Ignoré avec --quick"
fi

# 7. Auth Profiles (logique inline)
header "7. Auth Profiles"
python3 -c "
import json, os, sys
from datetime import datetime, timezone

GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
NC = '\033[0m'

ok = 0
issues = 0

# Auth profiles
for root, dirs, files in os.walk('/root/.openclaw'):
    for f in files:
        if f == 'auth-profiles.json':
            path = os.path.join(root, f)
            parent = os.path.basename(os.path.dirname(path))
            agent = os.path.basename(os.path.dirname(os.path.dirname(path))) if parent == 'agent' else parent
            try:
                with open(path) as fh:
                    data = json.load(fh)
                profiles = data if isinstance(data, list) else [data]
                for p in profiles:
                    stats = p.get('usageStats', {})
                    name = p.get('name', p.get('id', agent))
                    ec = stats.get('errorCount', 0)
                    cd = stats.get('cooldownUntil')
                    has_issue = ec > 0
                    if cd:
                        try:
                            cdt = datetime.fromisoformat(str(cd).replace('Z', '+00:00'))
                            has_issue = has_issue or cdt > datetime.now(timezone.utc)
                        except:
                            pass
                    if has_issue:
                        print(f'  {RED}✗{NC} {name} (errors={ec})')
                        issues += 1
                    else:
                        print(f'  {GREEN}✓{NC} {name}')
                        ok += 1
            except:
                print(f'  {RED}✗{NC} {agent}: erreur de parsing')
                issues += 1

# Credentials
creds = '/root/.claude/.credentials.json'
if os.path.exists(creds):
    try:
        with open(creds) as fh:
            data = json.load(fh)
        expires = data.get('expiresAt', data.get('claudeAiOauth', {}).get('expiresAt'))
        if expires:
            exp = datetime.fromisoformat(str(expires).replace('Z', '+00:00'))
            if exp > datetime.now(timezone.utc):
                hours = (exp - datetime.now(timezone.utc)).total_seconds() / 3600
                print(f'  {GREEN}✓{NC} credentials.json (expire dans {hours:.1f}h)')
                ok += 1
            else:
                print(f'  {RED}✗{NC} credentials.json expiré')
                issues += 1
        else:
            ok += 1
    except:
        issues += 1

# Résultat pour le compteur bash
print(f'AUTH_RESULT|{ok}|{issues}')
" 2>/dev/null | while IFS= read -r line; do
  case "$line" in
    AUTH_RESULT\|*)
      IFS='|' read -r _ auth_ok auth_fail <<< "$line"
      if [ "${auth_fail:-0}" -gt 0 ]; then
        FAIL_COUNT=$((FAIL_COUNT + auth_fail))
      fi
      OK_COUNT=$((OK_COUNT + ${auth_ok:-0}))
      ;;
    *) echo "$line" ;;
  esac
done

# 8. Ressources
header "8. Ressources"
echo -e "  ${BOLD}RAM:${NC}"
free -h | grep -E "Mem|Swap" | while read -r line; do
  echo "    $line"
done

echo -e "\n  ${BOLD}Disque:${NC}"
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | tr -d '%')
DISK_LINE=$(df -h / | tail -1)
if [ "$DISK_USAGE" -gt 90 ]; then
  count_fail "Disque: $DISK_LINE"
elif [ "$DISK_USAGE" -gt 80 ]; then
  count_warn "Disque: $DISK_LINE"
else
  count_ok "Disque: $DISK_LINE"
fi

echo -e "\n  ${BOLD}Docker:${NC}"
docker system df 2>/dev/null | while read -r line; do
  echo "    $line"
done

# 9. Services
header "9. Services"
for svc in docker cloudflared-openclaw tailscaled cron; do
  STATUS=$(systemctl is-active "$svc" 2>/dev/null || echo "not found")
  if [ "$STATUS" = "active" ]; then
    count_ok "$svc: active"
  elif [ "$STATUS" = "not found" ]; then
    count_warn "$svc: non trouvé"
  else
    count_fail "$svc: $STATUS"
  fi
done

# 10. Résumé
header "10. Résumé"
echo -e "  ${GREEN}${OK_COUNT} OK${NC} | ${YELLOW}${WARN_COUNT} WARN${NC} | ${RED}${FAIL_COUNT} FAIL${NC}"

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo -e "\n  ${RED}Des problèmes critiques ont été détectés.${NC}"
  exit 1
elif [ "$WARN_COUNT" -gt 0 ]; then
  echo -e "\n  ${YELLOW}Des avertissements à surveiller.${NC}"
fi
