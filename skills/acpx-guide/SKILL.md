---
name: acpx-guide
description: "Guide for using acpx to run Claude Code (or Codex, Gemini, etc.) from an OpenClaw agent. Covers the 'telephone game' pattern (exec → acpx CLI), known bugs with sessions_spawn, configuration, prerequisites, and troubleshooting. Use when: 'acpx', 'acp', 'lance claude code', 'spawn claude', 'piloter claude code', 'sessions_spawn', 'telephone game', 'acpx claude exec', 'run claude code from agent', 'comment lancer claude code depuis un agent', or when debugging ACP session failures."
---

# acpx Guide — Running Claude Code from an OpenClaw Agent

acpx is the ACP (Agent Client Protocol) runtime backend plugin for OpenClaw. It lets your agent spawn Claude Code (or Codex, Gemini, etc.) as a subprocess and get structured output back.

This guide is based on real production experience. It documents what actually works, what doesn't, and why.

## The One Pattern That Works: "Telephone Game"

The only reliable way to run Claude Code from an OpenClaw agent is via `exec` calling the `acpx` CLI directly. The community calls this the "telephone game" pattern because the agent talks to acpx which talks to Claude Code.

```
Agent → exec tool → acpx CLI → Claude Code subprocess → result back to agent
```

### How to use it

1. Write your prompt to a file (avoids shell quoting issues):
```
write: /tmp/my-prompt.txt
"Your prompt for Claude Code here..."
```

2. Launch acpx via exec:
```
exec: cd /your/project && /app/extensions/acpx/node_modules/.bin/acpx --approve-all --format text claude exec --file /tmp/my-prompt.txt 2>&1
```
Use `yieldMs: 10000` so it backgrounds after 10 seconds.

3. Poll for the result:
```
process(poll, sessionId, timeout: 30000)
```
Repeat until you get output. Between polls, you can send Telegram updates.

4. When output arrives, post the result to the user.

### Key flags

| Flag | Purpose |
|------|---------|
| `--approve-all` | Auto-approve all permission requests (no interactive prompts) |
| `--format text` | Human-readable output (vs `json` for structured) |
| `--file <path>` | Read prompt from file (avoids quoting nightmares) |
| `--timeout <sec>` | Optional max time — omit to let Claude Code finish naturally |
| `--cwd <dir>` | Working directory (defaults to current dir) |
| `--model <id>` | Override the model |

### Why a file for the prompt?

Multi-line prompts with quotes, backticks, and special characters break when passed through `exec` → shell → acpx. Writing to a file first, then using `--file`, eliminates all quoting issues. Always do this.

## What Does NOT Work: sessions_spawn

**Do not use `sessions_spawn(runtime: "acp")`** to spawn Claude Code. It's buggy in OpenClaw 2026.3.13.

The symptom: Claude Code starts but produces no output for 60+ seconds, then the stream log shows "may be waiting for interactive input." `sessions_history` returns empty messages forever.

### Why it fails

