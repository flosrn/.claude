#!/bin/bash
# Rafraîchissement des tokens OAuth Claude Code sur le VPS
# ⚠️ Script LOCAL — à exécuter depuis le Mac (PAS via SSH)
# Usage: ~/.claude/skills/vps-knowledge/scripts/vps-auth-refresh.sh [--dry-run]
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

DRY_RUN="${1:-}"

echo -e "${BOLD}VPS Auth Refresh — Rafraîchissement des tokens OAuth${NC}"
echo -e "Date: $(date '+%Y-%m-%d %H:%M:%S %Z')"

# 1. Vérifier qu'on est sur macOS
header "1. Vérification environnement"
if [ "$(uname)" != "Darwin" ]; then
  fail "Ce script doit être exécuté sur macOS (pas sur le VPS)"
  echo -e "  Usage: ${BOLD}~/.claude/skills/vps-knowledge/scripts/vps-auth-refresh.sh${NC}"
  exit 1
fi
ok "macOS détecté"

# Vérifier la connexion SSH
if ! ssh -o ConnectTimeout=5 vps 'echo ok' >/dev/null 2>&1; then
  fail "Impossible de se connecter au VPS via SSH"
  exit 1
fi
ok "Connexion SSH OK"

# 2. Extraire le token frais du Keychain
header "2. Extraction du token"
KEYCHAIN_RAW=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null || echo "")

if [ -z "$KEYCHAIN_RAW" ]; then
  fail "Impossible de lire les credentials depuis le Keychain"
  echo -e "  Vérifier que Claude Code est connecté localement"
  exit 1
fi

# Parser le JSON pour extraire le token OAuth
ACCESS_TOKEN=$(python3 -c "
import json, sys
try:
    data = json.loads('''$KEYCHAIN_RAW''')
    # Chercher le token dans différentes structures
    if 'claudeAiOauth' in data:
        token = data['claudeAiOauth'].get('accessToken', '')
    elif 'accessToken' in data:
        token = data['accessToken']
    else:
        token = ''
    if not token:
        print('ERROR', file=sys.stderr)
        sys.exit(1)
    print(token)
except Exception as e:
    print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null) || {
  fail "Impossible de parser le token OAuth depuis le Keychain"
  exit 1
}

TOKEN_PREFIX="${ACCESS_TOKEN:0:20}..."
ok "Token extrait: ${TOKEN_PREFIX}"

# Extraire aussi expiresAt si disponible
EXPIRES_AT=$(python3 -c "
import json
data = json.loads('''$KEYCHAIN_RAW''')
oauth = data.get('claudeAiOauth', data)
print(oauth.get('expiresAt', ''))
" 2>/dev/null || echo "")

if [ -n "$EXPIRES_AT" ]; then
  ok "Expire: $EXPIRES_AT"
fi

# 3. Préparer le JSON complet des credentials
header "3. Mise à jour sur le VPS"

CREDS_JSON=$(python3 -c "
import json
data = json.loads('''$KEYCHAIN_RAW''')
print(json.dumps(data))
" 2>/dev/null)

if [ "$DRY_RUN" = "--dry-run" ]; then
  echo -e "  ${YELLOW}[DRY RUN] Les actions suivantes seraient effectuées :${NC}"
  echo -e "  - Mise à jour de /root/.claude/.credentials.json"
  echo -e "  - Mise à jour des auth-profiles.json (token + reset usageStats)"
  echo -e "  - Restart du gateway"
  echo -e "  - Healthcheck"
  echo -e "  - Vérification auth"
  exit 0
fi

# Mettre à jour credentials.json sur le VPS
echo "$CREDS_JSON" | ssh vps "cat > /root/.claude/.credentials.json"
ok "credentials.json mis à jour"

# Mettre à jour les auth-profiles.json + reset usageStats
ssh vps "python3 -c \"
import json, os

# Trouver tous les auth-profiles.json
updated = 0
for root, dirs, files in os.walk('/root/.openclaw'):
    for f in files:
        if f == 'auth-profiles.json':
            path = os.path.join(root, f)
            try:
                with open(path) as fh:
                    data = json.load(fh)
                profiles = data if isinstance(data, list) else [data]
                modified = False
                for p in profiles:
                    # Reset usageStats
                    if 'usageStats' in p:
                        p['usageStats']['errorCount'] = 0
                        p['usageStats']['cooldownUntil'] = None
                        if 'failureCounts' in p['usageStats']:
                            p['usageStats']['failureCounts'] = {}
                        modified = True
                    # Mettre à jour le token si le profil en contient un
                    if 'accessToken' in p:
                        p['accessToken'] = '$ACCESS_TOKEN'
                        modified = True
                    if 'claudeAiOauth' in p and isinstance(p['claudeAiOauth'], dict):
                        p['claudeAiOauth']['accessToken'] = '$ACCESS_TOKEN'
                        modified = True
                if modified:
                    out = profiles if isinstance(data, list) else profiles[0]
                    with open(path, 'w') as fh:
                        json.dump(out, fh, indent=2)
                    updated += 1
            except Exception as e:
                print(f'Erreur sur {path}: {e}')

print(f'{updated} fichier(s) auth-profiles.json mis à jour')
\"" 2>/dev/null | while read -r line; do
  ok "$line"
done

# 4. Restart du gateway
header "4. Restart gateway"
ssh vps "cd /root/openclaw && docker compose restart openclaw-gateway" 2>/dev/null
ok "Gateway redémarré"

# 5. Healthcheck
header "5. Healthcheck"
for i in $(seq 1 12); do
  if ssh vps "curl -sf http://127.0.0.1:18789/healthz -o /dev/null" 2>/dev/null; then
    ok "Healthcheck OK après ${i} tentative(s)"
    break
  fi
  if [ "$i" -eq 12 ]; then
    fail "Healthcheck échoué après 60s"
    exit 1
  fi
  echo -e "  Tentative $i/12 — en attente..."
  sleep 5
done

# 6. Vérification auth
header "6. Vérification"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/vps-auth-check.sh" ]; then
  ssh vps 'bash -s' < "$SCRIPT_DIR/vps-auth-check.sh" 2>/dev/null || true
else
  # Vérification inline rapide
  ssh vps "python3 -c \"
import json, os
from datetime import datetime, timezone
creds = '/root/.claude/.credentials.json'
if os.path.exists(creds):
    with open(creds) as f:
        data = json.load(f)
    expires = data.get('expiresAt', data.get('claudeAiOauth', {}).get('expiresAt'))
    if expires:
        exp = datetime.fromisoformat(str(expires).replace('Z', '+00:00'))
        remaining = (exp - datetime.now(timezone.utc)).total_seconds() / 3600
        print(f'Token valide — expire dans {remaining:.1f}h')
    else:
        print('Token présent (pas d\\'expiration)')
else:
    print('WARN: credentials.json non trouvé')
\"" 2>/dev/null | while read -r line; do
    ok "$line"
  done
fi

echo -e "\n${GREEN}${BOLD}Rafraîchissement terminé avec succès${NC}"
