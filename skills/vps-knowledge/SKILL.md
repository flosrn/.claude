---
name: vps-knowledge
description: Référence complète du VPS de Flo (OpenClaw, Docker, services, réseau). ALWAYS use when the user mentions "vps", "openclaw", "serveur", "server", "gateway", "docker" (in VPS context), "telegram bot", "auto-update", "mise à jour", "gapila deploy", "lasdelaroute deploy", or asks about infrastructure, deployment, or VPS configuration.
---

<objective>
Fournir le contexte complet du VPS pour toute opération : déploiement, debug, configuration, maintenance.
</objective>

<context>

## Qu'est-ce qu'OpenClaw ?

OpenClaw (anciennement Clawdbot) est une **plateforme d'agent AI self-hosted** — pas juste un conteneur Docker. C'est un système complet qui permet de faire tourner des agents AI connectés à de multiples canaux de communication.

**Fonctionnalités principales :**
- **Channels** (32+) : Telegram, Discord, WhatsApp, Slack, Signal, Matrix, IRC, iMessage, MS Teams, Line, Nostr, Twitch, Feishu, Google Chat, Mattermost...
- **Providers** (30+) : Anthropic, OpenAI, Ollama, Mistral, OpenRouter, Bedrock, Together, LiteLLM, HuggingFace, NVIDIA...
- **Gateway** : API centralisée pour gérer les agents, sessions, messages, sécurité, sandboxing
- **Automation** : Cron jobs, webhooks, hooks, polling, Gmail pub/sub
- **Tools** : Bash, browser, skills, subagents, thinking, PDF, slash commands, plugins
- **Mémoire** : Système de mémoire persistante (SQLite + fichiers markdown + compaction)
- **CLI** : 60+ commandes (agent, cron, memory, skills, gateway, sessions, plugins...)
- **Web** : Webchat, dashboard, TUI, control UI
- **Nodes** : Camera, audio, images, location, voice, media understanding
- **Multi-agent** : Workspaces isolés, agent routing, ACP agents

**Documentation** : https://docs.openclaw.ai/ (voir skill `clawddocs`)

**Config principale** : `/root/.openclaw/openclaw.json` (providers, agents, cron, channels)

---

## Accès

| Élément | Valeur |
|---|---|
| **SSH** | `ssh vps` (alias configuré localement) |
| **IP** | Voir `~/.ssh/config` (alias `vps`) |
| **OS** | Ubuntu 24.04 LTS (Noble Numbat) |
| **Kernel** | 6.8.0-31-generic x86_64 |
| **RAM** | 3.8 GB (+2 GB swap) |
| **Disque** | 102 GB (`/dev/vda2`) |
| **Provider** | RackNerd |

## Docker

| Élément | Valeur |
|---|---|
| **Docker** | v29.2.1 |
| **Compose** | v5.0.2 |
| **Image** | `openclaw:local` (~6.73 GB) — buildée depuis les sources |
| **Build** | `docker build -f Dockerfile.clawpro -t openclaw:local .` |
| **Durée build** | ~6-7 minutes (full rebuild) |
| **Volumes** | Tout en bind mounts (pas de volumes Docker nommés) |
| **Réseau** | `openclaw_default` (bridge) |

## Conteneur principal : openclaw-gateway

```
Image: openclaw:local
Restart: unless-stopped
Limites: 2.5 CPUs, 3 GB RAM
Ports:
  - 8788:8788 (public — Cloudflare Tunnel)
  - 127.0.0.1:18789:18789 (gateway API)
  - 127.0.0.1:18790:18790 (bridge)
Healthcheck: curl -sf http://127.0.0.1:18789/healthz
Commande: node dist/index.js gateway --bind lan --port 18789
```

## Chemins clés sur le VPS

| Chemin | Description |
|---|---|
| `/root/openclaw/` | Repo git OpenClaw (source + Dockerfiles) |
| `/root/openclaw/docker-compose.yml` | Config Docker Compose |
| `/root/openclaw/Dockerfile.clawpro` | Dockerfile custom (celui utilisé pour le build) |
| `/root/openclaw/Dockerfile` | Dockerfile upstream (pas utilisé) |
| `/root/openclaw/.env` | Variables d'environnement |
| `/root/openclaw/auto-update.sh` | Script auto-updater |
| `/root/.openclaw/` | Données OpenClaw (config, mémoire, agents, cron) |
| `/root/.openclaw/workspace/` | Workspace OpenClaw (MEMORY.md, skills, IDENTITY.md) |
| `/root/.openclaw/openclaw.json` | Config principale OpenClaw |
| `/root/.openclaw/telegram/` | État des bots Telegram |
| `/root/.openclaw/memory/` | Fichiers mémoire (session memories) |
| `/root/.openclaw/memory/main.sqlite` | Index SQLite des mémoires |
| `/root/.claude/` | Config Claude Code (synced depuis Mac) |
| `/root/.claude.json` | Auth Claude Code |
| `/root/gapila/` | Repo Gapila (bind-mounted dans le conteneur) |
| `/root/lasdelaroute/` | Repo LasDelaRoute |
| `/var/log/openclaw-update.log` | Logs auto-updater |

## Variables d'environnement (.env)

```
OPENCLAW_IMAGE=openclaw:local
OPENCLAW_GATEWAY_BIND=lan
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_BRIDGE_PORT=18790
OPENCLAW_CONFIG_DIR=/root/.openclaw
OPENCLAW_WORKSPACE_DIR=/root/.openclaw/workspace
XDG_CONFIG_HOME=/home/node/.openclaw
# Secrets: OPENCLAW_GATEWAY_TOKEN, GOG_KEYRING_PASSWORD, OPENAI_API_KEY, ELEVENLABS_API_KEY
```

