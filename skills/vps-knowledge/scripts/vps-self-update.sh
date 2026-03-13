#!/bin/bash
# OpenClaw Self-Update Trigger
# Designed to be called BY THE AGENT from inside the container.
# Launches a detached helper container via docker socket that runs auto-update.sh.
#
# Usage from Mac:
#   ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-self-update.sh
#
# Usage from inside the container (by the agent):
#   /patches/self-update.sh
#
# The helper container:
#   - Mounts the host's /root/openclaw (source repo + compose + .env)
#   - Runs auto-update.sh (git pull → build → restart → healthcheck → notify)
#   - Survives the gateway container being stopped (it's an independent container)
#   - Uses --network host for healthcheck to reach 127.0.0.1:18789
set -euo pipefail

UPDATER_NAME="openclaw-updater"
IMAGE="openclaw:local"
COMPOSE_DIR="/root/openclaw"

# ── Pre-flight checks ──────────────────────────────────────────

# Check if an update is already running
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${UPDATER_NAME}$"; then
  echo "SKIP: update already in progress (container ${UPDATER_NAME} is running)"
  echo "Check logs: docker logs -f ${UPDATER_NAME}"
  exit 0
fi

# Clean up leftover stopped updater container (if any)
docker rm "${UPDATER_NAME}" 2>/dev/null || true

# Verify auto-update.sh exists on the host by checking if we can access it
# (either we're on the host, or it's bind-mounted)
if [ -f "${COMPOSE_DIR}/auto-update.sh" ]; then
  SCRIPT_PATH="${COMPOSE_DIR}/auto-update.sh"
elif [ -f "/patches/auto-update.sh" ]; then
  # Fallback: might be mounted at /patches inside container
  SCRIPT_PATH="${COMPOSE_DIR}/auto-update.sh"  # Still use host path for the helper
else
  # We're inside the container — the script exists on the host but we can't verify
  # Trust that it's there (it's managed by cron and was confirmed during setup)
  SCRIPT_PATH="${COMPOSE_DIR}/auto-update.sh"
fi

# ── Launch helper container ───────────────────────────────────

echo "Launching self-update helper container..."
echo "  Image: ${IMAGE}"
echo "  Script: ${SCRIPT_PATH}"
echo ""

CONTAINER_ID=$(docker run -d \
  --name "${UPDATER_NAME}" \
  --rm \
  -v "${COMPOSE_DIR}:${COMPOSE_DIR}" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/log:/var/log \
  --network host \
  -w "${COMPOSE_DIR}" \
  "${IMAGE}" \
  bash "${SCRIPT_PATH}")

echo "Helper container started: ${CONTAINER_ID:0:12}"
echo ""
echo "The update will:"
echo "  1. git fetch + pull from origin/main"
echo "  2. docker build (Dockerfile.clawpro) — ~7 min"
echo "  3. stop + restart the gateway (your session will be interrupted)"
echo "  4. healthcheck + Telegram notification"
echo ""
echo "Monitor progress:"
echo "  docker logs -f ${UPDATER_NAME}"
echo ""
echo "If no updates are available, the container will exit immediately."
