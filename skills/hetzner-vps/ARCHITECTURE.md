# Architecture VPS Hetzner — Référence complète

## 1. Infrastructure

### Serveur

| Spec | Value |
|------|-------|
| Provider | Hetzner Cloud |
| Server name | `openclaw-prod` |
| Type | CX53 (shared x86) |
| Location | Helsinki (hel1), Finland |
| IPv4 | `204.168.138.162` |
| IPv6 | `2a01:4f9:c014:b6c7::1` |
| vCPU | 16 |
| RAM | 32 GB |
| Disk | 320 GB SSD (local) |
| Traffic | 20 TiB/mois inclus |
| OS | Ubuntu 24.04 LTS (kernel 6.8) |
| Cost | ~€17/mois |
| Swap | 4 GB |

### Domain & DNS

| Item | Value |
|------|-------|
| Domain | `shipmate.bot` |
| DNS Provider | Cloudflare (zone active) |
| Zone ID | `27eda5886a0d3ae8be4a7582db386073` |
| Monitoring subdomain | `*.ops.shipmate.bot` |
| Cloudflare plan | Free |
| SSL mode | Full (Strict) |
| Registrar | Porkbun (nameservers → iris.ns.cloudflare.com, jihoon.ns.cloudflare.com) |
| Cloudflare Account ID | `d6c467db4e386d6abcd9ccdb39b5fff6` |
| CF API Token (DNS Edit) | In `/opt/docker/traefik/.env` as `CF_DNS_API_TOKEN` |
| ACME Email | `florian.seran@gmail.com` |
| Wildcard DNS | `*.ops.shipmate.bot` → A → `204.168.138.162` (DNS only, not proxied) |

---

## 2. Directory Structure

```
/opt/docker/                          # Root — all Docker stacks
├── Makefile                          # Global operations
├── .env.shared                       # Shared vars (DOMAIN, etc.)
│
├── traefik/                          # ── Reverse Proxy ──
│   ├── compose.yml
│   ├── traefik.yml                   # Static config
│   ├── config/
│   │   └── middlewares.yml           # Rate-limit, auth, headers
│   ├── acme.json                     # Let's Encrypt certs (chmod 600)
│   └── .env                          # CF_DNS_API_TOKEN, ACME_EMAIL
│
├── monitoring/                       # ── Observability ──
│   ├── compose.yml                   # Beszel, Uptime Kuma, Dozzle, Grafana, Loki, ntfy
│   ├── .env                          # GRAFANA_USER, GRAFANA_PASSWORD
│   ├── prometheus/
│   │   └── prometheus.yml
│   ├── grafana/
│   │   └── provisioning/
│   │       ├── datasources/
│   │       └── dashboards/
│   └── loki/
│       └── loki-config.yaml
│
├── openclaw/                         # ── Main Application ──
│   ├── compose.yml                   # Gateway + CLI + oc-ops sidecar
│   ├── .env                          # All OpenClaw secrets
│   ├── patches/                      # Runtime patches (apply-patch.sh)
│   └── Dockerfile.clawpro            # Custom build
│
├── services/                         # ── Auxiliary Services ──
│   ├── browser/
│   │   └── compose.yml               # openclaw-sandbox-browser
│   ├── clawmetry/
│   │   └── compose.yml               # Clawmetry metrics
│   └── keychains-proxy/              # Self-hosted credential proxy (Next.js 15)
│       ├── app/                      # API routes (/api/proxy, /api/health)
│       ├── lib/                      # config, cors, forward, placeholder
│       ├── .env                      # KEYCHAINS_API_URL
│       └── package.json
│
├── security/                         # ── Security ──
│   └── compose.yml                   # CrowdSec + wollomatic/socket-proxy
│
└── scripts/                          # ── Operations ──
    ├── auto-update.sh                # Cron 21h: git pull + build + restart + Telegram notif + dirty guard
    └── sync-clawmetry-sessions.sh    # Cron */5min: symlinks all agent sessions for ClawMetry
```

---

## 3. Docker Architecture

### daemon.json (`/etc/docker/daemon.json`)

```json
{
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5",
    "compress": "true"
  },
  "default-ulimits": {
    "nofile": { "Name": "nofile", "Hard": 65536, "Soft": 65536 }
  }
}
```

