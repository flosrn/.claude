#!/bin/bash
# Surveillance des erreurs et warnings dans les logs OpenClaw
# Usage: ssh vps 'bash -s' < vps-monitor.sh [--follow|-f] [--errors|-e] [--agent <id>] [N]
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

header() { echo -e "\n${BOLD}${BLUE}=== $* ===${NC}"; }

# Parsing des arguments
FOLLOW=false
ERRORS_ONLY=false
AGENT=""
LINES=100

while [[ $# -gt 0 ]]; do
  case "$1" in
    --follow|-f) FOLLOW=true; shift ;;
    --errors|-e) ERRORS_ONLY=true; shift ;;
    --agent) AGENT="${2:-}"; shift 2 ;;
    [0-9]*) LINES="$1"; shift ;;
    *) shift ;;
  esac
done

COMPOSE_DIR="/root/openclaw"

# Construire le pattern de filtrage
if [ "$ERRORS_ONLY" = true ]; then
  FILTER_PATTERN="error|Error|ERROR|fatal|Fatal|FATAL|panic|exception|Exception"
else
  FILTER_PATTERN="error|Error|ERROR|warn|Warn|WARN|fatal|Fatal|FATAL|panic|exception|Exception"
fi

# Ajouter filtre agent si spécifié
if [ -n "$AGENT" ]; then
  AGENT_FILTER="$AGENT"
else
  AGENT_FILTER=""
fi

if [ "$FOLLOW" = true ]; then
  header "Surveillance temps réel (Ctrl+C pour arrêter)"
  if [ -n "$AGENT_FILTER" ]; then
    echo -e "  Filtre agent: ${BOLD}${AGENT_FILTER}${NC}"
  fi
  if [ "$ERRORS_ONLY" = true ]; then
    echo -e "  Mode: ${RED}erreurs seulement${NC}"
  else
    echo -e "  Mode: ${YELLOW}erreurs + warnings${NC}"
  fi
  echo ""

  cd "$COMPOSE_DIR"
  if [ -n "$AGENT_FILTER" ]; then
    docker compose logs --follow --no-log-prefix openclaw-gateway 2>/dev/null \
      | grep --line-buffered -iE "$FILTER_PATTERN" \
      | grep --line-buffered -i "$AGENT_FILTER"
  else
    docker compose logs --follow --no-log-prefix openclaw-gateway 2>/dev/null \
      | grep --line-buffered -iE "$FILTER_PATTERN"
  fi
else
  # Mode batch : dernières N lignes
  header "Logs filtrés (dernières $LINES lignes)"

  cd "$COMPOSE_DIR"
  RAW_LOGS=$(docker compose logs --tail "$LINES" --no-log-prefix openclaw-gateway 2>/dev/null || echo "")

  if [ -z "$RAW_LOGS" ]; then
    echo -e "  ${YELLOW}⚠${NC} Aucun log disponible"
    exit 0
  fi

  # Filtrer par agent si demandé
  if [ -n "$AGENT_FILTER" ]; then
    RAW_LOGS=$(echo "$RAW_LOGS" | grep -i "$AGENT_FILTER" || true)
  fi

  # Compter erreurs et warnings
  ERROR_COUNT=$(echo "$RAW_LOGS" | grep -ciE "error|fatal|panic|exception" || true)
  WARN_COUNT=$(echo "$RAW_LOGS" | grep -ciE "warn" || true)
  TOTAL=$(echo "$RAW_LOGS" | wc -l | tr -d ' ')

  echo -e "  ${RED}${ERROR_COUNT} erreur(s)${NC} | ${YELLOW}${WARN_COUNT} warning(s)${NC} sur ${TOTAL} lignes"
  if [ -n "$AGENT_FILTER" ]; then
    echo -e "  Filtre agent: ${BOLD}${AGENT_FILTER}${NC}"
  fi
  echo ""

  # Afficher les lignes filtrées avec coloration
  if [ "$ERRORS_ONLY" = true ]; then
    FILTERED=$(echo "$RAW_LOGS" | grep -iE "error|fatal|panic|exception" || true)
  else
    FILTERED=$(echo "$RAW_LOGS" | grep -iE "$FILTER_PATTERN" || true)
  fi

  if [ -z "$FILTERED" ]; then
    echo -e "  ${GREEN}✓${NC} Aucune erreur/warning trouvée"
  else
    # Coloriser les erreurs en rouge et les warnings en jaune
    echo "$FILTERED" | sed \
      -e "s/\(.*[Ee][Rr][Rr][Oo][Rr].*\)/$(printf '\033[0;31m')\\1$(printf '\033[0m')/" \
      -e "s/\(.*[Ff][Aa][Tt][Aa][Ll].*\)/$(printf '\033[0;31m')\\1$(printf '\033[0m')/" \
      -e "s/\(.*[Ww][Aa][Rr][Nn].*\)/$(printf '\033[1;33m')\\1$(printf '\033[0m')/"
  fi
fi
