# APEX System Overview

> **APEX** (Analyze-Plan-Execute-eXamine) - A multi-session workflow orchestrator for Claude Code that handles complex implementation tasks through structured phases.

## Quick Reference

| Command | Purpose | Common Flags |
|---------|---------|--------------|
| `/apex:1-analyze` | Gather context & research | `--yolo`, `--background` |
| `/apex:2-plan` | Design implementation strategy | `--yolo` |
| `/apex:3-execute` | Implement changes | `--parallel`, `--dry-run`, `--quick` |
| `/apex:4-examine` | Validate & fix issues | `--skip-patterns`, `--background` |
| `/apex:tasks` | Divide plan into tasks | `--yolo` |
| `/apex:next` | Run next pending task | - |
| `/apex:status` | Show progress tree | - |
| `/apex:handoff` | Transfer context to new workflow | `--from`, `--edit` |
| `/apex:5-demo` | Browser testing with GIF | `--url=`, `--no-gif`, `--parallel` |

---

## Workflow Diagram

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
└───────────────────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  PHASE 2: PLAN                                 /apex:2-plan                    │
│  ─────────────                                                                 │
│  • Read analyze.md                                                             │
│  • ULTRA THINK: Design implementation strategy                                │
│  • Ask user questions if ambiguous                                            │
│  • Output: plan.md (file-centric, no code snippets)                           │
└───────────────────────────────────────────────────────────────────────────────┘
                           │
            ┌──────────────┴──────────────┐
            │                             │
            ▼                             ▼
┌─────────────────────────────┐   ┌─────────────────────────────┐
│  OPTIONAL: TASK DIVISION    │   │  DIRECT EXECUTION            │
│  /apex:tasks                │   │  (skip to Phase 3)           │
│  • ≥6 files → divide        │   │  • <6 files → execute        │
│  • Create tasks/index.md    │   └─────────────────────────────┘
│  • Output: task-01.md, etc  │
└──────────────┬──────────────┘
               │
               ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  PHASE 3: EXECUTE                              /apex:3-execute                 │
│  ───────────────                                                               │
│  • Task-by-Task Mode (if tasks/ exists) or Plan Mode (fallback)               │
│  • Sequential: one task at a time                                              │
│  • Parallel: 3,4 or --parallel for concurrent execution                       │
│  • Outputs: implementation.md, progress dashboard                              │
└───────────────────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  PHASE 4: EXAMINE                              /apex:4-examine                 │
│  ───────────────                                                               │
│  • Run build, typecheck, lint                                                 │
│  • React 19 pattern validation                                                │
│  • Auto-fix with parallel Snipper agents                                      │
│  • Update implementation.md with results                                      │
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

## Phase Details

### Phase 1: Analyze (`/apex:1-analyze`)

**Purpose**: Gather all context needed before planning

**Input**: Task description (string) or existing folder name
**Output**: `analyze.md` with findings

**What it does**:
- Creates numbered task folder (`tasks/NN-kebab-name/`)
- Launches parallel agents for research
- ULTRA THINKs about search strategy
- Produces comprehensive analysis document

**Flags**:
| Flag | Behavior |
|------|----------|
| `--yolo` | Auto-continue to next phase in new terminal |
| `--background` | Run research agents asynchronously |

**Example**:
```bash
/apex:1-analyze "Add JWT authentication to the API"
/apex:1-analyze 08-auth-feature --yolo
```

---

### Phase 2: Plan (`/apex:2-plan`)

**Purpose**: Design implementation strategy before coding

**Input**: `analyze.md` from Phase 1
**Output**: `plan.md` with file-centric changes

**What it does**:
- Reads analysis findings
- ULTRA THINKs about approach
- Asks clarifying questions if needed
- Creates file-by-file change plan (no code snippets)

**Flags**:
| Flag | Behavior |
|------|----------|
| `--yolo` | Auto-continue to `/apex:tasks` or `/apex:3-execute` |

