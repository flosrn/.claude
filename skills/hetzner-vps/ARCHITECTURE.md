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
│   └── clawmetry/
│       └── compose.yml               # Clawmetry metrics
│
├── security/                         # ── Security ──
│   └── compose.yml                   # CrowdSec + wollomatic/socket-proxy
│
└── scripts/                          # ── Operations ──
    ├── backup.sh                     # Restic → Hetzner Storage Box
    ├── health-check.sh               # Check all services
    └── update.sh                     # Pull + recreate stacks
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

## 5. Monitoring Stack (~400 MB RAM)

| Service | RAM | Port | Purpose |
|---------|-----|------|---------|
| Beszel hub + agent | ~50 MB | 8090 | System + Docker metrics, alerts, dashboard |
| Uptime Kuma | ~80 MB | 3001 | Uptime HTTP/SSL/Docker, status page, 90+ notification channels |
| Dozzle | ~10 MB | 8080 | Real-time Docker log viewer |
| Grafana | ~100 MB | 3000 | Dashboards, alerting |
| Loki | ~100 MB | 3100 | Log aggregation (indexed by labels only) |
| Promtail | ~30 MB | — | Ships Docker logs → Loki |
| ntfy | ~30 MB | 8091 | Push notifications (iOS/Android apps) |

### Alerting Flow

```
Event → Uptime Kuma/Grafana/Beszel → ntfy → Mobile push notification
                                   → Telegram (backup channel)
```

### External Heartbeat

Healthchecks.io (SaaS free tier, 20 checks) monitors OpenClaw agent heartbeats from outside the VPS. If the VPS is completely down, this is the only alert that fires.

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

- Proactive IDS/IPS with collective intelligence (~1M IPs/day)
- Traefik bouncer blocks malicious IPs at the proxy level
- Firewall bouncer blocks at iptables level
- Collections: `linux`, `sshd`, `traefik`, `http-cve`

### Layer 4: Tailscale (admin access)

All admin interfaces (Grafana, Dozzle, Beszel, Traefik dashboard) are accessible via public URLs protected by Cloudflare Access. Tailscale provides a secondary secure access path for SSH and direct service access.

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

Agent session metrics dashboard.
- Image: `python:3.11-slim` + pip install clawmetry
- Data: `/data/fleet.db` (named volume)

### Xray VLESS Reality

Proxy for censorship circumvention.
- Protocol: VLESS + Reality (xtls-rprx-vision)
- Port: 443 on public IP (bind directly, not through Traefik)
- Camouflage: `www.apple.com:443`
- Config: `/usr/local/etc/xray/config.json`
- **IMPORTANT**: `listen` field must match the VPS public IP

---

## 11. Migration Status

| Item | Status |
|------|--------|
| Old VPS | RackNerd `192.210.136.198` — still running |
| New VPS | Hetzner `204.168.138.162` — provisioned |
| Phase 1 (create VPS) | ✅ Done (Helsinki hel1, CX53) |
| Phase 2 (architecture) | 🔄 In progress — SSH hardened, Docker 29.3, UFW, Traefik v3.6 + HTTPS |
| Phase 3 (migrate data) | ⏳ Pending |
| Phase 4 (cutover) | ⏳ Pending |

Old VPS kept for 48h after successful cutover.
