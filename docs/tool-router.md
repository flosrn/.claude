# Tool Router (skill-suggester) - Complete Documentation

> An intelligent hook that analyzes user prompts and suggests the optimal tools/skills/commands for the task.

## Overview

The Tool Router is a **UserPromptSubmit hook** that runs on every user message. It uses regex pattern matching to detect task intent and injects **assertive tool suggestions** into the context.

**Key insight**: Research shows that assertive cues ("ALWAYS use") significantly influence tool selection compared to passive suggestions ("consider using").

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         TOOL ROUTER FLOW                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    User Prompt                    Hook Processing               Claude Sees
    ───────────                    ───────────────               ───────────
┌────────────────┐            ┌────────────────────┐         ┌─────────────────┐
│ "Help me debug │    →       │ Pattern Match:     │    →    │ <tool-router>   │
│  this SQL      │            │  /sql|query|       │         │ MANDATORY:      │
│  query"        │            │   database/i       │         │ Use "databases" │
└────────────────┘            │                    │         │ skill           │
                              │ Trigger: "sql"     │         └─────────────────┘
                              └────────────────────┘
```

---

## How It Works

### Execution Flow

1. **Input**: Hook receives user prompt via stdin as JSON
2. **Filter**: Skip short prompts (<15 chars) or greetings
3. **Match**: Run 31 regex patterns against lowercased prompt
4. **Output**: If matches found, inject `<tool-router>` block

### Output Format

When tools are matched, the hook outputs:

```xml
<tool-router>
MANDATORY TOOL SELECTION:
ALWAYS use Skill "databases" for database work. Provides PostgreSQL/MongoDB patterns, optimization, migrations. [trigger: "sql"]
ALWAYS run /debug command for systematic debugging. Uses ULTRA THINK for root cause analysis. Do NOT guess at fixes. [trigger: "error"]

