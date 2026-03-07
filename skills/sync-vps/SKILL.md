---
name: sync-vps
description: "Sync repos between Mac and VPS, or show their git status. ALWAYS use when the user says 'sync', 'sync vps', 'sync shipmate', 'sync clawd', 'sync gapibot', 'sync gapila', 'push vps', 'pull vps', 'status vps', 'repos status', 'etat des repos', 'etat vps', or mentions syncing local and VPS code. Also triggers on 'dirty repos', 'uncommitted changes vps', 'what needs pushing'."
allowed-tools: Bash
---

# Sync VPS

Sync repos between local Mac and VPS via git, or show status of all repos across both environments.

The VPS runs repos inside a Docker container. All VPS git commands go through:
```
ssh vps 'docker exec -u node openclaw-openclaw-gateway-1 bash -c "..."'
```

## Repos

| Name | Local (Mac) | VPS (container) | Sync? |
|------|-------------|-----------------|:-----:|
| shipmate-agent | `~/Code/claude/shipmate-agent` | `/home/node/.openclaw/workspace-shipmate` | yes |
| shipmate-bot | `~/Code/claude/shipmate-bot` | `/home/node/projects/shipmate-bot` | yes |
| shipmate | `~/Code/claude/shipmate` | `/home/node/projects/shipmate` | yes |
| clawd | `~/Code/claude/clawd` | `/home/node/.openclaw/workspace` | yes |
| gapibot | `~/Code/claude/gapibot` | `/home/node/.openclaw/workspace-gapibot` | yes |
| gapila | `~/Code/nextjs/gapila` | `/home/node/projects/gapila` | yes |

All 6 repos are syncable (local Mac + VPS).

## Usage

```bash
~/.claude/scripts/sync-vps.sh [options] [repo...]
```

### Commands

| Command | What it does |
|---------|-------------|
| `sync-vps.sh` | Push all syncable repos (Mac -> VPS) |
| `sync-vps.sh --pull` | Pull all syncable repos (VPS -> Mac) |
| `sync-vps.sh --sync` | Bidirectional sync (commit+push both sides, then pull both) |
| `sync-vps.sh --status` | Show git status of ALL repos (local + VPS) |
| `sync-vps.sh -i` | Interactive mode with fzf menus |
| `sync-vps.sh shipmate-agent` | Push only shipmate-agent |
| `sync-vps.sh --pull shipmate-bot` | Pull only shipmate-bot |
| `sync-vps.sh --sync shipmate` | Bidirectional sync only shipmate |
| `sync-vps.sh --status clawd` | Show status of clawd |
| `sync-vps.sh --dry-run` | Preview what would happen |

Interactive mode (`-i`) shows all repos with fzf, lets you pick one, see details, and choose an action (push, pull, sync both, discard). Loops until you press Esc. Requires `fzf` (brew install fzf).

### Intent mapping

| User says | Command |
|-----------|---------|
| "sync" / "sync vps" / "sync all" | push all |
| "sync shipmate" / "sync agent" | push that repo |
| "sync both" / "sync bidirectionnel" | `--sync` |
| "pull" / "pull vps" / "recupere" | `--pull` |
| "push" / "envoie" | push (default) |
| "status" / "etat" / "repos status" | `--status` |
| "dry run" / "preview" | `--dry-run` |
