---
name: vps-knowledge
description: Référence complète du VPS de Flo (OpenClaw, Docker, services, réseau). ALWAYS use when the user mentions "vps", "openclaw", "serveur", "server", "gateway", "docker" (in VPS context), "telegram bot", "auto-update", "mise à jour", "gapila deploy", "lasdelaroute deploy", "sandbox browser", "browser vps", "chromium vps", or asks about infrastructure, deployment, or VPS configuration.
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

## Logs internes (JSON structuré)

Le fichier de log interne est **bien plus riche** que `docker compose logs`. Il contient du JSON structuré avec chatId, titres de groupes, raisons de skip, etc.

```bash
# Accès au log du jour
ssh vps 'docker exec openclaw-openclaw-gateway-1 cat /tmp/openclaw/openclaw-$(date -u +%Y-%m-%d).log'

# Filtrer les erreurs
ssh vps 'docker exec openclaw-openclaw-gateway-1 cat /tmp/openclaw/openclaw-$(date -u +%Y-%m-%d).log' | grep '"logLevelName":"ERROR"'

# Chercher les messages Telegram skippés
ssh vps 'docker exec openclaw-openclaw-gateway-1 cat /tmp/openclaw/openclaw-$(date -u +%Y-%m-%d).log' | grep "skipping group"
```

