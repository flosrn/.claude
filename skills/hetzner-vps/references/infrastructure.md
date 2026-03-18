# Infrastructure — Server, Docker, Traefik

## Server

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

## Domain & DNS

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

## Directory Structure

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

/root/shared-skills/                  # Shared skills repo (mounted :ro in container)
└── → /home/node/shared-skills/       # (via bind mount)
    └── Loaded by all agents via openclaw.json extraDirs
```

## Docker Configuration

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
  traefik-public (external)
  ├── traefik, grafana, beszel, uptime-kuma, dozzle, ntfy, clawmetry, openclaw-gateway

  openclaw-internal
  ├── openclaw-gateway, openclaw-cli, oc-ops (sidecar)

  monitoring-internal
  ├── prometheus, loki, promtail, grafana

  socket-proxy-net
  ├── oc-ops, wollomatic/socket-proxy

  security-internal
  ├── crowdsec, crowdsec-bouncer
```

Rule: **Only Traefik exposes ports 80/443.** All other services communicate via internal Docker networks.

### Container Standards

Every container must have:
- `restart: unless-stopped`
- `deploy.resources.limits` (CPU + memory)
- `healthcheck` with `start_period`
- `no-new-privileges: true`
- Explicit network assignment

## Reverse Proxy — Traefik v3

- **Image**: `traefik:v3.6` (v3.6+ required for Docker 29 API compatibility)
- **Docker**: v29.3.0 (API v1.54) — Traefik <3.6.1 incompatible (hardcoded API v1.24)
- **Discovery**: Docker provider with `exposedByDefault: false`
- **TLS**: Let's Encrypt via Cloudflare DNS challenge (wildcard `*.ops.shipmate.bot`)
- **Entrypoints**: HTTP (80, redirects to HTTPS) + HTTPS (443)
- **Middlewares**: Secure headers, rate limiting (defined in `config/middlewares.yml`)
- **Ping**: Enabled (required for Docker healthcheck)
- **Config files**: `traefik.yml` (static), `config/` dir (dynamic, watched)

Docker socket: currently mounted `/var/run/docker.sock:ro` directly. TODO: migrate to `wollomatic/socket-proxy`.

Adding a new service — just add Traefik labels (see `references/traefik-labels.md`).

## Backup — Restic → Hetzner Storage Box

| Data | Path |
|------|------|
| OpenClaw config + agents | `/root/.openclaw/` |
| Compose files + configs | `/opt/docker/` |
| Projects | `/root/projects/` |
| Docker volumes | Named volumes via tar |
| PostgreSQL (if any) | `pg_dump` before backup |

Retention: 7 daily, 4 weekly, 3 monthly. Schedule: daily at 04:00 UTC.
Storage: Hetzner Storage Box (SFTP) + Backblaze B2 (geo-redundant).
See `scripts/backup.sh` for the implementation.

## Installed Software (host)

| Software | Version | Purpose |
|----------|---------|---------|
| Docker | 29.3.0 (API v1.54) | Container runtime |
| Node.js | 22.22.1 (nodesource) | Oktsec MCP, Clawsec, Keychains |
| Chromium | latest (apt) | PinchTab browser automation |
| Oktsec | 0.9.1 (Go binary) | AI agent runtime security |
| PinchTab | 0.8.2 (Go binary) | Browser automation bridge |
| Keychains CLI | 0.2.0 (npm global) | Credential delegation |
| Xray | 26.2.6 | VLESS Reality proxy |
| gh | 2.88.1 | GitHub CLI |
| Mosh | 1.4.0 | Low-latency SSH (UDP) |
| Tailscale | latest | VPN mesh |
| fail2ban | latest | SSH brute-force protection |
| UFW | latest | Firewall (+ DOCKER-USER) |
| unattended-upgrades | latest | Auto security patches |
