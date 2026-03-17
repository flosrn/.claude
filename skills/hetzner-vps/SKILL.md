---
name: hetzner-vps
description: "Complete reference for Flo's Hetzner VPS infrastructure (OpenClaw production). ALWAYS use when the user mentions \"vps\", \"hetzner\", \"openclaw\", \"serveur\", \"server\", \"gateway\", \"docker\" (in VPS context), \"monitoring\", \"traefik\", \"backup\", \"infrastructure\", \"telegram bot\", \"auto-update\", \"mise à jour\", \"deploy\", \"sandbox browser\", \"browser vps\", \"clawmetry\", \"beszel\", \"uptime kuma\", \"dozzle\", \"ntfy\", \"crowdsec\", \"xray\", \"vless\", \"ops.shipmate.bot\", \"oktsec\", \"pinchtab\", \"keychains\", \"clawsec\", \"soul-guardian\", \"agent security\", \"mission control\", \"clawbridge\", \"mengram\", \"mc.ops\", \"bridge.ops\", or asks about VPS configuration, deployment, architecture, or operational tasks. This skill is the single source of truth for the VPS — use it instead of guessing."
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
| **Connect** | `mosh vps` (preferred — faster from Bangkok) |
| **SSH** | `ssh root@204.168.138.162` (for non-interactive commands) |
| **Tailscale IP** | `100.77.103.17` |
| **Cost** | ~€17/mois |
| **Domain** | `*.ops.shipmate.bot` (Cloudflare) |

## Architecture Overview

```
Internet → Cloudflare (DDoS) → Traefik v3 (reverse proxy)
                                       │
         ┌──────────┬──────────┬───────┼──────────┬──────────┐
         ▼          ▼          ▼       ▼          ▼          ▼
     OpenClaw    Beszel    Uptime    Dozzle     ntfy    Clawmetry
     Gateway     hub+agent  Kuma    (logs)    (push)   (metrics)
         │
         ▼
     oc-ops (sidecar) → wollomatic/socket-proxy → Docker daemon

 Host-level services (systemd, via Traefik host.docker.internal):
     Oktsec v0.9.1      → oktsec.ops.shipmate.bot     (:8082 dashboard, :9090 MCP gateway)
     PinchTab v0.8.2    → pinchtab.ops.shipmate.bot   (:9867 browser automation API)
     Keychains Proxy    → keychains.ops.shipmate.bot   (:3100 credential delegation)

 Security skills (inside OpenClaw container):
     clawsec-suite v0.1.4, soul-guardian v0.0.2, openclaw-audit-watchdog v0.1.1
```

## Directory Structure

```
/opt/docker/
├── traefik/          # Reverse proxy + Let's Encrypt
├── monitoring/       # Beszel, Uptime Kuma, Dozzle, Grafana, Loki, ntfy
├── openclaw/         # Gateway + CLI + oc-ops sidecar
├── services/         # Browser, Clawmetry, Keychains Proxy
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
| Oktsec | `oktsec.ops.shipmate.bot` | AI agent runtime security (188 rules) |
| PinchTab | `pinchtab.ops.shipmate.bot` | Browser automation bridge |
| Keychains | `keychains.ops.shipmate.bot` | Credential delegation proxy |
| Mission Control | `mc.ops.shipmate.bot` | Agent orchestration dashboard (Builderz v2.0, Docker) |
| ClawBridge | `bridge.ops.shipmate.bot` | Mobile agent monitor (systemd :3200) |

## Common Operations

```bash
# Connect to VPS (interactive — use mosh, faster from Bangkok)
mosh vps

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

# Host-level services (systemd)
ssh root@204.168.138.162 'systemctl status oktsec pinchtab keychains-proxy'
ssh root@204.168.138.162 'systemctl restart oktsec'  # regenerates access code

# Oktsec access code (changes on restart)
ssh root@204.168.138.162 'journalctl -u oktsec --no-pager -n 30 | grep "Access code"'

# Soul Guardian — check agent file integrity
ssh root@204.168.138.162 'docker exec openclaw-gateway bash -c "cd /home/node/.openclaw/workspace && python3 skills/soul-guardian/scripts/soul_guardian.py check"'
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
