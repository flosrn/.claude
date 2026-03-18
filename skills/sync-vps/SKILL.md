---
name: sync-vps
description: "Sync repos between Mac and VPS, or show their git status. ALWAYS use when the user says 'sync', 'sync vps', 'sync shipmate', 'sync clawd', 'sync gapibot', 'sync gapila', 'sync .claude', 'sync dot-claude', 'push vps', 'pull vps', 'status vps', 'repos status', 'etat des repos', 'etat vps', or mentions syncing local and VPS code. Also triggers on 'dirty repos', 'uncommitted changes vps', 'what needs pushing'."
allowed-tools: Bash
---

# Sync VPS

Sync repos between local Mac and VPS via git, or show status of all repos across both environments.

The VPS runs repos inside a Docker container. All VPS git commands go through:
```
ssh vps 'docker exec -u node openclaw-gateway bash -c "..."'
```

## Repos

| Name | Local (Mac) | VPS (container) | Sync? |
|------|-------------|-----------------|:-----:|
| dot-claude | `~/.claude` | `/home/node/.claude` | yes |
| shipmate-agent | `~/Code/claude/shipmate-agent` | `/home/node/.openclaw/workspace-shipmate` | yes |
| shipmate-bot | `~/Code/claude/shipmate-bot` | `/home/node/projects/shipmate-bot` | yes |
| shipmate | `~/Code/claude/shipmate` | `/home/node/projects/shipmate` | yes |
| clawd | `~/Code/claude/clawd` | `/home/node/.openclaw/workspace` | yes |
| gapibot | `~/Code/claude/gapibot` | `/home/node/.openclaw/workspace-gapibot` | yes |
| gapila | `~/Code/nextjs/gapila` | `/home/node/projects/gapila` | yes |
| shared-skills | `~/Code/claude/shared-skills` | `/home/node/shared-skills` | yes |

All 8 repos are syncable (local Mac + VPS). `shared-skills` contains 24 skills shared across all agents via `extraDirs` in `openclaw.json`.

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
| `sync-vps.sh --sync dot-claude` | Sync only .claude config repo |
| `sync-vps.sh --dry-run` | Preview what would happen |
| `sync-vps.sh --sync -m "feat: add new skills"` | Sync with custom commit message |

Interactive mode (`-i`) shows all 7 repos (including dot-claude) with fzf, lets you pick one, see details, and choose an action (push, pull, sync both, discard). Also has a "Sync All" option at the top. Loops until you press Esc. Requires `fzf` (brew install fzf).

**Note:** Interactive mode runs in the terminal and requires user input — do NOT use `-i` from Claude Code. Always use the non-interactive flags instead.

### Intent mapping

| User says | Command |
|-----------|---------|
| "sync" / "sync vps" / "sync all" | push all |
| "sync shipmate" / "sync agent" | push that repo |
| "sync .claude" / "sync dot-claude" / "sync config" | `--sync dot-claude` |
| "sync both" / "sync bidirectionnel" | `--sync` |
| "pull" / "pull vps" / "recupere" | `--pull` |
| "push" / "envoie" | push (default) |
| "status" / "etat" / "repos status" | `--status` |
| "dry run" / "preview" | `--dry-run` |
| "interactif" / "interactive" / "menu" | `-i` |

### Commit messages

The script accepts `-m "message"` or `--message "message"` to set a custom commit message (applies to all repos in the invocation).

**When syncing repos with uncommitted changes, ALWAYS:**
1. Run `--dry-run` first to see what changed in each repo
2. Generate a meaningful commit message based on the actual changes (not a generic one)
3. Pass it via `-m "message"`
4. If repos have very different changes, run the script once per repo with a tailored message

**Do NOT** use the default generic "chore: sync" messages when you can see what the changes are.