Key settings:
- `live-restore`: Containers survive Docker daemon restart
- `no-new-privileges`: Prevent privilege escalation in all containers
- `log-opts`: Automatic rotation — max 50 MB per container (5 × 10 MB)

### Network Isolation

```
┌─────────────────────────────────────────────────┐
│                                                   │
│  traefik-public (external)                       │
│  ├── traefik                                     │
│  ├── grafana                                     │
│  ├── beszel                                      │
│  ├── uptime-kuma                                 │
│  ├── dozzle                                      │
│  ├── ntfy                                        │
│  ├── clawmetry                                   │
│  └── openclaw-gateway                            │
│                                                   │
│  openclaw-internal                               │
│  ├── openclaw-gateway                            │
│  ├── openclaw-cli                                │
│  └── oc-ops (sidecar)                            │
│                                                   │
│  monitoring-internal                             │
│  ├── prometheus                                  │
│  ├── loki                                        │
│  ├── promtail                                    │
│  └── grafana                                     │
│                                                   │
│  socket-proxy-net                                │
│  ├── oc-ops                                      │
│  └── wollomatic/socket-proxy                     │
│                                                   │
│  security-internal                               │
│  ├── crowdsec                                    │
│  └── crowdsec-bouncer                            │
│                                                   │
└─────────────────────────────────────────────────┘
```

Rule: **Only Traefik exposes ports 80/443.** All other services communicate via internal Docker networks. No service publishes ports directly on the host (except Xray on 443 for VLESS).

### Container Standards

Every container must have:
- `restart: unless-stopped`
- `deploy.resources.limits` (CPU + memory)
- `healthcheck` with `start_period`
- `no-new-privileges: true`
- Explicit network assignment

---

## 4. Reverse Proxy — Traefik v3

### How It Works

Traefik auto-discovers Docker services via labels. When a container starts with `traefik.enable=true`, Traefik automatically routes traffic to it based on the configured hostname. No manual config needed.

### Key Config

- **Image**: `traefik:v3.6` (v3.6+ required for Docker 29 API compatibility)
- **Docker**: v29.3.0 (API v1.54) — Traefik <3.6.1 incompatible (hardcoded API v1.24)
- **Discovery**: Docker provider with `exposedByDefault: false`
- **TLS**: Let's Encrypt via Cloudflare DNS challenge (wildcard `*.ops.shipmate.bot`)
- **Entrypoints**: HTTP (80, redirects to HTTPS) + HTTPS (443)
- **Middlewares**: Secure headers, rate limiting (defined in `config/middlewares.yml`)
- **Ping**: Enabled (required for Docker healthcheck)
- **Config files**: `traefik.yml` (static), `config/` dir (dynamic, watched)

### Docker Socket Access

Currently Traefik mounts `/var/run/docker.sock:ro` directly. TODO: migrate to `wollomatic/socket-proxy` with read-only access for better security.

### Adding a New Service

Just add Traefik labels to any container:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myservice.rule=Host(`myservice.ops.shipmate.bot`)"
  - "traefik.http.routers.myservice.entrypoints=websecure"
  - "traefik.http.routers.myservice.tls.certresolver=cloudflare"
  - "traefik.http.services.myservice.loadbalancer.server.port=8080"
