---
name: agent-memory
description: "Save a thematic memory to any OpenClaw agent workspace (gapibot, clawd, shipmate-agent). Writes a dated markdown file locally, then syncs to VPS. ALWAYS use when the user says 'save memory to gapibot', 'enregistre dans clawd', 'memory pour shipmate', 'sauvegarde ça dans l agent', 'note ça pour gapibot', 'ajoute cette mémoire', 'agent memory', or wants to persist knowledge/research/decisions in an agent's memory directory. Also use when you just completed research or a decision with the user and they ask to save it for a specific agent. Do NOT use for Claude Code's own auto-memory system (~/.claude/projects/) — that's a different system."
argument-hint: "<agent> <topic-slug> [content or 'from conversation']"
---

# Agent Memory

Save thematic memories to OpenClaw agent workspaces. Each agent has a `memory/` directory with dated markdown files that the agent reads at session startup.

## Agent Map

| Agent name | Aliases | Local path |
|-----------|---------|------------|
| `gapibot` | gapi, gapibot | `~/Code/claude/gapibot/` |
| `clawd` | clawd, claw | `~/Code/claude/clawd/` |
| `shipmate-agent` | shipmate, ship | `~/Code/claude/shipmate-agent/` |

## Execution

### Step 1: Parse the request

Extract from the user's message or conversation context:
- **Agent**: which agent to save to (required)
- **Topic**: a short slug for the filename (e.g., `midscene-qa-research`)
- **Content**: either explicitly provided, or synthesized from the current conversation

If the agent isn't specified, ask. If the topic isn't clear, propose one based on the content.

### Step 2: Write the memory file

**Filename**: `YYYY-MM-DD-<topic-slug>.md` in the agent's `memory/` directory.

**Format** — follow this template exactly:

```markdown
# <Title — descriptive, not just the slug>

## Contexte

<1-3 sentences: why this memory exists, what triggered it>

## <Main sections — adapt to content>

<The actual knowledge to preserve. Use markdown freely: tables, code blocks, lists.>
<Be thorough — the agent will read this in future sessions without the current conversation context.>
<Include decisions made, alternatives considered, and rationale.>

**Tags:** tag1, tag2, tag3
```

Guidelines for writing good agent memories:
- The agent reads these cold — include enough context to be useful standalone
- Tags are critical for searchability — include entities, technologies, and concepts
- Don't include session metadata (session key, session ID, source) — that's for auto-generated session logs, not thematic memories
- Keep it factual and actionable — this isn't a journal
- If referencing files/paths, use the VPS paths (e.g., `/home/node/projects/gapila/`) since the agent runs on the VPS

### Step 3: Verify no duplicate

Before writing, check if a memory with the same topic already exists:
```bash
ls ~/Code/claude/<agent>/memory/ | grep "<topic-slug>"
```

If a file exists with the same slug, read it and ask the user: update the existing one or create a new dated version?

### Step 4: Write the file

Use the Write tool to create the file at:
```
~/Code/claude/<agent>/memory/YYYY-MM-DD-<topic-slug>.md
```

### Step 5: Sync to VPS

Push the agent's repo to the VPS:
```bash
~/.claude/scripts/sync-vps.sh <agent-name>
```

Use the agent name as it appears in the sync script: `gapibot`, `clawd`, `shipmate-agent`.

Report the sync result to the user.

### Step 6: Confirm

Tell the user:
- File path written
- Sync status
- Suggest they can ask the agent about this topic in their next session
