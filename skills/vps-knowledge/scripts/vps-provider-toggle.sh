#!/bin/bash
# Toggle le provider d'un agent entre Claude Max et ClawRouter
# Usage: ssh vps 'bash -s -- <agent_id> <claude|blockrun|blockrun-eco|blockrun-premium>' < vps-provider-toggle.sh
set -euo pipefail

AGENT_ID="${1:?Usage: $0 <agent_id> <claude|blockrun|blockrun-eco|blockrun-premium>}"
MODE="${2:?Usage: $0 <agent_id> <claude|blockrun|blockrun-eco|blockrun-premium>}"
CONFIG="/root/.openclaw/openclaw.json"

case "$MODE" in
  claude)            MODEL="anthropic/claude-sonnet-4-6" ;;
  claude-opus)       MODEL="anthropic/claude-opus-4-6" ;;
  blockrun)          MODEL="blockrun/auto" ;;
  blockrun-eco)      MODEL="blockrun/eco" ;;
  blockrun-premium)  MODEL="blockrun/premium" ;;
  blockrun-free)     MODEL="blockrun/free" ;;
  *)                 echo "Mode invalide: $MODE (valides: claude, claude-opus, blockrun, blockrun-eco, blockrun-premium, blockrun-free)"; exit 1 ;;
esac

python3 -c "
import json, sys

with open('$CONFIG') as f:
    cfg = json.load(f)

found = False
for agent in cfg.get('agents', {}).get('list', []):
    if agent['id'] == '$AGENT_ID':
        agent['model'] = '$MODEL'
        found = True
        break

if not found:
    print(f'Agent $AGENT_ID non trouvé', file=sys.stderr)
    sys.exit(1)

with open('$CONFIG', 'w') as f:
    json.dump(cfg, f, indent=2)

print(f'✅ $AGENT_ID → $MODEL')
"

# Restart gateway
cd /root/openclaw
docker compose restart openclaw-gateway

# Healthcheck
for i in $(seq 1 12); do
  if curl -sf http://127.0.0.1:18789/healthz -o /dev/null 2>/dev/null; then
    echo "Gateway OK après ${i}s"
    exit 0
  fi
  sleep 5
done

echo "ERREUR: healthcheck échoué"
exit 1
