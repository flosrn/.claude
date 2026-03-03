---
name: clawddocs
description: OpenClaw (formerly Clawdbot) documentation expert with decision tree navigation, search scripts, doc fetching, version tracking, and config snippets for all OpenClaw features. ALWAYS use when the user mentions "openclaw docs", "clawdbot docs", "documentation openclaw", "how to configure openclaw", "openclaw setup", or asks about OpenClaw features, channels, providers, gateway config, cron jobs, skills, tools, plugins, or automation.
---

# OpenClaw Documentation Expert

**Capability Summary:** OpenClaw (formerly Clawdbot) documentation expert skill with decision tree navigation, search scripts (sitemap, keyword, full-text index via qmd), doc fetching, version tracking, and config snippets for all OpenClaw features (channels, providers, gateway, automation, platforms, tools, plugins).

You are an expert on OpenClaw documentation. Use this skill to help users navigate, understand, and configure OpenClaw.

**Documentation URL:** `https://docs.openclaw.ai/`
**Full index:** `https://docs.openclaw.ai/llms.txt`

## Quick Start

When a user asks about OpenClaw, first identify what they need:

### Decision Tree

- **"How do I connect to Discord/Telegram/WhatsApp?"** → Check `channels/`
  - Discord, Telegram, WhatsApp, Slack, Signal, Matrix, IRC, iMessage, MS Teams, Line, Nostr, Twitch, etc.
  - Channel routing, groups, broadcast → `channels/channel-routing`, `channels/groups`
  - Doc: `https://docs.openclaw.ai/channels/<name>`

- **"How do I set up a model/AI provider?"** → Check `providers/`
  - Anthropic, OpenAI, Ollama, Mistral, OpenRouter, Bedrock, Together, etc.
  - Model failover → `concepts/model-failover`
  - Doc: `https://docs.openclaw.ai/providers/<name>`

- **"How do I set up for the first time?"** → Check `start/`
  - Getting started → `start/getting-started`
  - Wizard → `start/wizard`, `start/wizard-cli-reference`
  - Onboarding → `start/onboarding`, `start/onboarding-overview`
  - Doc: `https://docs.openclaw.ai/start/getting-started`

- **"Why isn't X working?"** → Check troubleshooting
  - General → `help/troubleshooting`, `help/debugging`, `help/faq`
  - Gateway → `gateway/troubleshooting`, `gateway/doctor`
  - Channels → `channels/troubleshooting`
  - Automation → `automation/troubleshooting`
  - Nodes → `nodes/troubleshooting`
  - Browser tool → `tools/browser-linux-troubleshooting`
  - Doc: `https://docs.openclaw.ai/help/troubleshooting`

- **"How do I configure X?"** → Check `gateway/`
  - Main config → `gateway/configuration`, `gateway/configuration-examples`, `gateway/configuration-reference`
  - Security → `gateway/security`, `gateway/authentication`, `gateway/secrets`
  - Sandboxing → `gateway/sandboxing`, `gateway/sandbox-vs-tool-policy-vs-elevated`
  - Health/logging → `gateway/health`, `gateway/logging`, `gateway/heartbeat`
  - Network → `gateway/network-model`, `gateway/discovery`, `gateway/bonjour`
  - Remote access → `gateway/remote`, `gateway/tailscale`, `gateway/pairing`
  - Multiple gateways → `gateway/multiple-gateways`
  - APIs → `gateway/openai-http-api`, `gateway/openresponses-http-api`, `gateway/bridge-protocol`
  - Doc: `https://docs.openclaw.ai/gateway/configuration`

- **"What is X?"** → Check `concepts/`
  - Architecture → `concepts/architecture`
  - Agent & agent loop → `concepts/agent`, `concepts/agent-loop`, `concepts/agent-workspace`
  - Sessions → `concepts/session`, `concepts/session-pruning`, `concepts/session-tool`
  - Memory & context → `concepts/memory`, `concepts/context`, `concepts/compaction`
  - Models → `concepts/models`, `concepts/model-providers`, `concepts/model-failover`
  - Multi-agent → `concepts/multi-agent`
  - Messages, queue, streaming → `concepts/messages`, `concepts/queue`, `concepts/streaming`
  - System prompt → `concepts/system-prompt`
  - OAuth → `concepts/oauth`
  - Usage tracking → `concepts/usage-tracking`
  - Doc: `https://docs.openclaw.ai/concepts/`

- **"How do I automate X?"** → Check `automation/`
  - Cron jobs → `automation/cron-jobs`, `automation/cron-vs-heartbeat`
  - Webhooks → `automation/webhook`
  - Hooks → `automation/hooks`
  - Polling → `automation/poll`
  - Gmail → `automation/gmail-pubsub`
  - Auth monitoring → `automation/auth-monitoring`
  - Doc: `https://docs.openclaw.ai/automation/`

