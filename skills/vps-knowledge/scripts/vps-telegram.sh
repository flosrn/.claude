#!/bin/bash
# Diagnostics des bots Telegram OpenClaw
# Usage: ssh vps 'bash -s' < vps-telegram.sh [bot-name|all] [--test]
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

BOT_FILTER="${1:-all}"
TEST_MODE=false
COMPOSE_DIR="/root/openclaw"
CONFIG="/root/.openclaw/openclaw.json"

# Parser les arguments
for arg in "$@"; do
  case "$arg" in
    --test) TEST_MODE=true ;;
    all|--test) ;;
    *) BOT_FILTER="$arg" ;;
  esac
done

if [ ! -f "$CONFIG" ]; then
  fail "Config non trouvée : $CONFIG"
  exit 1
fi

header "Bots Telegram"

# Lister et tester les bots
python3 -c "
import json, sys, os
import urllib.request
import urllib.error

GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
BLUE = '\033[0;34m'
BOLD = '\033[1m'
NC = '\033[0m'

bot_filter = '$BOT_FILTER'
test_mode = $( [ "$TEST_MODE" = true ] && echo "True" || echo "False" )

with open('$CONFIG') as f:
    cfg = json.load(f)

accounts = cfg.get('channels', {}).get('telegram', {}).get('accounts', {})
allow_from = cfg.get('channels', {}).get('telegram', {}).get('allowFrom', [])

if not accounts:
    print(f'  {YELLOW}⚠{NC} Aucun bot Telegram configuré')
    sys.exit(0)

for name, acct in accounts.items():
    if bot_filter != 'all' and bot_filter.lower() != name.lower():
        continue

    token = acct.get('botToken', '')
    print(f'\n{BOLD}{BLUE}--- {name} ---{NC}')

    if not token:
        print(f'  {RED}✗{NC} Pas de botToken configuré')
        continue

    # Test connexion API : getMe
    try:
        req = urllib.request.Request(f'https://api.telegram.org/bot{token}/getMe')
        resp = urllib.request.urlopen(req, timeout=10)
        data = json.loads(resp.read())
        if data.get('ok'):
            bot_info = data['result']
            username = bot_info.get('username', '?')
            bot_id = bot_info.get('id', '?')
            print(f'  {GREEN}✓{NC} @{username} (ID: {bot_id})')
        else:
            print(f'  {RED}✗{NC} getMe échoué: {data.get(\"description\", \"?\")}')
            continue
    except urllib.error.HTTPError as e:
        print(f'  {RED}✗{NC} API erreur HTTP {e.code}: token invalide ou expiré')
        continue
    except Exception as e:
        print(f'  {RED}✗{NC} Connexion échouée: {e}')
        continue

    # Webhook / polling status
    try:
        req = urllib.request.Request(f'https://api.telegram.org/bot{token}/getWebhookInfo')
        resp = urllib.request.urlopen(req, timeout=10)
        wh = json.loads(resp.read())
        if wh.get('ok'):
            info = wh['result']
            url = info.get('url', '')
            pending = info.get('pending_update_count', 0)
            last_error = info.get('last_error_message', '')
            last_error_date = info.get('last_error_date', '')

            if url:
                print(f'  {GREEN}✓{NC} Webhook: {url}')
            else:
                print(f'  {YELLOW}⚠{NC} Pas de webhook (mode polling)')

            if pending > 0:
                print(f'  {YELLOW}⚠{NC} {pending} updates en attente')
            else:
                print(f'  {GREEN}✓{NC} 0 updates en attente')

            if last_error:
                print(f'  {RED}✗{NC} Dernière erreur: {last_error}')
            # Pas de message si pas d'erreur
    except Exception as e:
        print(f'  {YELLOW}⚠{NC} Impossible de vérifier le webhook: {e}')

    # Chat IDs autorisés
    if allow_from:
        print(f'  Chat IDs autorisés: {BOLD}{\", \".join(str(c) for c in allow_from)}{NC}')

    # Message de test
    if test_mode and allow_from:
        chat_id = allow_from[0]
        try:
            import urllib.parse
            msg = f'🔧 Test diagnostic — bot {name} OK'
            params = urllib.parse.urlencode({'chat_id': chat_id, 'text': msg}).encode()
            req = urllib.request.Request(f'https://api.telegram.org/bot{token}/sendMessage', data=params)
            resp = urllib.request.urlopen(req, timeout=10)
            result = json.loads(resp.read())
            if result.get('ok'):
                print(f'  {GREEN}✓{NC} Message de test envoyé au chat {chat_id}')
            else:
                print(f'  {RED}✗{NC} Échec envoi test: {result.get(\"description\", \"?\")}')
        except Exception as e:
            print(f'  {RED}✗{NC} Échec envoi test: {e}')
" 2>/dev/null

# Erreurs Telegram récentes dans les logs
header "Erreurs Telegram récentes"
cd "$COMPOSE_DIR"
TELEGRAM_ERRORS=$(docker compose logs --tail 500 --no-log-prefix openclaw-gateway 2>/dev/null \
  | grep -i "telegram" | grep -iE "error|fail|warn" | tail -10 || true)

if [ -n "$TELEGRAM_ERRORS" ]; then
  echo "$TELEGRAM_ERRORS"
else
  ok "Aucune erreur Telegram récente"
fi
