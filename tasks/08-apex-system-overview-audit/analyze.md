# Analysis: APEX System Overview & Audit

**Analyzed**: 2025-12-30
**Status**: Complete

## Quick Summary (TL;DR)

> Complete audit of the APEX (Analyze-Plan-Execute-eXamine) system - a sophisticated multi-session workflow orchestrator for Claude Code.

**System Components (10 files):**
- 5 core phases: `1-analyze`, `2-plan`, `3-execute`, `4-examine`, `5-tasks`
- 4 utilities: `handoff`, `next`, `status`, `test-live`
- 1 agent: `apex-executor` (Sonnet model for parallel task execution)

**Automation Stack:**
- `hook-apex-clipboard.ts` - PostToolUse hook: copies next command to clipboard
- `hook-stop.ts` - Stop hook: triggers YOLO continuation if active
- `apex-yolo-continue.ts` - Opens new terminal window for next phase

**Flags Discovered:**
| Flag | Commands | Behavior |
|------|----------|----------|
| `--yolo` | 1-analyze, 2-plan, 5-tasks | Auto-continue to next phase in new terminal |
| `--background` | 1-analyze, 4-examine | Run agents/diagnostics async |
| `--parallel` | 3-execute | Auto-detect parallelizable tasks |
| `--dry-run` | 3-execute | Preview task actions without executing |
| `--quick` | 3-execute | Run typecheck+lint after task |
| `--skip-patterns` | 4-examine | Skip React 19 pattern validation |
| `--no-gif` | test-live | Skip GIF recording |
| `--url=` | test-live | Explicit test URL |
| `--edit` | handoff | Open seed.md in Zed |
| `--from` | handoff | Specify source folder for context |

**Bash Portability Fixes Applied:**
- `/usr/bin/grep -E` instead of `grep -E` (bypasses rg alias)
- `sort -t- -k1 -n` instead of `sort -V` (portable numeric sort)
- `expr` instead of `$(( ))` for arithmetic (POSIX compatible)

**⚠️ Gotchas:**
- YOLO stops at execute phase (safety: user reviews tasks)
- `--background` only works for agents, not file writes
- GIF recording requires browser tab context first

**Dependencies:** No external dependencies. Uses only Claude Code built-in tools + Bun scripts.

**Estimation:** ~3-4 tasks for documentation, ~2h total

---

## System Architecture

### Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           APEX WORKFLOW                                       │
└─────────────────────────────────────────────────────────────────────────────┘

                    ┌──────────────┐
                    │   seed.md    │ (optional, from /apex:handoff)
                    │ Prior Context│
                    └──────┬───────┘
                           │
                           ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  PHASE 1: ANALYZE                              /apex:1-analyze                 │
│  ─────────────────                                                             │
│  • Create task folder: tasks/NN-kebab-name/                                   │
│  • Launch parallel agents: explore-codebase, explore-docs, websearch         │
│  • ULTRA THINK: Plan search strategy                                          │
│  • Output: analyze.md                                                          │
│                                                                                │
│  Flags: --background (async agents), --yolo (auto-continue)                  │
└───────────────────────────────────────────────────────────────────────────────┘
                           │
                           │ Hook: hook-apex-clipboard.ts
                           │ → Copies "/apex:2-plan <folder>" to clipboard
                           ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  PHASE 2: PLAN                                 /apex:2-plan                    │
│  ─────────────                                                                 │
│  • Read analyze.md                                                             │
│  • ULTRA THINK: Design implementation strategy                                │
│  • Ask user questions if ambiguous                                            │
│  • Output: plan.md (file-centric, no code snippets)                           │
│                                                                                │
│  Flags: --yolo (auto-continue)                                                │
└───────────────────────────────────────────────────────────────────────────────┘
                           │
                           │ Hook: Detects file count
                           │ → If ≥6 files: copies "/apex:5-tasks"
                           │ → If <6 files: copies "/apex:3-execute"
                           ▼
            ┌──────────────┴──────────────┐
            │                             │
            ▼                             ▼
