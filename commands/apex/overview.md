---
description: APEX System Overview
argument-hint: (no arguments - displays visual guide)
---

# APEX Visual Guide

> **APEX** (Analyze-Plan-Execute-eXamine) - A multi-session workflow orchestrator for complex implementation tasks.

**For quick reference**: See [CLAUDE.md](./CLAUDE.md)
**For command details**: See individual command files (1-analyze.md, 2-plan.md, etc.)

---

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           APEX WORKFLOW                                      │
│                                                                              │
│  "Think before you act. Think deeper. Then act precisely."                  │
└─────────────────────────────────────────────────────────────────────────────┘

                         ┌──────────────────┐
                         │  User Request    │
                         │  "Add feature X" │
                         └────────┬─────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
                    ▼                           ▼
    ┌───────────────────────────┐   ┌───────────────────────────┐
    │  VAGUE / EXPLORATORY?     │   │  CLEAR / SPECIFIC?        │
    │  /apex:0-brainstorm       │   │  Skip to analyze          │
    │  • Interactive Q&A        │   │                           │
    │  • Adaptive agent routing │   │                           │
    │  • Research loops (max 5) │   │                           │
    │  • Output: seed.md        │   │                           │
    └─────────────┬─────────────┘   └─────────────┬─────────────┘
                  │                               │
                  └───────────────┬───────────────┘
                                  │
                                  ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  PHASE 1: ANALYZE                              /apex:1-analyze                │