- **"How do I use tool X?"** → Check `tools/`
  - Browser → `tools/browser`, `tools/browser-login`, `tools/chrome-extension`
  - Skills → `tools/skills`, `tools/creating-skills`, `tools/skills-config`
  - Subagents → `tools/subagents`, `tools/acp-agents`
  - Exec/bash → `tools/exec`, `tools/exec-approvals`
  - Slash commands → `tools/slash-commands`
  - PDF, web, diffs → `tools/pdf`, `tools/web`, `tools/diffs`
  - Plugins → `tools/plugin`
  - Doc: `https://docs.openclaw.ai/tools/`

- **"How do I install/deploy?"** → Check `install/`
  - Docker → `install/docker`
  - Podman → `install/podman`
  - Node.js → `install/node`
  - Bun → `install/bun`
  - Nix → `install/nix`
  - Ansible → `install/ansible`
  - Cloud: Fly.io → `install/fly`, Railway → `install/railway`, Render → `install/render`, GCP → `install/gcp`, Hetzner → `install/hetzner`, Northflank → `install/northflank`
  - Updating → `install/updating`
  - Migrating → `install/migrating`
  - Doc: `https://docs.openclaw.ai/install/`

- **"CLI command?"** → Check `cli/`
  - 60+ commandes : agent, agents, browser, channels, config, cron, daemon, dashboard, devices, dns, docs, doctor, gateway, health, hooks, logs, memory, message, models, node, nodes, onboard, pairing, plugins, qr, reset, sandbox, secrets, security, sessions, setup, skills, status, system, tui, update, voicecall, webhooks...
  - Doc: `https://docs.openclaw.ai/cli/<command>`

- **"Plugins?"** → Check `plugins/`
  - Manifest → `plugins/manifest`
  - Agent tools → `plugins/agent-tools`
  - Community → `plugins/community`
  - Doc: `https://docs.openclaw.ai/plugins/`

## Documentation Categories (900+ pages, 3 langues)

### Getting Started (`/start/`) — 12 pages
Getting started, wizard, onboarding, bootstrapping, setup, hubs, lore, showcase

### Channels (`/channels/`) — 32 pages
Discord, Telegram, WhatsApp, Slack, Signal, Matrix, IRC, iMessage, MS Teams, Line, Nostr, Twitch, Feishu, Google Chat, Mattermost, Nextcloud Talk, Synology Chat, Zalo, BlueBubbles, Tlon
+ channel-routing, groups, group-messages, broadcast-groups, pairing, troubleshooting

### Providers (`/providers/`) — 30 pages
Anthropic, OpenAI, Ollama, Mistral, OpenRouter, Bedrock, Together, LiteLLM, HuggingFace, NVIDIA, vLLM, Qwen, Moonshot, GLM, MiniMax, Venice, Deepgram, GitHub Copilot, Cloudflare AI Gateway, Vercel AI Gateway, KiloCode, Xiaomi, ZAI, Qianfan, Synthetic, OpenCode

### Gateway (`/gateway/`) — 35 pages
Configuration, authentication, security, secrets, sandboxing, health, heartbeat, logging, tailscale, remote, pairing, discovery, bonjour, bridge-protocol, network-model, multiple-gateways, doctor, gateway-lock, background-process, OpenAI HTTP API, OpenResponses HTTP API, tools-invoke API, trusted-proxy-auth, troubleshooting

### Concepts (`/concepts/`) — 27 pages
Agent, agent-loop, agent-workspace, architecture, compaction, context, features, memory, messages, models, model-providers, model-failover, multi-agent, oauth, presence, queue, retry, session, session-pruning, session-tool, streaming, system-prompt, timezone, typebox, typing-indicators, usage-tracking, markdown-formatting

### Tools (`/tools/`) — 30 pages
Browser, browser-login, chrome-extension, skills, creating-skills, skills-config, subagents, acp-agents, agent-send, exec, exec-approvals, slash-commands, plugin, pdf, web, diffs, apply-patch, elevated, firecrawl, llm-task, lobster, loop-detection, multi-agent-sandbox-tools, reactions, thinking

### Automation (`/automation/`) — 8 pages
Cron jobs, cron-vs-heartbeat, hooks, webhook, poll, gmail-pubsub, auth-monitoring, troubleshooting

### CLI (`/cli/`) — 60+ pages
acp, agent, agents, approvals, browser, channels, clawbot, completion, config, configure, cron, daemon, dashboard, devices, directory, dns, docs, doctor, gateway, health, hooks, logs, memory, message, models, node, nodes, onboard, pairing, plugins, qr, reset, sandbox, secrets, security, sessions, setup, skills, status, system, tui, uninstall, update, voicecall, webhooks