```

See `references/traefik-labels.md` for more patterns.

---

## 5. Monitoring Stack (~210 MB RAM deployed)

| Service | Image | Port | URL | Status |
|---------|-------|------|-----|--------|
| Beszel hub | `henrygd/beszel:latest` | 8090 | `beszel.ops.shipmate.bot` | ✅ Running |
| Beszel agent | `henrygd/beszel-agent:latest` | 45876 | — | ✅ Running |
| Uptime Kuma | `louislam/uptime-kuma:2` | 3001 | `status.ops.shipmate.bot` | ✅ v2.2.1 |
| Dozzle | `amir20/dozzle:latest` | 8080 | `logs.ops.shipmate.bot` | ✅ Running |
| ntfy | `binwiederhier/ntfy:latest` | 80 | `ntfy.ops.shipmate.bot` | ✅ Running |
| Clawmetry | `python:3.11-slim` + clawmetry | 8900 | `clawmetry.ops.shipmate.bot` | ✅ v0.12.47 |
| Grafana + Loki | — | — | — | ⏳ Not yet deployed |

### Host-level Services (systemd, not Docker)

| Service | Binary | Port | URL | Status |
|---------|--------|------|-----|--------|
| Oktsec | `/usr/local/bin/oktsec` v0.9.1 (Go) | 8082 (dashboard), 9090 (MCP gateway) | `oktsec.ops.shipmate.bot` | ✅ Running |
| PinchTab | `/usr/local/bin/pinchtab` v0.8.2 (Go) | 9867 | `pinchtab.ops.shipmate.bot` | ✅ Running |
| Keychains Proxy | Next.js 15 (Node.js) | 3100 | `keychains.ops.shipmate.bot` | ✅ Running |
| ClawBridge | Node.js (v1.2.0) | 3200 | `bridge.ops.shipmate.bot` | ✅ Running |

### Docker Services (Session 2)

| Service | Image | Port | URL | Status |
|---------|-------|------|-----|--------|
| Mission Control | `mission-control` (built locally, Next.js 16) | 3000 | `mc.ops.shipmate.bot` | ✅ v2.0.0 |

### Mission Control — Setup Notes

MC connects to the OpenClaw gateway via WebSocket (browser → `wss://gateway.ops.shipmate.bot`).

**Critical config:**
- `openclaw.json` → `gateway.controlUi.allowedOrigins` MUST include `https://mc.ops.shipmate.bot`
- `openclaw.json` permissions MUST be `644` (MC container runs as uid 1001 `nextjs`)
- `/root/.openclaw/agents/` permissions MUST be `o+rX` recursively (for "Sync Local" to find agents)
- Gateway settings stored in SQLite `gateways` table (host, port, token) — UI changes update DB, not env vars
- `.env` must have: `OPENCLAW_STATE_DIR=/run/openclaw`, `OPENCLAW_CONFIG_PATH=/run/openclaw/openclaw.json`
- Compose: `/root/.openclaw:/run/openclaw:ro` volume mount, `traefik-public` network, labels use map syntax (not list) to avoid backtick escaping issues
- Traefik labels for multi-service containers MUST include explicit `traefik.http.routers.X.service=X` binding

### Mengram v2.20.0

Installed on host via `pip3 install --break-system-packages mengram-ai`. Requires interactive `mengram setup` (email registration). Not yet configured.

These services run as systemd units on the host, routed through Traefik via `host.docker.internal` (extra_hosts in Traefik compose). UFW rules allow Docker-internal traffic (172.16.0.0/12) to ports 8082, 9867, 3100.

### Security Skills (inside OpenClaw container)

| Skill | Version | Purpose |
|-------|---------|---------|
| clawsec-suite | v0.1.4 | Advisory feed + guarded skill installer + signature verification |
| soul-guardian | v0.0.2 | Drift detection + baseline integrity for SOUL.md, AGENTS.md, IDENTITY.md |
| openclaw-audit-watchdog | v0.1.1 | Automated daily security audits with email reporting |

### Beszel Agent Config

The agent runs on the `monitoring` Docker network (not `network_mode: host`) with `/:/rootfs:ro` mounted for filesystem metrics. The hub connects to it via Docker DNS name `beszel-agent`.

### Uptime Kuma Alerting

- **Version**: 2.2.1 (major upgrade from v1)
- **Notifications**: Telegram (bot token `8569104613:...`, chat ID `1127788632`)
- **Monitors**: HTTP checks on all `*.ops.shipmate.bot` URLs + OpenClaw gateway healthz

### ntfy

Self-hosted push notification server. iOS/Android app available.
- Base URL: `https://ntfy.ops.shipmate.bot`
- Upstream: `https://ntfy.sh` (for iOS push relay)
- Usage: `curl -d "message" https://ntfy.ops.shipmate.bot/alerts`
- Currently used as optional secondary channel — Telegram is primary for alerting

### External Heartbeat

Healthchecks.io (SaaS free tier, 20 checks) monitors OpenClaw agent heartbeats from outside the VPS. If the VPS is completely down, this is the only alert that fires. TODO: configure.

---

## 6. Security — 4 Layers

