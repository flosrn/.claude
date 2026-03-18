---
name: hetzner-vps
description: "Complete operational reference for Flo's Hetzner VPS running the OpenClaw agent platform (5 Telegram bots, Docker stacks, monitoring, security). Single source of truth for VPS infrastructure — architecture, services, deployments, troubleshooting. Use this skill whenever working with the production server: deploying services, checking status, debugging containers, configuring Traefik, managing backups, reviewing security, updating memory backends (QMD/lossless-claw), or managing shared skills. Also use when discussing any ops.shipmate.bot service (Beszel, Dozzle, Grafana, ntfy, Clawmetry, Oktsec, PinchTab, Mission Control, ClawBridge), Docker operations on the VPS, the oc-ops sidecar, or Xray/VLESS proxy. This skill is authoritative — use it instead of guessing about VPS configuration."
---

# Hetzner VPS — Infrastructure Reference

## Quick Reference

| Info | Value |
|------|-------|
| **Provider** | Hetzner Cloud |
| **Location** | Helsinki (hel1), Finland |
| **Type** | CX53 — 16 vCPU, 32 GB RAM, 320 GB SSD |
| **IP** | `204.168.138.162` |
| **OS** | Ubuntu 24.04 LTS |
| **Connect** | `mosh vps` (preferred — faster from Bangkok) |
| **SSH** | `ssh root@204.168.138.162` |
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
     Oktsec v0.9.1      → oktsec.ops.shipmate.bot
     PinchTab v0.8.2    → pinchtab.ops.shipmate.bot
     Keychains Proxy    → keychains.ops.shipmate.bot

 Security skills (inside OpenClaw container):
     clawsec-suite v0.1.4, soul-guardian v0.0.2, openclaw-audit-watchdog v0.1.1
```

## Agents

5 agents on the gateway, each with a distinct role:

| Agent | Role | Telegram |
|-------|------|----------|
| **Claude Code** | Developer / executor | N/A (CLI) |
| **Clawd** | Personal agent | @flosrn_ClawdBot |
| **Gapibot** | PM for Gapila startup | @GapibotGapila_bot |
| **Shipmate** | VPS infra architect | @Shipmatethebot |
| **Teachers** | Language practice | @FloEnglishProf_bot / @FloChineseProf_bot |

22 **shared-skills** loaded by all agents via `extraDirs` in `openclaw.json`. Agent-specific skills live in each workspace's `skills/` directory.

## Service URLs

All behind `*.ops.shipmate.bot` with Cloudflare Access (email OTP).

| Service | URL |
|---------|-----|
| Grafana | `grafana.ops.shipmate.bot` |
| Beszel | `beszel.ops.shipmate.bot` |
| Uptime Kuma | `status.ops.shipmate.bot` |
| Dozzle | `logs.ops.shipmate.bot` |
| ntfy | `ntfy.ops.shipmate.bot` |
| Clawmetry | `clawmetry.ops.shipmate.bot` |
| Traefik | `traefik.ops.shipmate.bot` |
| Oktsec | `oktsec.ops.shipmate.bot` |
| PinchTab | `pinchtab.ops.shipmate.bot` |
| Keychains | `keychains.ops.shipmate.bot` |
| Mission Control | `mc.ops.shipmate.bot` |
| ClawBridge | `bridge.ops.shipmate.bot` |

## Common Operations

```bash
# Connect (interactive — use mosh from Bangkok)
mosh vps

# View all containers
ssh root@204.168.138.162 'docker ps'

# View logs of a stack
ssh root@204.168.138.162 'cd /opt/docker/openclaw && docker compose logs -f --tail=50'

# Restart a stack
ssh root@204.168.138.162 'cd /opt/docker/openclaw && docker compose up -d --force-recreate'

# Run backup / health check / update
ssh root@204.168.138.162 '/opt/docker/scripts/backup.sh'
ssh root@204.168.138.162 '/opt/docker/scripts/health-check.sh'
ssh root@204.168.138.162 '/opt/docker/scripts/update.sh openclaw'

# Host services (systemd)
ssh root@204.168.138.162 'systemctl status oktsec pinchtab keychains-proxy'

# Soul Guardian — check agent file integrity
ssh root@204.168.138.162 'docker exec openclaw-gateway bash -c "cd /home/node/.openclaw/workspace && python3 skills/soul-guardian/scripts/soul_guardian.py check"'
```

## When to Read More

| Task | Read |
|------|------|
| Server specs, directory layout, Docker config, Traefik, installed software | `references/infrastructure.md` |
| Service details (monitoring, host services, MC, ClawBridge, Clawmetry, browser, Xray) | `references/services.md` |
| Security layers, firewall, CrowdSec, SSH, Docker socket | `references/security.md` |
| Gateway self-update via oc-ops sidecar | `references/oc-ops.md` |
| Memory search (QMD), context engine (lossless-claw) | `references/memory-stack.md` |
| Shared skills architecture, sync, Telegram commands | `references/shared-skills.md` |
| Traefik label patterns for new services | `references/traefik-labels.md` |
| Cloudflare Access / Zero Trust setup | `references/cloudflare-access.md` |
| Container diagnostic commands (inside gateway) | `references/container-diagnostics.md` |
| Docker daemon config | `references/daemon.json` |

## Secrets

All secrets in `.env` files per stack — never hardcoded.

| Stack | Path |
|-------|------|
| OpenClaw | `/opt/docker/openclaw/.env` |
| Traefik | `/opt/docker/traefik/.env` |
| Monitoring | `/opt/docker/monitoring/.env` |
