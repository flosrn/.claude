#!/bin/bash
# Statut détaillé des agents OpenClaw
# Usage: ssh vps 'bash -s' < vps-agents.sh [agent-id]
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

AGENT_FILTER="${1:-}"
CONTAINER="openclaw-openclaw-gateway-1"
OPENCLAW_CMD="docker exec $CONTAINER node dist/index.js"
COMPOSE_DIR="/root/openclaw"
CONFIG="/root/.openclaw/openclaw.json"

# Vérifier que le conteneur tourne
if ! docker ps --format '{{.Names}}' | grep -q "$CONTAINER"; then
  fail "Conteneur $CONTAINER non trouvé"
  exit 1
fi

# Liste des agents
header "Agents"
AGENTS_OUTPUT=$($OPENCLAW_CMD agents 2>/dev/null || echo "")
if [ -n "$AGENTS_OUTPUT" ]; then
  echo "$AGENTS_OUTPUT"
else
  warn "Impossible de lister les agents"
fi

# Sessions actives
header "Sessions"
SESSIONS_OUTPUT=$($OPENCLAW_CMD sessions 2>/dev/null || echo "")
if [ -n "$SESSIONS_OUTPUT" ]; then
  echo "$SESSIONS_OUTPUT"
else
  warn "Aucune session active"
fi

# Auth status par agent
header "Auth par agent"
python3 -c "
import json, os
from datetime import datetime, timezone

GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
BOLD = '\033[1m'
NC = '\033[0m'

agent_filter = '$AGENT_FILTER'

# Scanner les auth-profiles.json
auth_files = []
for root, dirs, files in os.walk('/root/.openclaw'):
    for f in files:
        if f == 'auth-profiles.json':
            auth_files.append(os.path.join(root, f))

if not auth_files:
    print(f'  {YELLOW}⚠{NC} Aucun auth-profiles.json trouvé')
else:
    for path in sorted(auth_files):
        parent = os.path.basename(os.path.dirname(path))
        agent = os.path.basename(os.path.dirname(os.path.dirname(path))) if parent == 'agent' else parent
        if agent_filter and agent_filter.lower() != agent.lower():
            continue
        try:
            with open(path) as fh:
                data = json.load(fh)
            profiles = data if isinstance(data, list) else [data]
            for p in profiles:
                name = p.get('name', p.get('id', agent))
                stats = p.get('usageStats', {})
                ec = stats.get('errorCount', 0)
                cd = stats.get('cooldownUntil')
                status = f'{GREEN}OK{NC}' if ec == 0 and not cd else f'{RED}ERREUR{NC} (errors={ec})'
                print(f'  {BOLD}{name}{NC}: {status}')
        except Exception as e:
            print(f'  {RED}✗{NC} {agent}: {e}')
" 2>/dev/null

# Erreurs récentes par agent
header "Erreurs récentes"
cd "$COMPOSE_DIR"
RECENT_LOGS=$(docker compose logs --tail 500 --no-log-prefix openclaw-gateway 2>/dev/null || echo "")

if [ -n "$AGENT_FILTER" ]; then
  AGENT_ERRORS=$(echo "$RECENT_LOGS" | grep -i "$AGENT_FILTER" | grep -iE "error|fail" | tail -10 || true)
  if [ -n "$AGENT_ERRORS" ]; then
    echo -e "${BOLD}Agent: ${AGENT_FILTER}${NC}"
    echo "$AGENT_ERRORS"
  else
    ok "Aucune erreur récente pour $AGENT_FILTER"
  fi
else
  # Compter les erreurs par agent connu
  python3 -c "
import json, os

GREEN = '\033[0;32m'
RED = '\033[0;31m'
NC = '\033[0m'

# Récupérer les noms d'agents depuis la config
agents = []
config_path = '/root/.openclaw/openclaw.json'
if os.path.exists(config_path):
    try:
        with open(config_path) as f:
            cfg = json.load(f)
        # Agents depuis channels.telegram.accounts
        accounts = cfg.get('channels', {}).get('telegram', {}).get('accounts', {})
        agents = list(accounts.keys())
    except:
        pass

if not agents:
    agents = ['default', 'gapibot', 'english', 'chinese']

logs = '''$(echo "$RECENT_LOGS" | sed "s/'/'\\\\''/g")'''

for agent in agents:
    count = sum(1 for line in logs.split('\n') if agent.lower() in line.lower() and any(e in line.lower() for e in ['error', 'fail']))
    if count > 0:
        print(f'  {RED}✗{NC} {agent}: {count} erreur(s) (500 dernières lignes)')
    else:
        print(f'  {GREEN}✓{NC} {agent}: aucune erreur')
" 2>/dev/null || warn "Impossible d'analyser les logs"
fi

# Bindings Telegram (extrait du CLI agents)
header "Bindings Telegram"
if [ -n "$AGENTS_OUTPUT" ]; then
  # Parser la sortie CLI : lignes "Routing: Telegram <account>"
  echo "$AGENTS_OUTPUT" | python3 -c "
import sys

BOLD = '\033[1m'
NC = '\033[0m'

agent_filter = '$AGENT_FILTER'
current_agent = ''
for line in sys.stdin:
    line = line.rstrip()
    # Ligne d'agent : '- main (default) (Clawd)' ou '- gapibot (Gapibot)'
    if line.startswith('- '):
        parts = line[2:].split(' ', 1)
        current_agent = parts[0]
    # Ligne routing : '  Routing: Telegram default'
    if 'Routing:' in line and 'Telegram' in line:
        tg_account = line.split('Telegram')[-1].strip()
        if agent_filter and agent_filter.lower() != current_agent.lower():
            continue
        print(f'  {BOLD}{current_agent}{NC} → telegram:{tg_account}')
" 2>/dev/null
else
  warn "Données agents non disponibles"
fi