### Layer 1: Hetzner Cloud Firewall (network level)

Applied at the Hetzner infrastructure level, before packets reach the VPS.

| Rule | Protocol | Port | Source |
|------|----------|------|--------|
| SSH | TCP | 22 | 0.0.0.0/0 |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| HTTPS | TCP | 443 | 0.0.0.0/0 |
| Mosh | UDP | 60000-61000 | 0.0.0.0/0 |
| All outbound | * | * | — |

### Layer 2: UFW + DOCKER-USER (host level)

UFW is configured but Docker bypasses it via the FORWARD chain. The `DOCKER-USER` iptables chain provides the real filtering for Docker-published ports.

### Layer 3: CrowdSec (application level)

- Image: `crowdsecurity/crowdsec:latest`
- Proactive IDS/IPS with collective intelligence (~1M IPs/day)
- Collections: `linux`, `sshd`, `traefik`, `http-cve`, `base-http-scenarios`, `whitelist-good-actors`
- Reads `/var/log` from host (read-only)
- LAPI exposed on `127.0.0.1:8080` (for firewall bouncer)
- **Traefik bouncer**: `fbonalair/traefik-crowdsec-bouncer` — forward-auth middleware, checks every HTTP request
- **Firewall bouncer**: `crowdsec-firewall-bouncer-nftables` (host) — blocks IPs at nftables level

### Layer 3b: Docker Socket Proxy

- Image: `wollomatic/socket-proxy:1`
- Runs as `user: "0:988"` (Docker GID)
- Allows: GET containers/images, POST images/create + containers start/stop/restart, DELETE containers
- Blocks: exec, build, volumes, privileged
- Network: `security` (isolated)

### Layer 4: Tailscale (admin access)

- Tailscale IP: `100.77.103.17`
- Hostname: `openclaw-prod`
- All admin interfaces accessible via `*.ops.shipmate.bot` (public, no Cloudflare Access yet)
- Tailscale provides secondary secure access for SSH and direct service access
- Also used for VPS-to-VPS rsync during migration (faster than public IP)

### SSH Config

- Key-only authentication (ed25519)
- `PermitRootLogin prohibit-password`
- `MaxAuthTries 3`
- Strong ciphers: chacha20-poly1305, aes256-gcm
- Mosh enabled (UDP 60000-61000) for low-latency from Bangkok

### Docker Socket Security

The Docker socket is NEVER mounted directly in application containers.

```
openclaw-gateway → oc-ops (sidecar) → wollomatic/socket-proxy → docker.sock
                   (REST API)         (regex whitelist)
```

wollomatic allows only:
- GET: `/_ping`, `/containers/json`, `/containers/{id}/json`, `/images/json`
- POST: `/images/create` (pull), `/containers/{id}/(start|stop|restart)`, `/containers/create`
- DELETE: `/containers/{id}` (remove old)
- BLOCKED: `exec`, `build`, `volumes`, `privileged`

---

## 7. Self-Update — Sidecar Operator (oc-ops)

### The Problem

A container cannot safely restart itself — the process dies before the new container is created (race condition).

### The Solution

`oc-ops` is a lightweight sidecar that survives during updates:

```
Agent POST /self-update → oc-ops pulls new image → oc-ops recreates gateway
                          (sidecar stays alive)     → new gateway starts
                                                    → healthcheck passes
                                                    → done
```

### API Endpoints

| Method | Endpoint | Action |
|--------|----------|--------|
| POST | `/self-update` | Pull + recreate openclaw-gateway |
| POST | `/containers/{name}/start` | Start a named container |
| POST | `/containers/{name}/stop` | Stop a named container |
| POST | `/containers/{name}/restart` | Restart a named container |
| POST | `/rebuild` | Build from Dockerfile + recreate |
| GET | `/containers` | List all containers + status |
| GET | `/health` | Sidecar health |

Auth: `X-Ops-Token` header required on all endpoints.
Token in `/opt/docker/openclaw/.env` as `OPS_TOKEN`.

### Usage

