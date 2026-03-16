#!/bin/bash
# Health check script — verify all services are running
# Usage: /opt/docker/scripts/health-check.sh [--notify]
set -euo pipefail

NTFY_URL="${NTFY_URL:-http://localhost:8091/health}"
NOTIFY="${1:-}"
ERRORS=()

check() {
  local name="$1" cmd="$2"
  if eval "$cmd" > /dev/null 2>&1; then
    echo "  ✅ $name"
  else
    echo "  ❌ $name"
    ERRORS+=("$name")
  fi
}

echo "=== Health Check $(date '+%Y-%m-%d %H:%M:%S') ==="

echo ""
echo "── Docker Containers ──"
check "openclaw-gateway" "docker inspect --format='{{.State.Health.Status}}' openclaw-openclaw-gateway-1 2>/dev/null | grep -q healthy"
check "openclaw-browser" "docker ps --format='{{.Names}}' | grep -q openclaw-browser"
check "clawmetry" "docker ps --format='{{.Names}}' | grep -q clawmetry"
check "traefik" "docker ps --format='{{.Names}}' | grep -q traefik"
check "beszel" "docker ps --format='{{.Names}}' | grep -q beszel"
check "uptime-kuma" "docker ps --format='{{.Names}}' | grep -q uptime-kuma"
check "dozzle" "docker ps --format='{{.Names}}' | grep -q dozzle"
check "ntfy" "docker ps --format='{{.Names}}' | grep -q ntfy"
check "grafana" "docker ps --format='{{.Names}}' | grep -q grafana"
check "loki" "docker ps --format='{{.Names}}' | grep -q loki"

echo ""
echo "── HTTP Endpoints ──"
check "Gateway /healthz" "curl -sf http://127.0.0.1:18789/healthz"
check "Traefik" "curl -sf http://127.0.0.1:80 -o /dev/null -w '%{http_code}' | grep -q '308\|301\|200'"
check "Grafana" "curl -sf http://127.0.0.1:3000/api/health"
check "Beszel" "curl -sf http://127.0.0.1:8090/"
check "Uptime Kuma" "curl -sf http://127.0.0.1:3001/"

echo ""
echo "── System Services ──"
check "Tailscale" "tailscale status > /dev/null 2>&1"
check "Xray" "systemctl is-active xray > /dev/null 2>&1"
check "CrowdSec" "docker ps --format='{{.Names}}' | grep -q crowdsec"

echo ""
echo "── Resources ──"
DISK_PCT=$(df / --output=pcent | tail -1 | tr -d ' %')
MEM_PCT=$(free | awk '/Mem:/{printf "%.0f", $3/$2*100}')
echo "  Disk: ${DISK_PCT}% used"
echo "  RAM: ${MEM_PCT}% used"
[ "$DISK_PCT" -gt 85 ] && ERRORS+=("Disk > 85%")
[ "$MEM_PCT" -gt 90 ] && ERRORS+=("RAM > 90%")

echo ""
if [ ${#ERRORS[@]} -eq 0 ]; then
  echo "✅ All checks passed"
else
  echo "❌ ${#ERRORS[@]} issue(s): ${ERRORS[*]}"
  if [ "$NOTIFY" = "--notify" ]; then
    curl -sf -H "Priority: high" -H "Tags: warning" \
      -d "Health check failed: ${ERRORS[*]}" "$NTFY_URL" > /dev/null 2>&1 || true
  fi
  exit 1
fi
