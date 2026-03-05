#!/bin/bash
# Envoie un message Telegram via le bot default d'OpenClaw
# Usage: ./tg-send.sh "Message texte" [--html]
set -euo pipefail

MESSAGE="${1:?Usage: tg-send.sh \"message\" [--html]}"
PARSE_MODE="${2:---markdown}"

# Récupérer token + chat_id depuis openclaw.json
CONFIG="/root/.openclaw/openclaw.json"
BOT_TOKEN=$(python3 -c "
import json
with open('$CONFIG') as f:
    d = json.load(f)
print(d['channels']['telegram']['accounts']['default']['botToken'])
")
CHAT_ID=$(python3 -c "
import json
with open('$CONFIG') as f:
    d = json.load(f)
print(d['channels']['telegram']['allowFrom'][0])
")

if [ "$PARSE_MODE" = "--html" ]; then
  MODE="HTML"
else
  MODE="Markdown"
fi

curl -sf -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d chat_id="$CHAT_ID" \
  -d parse_mode="$MODE" \
  -d text="$MESSAGE" > /dev/null