## Bind Mounts (docker-compose.yml)

```yaml
volumes:
  - /root/.openclaw:/home/node/.openclaw
  - /root/.openclaw/workspace:/home/node/.openclaw/workspace
  - /root/.claude:/home/node/.claude
  - /root/.claude.json:/home/node/.claude.json
  - /root/.config/gh:/home/node/.config/gh
  - /var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock
  - /var/run/docker.sock:/var/run/docker.sock  # gateway only
  - /root/gapila:/home/node/gapila              # gateway only
```

## Services systemd actifs

| Service | Description |
|---|---|
| `cloudflared-openclaw.service` | Cloudflare Tunnel (accès public) |
| `tailscaled.service` | Tailscale (réseau privé) |
| `docker.service` | Docker daemon |
| `xray.service` | Xray (proxy) |
| `ssh.service` | OpenSSH |
| `cron.service` | Cron daemon |

## Telegram (4 bots configurés)

Les tokens et chat IDs sont dans `/root/.openclaw/openclaw.json` sur le VPS (clé `channels.telegram.accounts`).

| Compte | Usage |
|---|---|
| **default** | Bot principal (Clawd.bot) — utilisé par l'auto-updater |
| **english** | Variante anglaise |
| **chinese** | Variante chinoise |
| **gapibot** | Bot Gapila (commandes /bug, /feature, /status, /explore, /dev) |

**Envoyer un message Telegram :**
```bash
ssh vps 'bash -s' < scripts/tg-send.sh "Mon message"
```

## Sync Mac ↔ VPS

| Repo | Local (Mac) | VPS | Branche |
|---|---|---|---|
| claude | `~/.claude/` | `/root/.claude/` | main |
| clawd | `~/clawd/` | `/root/.openclaw/workspace/` | master |
| gapila | `~/code/nextjs/gapila/` | `/root/gapila/` | main |
| lasdelaroute | `~/code/nextjs/lasdelaroute/` | `/root/lasdelaroute/` | main |

**Script** : `~/.claude/scripts/sync-vps.sh` (push/pull, un ou tous les repos)

## Auto-Updater

| Élément | Valeur |
|---|---|
| **Script** | `/root/openclaw/auto-update.sh` |
| **Cron** | `0 21 * * *` (21h UTC = 4h Bangkok) |
| **Logs** | `/var/log/openclaw-update.log` |
| **Notifications** | 3 messages Telegram (début, build, résultat) |
| **Rollback** | Automatique si healthcheck échoue |
| **Verrou** | `/tmp/openclaw-update.lock` |

**Flow** : git fetch → compare → git pull → docker build → stop gateway → start gateway → healthcheck → prune → notif

**Commandes manuelles :**
```bash
ssh vps '/root/openclaw/auto-update.sh'            # Lancer manuellement
ssh vps 'crontab -r'                                # Désactiver
ssh vps 'echo "0 21 * * * /root/openclaw/auto-update.sh >> /var/log/openclaw-update.log 2>&1" | crontab -'  # Réactiver
```

## Scripts utilitaires

Tous les scripts sont dans `scripts/` de ce skill. Usage depuis le Mac via `ssh vps 'bash -s' < script.sh [args]`.

| Script | Usage | Description |
|---|---|---|
| `tg-send.sh` | `"message" [--html]` | Envoie un message Telegram via le bot default |
| `vps-status.sh` | *(aucun)* | État complet : conteneurs, RAM, disque, services, git |
| `vps-logs.sh` | `[gateway\|updater\|all] [N]` | Logs récents du gateway et/ou de l'auto-updater |
| `vps-cleanup.sh` | *(aucun)* | Nettoyage Docker (images + build cache) |
| `vps-restart.sh` | *(aucun)* | Restart du gateway + healthcheck |
| `vps-rebuild.sh` | `[--no-restart]` | Rebuild complet de l'image + restart + cleanup |
| `memory-search.sh` | `"query"` | Recherche dans la mémoire OpenClaw |
| `memory-save.sh` | `"topic" "contenu"` | Sauvegarde une mémoire + reindex |

**Exemples :**
```bash
# Status complet du VPS
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-status.sh

# Logs du gateway (100 dernières lignes)
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-logs.sh gateway 100

# Rebuild + restart
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-rebuild.sh

# Nettoyage
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-cleanup.sh

# Recherche mémoire
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/memory-search.sh "gapila"
```

## Contraintes et limites

- **RAM limitée (3.8 GB)** : le build Docker consomme ~2.4 GB. Éviter de builder pendant que le gateway est sous charge.
- **Pas de registry** : l'image est buildée localement, pas de `docker pull`.
- **Image volumineuse** : ~6.73 GB. Chaque build + ancienne image = ~14 GB temporairement. Toujours `prune` après.
- **Dockerfile.clawpro** : installe aussi Claude Code, GitHub CLI, Docker CLI, Supabase CLI, Bun. C'est plus lourd que le Dockerfile upstream.
- **Connexion SSH fragile pendant les builds** : les builds gourmands en IO peuvent couper la connexion. Utiliser `nohup` ou lancer en background.

</context>

<quick_start>
Quand l'utilisateur mentionne le VPS ou OpenClaw, utilise ce contexte pour :
1. **Répondre aux questions** sur l'infra sans avoir à SSH explorer
2. **Exécuter des commandes** avec les bons chemins et paramètres
3. **Diagnostiquer** les problèmes avec les bonnes commandes
4. **Déployer/mettre à jour** avec le workflow correct
</quick_start>