┌─────────────────────────────┐   ┌─────────────────────────────┐
│  OPTIONAL: TASK DIVISION    │   │  DIRECT EXECUTION            │
│  /apex:5-tasks              │   │  (skip to Phase 3)           │
│  ───────────────────────    │   └─────────────────────────────┘
│  • Divide plan into tasks   │
│  • Create tasks/ folder     │
│  • Create task-01.md, etc.  │
│  • Create index.md          │
│  • Output: tasks/index.md   │
│                             │
│  Flags: --yolo              │
└──────────────┬──────────────┘
               │
               │ YOLO STOPS HERE (safety)
               ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  PHASE 3: EXECUTE                              /apex:3-execute                 │
│  ───────────────                                                               │
│                                                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  MODE DETECTION                                                          │  │
│  │  • tasks/ folder exists → Task-by-Task Mode (preferred)                 │  │
│  │  • No tasks/ folder → Plan Mode (fallback to plan.md)                   │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
│                                                                                │
│  EXECUTION MODES:                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │ Sequential  │  │ Parallel    │  │ --parallel  │  │ --dry-run   │          │
│  │ (default)   │  │ Explicit    │  │ Auto-detect │  │ Preview     │          │
│  │             │  │ (3,4,5)     │  │             │  │             │          │
│  │ One task    │  │ Multiple    │  │ Find ready  │  │ No changes  │          │
│  │ at a time   │  │ tasks       │  │ tasks       │  │ made        │          │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘          │
│                                                                                │
│  PARALLEL EXECUTION: Uses apex-executor subagent (Sonnet model)               │
│                                                                                │
│  Outputs:                                                                      │
│  • Updates tasks/index.md (marks [x] complete)                                │
│  • Creates/appends implementation.md (session log)                            │
│  • Shows progress dashboard                                                    │
│                                                                                │
│  Flags: --parallel, --dry-run, --quick                                        │
└───────────────────────────────────────────────────────────────────────────────┘
                           │
                           │ All tasks complete?
                           ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  PHASE 4: EXAMINE                              /apex:4-examine                 │
│  ───────────────                                                               │
│  • Run build, typecheck, lint                                                 │
│  • React 19 pattern validation (Context.Provider, useContext, memo)           │
│  • Create fix areas (max 5 files each)                                        │
│  • Launch parallel Snipper agents for auto-fixing                             │
│  • Run format                                                                  │
│  • Update implementation.md with validation results                           │
│                                                                                │
│  Flags: --background (async diagnostics), --skip-patterns                     │
└───────────────────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  OPTIONAL: TEST-LIVE                           /apex:test-live                 │
│  ──────────────────                                                            │
│  • Live browser testing with chrome-devtools MCP                              │
│  • GIF recording of test flows                                                │
│  • Console/network error detection                                            │
│  • Parallel test scenarios with --parallel                                    │
│  • Save recordings to recordings/success/ or recordings/errors/               │
│                                                                                │
│  Flags: --url=, --no-gif, --parallel                                          │
└───────────────────────────────────────────────────────────────────────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   COMPLETE   │
                    │  Ready for   │
                    │  deployment  │
                    └──────────────┘
```

### Utility Commands

```
┌───────────────────────────────────────────────────────────────────────────────┐
│  UTILITY COMMANDS                                                              │
└───────────────────────────────────────────────────────────────────────────────┘

/apex:status [folder]          │  Show visual status tree of artifacts
                               │  • analyze.md ✓/✗
                               │  • plan.md ✓/✗
                               │  • tasks/ with progress
                               │  • Suggest next action

/apex:next [folder]            │  Execute next pending task automatically
                               │  • Auto-detect most recent folder if not provided
                               │  • Check dependencies before executing
                               │  • Use apex-executor agent