These tools exist because they provide better results than manual approaches.
Invoke the specified Skill/command/agent FIRST before attempting manual work.
</tool-router>
```

### Performance

- **Execution time**: ~5ms (pure regex, no network)
- **No dependencies**: Uses only Bun built-ins
- **Bilingual**: Supports English AND French triggers

---

## Pattern Categories

### 1. Media Processing (`ai-multimodal` skill)

**Triggers**: pdf, document, image, screenshot, photo, audio, video, mp3, mp4, transcri, ocr, extract, fichier, extraire, analyser.*image

**Suggestion**: Use Skill "ai-multimodal" for PDFs/images/audio/video. Do NOT manually read or describe media files.

---

### 2. External Repositories (`repomix` skill)

**Triggers**: third.?party, external.*repo, library.*code, security.*audit, github\.com, repo.*externe

**Suggestion**: Use Skill "repomix" for external repositories. Do NOT manually clone or browse external repos.

---

### 3. Semantic Code Operations (`lsp-navigation` skill)

**Triggers**: rename.*symbol, find.*references, find.*usages, where.*used, refactor.*name, renommer.*symbole

**Suggestion**: Use Skill "lsp-navigation" for find refs/rename. Do NOT use Grep for semantic code operations.

---

### 4. Code Understanding (`/explain` command)

**Triggers**: trace, architecture, flow, diagram, how.*works.*internally, deep.*dive, understand.*system

**Suggestion**: Run /explain command for deep code understanding. Do NOT manually search and read files.

---

### 5. Decision Making (`/brainstorm` command)

**Triggers**: best.*approach, should.*i.*use, compare, pros.*cons, evaluate, decision, trade.?offs, alternatives

**Suggestion**: Run /brainstorm command for decisions/comparisons. Uses Opus model with multi-round skeptical analysis.

---

### 6. Knowledge Persistence (`/create-context-docs`)

**Triggers**: learn.*about, document.*for.*later, reference, cheat.?sheet, remember.*how, knowledge.*base

**Suggestion**: Run /create-context-docs to save reusable knowledge in .claude/docs/

---

### 7. Design Work (`aesthetic` skill)

**Triggers**: beautiful, design, \bui\b, \bux\b, aesthetic, inspiration, dribbble, pretty, visual, look.*feel, beau, joli

**Suggestion**: Use Skill "aesthetic" for design work. Provides structured design analysis using Gemini vision.

---

### 8. Complex Problems (`/ultrathink`)

**Triggers**: complex, elegant, perfect, best.*way, architect, clean.*code, masterpiece, ideal.*solution, parfait

**Suggestion**: Run /ultrathink for complex problems requiring craftsmanship. Deep thinking mode for elegant solutions.

---

### 9. UI Debugging (`vision-analyzer` agent)

**Triggers**: screenshot, visual.*bug, ui.*issue, looks.*wrong, display.*problem, layout.*broken, capture.*écran

**Suggestion**: Use Task agent "vision-analyzer" for UI bugs. Analyzes screenshots to identify visual issues.

---

### 10. Database Work (`databases` skill)

**Triggers**: sql, query, database, postgres, mongo, migration, schema, index, performance.*query, base.*données

**Suggestion**: Use Skill "databases" for database work. Provides PostgreSQL/MongoDB patterns, optimization, migrations.

---

### 11. Bug Fixing (`/debug` command)

**Triggers**: error, exception, bug, crash, broken, not working, fails, ça marche pas, ne fonctionne pas, erreur, plantage

**Suggestion**: Run /debug command for systematic debugging. Uses ULTRA THINK for root cause analysis. Do NOT guess at fixes.

---

### 12. Mass Changes (`/refactor` command)

**Triggers**: refactor.*all, rename.*everywhere, change.*across, update.*all.*files, mass.*update

**Suggestion**: Run /refactor command for mass code changes. Uses parallel Snipper agents for speed. Do NOT edit files one by one.

---

### 13. Prompt Engineering (`create-prompt` skill)

**Triggers**: write.*prompt, create.*prompt, optimize.*prompt, improve.*prompt, system.*prompt

**Suggestion**: Use Skill "create-prompt" for prompt engineering. Covers Anthropic/OpenAI best practices.

---

### 14. Claude Code Configuration (`claude-code` skill)

**Triggers**: \bhook\b, \bskill\b, \bcommand\b, \bagent\b, \bsubagent\b, \bmcp\b, slash.*command, task.*tool

**Suggestion**: Use Skill "claude-code" for Claude Code configuration (hooks, skills, commands, agents, MCP).

---

### 15. Documentation Search (`docs-seeker` skill)

**Triggers**: documentation.*for, docs.*for, how.*to.*use.*library, llms\.txt, context7, chercher.*doc

**Suggestion**: Use Skill "docs-seeker" for library/framework documentation. Uses context7.com llms.txt.

---

### 16-20. Makerkit Integration

**Triggers**: Various patterns for Supabase, Drizzle, migrations, health checks, Makerkit patterns

**Suggestions**: Specialized Makerkit commands and skills for database sync, updates, health checks.

---

### 21. Systematic Debugging (`debugging` skill)

**Triggers**: root.*cause, systematic.*debug, test.*fail, why.*fail, supabase.*error, drizzle.*error, hydration.*mismatch

**Suggestion**: Use Skill "debugging" for systematic debugging. Four-phase framework + Makerkit patterns.

---

### 22. TypeScript Strict (`typescript-strict` skill)

**Triggers**: \bany\b.*type, type.*error, ts-ignore, type.*guard, unknown.*type, zod.*schema, type.*safety

**Suggestion**: Use Skill "typescript-strict" for TypeScript type safety. Patterns for avoiding `any`, type guards, Zod.

---

### 23-27. React/Next.js Optimization

**Triggers**: use cache, cacheLife, react.*compiler, code.*splitting, optimize.*next, ViewTransition

**Suggestions**: Cache Components, React Compiler, code-splitting, performance analysis, React 19 patterns.

---

### 28. MCP Management (`mcp-management` skill)

**Triggers**: mcp.*scope, user.*scope, project.*scope, \.mcp\.json, mcp.*server

**Suggestion**: Use Skill "mcp-management" for MCP server configuration and scopes.

---

### 29. Web Search (`websearch` agent)

**Triggers**: search.*web, web.*search, what's.*the.*latest, current.*news, latest.*version

**Suggestion**: Use Task agent "websearch" for current information, news, or documentation not in codebase.

---

### 30. Deep Research (`intelligent-search` agent)

**Triggers**: deep.*search, intelligent.*search, compare.*sources, multi.*provider, perplexity, tavily

**Suggestion**: Use Task agent "intelligent-search" for deep research with multiple providers.

---

### 31. Code Review (`code-review-mastery` skill)

**Triggers**: code.*review, review.*pr, check.*my.*code, audit.*code, revue.*code

**Suggestion**: Use Skill "code-review-mastery" for complete code review lifecycle. WHAT to review (OWASP, SOLID) + HOW to interact.

---

## Integration with CLAUDE.md

The Tool Router works in tandem with the global `CLAUDE.md` instruction:

```markdown
## Tool Router (MANDATORY)