**Example**:
```bash
/apex:2-plan 08-auth-feature
```

---

### Phase 3: Execute (`/apex:3-execute`)

**Purpose**: Implement the planned changes

**Input**: `plan.md` or `tasks/*.md` files
**Output**: `implementation.md`, progress dashboard

**Execution Modes**:

| Mode | When Used | Behavior |
|------|-----------|----------|
| Sequential (default) | Single task or no number | One task at a time |
| Parallel Explicit | `3,4` or `3,4,5` | Run specified tasks concurrently |
| Parallel Auto | `--parallel` | Detect parallelizable tasks |
| Dry-Run | `--dry-run` | Preview without executing |
| Quick | `--quick` | Run typecheck+lint after task |

**Flags**:
| Flag | Behavior |
|------|----------|
| `--parallel` | Auto-detect parallelizable tasks from index.md |
| `--dry-run` | Preview task actions without changes |
| `--quick` | Immediate validation after implementation |

**Examples**:
```bash
/apex:3-execute 08-auth-feature        # Next pending task
/apex:3-execute 08-auth-feature 3      # Specific task
/apex:3-execute 08-auth-feature 3,4    # Parallel tasks
/apex:3-execute 08-auth-feature --parallel  # Auto-detect parallel
/apex:3-execute 08-auth-feature 3 --dry-run # Preview only
```

---

### Phase 4: Examine (`/apex:4-examine`)

**Purpose**: Validate implementation and auto-fix issues

**Input**: Codebase with recent changes
**Output**: Updates `implementation.md` with validation results

**What it does**:
- Runs build, typecheck, lint
- Checks React 19 patterns (Context.Provider, useContext, memo)
- Groups errors into fix areas (max 5 files each)
- Launches parallel Snipper agents for auto-fixing
- Runs format

**Flags**:
| Flag | Behavior |
|------|----------|
| `--skip-patterns` | Skip React 19 pattern validation |
| `--background` | Run diagnostics asynchronously |

**Example**:
```bash
/apex:4-examine 08-auth-feature
/apex:4-examine 08-auth-feature --skip-patterns
```

---

### Phase 5: Tasks (`/apex:tasks`)

**Purpose**: Divide plan into granular, parallelizable tasks

**Input**: `plan.md`
**Output**: `tasks/index.md`, `task-01.md`, `task-02.md`, etc.

**When to use**: When plan has ≥6 file changes

**What it does**:
- Creates `tasks/` subfolder
- Generates individual task files with:
  - Problem statement
  - Proposed solution
  - Dependencies
  - Success criteria
- Creates `index.md` with execution order

**Flags**:
| Flag | Behavior |
|------|----------|
| `--yolo` | STOPS after task creation (safety) |

**Example**:
```bash
/apex:tasks 08-auth-feature
```

---

## Utility Commands

### `/apex:next`

**Purpose**: Execute next pending task automatically

**What it does**:
- Auto-detects most recent task folder (if not provided)
- Finds first incomplete task from `index.md`
- Checks dependencies are satisfied
- Runs via apex-executor agent

**Example**:
```bash
/apex:next                    # Most recent folder
/apex:next 08-auth-feature    # Specific folder
```

---

### `/apex:status`

**Purpose**: Show visual progress tree

**Output**:
```
tasks/08-auth-feature/
├── analyze.md ✓
├── plan.md ✓
├── implementation.md
└── tasks/
    ├── index.md
    ├── ✓ task-01.md (Setup middleware)
    ├── ✓ task-02.md (Token validation)
    ├── ○ task-03.md (Route protection)
    └── ○ task-04.md (Tests)

Progress: 2/4 (50%)
Next: /apex:3-execute 08-auth-feature 3
```

---

### `/apex:handoff`

**Purpose**: Transfer context to next workflow

**Output**: Creates `seed.md` with BLUF structure