│  ─────────────────                                                            │
│  • Create task folder: .claude/tasks/NN-kebab-name/                          │
│  • Launch parallel agents (adaptive based on scores)                         │
│  • ULTRA THINK: Plan search strategy                                         │
│  • Output: analyze.md                                                         │
└───────────────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  PHASE 2: PLAN                                 /apex:2-plan                   │
│  ─────────────                                                                │
│  • Read analyze.md                                                            │
│  • ULTRA THINK: Design implementation strategy                               │
│  • Ask user questions if ambiguous                                           │
│  • Output: plan.md (file-centric, no code snippets)                          │
└───────────────────────────────────────────────────────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
                    ▼                           ▼
    ┌───────────────────────────┐   ┌───────────────────────────┐
    │  COMPLEX (≥6 files)?      │   │  SIMPLE (<6 files)?       │
    │  /apex:tasks              │   │  Skip to execute          │
    │  • Divide into task files │   │                           │
    │  • Define dependencies    │   │                           │
    │  • Output: tasks/*.md     │   │                           │
    └─────────────┬─────────────┘   └─────────────┬─────────────┘
                  │                               │
                  └───────────────┬───────────────┘
                                  │
                                  ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  PHASE 3: EXECUTE                              /apex:3-execute                │
│  ───────────────                                                              │
│  • Task-by-Task Mode (if tasks/ exists) or Plan Mode (fallback)              │
│  • Sequential (default) or Parallel (3,4 or --parallel)                      │
│  • Validation SKIPPED by default (use --validate to opt-in)                  │
│  • Output: implementation.md                                                  │
└───────────────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  PHASE 4: EXAMINE                              /apex:4-examine                │
│  ───────────────                                                              │
│  • Phase 1: Technical (build, typecheck, lint)                               │
│  • Phase 2: Logical (coherence, edge cases, patterns)                        │
│  • Auto-fix with parallel Snipper agents                                     │
│  • Output: Updated implementation.md                                          │
└───────────────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  PHASE 5: BROWSER TEST (optional)             /apex:5-browser-test           │
│  ─────────────────────────────                                                │
│  • Live browser validation with GIF recording                                │
│  • Console/network error detection                                           │
│  • Visual proof of functionality                                             │
└───────────────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
                         ┌──────────────┐
                         │   COMPLETE   │
                         │  Ready for   │
                         │  deployment  │
                         └──────────────┘
```

---

## YOLO Mode Automation

YOLO mode enables automatic phase transitions without user intervention.

```
User runs: /apex:1-analyze "task" --yolo
                    │
                    ▼
         ┌──────────────────────────────┐
         │ 1. Create .yolo marker file  │
         └──────────────┬───────────────┘
                        │
                        ▼
         ┌──────────────────────────────┐
         │ 2. Phase completes           │
         │    → Writes analyze.md       │
         └──────────────┬───────────────┘
                        │
                        ▼
         ┌──────────────────────────────┐
         │ 3. PostToolUse Hook fires    │
         │    hook-apex-clipboard.ts    │
         │    • Detects APEX file write │
         │    • Copies next command     │
         └──────────────┬───────────────┘
                        │
                        ▼
         ┌──────────────────────────────┐
         │ 4. Stop Hook fires           │
         │    hook-stop.ts              │
         │    • Launches new terminal   │
         │    • Runs next command       │
         └──────────────────────────────┘

⚠️ YOLO STOPS at /apex:3-execute (safety measure)
   User must manually review and execute tasks
```

**Supported commands**: `1-analyze`, `2-plan`, `tasks`

---

## Key Patterns

### ULTRA THINK

All commands mandate deep thinking before action:
- **Brainstorm**: Score task to select optimal agents
- **Analyze**: Plan search strategy before launching agents
- **Plan**: Design complete strategy before writing
- **Execute**: Think through each change before editing
- **Tasks**: Consider dependencies and size balance

### Adaptive Agent Routing

Brainstorm and Analyze use a **scoring system** to select agents:

```
┌─────────────────────────────────────────────────┐
│ STRATEGY SCORES                                 │
├─────────────────────────────────────────────────┤
│ Code:  X/6 → {Skip | 1 agent | 2 agents}       │
│ Web:   Y/6 → {Skip | websearch | intelligent}  │
│ Docs:  Z/6 → {Skip | explore-docs}             │
└─────────────────────────────────────────────────┘
```

### Directive Template

Used in `seed.md` structure (most important first):
1. **🎯 Objectif** - The mission (FIRST)
2. **✅ Critères de succès** - How to know when done
3. **🚀 Point de départ** - Files to read first
4. **⛔ Interdictions** - Gotchas to avoid
5. **📋 Spécifications** - Requirements
6. **📚 Artifacts** - Lazy-loaded references

### Parallel Notation

Execution strategy uses arrows and pipes:
- `→` sequential dependency
- `‖` parallel execution possible

Example: `Task 1 → [Task 2 ‖ Task 3] → Task 4`

### File-Centric Planning

Plans organized by file, not feature:
```markdown
### `src/auth/middleware.ts`
- Create JWT validation function
- Add error handling for expired tokens
```

---

## Separation of Concerns

```
┌────────────────────────────────────────────────────────────────────────────┐
│                     RESPONSIBILITY MATRIX                                   │
├────────────────────┬───────────────────────────────────────────────────────┤
│  /apex:0-brainstorm│ Research, explore options, form recommendations       │
│  /apex:1-analyze   │ Gather context, understand codebase                   │
│  /apex:2-plan      │ Design strategy, no code                              │
│  /apex:tasks       │ Divide work, define dependencies                      │
│  /apex:3-execute   │ Implement code (validation OPTIONAL)                  │
│  /apex:4-examine   │ Validate (technical + logical)                        │
│  /apex:5-browser   │ Visual proof, GIF documentation                       │
└────────────────────┴───────────────────────────────────────────────────────┘
```

**Key insight**: Execute focuses on implementation, Examine handles all validation. This prevents duplication and keeps each phase focused.

---

## Future Improvements

Potential enhancements:

| Feature | Description | Priority |
|---------|-------------|----------|
| `/apex:rollback` | Undo last execute session | 🟡 Medium |
| `--watch` for examine | Auto-rerun on file changes | 🟢 Low |
| Task templates | Common patterns (API, component) | 🟢 Low |
| Test generation | Auto-create tests during execute | 🟡 Medium |

---

## Quick Navigation

| Need | Command |
|------|---------|
| Start new feature | `/apex:1-analyze "description"` |
| Explore first | `/apex:0-brainstorm "topic"` |
| Check progress | `/apex:status folder-name` |
| Run next task | `/apex:next folder-name` |
| Validate everything | `/apex:4-examine folder-name` |
| Visual proof | `/apex:5-browser-test folder-name` |

**Full reference**: [CLAUDE.md](./CLAUDE.md)