Le fichier change chaque jour : `/tmp/openclaw/openclaw-YYYY-MM-DD.log` (à l'intérieur du conteneur).

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
| `/root/.openclaw/workspace/` | Workspace agent default (MEMORY.md, skills, IDENTITY.md) — repo git `flosrn/clawd` |
| `/root/.openclaw/workspace-gapibot/` | Workspace agent gapibot — repo git `flosrn/gapibot` (branche `master`) |
| `/root/.openclaw/openclaw.json` | Config principale OpenClaw |
| `/root/.openclaw/telegram/` | État des bots Telegram |
| `/root/.openclaw/memory/` | Fichiers mémoire (session memories) |
| `/root/.openclaw/memory/main.sqlite` | Index SQLite des mémoires |
| `/root/.claude/` | Config Claude Code (synced depuis Mac) |
| `/root/.claude.json` | Auth Claude Code |
| `/root/projects/` | Repos git persistants (montés dans `/home/node/projects/`) |
| `/root/projects/gapila/` | Repo Gapila |
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
  - /root/projects:/home/node/projects          # git repos (gapila, etc.)
  - /root/.config/gh:/home/node/.config/gh      # GitHub CLI auth
  - /root/.claude:/home/node/.claude             # Claude Code config
  - /root/.claude.json:/home/node/.claude.json:ro
  - /root/.gitconfig:/home/node/.gitconfig:ro   # gh credential helper pour git
```

**Env vars notables (docker-compose) :**
- `GH_TOKEN` — token GitHub CLI (auth git + gh)

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

| Compte | Bot | Usage |
|---|---|---|
| **default** | @flosrn_ClawdBot | Bot principal (Clawd.bot) — utilisé par l'auto-updater |
| **english** | @FloEnglishProf_bot | Variante anglaise |
| **chinese** | @FloChineseProf_bot | Variante chinoise |
| **gapibot** | @GapibotGapila_bot | Bot Gapila (commandes /bug, /feature, /status, /explore, /dev) |

### Config Telegram : allowFrom vs groups

⚠️ **`allowFrom` ne concerne que les DMs** (user IDs). Pour les groupes, il faut les lister dans `accounts.<bot>.groups.<chatId>`.

```json
{
  "accounts": {
    "gapibot": {
      "allowFrom": ["1127788632"],           // DM — user IDs uniquement
      "groupPolicy": "open",
      "groups": {
        "-1003718059427": {"requireMention": false},  // Gapila Board (3 membres)
        "-5206151881": {"requireMention": false}       // Flo & Gapibot
      }
    }
  }
}
```

- `groupPolicy: "open"` = accepte les messages de tous les membres, mais le groupe doit quand même être **listé** dans `groups`
- `requireMention: false` = le bot peut répondre sans @mention (mais peut choisir de requérir le @mention dans les groupes multi-utilisateurs)
- `allowFrom` dans un groupe = restreint quels **expéditeurs** peuvent déclencher le bot dans ce groupe

### Groupes configurés

| Bot | Groupe | Chat ID |
|---|---|---|
| **default** | *(3 groupes)* | `-5136045193`, `-5184759927`, `-5201575851` |
| **gapibot** | Gapila Board | `-1003718059427` |
| **gapibot** | Flo & Gapibot | `-5206151881` |

### Trouver un chat ID de groupe

1. Envoyer un message dans le groupe
2. Chercher dans les logs internes :
```bash
ssh vps 'docker exec openclaw-openclaw-gateway-1 cat /tmp/openclaw/openclaw-$(date -u +%Y-%m-%d).log' | grep -i "not-allowed\|skipping group"
```
Le log contient `chatId` et `title` du groupe dans le JSON.

### Commandes Telegram et Skills

⚠️ **`nativeSkills: false`** est configuré sur gapibot pour éviter d'exposer les skills partagés (compta-mensuelle, gmail, proton-pass...) et bundled (weather, coding-agent...) dans le menu Telegram.

À la place, les commandes sont gérées via `customCommands` (entrées du menu Telegram) avec des **noms courts** (`/bug`, `/deploy`, `/gh`...).

**Quand tu ajoutes un nouveau skill gapibot :**
1. Créer le skill dans `/root/.openclaw/workspace-gapibot/skills/<name>/`
2. Lancer le diagnostic : `ssh vps 'bash -s' < vps-telegram-sync.sh`
3. Analyser le JSON retourné : les skills dans `unmatched_skills` n'ont pas de commande Telegram
4. Choisir le meilleur nom court pour chaque skill manquant (concis, mémorable, sans conflit)
5. Ajouter la commande via SSH (modifier `customCommands` dans openclaw.json)
6. Restart le gateway

**Script de diagnostic :**
```bash
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-telegram-sync.sh gapibot
```
Retourne un JSON avec `skills`, `commands`, `matched`, `unmatched_skills`, `unmatched_commands`.

**Envoyer un message Telegram :**
```bash
ssh vps 'bash -s' < scripts/tg-send.sh "Mon message"
```

## Sync Mac ↔ VPS

| Repo | Local (Mac) | VPS | Branche |
|---|---|---|---|
| claude | `~/.claude/` | `/root/.claude/` | main |
| clawd | `~/clawd/` | `/root/.openclaw/workspace/` | master |
| gapibot | *(pas de clone local)* | `/root/.openclaw/workspace-gapibot/` | master |
| gapila | `~/code/nextjs/gapila/` | `/root/projects/gapila/` | main |
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

**Self-update depuis le conteneur (par l'agent) :**
Le script `/patches/self-update.sh` (bind-mounted depuis `/root/openclaw/patches/`) permet à l'agent de déclencher sa propre mise à jour via docker socket. Il lance un conteneur helper détaché qui exécute `auto-update.sh`. Le helper survit à l'arrêt du gateway.
```bash
# Depuis l'intérieur du conteneur (par l'agent)
bash /patches/self-update.sh

# Depuis le Mac
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-self-update.sh
```

**Image Docker officielle (ghcr.io) :**
```
ghcr.io/openclaw/openclaw:latest    # Image officielle (non utilisée actuellement)
ghcr.io/openclaw/openclaw:<version> # Ex: 2026.2.26
```
L'image `openclaw:local` est buildée depuis les sources (Dockerfile.clawpro), pas depuis le registry.

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
| `vps-browser.sh` | `start\|stop\|restart\|status\|logs [N]` | Toggle du conteneur sandbox-browser (Chromium CDP) |
| `vps-auth-check.sh` | `[--verbose]` | Vérifie les tokens auth pour tous les agents (auth-profiles + credentials) |
| `vps-doctor.sh` | `[--quick]` | Diagnostic complet (10 sections : conteneur, health, auth, ressources, services) |
| `vps-agents.sh` | `[agent-id]` | Statut détaillé des agents (sessions, auth, erreurs, bindings Telegram) |
| `vps-monitor.sh` | `[--follow\|-f] [--errors\|-e] [--agent <id>] [N]` | Surveillance erreurs/warnings dans les logs |
| `vps-telegram.sh` | `[bot-name\|all] [--test]` | Diagnostics Telegram (API, webhook, pending updates, erreurs) |
| `vps-auth-refresh.sh` | `[--dry-run]` | ⚠️ LOCAL Mac — Rafraîchit les tokens OAuth depuis le Keychain |
| `vps-telegram-sync.sh` | `[bot]` | Diagnostic JSON : skills vs customCommands (Claude Code analyse et décide) |
| `vps-provider-toggle.sh` | `<agent_id> <mode>` | Toggle provider d'un agent (claude, claude-opus, blockrun, blockrun-eco, blockrun-premium, blockrun-free) |
| `vps-self-update.sh` | *(aucun)* | Déclenche la mise à jour autonome via docker socket (helper container) |

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

# Diagnostic complet du VPS (10 checks)
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-doctor.sh

# Diagnostic rapide (skip health probes)
ssh vps 'bash -s -- --quick' < ~/.claude/skills/vps-knowledge/scripts/vps-doctor.sh

# Vérifier les tokens auth
ssh vps 'bash -s -- --verbose' < ~/.claude/skills/vps-knowledge/scripts/vps-auth-check.sh

# Statut des agents
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-agents.sh
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-agents.sh gapibot

# Surveillance erreurs temps réel
ssh vps 'bash -s -- --follow' < ~/.claude/skills/vps-knowledge/scripts/vps-monitor.sh
ssh vps 'bash -s -- --errors --agent gapibot 200' < ~/.claude/skills/vps-knowledge/scripts/vps-monitor.sh

# Diagnostics Telegram
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-telegram.sh
ssh vps 'bash -s -- gapibot --test' < ~/.claude/skills/vps-knowledge/scripts/vps-telegram.sh

# Rafraîchir les tokens OAuth (LOCAL — depuis le Mac)
~/.claude/skills/vps-knowledge/scripts/vps-auth-refresh.sh
~/.claude/skills/vps-knowledge/scripts/vps-auth-refresh.sh --dry-run

# Toggle provider d'un agent (ClawRouter / Claude Max)
ssh vps 'bash -s -- clawd blockrun' < ~/.claude/skills/vps-knowledge/scripts/vps-provider-toggle.sh
ssh vps 'bash -s -- clawd claude' < ~/.claude/skills/vps-knowledge/scripts/vps-provider-toggle.sh
ssh vps 'bash -s -- shipmate-agent blockrun-eco' < ~/.claude/skills/vps-knowledge/scripts/vps-provider-toggle.sh

# Self-update autonome (via docker socket helper container)
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-self-update.sh
```

## Sandbox Browser (Chromium headful)

Conteneur Docker séparé avec Chromium contrôlable via CDP (Chrome DevTools Protocol).
Permet aux agents d'automatiser la navigation web (gmail, login, scraping...).

| Élément | Valeur |
|---|---|
| **Image** | `openclaw-sandbox-browser:bookworm-slim` (~382 MB) |
| **Base** | Debian bookworm-slim + Chromium + Xvfb + VNC + noVNC |
| **Dockerfile** | `/root/openclaw/Dockerfile.sandbox-browser` |
| **Entrypoint** | `/root/openclaw/scripts/sandbox-browser-entrypoint.sh` |
| **CDP** | Port 9222 (interne, entre conteneurs) |
| **VNC** | Port 5900 (`127.0.0.1` — debug via SSH tunnel) |
| **noVNC** | Port 6080 (`127.0.0.1` — debug via navigateur web) |
| **RAM** | ~500 MB - 1 GB (limite : 1 GB) |
| **CPU** | Limite : 1.5 CPUs |
| **Profile Compose** | `browser` (ne démarre PAS avec `docker compose up` normal) |
| **Restart** | `no` (start/stop à la demande) |

**Config dans openclaw.json :**
```json
{
  "browser": {
    "profiles": {
      "sandbox": {
        "cdpUrl": "http://sandbox-browser:9222"
      }
    }
  }
}
```

**Commandes toggle :**
```bash
# Démarrer
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-browser.sh start

# Arrêter
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-browser.sh stop

# Status
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-browser.sh status

# Logs
ssh vps 'bash -s' < ~/.claude/skills/vps-knowledge/scripts/vps-browser.sh logs 100

# Debug visuel via noVNC (SSH tunnel puis ouvrir http://localhost:6080)
ssh -L 6080:127.0.0.1:6080 vps
```

**Rebuild image :**
```bash
ssh vps 'cd /root/openclaw && bash scripts/sandbox-browser-setup.sh'
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