```bash
TOKEN=$(grep OPS_TOKEN /opt/docker/openclaw/.env | cut -d= -f2)

# Health
curl -H "X-Ops-Token: $TOKEN" http://127.0.0.1:8400/health

# List containers
curl -H "X-Ops-Token: $TOKEN" http://127.0.0.1:8400/containers

# Restart a container
curl -X POST -H "X-Ops-Token: $TOKEN" http://127.0.0.1:8400/containers/openclaw-gateway/restart

# Self-update (pull + recreate gateway)
curl -X POST -H "X-Ops-Token: $TOKEN" http://127.0.0.1:8400/self-update
```

---

## 8. Backup — Restic → Hetzner Storage Box

### What Gets Backed Up

| Data | Path | Method |
|------|------|--------|
| OpenClaw config + agents | `/root/.openclaw/` | Restic |
| Compose files + configs | `/opt/docker/` | Restic |
| Projects | `/root/projects/` | Restic |
| Docker volumes | Named volumes via tar | Restic |
| PostgreSQL (if any) | `pg_dump` before backup | Restic |

### Retention Policy

- 7 daily snapshots
- 4 weekly snapshots
- 3 monthly snapshots

### Schedule

- Cron: daily at 04:00 UTC
- Integrity check: weekly (Sundays)
- Restore test: monthly (manual)

### Storage

- Primary: Hetzner Storage Box (SFTP, same region)
- Secondary: Backblaze B2 (geo-redundant, ~$0.006/GB/month)

See `scripts/backup.sh` for the complete script.

---

## 9. Cloudflare Access (Zero Trust)

All `*.ops.shipmate.bot` URLs are protected by Cloudflare Access:

- Auth method: Email OTP (or Google SSO)
- Session duration: 7 days
- No VPN required — works from any device (iPhone, Mac, etc.)

Flow: User visits `grafana.ops.shipmate.bot` → Cloudflare Access login page → Email OTP → Redirected to Grafana with session cookie.

See `references/cloudflare-access.md` for setup instructions.

---

## 10. Services

### OpenClaw Gateway

The main application — AI agent platform with 5 Telegram bots.

| Bot | Handle |
|-----|--------|
| Clawd (personal) | @flosrn_ClawdBot |
| English Teacher | @FloEnglishProf_bot |
| Gapibot (Gapila) | @GapibotGapila_bot |
| Shipmate | @Shipmatethebot |

### Sandbox Browser

Headless Chromium in a Docker container for agent web browsing.
- Image: `openclaw-sandbox-browser:bookworm-slim`
- Ports: 6080 (noVNC), 9222 (CDP)
- Memory limit: 1 GB

### Clawmetry

Agent session metrics dashboard (v0.12.47).
- Image: `python:3.11-slim` + pip install clawmetry
- Compose: `/opt/docker/services/clawmetry/compose.yml`
- URL: `clawmetry.ops.shipmate.bot` (via Traefik)
- Auth: gateway token required (auto-detected from `~/.openclaw/openclaw.json`)
- Critical env: `HOME=/home/node` (sinon ClawMetry ne trouve pas `openclaw.json`)
- Auto-detect: workspace, sessions, gateway token — ne pas forcer `--sessions-dir`
- Fleet DB: `/home/node/.openclaw/workspace/.clawmetry-fleet.db`
- Volume: `/root/.openclaw:/home/node/.openclaw` (read-write, pas :ro)

### Xray VLESS Reality

Proxy for censorship circumvention.
- Protocol: VLESS + Reality (xtls-rprx-vision)
- **Port: 8443** on public IP (443 is used by Traefik)
- Second inbound: VLESS-WS on `127.0.0.1:20443`
- Camouflage: `www.apple.com:443`
- Config: `/usr/local/etc/xray/config.json`
- `listen`: `204.168.138.162`
- Client UUID: `6d7aa342-a586-437f-a4b9-b0ef845c96fb`
- **Client config**: address `204.168.138.162`, port `8443`

---

## 11. Installed Software (host)

