---
name: hetzner-vps
description: "Complete reference for Flo's Hetzner VPS infrastructure (OpenClaw production). ALWAYS use when the user mentions \"vps\", \"hetzner\", \"openclaw\", \"serveur\", \"server\", \"gateway\", \"docker\" (in VPS context), \"monitoring\", \"traefik\", \"backup\", \"infrastructure\", \"telegram bot\", \"auto-update\", \"mise à jour\", \"deploy\", \"sandbox browser\", \"browser vps\", \"clawmetry\", \"beszel\", \"uptime kuma\", \"dozzle\", \"ntfy\", \"crowdsec\", \"xray\", \"vless\", \"ops.shipmate.bot\", or asks about VPS configuration, deployment, architecture, or operational tasks. This skill is the single source of truth for the VPS — use it instead of guessing."
---

# Hetzner VPS — Infrastructure Reference

This skill documents the complete architecture of Flo's production VPS on Hetzner Cloud. Read ARCHITECTURE.md for the full technical reference.

## Quick Reference

| Info | Value |
|------|-------|
| **Provider** | Hetzner Cloud |
| **Location** | Helsinki (hel1), Finland |
| **Type** | CX53 — 16 vCPU, 32 GB RAM, 320 GB SSD |
| **IP** | `204.168.138.162` |
| **OS** | Ubuntu 24.04 LTS |
| **SSH** | `ssh root@204.168.138.162` |
| **Cost** | ~€17/mois |
| **Domain** | `*.ops.shipmate.bot` (Cloudflare) |

## Architecture Overview

```
Internet → Cloudflare (DDoS + Access SSO) → Traefik v3 (reverse proxy)
                                                    │
              ┌─────────┬──────────┬────────────────┼──────────┐
              ▼          ▼          ▼                ▼          ▼
          OpenClaw    Beszel    Grafana/Loki    Uptime Kuma   ntfy
          Gateway     Dozzle    Promtail        Clawmetry
              │
              ▼
          oc-ops (sidecar) → wollomatic/socket-proxy → Docker daemon
```

## Directory Structure

```
/opt/docker/
├── traefik/          # Reverse proxy + Let's Encrypt
├── monitoring/       # Beszel, Uptime Kuma, Dozzle, Grafana, Loki, ntfy
├── openclaw/         # Gateway + CLI + oc-ops sidecar
├── services/         # Browser, Clawmetry
├── security/         # CrowdSec + Docker Socket Proxy
├── scripts/          # backup.sh, health-check.sh, update.sh
└── Makefile          # make up, make down, make logs, make backup
```

## Service URLs

All services accessible via `*.ops.shipmate.bot` with Cloudflare Access (email OTP).

| Service | URL | Purpose |
|---------|-----|---------|
| Grafana | `grafana.ops.shipmate.bot` | Dashboards + logs |
| Beszel | `beszel.ops.shipmate.bot` | System + Docker metrics |
| Uptime Kuma | `status.ops.shipmate.bot` | Uptime + SSL monitoring |
| Dozzle | `logs.ops.shipmate.bot` | Real-time Docker logs |
| ntfy | `ntfy.ops.shipmate.bot` | Push notifications |
| Clawmetry | `clawmetry.ops.shipmate.bot` | Agent metrics |
| Traefik | `traefik.ops.shipmate.bot` | Proxy dashboard |

## Common Operations

```bash
# SSH into VPS
ssh root@204.168.138.162

# View all containers
ssh root@204.168.138.162 'docker ps'

# View logs of a service
ssh root@204.168.138.162 'cd /opt/docker/openclaw && docker compose logs -f --tail=50'

# Restart a stack
ssh root@204.168.138.162 'cd /opt/docker/openclaw && docker compose up -d --force-recreate'

# Run backup
ssh root@204.168.138.162 '/opt/docker/scripts/backup.sh'

# Health check
ssh root@204.168.138.162 '/opt/docker/scripts/health-check.sh'

# Update a stack (pull + recreate)
ssh root@204.168.138.162 '/opt/docker/scripts/update.sh openclaw'
```

## When to Read More

- **Full architecture details** → Read `ARCHITECTURE.md`
- **Backup/restore procedures** → Read `scripts/backup.sh`
- **Traefik label patterns** → Read `references/traefik-labels.md`
- **Cloudflare Access setup** → Read `references/cloudflare-access.md`
- **Docker daemon config** → Read `references/daemon.json`

## Migration Context

This VPS replaces the old RackNerd VPS (`192.210.136.198`). Migration plan is in Claude memory (`project_vps-migration-hetzner.md`). Key difference: the new architecture uses `/opt/docker/` structure with isolated stacks, Traefik reverse proxy, proper monitoring, and security hardening.

## Key Secrets Locations

All secrets are in `.env` files per stack — never hardcoded in compose files.

| Stack | .env path |
|-------|-----------|
| OpenClaw | `/opt/docker/openclaw/.env` |
| Traefik | `/opt/docker/traefik/.env` |
| Monitoring | `/opt/docker/monitoring/.env` |

Cloudflare API token (DNS challenge) is in Traefik's `.env`.