When `<tool-router>` appears in context, you MUST:
1. **Invoke the specified Skill/command/agent FIRST** - do not skip
2. **Do NOT manually replicate** what the tool does
3. These suggestions exist because you forget specialized tools

This is non-negotiable. The tool-router identifies the RIGHT tool.
```

---

## Configuration

The hook is registered in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "bun ~/.claude/scripts/hook-skill-suggester.ts"
          }
        ]
      }
    ]
  }
}
```

---

## Source Code Analysis

**Location**: `~/.claude/scripts/hook-skill-suggester.ts`

**Key Components**:

1. **Input Parsing**: Reads JSON from stdin, extracts `prompt` field
2. **Skip Logic**: Ignores prompts <15 chars or starting with greetings
3. **Pattern Matching**: 31 regex patterns with trigger capture
4. **Output Generation**: Builds `<tool-router>` block with all matches

**Pattern Template**:
```typescript
const trigger = matchTrigger(
  /pattern|alternate|français/i,
  prompt
);
if (trigger) {
  suggestions.push(
    `ALWAYS use [Tool] for [purpose]. [Instructions]. [trigger: "${trigger}"]`
  );
}
```

---

## Adding New Patterns

To add a new tool suggestion:

1. **Identify triggers**: What words/phrases indicate this tool is needed?
2. **Support both languages**: Include English AND French patterns
3. **Write assertive instruction**: "ALWAYS use..." not "consider using..."
4. **Include trigger in output**: Helps users understand why tool was suggested

**Example**:
```typescript
// 99. New Tool - Purpose
const trigger99 = matchTrigger(
  /keyword1|keyword2|mot_français/i,
  prompt,
);
if (trigger99) {
  suggestions.push(
    `ALWAYS use [Tool Name] for [purpose]. [What it provides]. [trigger: "${trigger99}"]`,
  );
}
```

---

## Why Assertive Language?

Research on LLM behavior shows:
- **Passive**: "Consider using X" → Often ignored
- **Assertive**: "ALWAYS use X" → Much higher compliance
- **Mandatory**: "MUST use X FIRST" → Near-guaranteed compliance

The Tool Router uses assertive language because specialized tools exist for a reason - they provide better results than manual approaches.

---

## Debugging

Enable debug output by examining hook logs:

```bash
# Check hook execution
tail -f ~/.claude/logs/hooks.log

# Test pattern matching manually
echo '{"prompt":"help me debug this sql query"}' | bun ~/.claude/scripts/hook-skill-suggester.ts
```

---

## Best Practices

1. **Trust the suggestions** - Tools are suggested because they're better
2. **Don't fight the router** - If you need a different approach, be explicit
3. **Report missing patterns** - If a tool should trigger but doesn't, add the pattern
4. **Use French or English** - Both work equally well
5. **Be specific** - More specific prompts get more accurate suggestions