| Software | Version | Purpose |
|----------|---------|---------|
| Docker | 29.3.0 (API v1.54) | Container runtime |
| Node.js | 22.22.1 (via nodesource) | Required by Oktsec MCP, Clawsec, Keychains |
| Chromium | latest (apt) | Required by PinchTab browser automation |
| Oktsec | 0.9.1 (Go binary) | AI agent runtime security — systemd `oktsec.service` |
| PinchTab | 0.8.2 (Go binary) | Browser automation bridge — systemd `pinchtab.service` |
| Keychains CLI | 0.2.0 (npm global) | Credential delegation CLI |
| Xray | 26.2.6 | VLESS Reality proxy |
| gh | 2.88.1 | GitHub CLI |
| Mosh | 1.4.0 | Low-latency SSH (UDP) |
| Tailscale | latest | VPN mesh |
| fail2ban | latest | SSH brute-force protection |
| UFW | latest | Firewall (+ DOCKER-USER) |
| unattended-upgrades | latest | Auto security patches |

## 12. Migration Status

| Item | Status |
|------|--------|
| Old VPS | RackNerd `192.210.136.198` — still running |
| New VPS | Hetzner `204.168.138.162` (Helsinki) |
| Phase 1 (create VPS) | ✅ Done |
| Phase 2 (architecture) | ✅ Done — SSH, Docker 29.3, UFW, Traefik v3.6, monitoring, CrowdSec, Tailscale |
| Phase 3 (migrate data) | ✅ Done — .openclaw (5.9 GB), projects, configs, Docker images (openclaw:local + browser) |
| Phase 4 (cutover) | ✅ Done — bots responding on all 4 Telegram channels |

### Data transferred

| Data | Size | Destination |
|------|------|-------------|
| `.openclaw/` | 5.9 GB | `/root/.openclaw/` |
| OpenClaw build context | 452 MB | `/opt/docker/openclaw/` |
| Projects | 1.7 GB | `/root/projects/` |
| Gapila | 283 MB | `/root/gapila/` |
| Lasdelaroute | 44 MB | `/root/lasdelaroute/` |
| `.claude/` | 187 MB | `/root/.claude/` |
| Config files (gh, gitconfig, xray, cloudflared) | ~2 MB | Various |
| Docker image `openclaw:local` | 8.47 GB | Docker |
| Docker image `openclaw-sandbox-browser` | 1.47 GB | Docker |

### Cutover completed

- [x] Stop old VPS gateway
- [x] Final delta rsync `.openclaw/` (21 MB delta, speedup 258x)
- [x] Fix Xray config IP → `204.168.138.162:8443`
- [x] Fix compose patches path → `/opt/docker/openclaw/patches`
- [x] Start OpenClaw gateway — healthy
- [x] Start Xray on port 8443
- [x] Test Telegram bots — all 4 responding (Clawd, English, Gapibot, Shipmate)
- [x] ClawRouter ready, wallet loaded

### Post-migration TODO

- [x] Update `~/.ssh/config` alias `vps` → `204.168.138.162` (old = `vps-old`)
- [ ] Update VLESS clients (iPhone/Mac) → address `204.168.138.162`, port `8443`
- [ ] Set up Cloudflare Access (Zero Trust) on `*.ops.shipmate.bot`
- [x] Deploy browser container (`openclaw-browser`, ports 6080/9222)
- [x] Deploy clawmetry container (port 8900)
- [x] Set up crontab (`auto-update.sh` at 21:00 daily)
- [ ] Set up Restic backups → Hetzner Storage Box (Restic v0.16.4 installé, pas de Storage Box commandé)
- [x] Configure Hetzner Cloud Firewall `openclaw-fw` (SSH, HTTP, HTTPS, 8443, Mosh)
- [x] Enable Xray + cloudflared at boot
- [ ] Keep old VPS (RackNerd) 48h as backup, then cancel

### Improvement Roadmap

**P0 — Sécurité + Fiabilité :**
1. [ ] Cloudflare Access — nécessite Cloudflare Tunnel (proxy orange casse les certs Traefik). Application créée mais pas fonctionnelle. Dashboards protégés par login natif (Beszel, Kuma) en attendant. Dozzle est exposé sans auth.
2. [ ] Restic backups → Hetzner Storage Box — Restic installé, Storage Box pas encore commandé, script backup.sh à écrire
3. [x] Nettoyer docker-compose OpenClaw — resource limits, security_opt, networks, Traefik labels, paths relatifs

