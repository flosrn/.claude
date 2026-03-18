# Services — Monitoring, Host, Docker

## Monitoring Stack (~210 MB RAM)

| Service | Image | Port | URL | Status |
|---------|-------|------|-----|--------|
| Beszel hub | `henrygd/beszel:latest` | 8090 | `beszel.ops.shipmate.bot` | ✅ |
| Beszel agent | `henrygd/beszel-agent:latest` | 45876 | — | ✅ |
| Uptime Kuma | `louislam/uptime-kuma:2` | 3001 | `status.ops.shipmate.bot` | ✅ v2.2.1 |
| Dozzle | `amir20/dozzle:latest` | 8080 | `logs.ops.shipmate.bot` | ✅ |
| ntfy | `binwiederhier/ntfy:latest` | 80 | `ntfy.ops.shipmate.bot` | ✅ |
| Clawmetry | `python:3.11-slim` + clawmetry | 8900 | `clawmetry.ops.shipmate.bot` | ✅ v0.12.47 |
| Grafana + Loki | — | — | — | ⏳ Not deployed |

### Beszel Agent

Runs on the `monitoring` Docker network (not `network_mode: host`) with `/:/rootfs:ro` for filesystem metrics. Hub connects via Docker DNS name `beszel-agent`.

### Uptime Kuma Alerting

- Notifications: Telegram (bot token `8569104613:...`, chat ID `1127788632`)
- Monitors: HTTP checks on all `*.ops.shipmate.bot` URLs + OpenClaw gateway healthz

### ntfy

Self-hosted push notifications. iOS/Android app available.
- Base URL: `https://ntfy.ops.shipmate.bot`
- Upstream: `https://ntfy.sh` (for iOS push relay)
- Usage: `curl -d "message" https://ntfy.ops.shipmate.bot/alerts`
- Secondary channel — Telegram is primary for alerting

### External Heartbeat

Healthchecks.io (free tier, 20 checks) for external monitoring when the VPS itself is down. TODO: configure.

---

## Host-Level Services (systemd)

These run as systemd units on the host, routed through Traefik via `host.docker.internal` (extra_hosts in Traefik compose). UFW allows Docker-internal traffic (172.16.0.0/12) to their ports.

| Service | Binary | Port | URL |
|---------|--------|------|-----|
| Oktsec | `/usr/local/bin/oktsec` v0.9.1 (Go) | 8082 (dashboard), 9090 (MCP gateway) | `oktsec.ops.shipmate.bot` |
| PinchTab | `/usr/local/bin/pinchtab` v0.8.2 (Go) | 9867 | `pinchtab.ops.shipmate.bot` |
| Keychains Proxy | Next.js 15 (Node.js) | 3100 | `keychains.ops.shipmate.bot` |
| ClawBridge | Node.js (v1.2.0) | 3200 | `bridge.ops.shipmate.bot` |

### Oktsec

AI agent runtime security (188 rules, observe mode). Access code changes on restart:
```bash
ssh root@204.168.138.162 'journalctl -u oktsec --no-pager -n 30 | grep "Access code"'
```

### ClawBridge v1.2.0

Installed as OpenClaw skill at `/root/.openclaw/workspace/skills/clawbridge/`.

- **Access Key**: in `/root/.openclaw/workspace/skills/clawbridge/.env` as `ACCESS_KEY`
- **Config**: `PORT=3200`, `ENABLE_EMBEDDED_TUNNEL=false` (using Traefik)
- **Data**: reads logs passively — no impact on agent performance
- **Systemd**: `clawbridge.service`, env file at skill `.env`

### Mengram v2.20.0

Installed on host via `pip3 install --break-system-packages mengram-ai`. Requires interactive `mengram setup`. Not yet configured.

---

## Docker Services

### Mission Control v2.0.0

Agent orchestration dashboard (Builderz v2.0, Next.js 16, Docker).
URL: `mc.ops.shipmate.bot` — connects to gateway via WebSocket (`wss://gateway.ops.shipmate.bot`).

**Critical config:**
- `openclaw.json` → `gateway.controlUi.allowedOrigins` MUST include `https://mc.ops.shipmate.bot`
- `openclaw.json` permissions MUST be `644` (MC container runs as uid 1001 `nextjs`)
- `/root/.openclaw/agents/` permissions MUST be `o+rX` recursively (for "Sync Local")
- Gateway settings in SQLite `gateways` table (host, port, token) — UI changes update DB, not env vars
- `.env`: `OPENCLAW_STATE_DIR=/run/openclaw`, `OPENCLAW_CONFIG_PATH=/run/openclaw/openclaw.json`
- Compose: `/root/.openclaw:/run/openclaw:ro` volume mount, `traefik-public` network
- Traefik labels use map syntax (not list) to avoid backtick escaping issues
- Multi-service containers: MUST include explicit `traefik.http.routers.X.service=X` binding

**Known limitations (v2.0 alpha):**
- Only reads session history from main workspace. Other agents' conversations not visible.
- Use Clawmetry or ClawBridge for full multi-agent session history.
- Adding new agent: add volume mount `/root/.openclaw/workspace-NEWAGENT:/mc-home/.agents/NEWAGENT:ro`

### OpenClaw Gateway

AI agent platform with 5 Telegram bots:

| Bot | Handle |
|-----|--------|
| Clawd (personal) | @flosrn_ClawdBot |
| English Teacher | @FloEnglishProf_bot |
| Gapibot (Gapila) | @GapibotGapila_bot |
| Shipmate | @Shipmatethebot |

### Sandbox Browser

Headless Chromium for agent web browsing.
- Image: `openclaw-sandbox-browser:bookworm-slim`
- Ports: 6080 (noVNC), 9222 (CDP)
- Memory limit: 1 GB

### Clawmetry v0.12.47

Agent session metrics dashboard.
- Compose: `/opt/docker/services/clawmetry/compose.yml`
- Auth: gateway token (auto-detected from `~/.openclaw/openclaw.json`)
- Critical env: `HOME=/home/node` (sinon ne trouve pas `openclaw.json`)
- Auto-detect workspace, sessions, gateway token — ne pas forcer `--sessions-dir`
- Fleet DB: `/home/node/.openclaw/workspace/.clawmetry-fleet.db`
- Volume: `/root/.openclaw:/home/node/.openclaw` (read-write, pas :ro)

### Xray VLESS Reality

Proxy for censorship circumvention.
- Protocol: VLESS + Reality (xtls-rprx-vision)
- **Port: 8443** on public IP (443 used by Traefik)
- Second inbound: VLESS-WS on `127.0.0.1:20443`
- Camouflage: `www.apple.com:443`
- Config: `/usr/local/etc/xray/config.json`
- `listen`: `204.168.138.162`
- Client UUID: `6d7aa342-a586-437f-a4b9-b0ef845c96fb`
- **Client config**: address `204.168.138.162`, port `8443`

---

## Security Skills (inside OpenClaw container)

| Skill | Version | Purpose |
|-------|---------|---------|
| clawsec-suite | v0.1.4 | Advisory feed + guarded skill installer + signature verification |
| soul-guardian | v0.0.2 | Drift detection + baseline integrity for SOUL.md, AGENTS.md, IDENTITY.md |
| openclaw-audit-watchdog | v0.1.1 | Automated daily security audits with email reporting |