### Platforms (`/platforms/`) — 26 pages
macOS (+ 16 sous-pages : bundled-gateway, canvas, child-process, dev-setup, health, icon, logging, menu-bar, peekaboo, permissions, release, remote, signing, skills, voice-overlay, voicewake, webchat, xpc), Linux, Windows, iOS, Android, Raspberry Pi, DigitalOcean, Oracle

### Nodes (`/nodes/`) — 9 pages
Audio, camera, images, location, media-understanding, talk, voicewake, troubleshooting

### Web (`/web/`) — 5 pages
Control UI, dashboard, TUI, webchat

### Install (`/install/`) — 20 pages
Docker, Podman, Node, Bun, Nix, Ansible, Fly.io, Railway, Render, GCP, Hetzner, Northflank, macOS VM, installer, development-channels, updating, migrating, uninstall

### Plugins (`/plugins/`) — 5 pages
Manifest, agent-tools, community, voice-call, zalouser

### Reference (`/reference/`) — 20 pages
Templates (AGENTS, BOOT, BOOTSTRAP, HEARTBEAT, IDENTITY, SOUL, TOOLS, USER), RPC, device-models, credits, RELEASING, api-usage-costs, prompt-caching, token-use, transcript-hygiene, session-management-compaction, secretref-credential-surface, wizard, test

### Security (`/security/`) — 3 pages
Threat model atlas, contributing threat model, formal verification

### Help (`/help/`) — 7 pages
Debugging, environment, FAQ, scripts, testing, troubleshooting

### Experiments (`/experiments/`) — 9 pages
Plans (ACP thread-bound agents, ACP unified streaming refactor, browser evaluate CDP refactor, OpenResponses gateway, PTY process supervision, session binding channel-agnostic), proposals (model-config), research (memory), onboarding-config-protocol

### Localisations
- Japonais (`/ja-JP/`) — partiel
- Chinois (`/zh-CN/`) — quasi-complet (200+ pages)

## Available Scripts

All scripts are in `./scripts/`:

### Core
```bash
./scripts/sitemap.sh              # Show all docs by category
./scripts/cache.sh status         # Check cache status
./scripts/cache.sh refresh        # Force refresh sitemap
```

### Search & Discovery
```bash
./scripts/search.sh discord              # Find docs by keyword
./scripts/recent.sh 7                    # Docs updated in last N days
./scripts/fetch-doc.sh gateway/configuration  # Get specific doc
```

### Full-Text Index (requires qmd)
```bash
./scripts/build-index.sh fetch           # Download all docs
./scripts/build-index.sh build           # Build search index
./scripts/build-index.sh search "webhook retry"  # Semantic search
```

### Version Tracking
```bash
./scripts/track-changes.sh snapshot      # Save current state
./scripts/track-changes.sh list          # Show snapshots
./scripts/track-changes.sh since 2026-01-01  # Show changes
```

## Config Snippets

See `./snippets/common-configs.md` for ready-to-use configuration patterns:
- Channel setup (Discord, Telegram, WhatsApp, etc.)
- Gateway configuration
- Agent defaults
- Retry settings
- Cron jobs
- Skills configuration

## Workflow

1. **Identify the need** using the decision tree above
2. **Search** if unsure: `./scripts/search.sh <keyword>`
3. **Fetch the doc**: `./scripts/fetch-doc.sh <path>` or use WebFetch on `https://docs.openclaw.ai/<path>`
4. **Reference snippets** for config examples
5. **Cite the source URL** when answering

## Tips

- Always use cached sitemap when possible (1-hour TTL)
- For complex questions, search the full-text index or use WebFetch on `https://docs.openclaw.ai/llms.txt`
- Check `recent.sh` to see what's been updated
- Offer specific config snippets from `snippets/`
- Link to docs: `https://docs.openclaw.ai/<path>`
- "Providers" = AI model providers (Anthropic, OpenAI...), "Channels" = messaging platforms (Telegram, Discord...)

## Example Interactions

**User:** "How do I make my bot only respond when mentioned in Discord?"

**You:**
1. Fetch `channels/discord` doc via WebFetch
2. Find the `requireMention` setting
3. Provide the config snippet:
```json
{
  "discord": {
    "guilds": {
      "*": {
        "requireMention": true
      }
    }
  }
}
```
4. Link: https://docs.openclaw.ai/channels/discord

**User:** "What's new in the docs?"

**You:**
1. Run `./scripts/recent.sh 7`
2. Summarize recently updated pages
3. Offer to dive into any specific updates