**P1 — Architecture :**
4. [x] Sidecar `oc-ops` — Python REST API (port 8400, localhost only), auth via X-Ops-Token, parle au socket-proxy
5. [x] Makefile `/opt/docker/Makefile` — `make up`, `make down`, `make ps`, `make health`, `make logs-*`, `make backup`, `make prune`
6. [x] Browser + Clawmetry en compose (`/opt/docker/services/browser/compose.yml` + `/opt/docker/services/clawmetry/compose.yml`)
7. [x] Traefik labels sur clawmetry → `clawmetry.ops.shipmate.bot` (HTTP 200)
8. [x] CrowdSec bouncers — Traefik bouncer (`fbonalair/traefik-crowdsec-bouncer`, forward-auth) + firewall bouncer (nftables, host)
9. [x] Oktsec v0.9.1 — Agent runtime security (188 rules, observe mode), MCP gateway, systemd service, Traefik routing
10. [x] PinchTab v0.8.2 — Browser automation bridge (accessibility-first), systemd service, Traefik routing
11. [x] Keychains Satellite Proxy v0.1.0 — Self-hosted credential delegation proxy (Next.js 15), systemd, Traefik routing
12. [x] Clawsec Suite v0.1.4 + soul-guardian v0.0.2 + openclaw-audit-watchdog v0.1.1 — inside OpenClaw container
13. [x] Node.js 22 + Chromium installés sur l'host (requis par Oktsec MCP, Clawsec, PinchTab)
14. [x] Traefik `extra_hosts: host.docker.internal:host-gateway` + `config/host-services.yml` pour services systemd

**P2 — Polish :**
15. [ ] Grafana + Loki — logs persistants avec alertes sur patterns
16. [x] Vérifier auto-update.sh avec les nouveaux paths (`/opt/docker/scripts/auto-update.sh`, crontab 21:00)
17. [ ] Migrer volume clawmetry-data depuis l'ancien VPS
18. [x] Hetzner Cloud Firewall — ajouté règle Tailscale WireGuard (41641/udp)
19. [ ] Keychains.dev — créer compte, `keychains machine register`, `keychains proxy set`
20. [ ] Oktsec — passer en enforce mode après validation des règles
21. [ ] Soul Guardian — configurer cron/hook pour checks réguliers
22. [ ] Uptime Kuma — ajouter monitors pour oktsec, pinchtab, keychains

### Fixes applied (16 mars 2026)

- **Gateway healthcheck**: Node.js v22.22 avec TypeScript strip mode cassait `fetch(http://...)` → ajouté quotes `fetch('http://...')`
- **Cloudflared**: binaire manquant sur le nouveau VPS → installé v2026.3.0 (quick tunnel, pas named tunnel)
- **auto-update.sh**: `COMPOSE_DIR` et `.env` path pointaient vers `/root/openclaw/` → corrigé vers `/opt/docker/openclaw/`
- **`.env.shared`**: créé avec `DOMAIN`, `VPS_IP`, `TAILSCALE_IP`
- **ClawMetry**: volume monté en `:ro` empêchait l'écriture des métriques → retiré `:ro`. `HOME=/root` empêchait auto-detect de `openclaw.json` → ajouté `HOME=/home/node`. Ne pas forcer `--sessions-dir` — laisser l'auto-detect. Sessions multi-agents via `/root/.openclaw/all-sessions/` (symlinks relatifs, cron sync */5min)
- **Socket-proxy regex**: POST trop restrictive (`/containers` au lieu de `/containers/.+/(start|stop|restart)`) → corrigée pour permettre oc-ops
- **SSH key Hetzner**: supprimée par accident dans la console → recréée (`flo-mac`, id 109190390)
- **repos-status.sh**: créé dans `/root/.openclaw/bin/` + bind mount `/home/node/bin:ro` dans le gateway. Auto-détecte host vs container. Wildcard `safe.directory = *` ajouté au `.gitconfig`
- **auto-update.sh dirty guard**: vérifie les fichiers dirty dans `/opt/docker/openclaw/` (build context) avant `git pull`. Ne vérifie PAS les repos de travail (bind mounts, pas affectés par l'update)
- **Crons nettoyés**: supprimé `apex-bug-page-mes-campagnes` (poll inutile), `openclaw-auto-update` Shipmate (doublon du cron host), `Rappel Grab` (désactivé). 4 crons restants, tous gapibot/main