**Flags**:
| Flag | Behavior |
|------|----------|
| `--from <folder>` | Extract context from specific folder |
| `--edit` | Open seed.md in Zed editor |

**Example**:
```bash
/apex:handoff "Continue auth work with refresh tokens" --from 08-auth-feature
```

---

### `/apex:5-demo`

**Purpose**: Browser testing with GIF recording

**What it does**:
- Opens browser with chrome-devtools MCP
- Records test flows as GIF
- Detects console/network errors
- Saves recordings to `recordings/` folder

**Flags**:
| Flag | Behavior |
|------|----------|
| `--url=` | Explicit test URL |
| `--no-gif` | Skip GIF recording |
| `--parallel` | Run test scenarios concurrently |

**Example**:
```bash
/apex:5-demo 08-auth-feature
/apex:5-demo 08-auth-feature --url=http://localhost:3000/login
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
         │    → Writes analyze.md      │
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

## File Structure

### Task Folder Template

```
tasks/NN-kebab-name/
├── seed.md              # Optional: context from /apex:handoff
├── analyze.md           # Phase 1 output
├── plan.md              # Phase 2 output
├── implementation.md    # Phase 3/4 output (session log)
├── .yolo                # Marker file for YOLO mode
└── tasks/               # Optional: from /apex:tasks
    ├── index.md         # Task list with dependencies
    ├── task-01.md       # Individual task
    ├── task-02.md
    └── ...
```

### Artifact Lifecycle

| File | Created By | Purpose |
|------|------------|---------|
| `seed.md` | `/apex:handoff` | Prior context transfer |
| `analyze.md` | `/apex:1-analyze` | Research findings |
| `plan.md` | `/apex:2-plan` | Implementation strategy |
| `tasks/` | `/apex:tasks` | Granular task breakdown |
| `implementation.md` | `/apex:3-execute` | Session log, changes made |

---

## Key Patterns

### ULTRA THINK

All commands mandate deep thinking before action:
- **Analyze**: Plan search strategy before launching agents
- **Plan**: Design complete strategy before writing
- **Execute**: Think through each change before editing
- **Tasks**: Consider dependencies and size balance

### BLUF (Bottom Line Up Front)

Used in `seed.md` structure:
1. **Objectif** - Most important, shown first
2. Supporting context
3. Technical details
4. Lazy load references (artifacts table)

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

## Troubleshooting

### Bash Portability

The system uses portable bash constructs:
- `/usr/bin/grep -E` instead of `grep -E` (bypasses rg alias)
- `sort -t- -k1 -n` instead of `sort -V` (portable numeric sort)
- `expr` instead of `$(( ))` for arithmetic

### Common Issues

| Issue | Solution |
|-------|----------|
| YOLO doesn't continue | Check `.yolo` file exists in task folder |
| GIF recording fails | Ensure browser tab context exists first |
| Parallel tasks conflict | Verify no dependencies between tasks |
| Hook not triggering | Check hook registration in settings.json |

### Untested Flag Combinations

Exercise caution with:
- `--parallel --dry-run` (may have undefined behavior)
- Multiple flags in combination

---

## Future Improvements

Suggested enhancements from audit:

1. **`/apex:rollback`** - Undo last execute session
2. **`--watch` flag for examine** - Auto-rerun on file changes
3. **Task templates** - Common patterns (API endpoint, component, etc.)
4. **Improved GIF workflow** - Auto-move from Downloads to task folder

---

## Related Documentation

- [1-analyze](./1-analyze.md) - Analysis phase details
- [2-plan](./2-plan.md) - Planning phase details
- [3-execute](./3-execute.md) - Execution phase details
- [4-examine](./4-examine.md) - Validation phase details
- [tasks](./tasks.md) - Task division details
- [5-demo](./5-demo.md) - Browser testing with GIF
- [handoff](./handoff.md) - Context transfer
- [next](./next.md) - Auto-execute next task
- [status](./status.md) - Progress display
