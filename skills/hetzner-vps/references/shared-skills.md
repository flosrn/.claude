# Shared Skills Architecture

## Overview

Skills shared across all agents (Clawd, Gapibot, Shipmate) live in a dedicated repo (`flosrn/shared-skills`, private) instead of being duplicated per workspace.

## How It Works

```
Mac (local)                          VPS (container)
~/Code/claude/shared-skills/ ──git──► /root/shared-skills/  (host)
                                          │
                                     bind mount :ro
                                          │
                                          ▼
                                     /home/node/shared-skills/  (container)
                                          │
                                     openclaw.json extraDirs
                                          │
                                          ▼
                                     All agents load shared skills
```

## Key Configuration

**openclaw.json:**
```json
{
  "skills": {
    "load": {
      "extraDirs": ["/home/node/shared-skills"]
    }
  },
  "commands": {
    "nativeSkills": false
  }
}
```

- `extraDirs` — OpenClaw scans these directories for skills in addition to each agent's workspace `skills/`
- `nativeSkills: false` — Disables automatic Telegram command registration (handled by `telegram-sync`)

**Docker compose (openclaw):**
```yaml
volumes:
  - /root/shared-skills:/home/node/shared-skills:ro
```

The `:ro` mount means git operations (pull) must run on the **host** (`ssh vps`), not inside the container. The `sync-vps.sh` script handles this via `HOST_REPOS` + `vps_host_exec()`.

## Sync & Telegram Command Registration

When `sync-vps.sh` pushes changes to a skill-containing repo, it automatically registers Telegram bot menu commands:

```
sync-vps.sh push shared-skills
    │
    ├── git push + VPS git pull (host-side)
    │
    └── post_sync_telegram()
         │
         └── docker exec register_commands.py
              ├── Scans workspace + extraDirs skills
              ├── Merges with existing customCommands
              ├── Truncates descriptions (Telegram ~5000 char total budget)
              └── Calls Telegram API setMyCommands per agent
```

**Skill repo → agent mapping** (in `sync-vps.sh`):

| Repo | Affects agent(s) |
|------|-----------------|
| `clawd` | `default` only |
| `gapibot` | `gapibot` only |
| `shipmate-agent` | `shipmate` only |
| `shared-skills` | **all agents** |

Non-skill repos (`shipmate-bot`, `shipmate`, `gapila`, `dot-claude`) do not trigger sync.

## Scripts (in `shared-skills/telegram-sync/scripts/`)

| Script | Purpose |
|--------|---------|
| `diagnostic.py` | Audit: list matched, unmatched skills, orphan commands |
| `add_command.py` | Manually add a single command to openclaw.json |
| `register_commands.py` | Full pipeline: scan → merge → fit descriptions → API call |

## Telegram API Constraint

Telegram's `setMyCommands` has an **undocumented ~5000 character total description budget**. Exceeding it triggers `BOT_COMMANDS_TOO_MUCH` even with < 100 commands. `register_commands.py` auto-truncates descriptions proportionally to fit.

## Local (Mac) Setup

16 symlinks from `~/.claude/skills/` → `~/Code/claude/shared-skills/` for Claude Code local access. The `sync-vps.sh` script syncs `shared-skills` as one of 8 repos.
