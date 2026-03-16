#!/bin/bash
# Restic backup script for Hetzner VPS
# Cron: 0 4 * * * /opt/docker/scripts/backup.sh >> /var/log/backup.log 2>&1
set -euo pipefail

# ── Config (sourced from env or defaults) ──
export RESTIC_REPOSITORY="${RESTIC_REPOSITORY:-sftp:restic@uXXXXX.your-storagebox.de:/backups}"
export RESTIC_PASSWORD_FILE="${RESTIC_PASSWORD_FILE:-/root/.restic-password}"

LOG_FILE="/var/log/backup.log"
NTFY_URL="${NTFY_URL:-http://localhost:8091/backup}"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
notify() { curl -sf -d "$1" "$NTFY_URL" > /dev/null 2>&1 || true; }

log "=== Backup started ==="

# ── Pre-backup: dump databases ──
DUMP_DIR="/tmp/db-dumps"
mkdir -p "$DUMP_DIR"

# PostgreSQL (if running)
if docker ps --format '{{.Names}}' | grep -q postgres; then
  log "Dumping PostgreSQL..."
  docker exec postgres pg_dumpall -U postgres | gzip > "$DUMP_DIR/postgres-$(date +%Y%m%d).sql.gz"
fi

# Docker volumes (named)
log "Backing up Docker volumes..."
for vol in $(docker volume ls -q); do
  docker run --rm -v "$vol":/data:ro -v "$DUMP_DIR":/backup alpine \
    tar czf "/backup/vol-${vol}-$(date +%Y%m%d).tar.gz" -C /data . 2>/dev/null || true
done

# ── Restic backup ──
log "Running restic backup..."
restic backup \
  /opt/docker \
  /root/.openclaw \
  /root/projects \
  "$DUMP_DIR" \
  --exclude="**/node_modules" \
  --exclude="**/.next" \
  --exclude="**/.turbo" \
  --exclude="**/.git" \
  --exclude="**/dist" \
  --tag "daily" \
  --verbose

# ── Retention ──
log "Applying retention policy..."
restic forget \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 3 \
  --prune

# ── Cleanup ──
rm -rf "$DUMP_DIR"

# ── Stats ──
STATS=$(restic stats --mode restore-size --json 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'{d[\"total_size\"]/1024/1024/1024:.1f} GB')" 2>/dev/null || echo "unknown")
log "=== Backup completed — Total: $STATS ==="
notify "Backup completed — $STATS"
