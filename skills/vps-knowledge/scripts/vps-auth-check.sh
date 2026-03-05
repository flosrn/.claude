#!/bin/bash
# Vérification des tokens d'authentification pour tous les agents OpenClaw
# Usage: ssh vps 'bash -s' < vps-auth-check.sh [--verbose]
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

VERBOSE="${1:-}"

header "Auth Profiles"

# Scan tous les auth-profiles.json et credentials, résultat formaté
python3 -c "
import json, os, sys
from datetime import datetime, timezone

VERBOSE = '$VERBOSE' == '--verbose'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
BOLD = '\033[1m'
NC = '\033[0m'

valid = 0
errors = 0
cooldown = 0

# Chercher les auth-profiles.json dans /root/.openclaw
auth_files = []
for root, dirs, files in os.walk('/root/.openclaw'):
    for f in files:
        if f == 'auth-profiles.json':
            auth_files.append(os.path.join(root, f))

if not auth_files:
    print(f'  {YELLOW}⚠{NC} Aucun fichier auth-profiles.json trouvé dans /root/.openclaw')
else:
    for path in sorted(auth_files):
        # Nom de l'agent — structure : agents/<name>/agent/auth-profiles.json
        parent = os.path.basename(os.path.dirname(path))
        if parent == 'agent':
            agent = os.path.basename(os.path.dirname(os.path.dirname(path)))
        else:
            agent = parent
        print(f'\n{BOLD}Agent: {agent}{NC}')
        try:
            with open(path) as fh:
                data = json.load(fh)
            profiles = data if isinstance(data, list) else [data]
            for p in profiles:
                name = p.get('name', p.get('id', agent))
                stats = p.get('usageStats', {})
                error_count = stats.get('errorCount', 0)
                cooldown_until = stats.get('cooldownUntil', None)
                failure_counts = stats.get('failureCounts', {})

                issues = []
                if error_count > 0:
                    issues.append(f'errorCount={error_count}')
                if cooldown_until:
                    try:
                        cd = datetime.fromisoformat(str(cooldown_until).replace('Z', '+00:00'))
                        if cd > datetime.now(timezone.utc):
                            issues.append(f'cooldown jusqu\\'à {cooldown_until}')
                            cooldown += 1
                        else:
                            issues.append(f'cooldown expiré ({cooldown_until})')
                    except:
                        issues.append(f'cooldown={cooldown_until}')
                if failure_counts and isinstance(failure_counts, dict):
                    total = sum(failure_counts.values())
                    if total > 0:
                        issues.append(f'failures={total}')

                if issues:
                    print(f'  {RED}✗{NC} {name} — {\"  \".join(issues)}')
                    errors += 1
                else:
                    print(f'  {GREEN}✓{NC} {name}')
                    valid += 1

                if VERBOSE:
                    print(json.dumps(p, indent=2, default=str))
        except Exception as e:
            print(f'  {RED}✗{NC} Erreur de parsing: {e}')
            errors += 1

# Vérifier credentials Claude Code
print(f'\n{BOLD}{chr(0x1b)}[0;34m=== Credentials Claude Code ==={NC}')

creds_file = '/root/.claude/.credentials.json'
if os.path.exists(creds_file):
    try:
        with open(creds_file) as fh:
            data = json.load(fh)
        # Chercher expiresAt dans différentes structures possibles
        expires = data.get('expiresAt')
        if not expires and isinstance(data.get('claudeAiOauth'), dict):
            expires = data['claudeAiOauth'].get('expiresAt')
        if expires:
            exp = datetime.fromisoformat(str(expires).replace('Z', '+00:00'))
            now = datetime.now(timezone.utc)
            if exp > now:
                hours = (exp - now).total_seconds() / 3600
                print(f'  {GREEN}✓{NC} Token valide (expire dans {hours:.1f}h)')
                valid += 1
            else:
                print(f'  {RED}✗{NC} Token expiré depuis {expires}')
                errors += 1
        else:
            print(f'  {YELLOW}⚠{NC} Champ expiresAt non trouvé')
    except Exception as e:
        print(f'  {RED}✗{NC} Erreur: {e}')
        errors += 1
else:
    print(f'  {YELLOW}⚠{NC} Fichier {creds_file} non trouvé')

# Résumé
print(f'\n{BOLD}{chr(0x1b)}[0;34m=== Résumé ==={NC}')
print(f'  {GREEN}{valid} valide(s){NC} | {RED}{errors} erreur(s){NC} | {YELLOW}{cooldown} en cooldown{NC}')

if errors > 0 or cooldown > 0:
    print(f'\n  {YELLOW}⚠{NC} Problèmes détectés — exécuter vps-auth-refresh.sh pour rafraîchir les tokens')
    sys.exit(1)
"