/apex:handoff "description"    │  Generate seed.md for next workflow
                               │  • Extract learnings from current folder
                               │  • BLUF structure (Objectif first)
                               │  • Lazy load references to artifacts
                               │  • Flags: --from <folder>, --edit
```

### Automation System (YOLO Mode)

```
┌───────────────────────────────────────────────────────────────────────────────┐
│  YOLO MODE AUTOMATION                                                          │
└───────────────────────────────────────────────────────────────────────────────┘

                    User runs: /apex:1-analyze "task" --yolo
                                        │
                                        ▼
                         ┌──────────────────────────────┐
                         │ 1. Create .yolo marker file  │
                         │    in task folder            │
                         └──────────────┬───────────────┘
                                        │
                                        ▼
                         ┌──────────────────────────────┐
                         │ 2. Phase completes           │
                         │    → Writes analyze.md      │
                         └──────────────┬───────────────┘
                                        │
                                        ▼
                         ┌──────────────────────────────┐
                         │ 3. PostToolUse Hook fires    │
                         │    hook-apex-clipboard.ts    │
                         │    • Detects APEX file write │
                         │    • Copies next command     │
                         │    • Creates /tmp/.apex-     │
                         │      yolo-continue JSON      │
                         └──────────────┬───────────────┘
                                        │
                                        ▼
                         ┌──────────────────────────────┐
                         │ 4. Claude says "YOLO mode:   │
                         │    Session will exit..."     │
                         │    then STOPS                │
                         └──────────────┬───────────────┘
                                        │
                                        ▼
                         ┌──────────────────────────────┐
                         │ 5. Stop Hook fires           │
                         │    hook-stop.ts              │
                         │    • Plays success sound     │
                         │    • Detects YOLO flag       │
                         │    • Launches background:    │
                         │      apex-yolo-continue.ts   │
                         └──────────────┬───────────────┘
                                        │
                                        ▼
                         ┌──────────────────────────────┐
                         │ 6. apex-yolo-continue.ts     │
                         │    • Detects terminal type   │
                         │    • Opens NEW window/split  │
                         │    • Runs: cc "/apex:2-plan" │
                         └──────────────────────────────┘

                    YOLO STOPS at /apex:3-execute (safety)
                    .yolo file deleted, flag not created