The gateway calls `acpx claude prompt --session <name>`, but never creates the session first with `acpx claude sessions new`. This is documented in [GitHub issue #31273](https://github.com/openclaw/openclaw/issues/31273). The acpx CLI returns `NO_SESSION`, the gateway reports `ACP_TURN_FAILED`, and the whole thing stalls.

### Other sessions_spawn issues

| Issue | Description |
|-------|-------------|
| [#31273](https://github.com/openclaw/openclaw/issues/31273) | `prompt --session` fails without `sessions new` first |
| [#28786](https://github.com/openclaw/openclaw/issues/28786) | acpx spawns without PTY → Ink raw mode crash (fixed in #34020) |
| [#35861](https://github.com/openclaw/openclaw/issues/35861) | sessions_spawn fails with exit code 5 — bypass script needed |
| [#31065](https://github.com/openclaw/openclaw/issues/31065) | ACP_TURN_FAILED on every sessions_spawn call |

Thread binding (`thread: "auto"`) for Telegram is also not supported — it returns "Thread bindings do not support ACP thread spawn for telegram."

## Built-in Agents

acpx ships with these harness aliases:

| Agent | Command spawned |
|-------|----------------|
| `claude` | `npx -y @zed-industries/claude-agent-acp@^0.21.0` |
| `codex` | `npx @zed-industries/codex-acp` |
| `pi` | `npx pi-acp` |
| `opencode` | `npx -y opencode-ai acp` |
| `gemini` | `gemini` |
| `kimi` | (built-in) |

The source of truth is `ACPX_BUILTIN_AGENT_COMMANDS` in the acpx source code at `/app/extensions/acpx/src/runtime-internals/mcp-agent-command.ts`.

## Configuration

### Enable acpx in openclaw.json

```json
{
  "acp": {
    "enabled": true,
    "backend": "acpx",
    "defaultAgent": "claude",
    "dispatch": { "enabled": true }
  },
  "plugins": {
    "entries": {
      "acpx": { "enabled": true }
    }
  }
}
```

Enable with CLI: `openclaw plugins enable acpx`

Verify it loaded: look for `acpx runtime backend ready` in gateway logs.

### agentToAgent permissions

If using `sessions_history` to read ACP session output, `"claude"` must be in `tools.agentToAgent.allow`:

```json
{
  "tools": {
    "agentToAgent": {
      "enabled": true,
      "allow": ["gapibot", "shipmate", "claude"]
    },
    "sessions": {
      "visibility": "all"
    }
  }
}
```

Without this, `sessions_history` returns `"forbidden"`.

## Prerequisites (VPS / Docker)

These components live inside the container and are lost on every recreate. They must be reinstalled via `init-gateway.sh`:

| Component | How to install | Persistence |
|-----------|---------------|-------------|
| Claude Code CLI | `curl -fsSL https://claude.ai/install.sh \| bash` (as node user) | `init-gateway.sh` reinstalls |
| Playwright MCP | `npm install -g @playwright/mcp` (as root) | `npm-globals.txt` |
| npm cache fix | `chown -R node:node /home/node/.npm` | `init-gateway.sh` step 3 |

### The npm cache trap

When you `npm install -g` as root, it poisons the npm cache at `/home/node/.npm`. Then acpx (running as node) can't `npx` packages → `EACCES` → session stalls silently. Always run `chown -R node:node /home/node/.npm` after any root npm install.

### Pre-warming

The first `acpx claude exec` after a restart downloads `@zed-industries/claude-agent-acp` via npx, which takes 30-60 seconds. Run a quick warm-up after each restart to avoid the first-run stall:

```bash
acpx --approve-all --timeout 20 claude exec "say ok"
```

## Troubleshooting

### "no output for 60s. It may be waiting for interactive input."

Causes (check in order):
1. **npm cache permissions** — `ls -la /home/node/.npm` shows root ownership → `chown -R node:node /home/node/.npm`
2. **Claude Code not installed** — `/home/node/.local/bin/claude --version` fails → run installer
3. **Browser container crashed** — `curl -sf http://172.18.0.200:9222/json/version` fails → restart browser: `docker compose restart openclaw-browser`
4. **Stale acpx sessions** — `ps aux | grep claude-agent-acp` shows old processes → `pkill -f claude-agent-acp`

### "ACP_TURN_FAILED" or "NO_SESSION"

This is the sessions_spawn bug (#31273). Don't use sessions_spawn — use the telephone game pattern (exec → acpx CLI).

### "Thread bindings do not support ACP thread spawn for telegram"

Thread binding for ACP is not supported on Telegram in OpenClaw 2026.3.13. Use polling with `process(poll)` instead.

### acpx claude exec times out

1. Check if the browser container is healthy: `curl -sf http://172.18.0.200:9222/json/version`
2. Check for leftover pages: `curl -sf http://172.18.0.200:9222/json/list` — if pages from previous sessions exist, restart the browser container
3. Test without Playwright: `acpx --approve-all --timeout 15 claude exec "say hello"` — if this works, the issue is browser-related

### Claude Code uses wrong MCP server

If both `playwright` and `playwright-stealth` are configured in `~/.claude.json`, Claude Code may pick the wrong one. Specify explicitly in the prompt: "Use `mcp__playwright__*` tools, NOT `playwright-stealth`."

## Resources

- [Official ACP docs](https://docs.openclaw.ai/tools/acp-agents)
- [acpx GitHub repo](https://github.com/openclaw/acpx)
- [DeepWiki guide](https://deepwiki.com/openclaw/acpx/1.1-installation-and-quick-start)
- [ACP Harness Router skill](https://lobehub.com/skills/dbillionaer-wholesaile-acp-router) — community "telephone game" pattern
- [Coding Lead skill](https://clawhub.ai/skills/coding-lead) — ACP with auto-fallback
- [Bug #31273](https://github.com/openclaw/openclaw/issues/31273) — the sessions_spawn bug
- [Bug #28786](https://github.com/openclaw/openclaw/issues/28786) — PTY/Ink crash (fixed)
- [Bug #35861](https://github.com/openclaw/openclaw/issues/35861) — bypass script workaround
