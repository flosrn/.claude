#!/usr/bin/env bash
set -euo pipefail

# Toggle sandbox-browser container on the VPS
# Usage: ssh vps 'bash -s' < vps-browser.sh [start|stop|status|logs]

CMD="${1:-status}"
COMPOSE_DIR="/root/openclaw"

case "$CMD" in
  start)
    echo "Starting sandbox-browser..."
    cd "$COMPOSE_DIR"
    docker compose --profile browser up -d sandbox-browser
    # Wait for healthcheck
    for i in $(seq 1 15); do
      if docker compose ps sandbox-browser 2>/dev/null | grep -q "healthy"; then
        echo "sandbox-browser is healthy"
        break
      fi
      sleep 1
    done
    docker compose ps sandbox-browser
    ;;
  stop)
    echo "Stopping sandbox-browser..."
    cd "$COMPOSE_DIR"
    docker compose --profile browser stop sandbox-browser
    echo "sandbox-browser stopped"
    ;;
  restart)
    echo "Restarting sandbox-browser..."
    cd "$COMPOSE_DIR"
    docker compose --profile browser restart sandbox-browser
    echo "sandbox-browser restarted"
    ;;
  status)
    cd "$COMPOSE_DIR"
    if docker compose --profile browser ps sandbox-browser 2>/dev/null | grep -q "Up"; then
      echo "RUNNING"
      docker compose --profile browser ps sandbox-browser
      echo ""
      # Show CDP version
      docker exec openclaw-sandbox-browser-1 curl -sf http://127.0.0.1:9222/json/version 2>/dev/null | python3 -m json.tool 2>/dev/null || true
    else
      echo "STOPPED"
    fi
    ;;
  logs)
    cd "$COMPOSE_DIR"
    docker compose --profile browser logs sandbox-browser --tail="${2:-50}"
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|logs [N]}"
    exit 1
    ;;
esac