```

---

## Command Reference

### Phase Commands

| Command | Description | Input | Output | Flags |
|---------|-------------|-------|--------|-------|
| `/apex:1-analyze` | Gather context | Task description OR folder | `analyze.md` | `--background`, `--yolo` |
| `/apex:2-plan` | Create strategy | `analyze.md` | `plan.md` | `--yolo` |
| `/apex:3-execute` | Implement | `plan.md` OR `tasks/*.md` | `implementation.md` | `--parallel`, `--dry-run`, `--quick` |
| `/apex:4-examine` | Validate | Codebase | Updates `implementation.md` | `--background`, `--skip-patterns` |
| `/apex:5-tasks` | Divide work | `plan.md` | `tasks/index.md`, `task-*.md` | `--yolo` |

### Utility Commands

| Command | Description | Input | Output | Flags |
|---------|-------------|-------|--------|-------|
| `/apex:next` | Run next task | Optional folder | Runs task | None |
| `/apex:status` | Show progress | Optional folder | Visual tree | None |
| `/apex:handoff` | Transfer context | Description | `seed.md` | `--from`, `--edit` |
| `/apex:test-live` | Browser testing | Folder | GIF recordings | `--url=`, `--no-gif`, `--parallel` |

---

## File Artifacts

### Task Folder Structure

```
tasks/NN-kebab-name/
├── seed.md              # Optional: context from /apex:handoff
├── analyze.md           # Phase 1 output
├── plan.md              # Phase 2 output
├── implementation.md    # Phase 3/4 output (session log)
├── .yolo                # Marker file for YOLO mode
└── tasks/               # Optional: from /apex:5-tasks
    ├── index.md         # Task list with dependencies
    ├── task-01.md       # Individual task
    ├── task-02.md
    └── ...
```

### Artifact Templates

**seed.md (BLUF Pattern):**
```markdown
# 🔄 [Task Name] - Seed

## 🎯 Objectif (FIRST - most important)
## 📂 Point de départ (critical files)
## ⚠️ Pièges à éviter (gotchas)
## 📋 Spécifications (requirements)
## 🔍 Contexte technique (optional, lazy load)
## 📚 Artifacts source (lazy load table)
```

**index.md (Task List):**
```markdown
# Tasks: [Feature]

## Task List
| Task | Name | Dependencies |

- [ ] **Task 1**: [Name] - `task-01.md`
- [ ] **Task 2**: [Name] - `task-02.md` (depends on Task 1)

## Execution Strategy
Task 1 → [Task 2 ‖ Task 3] → Task 4
```

---

## Patterns Discovered

### 1. ULTRA THINK Pattern
All commands mandate "ULTRA THINK" before action:
- Analysis: Plan search strategy before launching agents
- Planning: Design complete strategy before writing
- Execution: Think through each change before editing
- Tasks: Consider dependencies and size balance

### 2. BLUF (Bottom Line Up Front)
Used in seed.md structure:
- 🎯 Objectif FIRST (most important)
- Then supporting context
- Lazy load section last

### 3. Lazy Loading
- Artifacts table references files but doesn't auto-read
- Saves tokens until content is needed
- Used in seed.md and analyze.md

### 4. Parallel Notation
Execution strategy uses: `Task 1 → [Task 2 ‖ Task 3] → Task 4`
- `→` sequential dependency
- `‖` parallel execution possible

### 5. File-Centric Planning
Plans organized by file, not feature:
```markdown
### `src/auth/middleware.ts`
- Action 1: What to change
- Action 2: Specific modification
```

---

## Audit Findings

### ✅ Strengths

1. **Comprehensive workflow** - Covers entire development cycle
2. **Parallel execution** - Both agents and task execution
3. **Cross-session context** - seed.md transfers learnings
4. **Visual documentation** - GIF recordings, progress dashboards
5. **Safety stops** - YOLO halts at execute phase
6. **Hook integration** - Seamless clipboard automation
7. **Terminal-agnostic** - Works with tmux, Ghostty, iTerm, Terminal.app

### ⚠️ Potential Issues

1. **Bash portability** - Recently fixed, but worth monitoring
2. **Complex flag combinations** - Some combinations untested (e.g., `--parallel --dry-run`)
3. **No rollback mechanism** - Implementation changes are permanent
4. **GIF storage location** - Downloads folder requires manual move

### 📋 Suggested Improvements

1. **Add `/apex:rollback`** - Undo last execute session
2. **Add `--watch` flag to examine** - Auto-rerun on file changes
3. **Create `/apex:overview`** - Generate this documentation automatically
4. **Add task templates** - Common patterns (API endpoint, component, etc.)
5. **Improve GIF workflow** - Auto-move from Downloads to task folder

---

## Key Files Reference

| File | Purpose | Lines |
|------|---------|-------|
| `commands/apex/1-analyze.md` | Analysis phase | 220 |
| `commands/apex/2-plan.md` | Planning phase | 151 |
| `commands/apex/3-execute.md` | Execution phase | 614 |
| `commands/apex/4-examine.md` | Validation phase | 324 |
| `commands/apex/5-tasks.md` | Task division | 258 |
| `commands/apex/handoff.md` | Context transfer | 239 |
| `commands/apex/next.md` | Auto-execute next | 93 |
| `commands/apex/status.md` | Progress display | 116 |
| `commands/apex/test-live.md` | Browser testing | 398 |
| `agents/apex-executor.md` | Task executor agent | 98 |
| `scripts/hook-apex-clipboard.ts` | PostToolUse hook | 206 |
| `scripts/hook-stop.ts` | Stop hook + YOLO | 118 |
| `scripts/apex-yolo-continue.ts` | Terminal automation | 181 |
