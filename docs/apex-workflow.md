# APEX Workflow - Complete Documentation

> **APEX** = **A**nalyze → **P**lan → **E**xecute → e**X**amine
>
> A multi-session workflow orchestrator for complex implementation tasks.

## Overview

APEX is a structured methodology that breaks down complex coding tasks into manageable phases. It ensures thorough analysis before coding, comprehensive planning, disciplined execution, and rigorous validation.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           APEX WORKFLOW                                      │
└─────────────────────────────────────────────────────────────────────────────┘

                    ┌──────────────┐
                    │   seed.md    │ ← Optional (from /apex:handoff or /apex:0-brainstorm)
                    └──────┬───────┘
                           │
┌──────────────────────────▼──────────────────────────────────────────────────┐
│  PHASE 0: BRAINSTORM (optional)                   /apex:0-brainstorm        │
│  • Interactive Q&A for vague tasks                                          │
│  • Multi-round research with skeptical analysis                            │
│  • Generates seed.md with insights                                         │
└─────────────────────────────────────────────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────────────────┐
│  PHASE 1: ANALYZE                                 /apex:1-analyze           │
│  • Create task folder: .claude/tasks/NN-kebab-name/                        │
│  • Launch parallel agents: explore-codebase, explore-docs, websearch       │
│  • Output: analyze.md                                                       │
└─────────────────────────────────────────────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────────────────┐
│  PHASE 2: PLAN                                    /apex:2-plan              │
│  • Read analyze.md, design implementation strategy                         │
│  • File-centric planning (organized by file, not feature)                  │
│  • Output: plan.md                                                          │
└─────────────────────────────────────────────────────────────────────────────┘
                           │
            ┌──────────────┴──────────────┐
            ▼                             ▼
┌───────────────────────┐   ┌───────────────────────────────────────────────┐
│  /apex:tasks          │   │  Direct Execution (for smaller plans)         │
│  • Divide into tasks  │   │  → Skip to Phase 3                            │
│  • Output: tasks/     │   └───────────────────────────────────────────────┘
└───────────┬───────────┘
            │
┌───────────▼─────────────────────────────────────────────────────────────────┐
│  PHASE 3: EXECUTE                                 /apex:3-execute           │
│  • Task-by-Task Mode (if tasks/ exists) or Plan Mode                       │
│  • Sequential or Parallel execution                                         │
│  • Smart Model Selection (Sonnet vs Opus based on complexity)              │
│  • Output: implementation.md, progress dashboard                            │
└─────────────────────────────────────────────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────────────────┐
│  PHASE 4: EXAMINE                                 /apex:4-examine           │
│  • Two-phase validation: Technical (build/lint/typecheck) + Logical        │
│  • Auto-fix with parallel Snipper agents                                   │
│  • React 19 pattern validation                                              │
│  • Output: Updated implementation.md                                        │
└─────────────────────────────────────────────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────────────────┐
│  PHASE 5: BROWSER TEST (optional)                 /apex:5-browser-test      │
│  • Live browser validation with GIF recording                              │
│  • Console/network error detection                                          │
│  • Visual proof of functionality                                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Command Reference

| Command | Purpose | Key Flags |
|---------|---------|-----------|
| `/apex:0-brainstorm` | Interactive Q&A research (vague tasks) | - |
| `/apex:1-analyze` | Gather context & research | `--yolo` |
| `/apex:2-plan` | Design implementation strategy | `--yolo` |
| `/apex:tasks` | Divide plan into task files | `--yolo` |
| `/apex:3-execute` | Implement changes | `--parallel`, `--dry-run`, `--quick`, `--force-sonnet`, `--force-opus` |
| `/apex:4-examine` | Two-phase validation | `--foreground`, `--global`, `--skip-patterns` |
| `/apex:5-browser-test` | Browser testing with GIF | `--url=`, `--no-gif`, `--parallel` |
| `/apex:next` | Run next pending task | - |
| `/apex:status` | Show progress tree | - |
| `/apex:handoff` | Transfer context to new workflow | `--vision`, `--brainstorm` |

---

## YOLO Mode (`--yolo`)

YOLO mode enables **autonomous workflow automation** - phases automatically continue without user intervention.

### How It Works

```
User runs: /apex:1-analyze "Add auth" --yolo
                    │
                    ▼
         ┌──────────────────────────────┐
         │ 1. Creates .yolo marker file │
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
         │    • Detects APEX file write │
         │    • Copies next command     │
         └──────────────┬───────────────┘
                        │
                        ▼
         ┌──────────────────────────────┐
         │ 4. Stop Hook fires           │
         │    • Launches new terminal   │
         │    • Runs next command       │
         └──────────────────────────────┘

⚠️ YOLO STOPS at /apex:3-execute (safety)
   Manual review required before implementing
```

### Supported Commands

- `/apex:1-analyze --yolo` → Auto-continues to `/apex:2-plan`
- `/apex:2-plan --yolo` → Auto-continues to `/apex:tasks` or `/apex:3-execute`
- `/apex:tasks --yolo` → STOPS (safety measure before execution)

### When to Use YOLO

**Good for:**
- Well-defined tasks with clear requirements
- When you trust the analysis/planning phases
- Batch processing multiple related tasks

**Avoid when:**
- Task is exploratory or vague
- You need to make decisions at each phase
- Working on critical/production code

---

## Phase Details

### Phase 0: Brainstorm (`/apex:0-brainstorm`)

**Purpose**: Deep research and clarification for vague tasks

**Process**:
1. **Phase 0: Context Gathering** - Interactive Q&A to understand the problem
2. **Round 1: Initial Exploration** - Parallel web/docs/codebase research
3. **Round 2: Skeptical Challenge** - Question initial findings, find alternatives
4. **Round 3: Multi-Perspective Analysis** - Pragmatist, Perfectionist, Skeptic, Expert, Beginner views
5. **Round 4: Synthesis** - Core insights, recommendations, confidence levels

**Output**: `seed.md` with structured findings

**Triggers**:
- Vague adjectives: "améliorer", "optimiser", "better", "improve"
- Exploratory language: "explorer", "brainstorm", "investigate"
- Question framing: "comment faire", "quelle approche", "how to"

---

### Phase 1: Analyze (`/apex:1-analyze`)

**Purpose**: Gather ALL context before planning

**What it does**:
1. Creates numbered task folder (`.claude/tasks/NN-kebab-name/`)
2. Launches parallel agents:
   - `explore-codebase` - Find files, patterns, examples
   - `explore-docs` - Library documentation (skipped if post-brainstorm)
   - `websearch` - Latest approaches (skipped if post-brainstorm)
   - `vision-analyzer` - If image provided via `--vision`
3. Asks clarifying questions based on discoveries
4. Produces comprehensive `analyze.md`

**Smart Skip (Post-Brainstorm)**:
When seed.md contains "Brainstorm Summary", skips redundant research:
- ⏭️ Skip: `websearch`, `explore-docs` (already done in brainstorm)
- ✅ Keep: `explore-codebase` (always needed for file locations)

---

### Phase 2: Plan (`/apex:2-plan`)

**Purpose**: Design implementation strategy before coding

**Key Principles**:
- **File-Centric**: Organize by file, not by feature
- **No Code Snippets**: Plans describe actions, not implementations
- **Actionable**: Every step must be clear and executable
- **Ask First**: Clarify ambiguities before proceeding

**Output Structure**:
```markdown
### `src/auth/middleware.ts`
- Create JWT validation function
- Add error handling for expired tokens
- Follow pattern from `src/api/auth.ts:45`
```

---

### Phase 3: Execute (`/apex:3-execute`)

**Purpose**: Implement the planned changes

**Execution Modes**:

| Mode | When | Behavior |
|------|------|----------|
| Sequential | Default | One task at a time |
| Parallel Explicit | `3,4` or `3,4,5` | Run specified tasks concurrently |
| Parallel Auto | `--parallel` | Detect parallelizable tasks from index.md |
| Dry-Run | `--dry-run` | Preview without executing |
| Quick | `--quick` | Immediate typecheck/lint after task |

**Smart Model Selection**:

Automatically chooses Sonnet or Opus based on task complexity:

| Criterion | Points |
|-----------|--------|
| Modifies existing files | +2 |
| Modifies 3+ existing files | +1 |
| Contains "integration/integrate" | +2 |
| Contains "API/SDK/callback" | +1 |
| Contains "refactor/migration" | +1 |
| Has 3+ dependencies | +1 |
| Mentions gotchas/risks | +1 |

**Thresholds**: 0-2 = Sonnet, 3+ = Opus

**Override**: `--force-sonnet` or `--force-opus`

---

### Phase 4: Examine (`/apex:4-examine`)

**Purpose**: Two-phase validation ensuring deployment readiness

**Phase 1: Technical Validation** (Fast)
- Build
- Typecheck
- Lint
- Runs in background by default

**Phase 2: Logical Analysis** (Deep)
- Coherence check (do all files work together?)
- Edge case analysis (empty inputs, null values, errors)
- Code quality (unnecessary complexity, duplication)
- React 19 patterns (if applicable)

**Flags**:
- `--foreground` - Synchronous execution
- `--global` - Analyze ALL feature files (not just modified)
- `--skip-patterns` - Skip React 19 pattern validation

---

### Phase 5: Browser Test (`/apex:5-browser-test`)

**Purpose**: Visual validation with GIF recording

**What it does**:
1. Identifies test flows from implementation
2. Detects dev server port
3. Creates/reuses browser tab
4. Records GIF of test execution
5. Validates console/network for errors
6. Saves recordings to `recordings/success/` or `recordings/errors/`

**Flags**:
- `--url=<url>` - Explicit test URL
- `--no-gif` - Skip recording
- `--parallel` - Run scenarios concurrently

---

## File Structure

```
.claude/tasks/NN-kebab-name/
├── seed.md              # Optional: from /apex:handoff or /apex:0-brainstorm
├── analyze.md           # Phase 1 output
├── plan.md              # Phase 2 output
├── implementation.md    # Phase 3/4 output (session log)
├── .yolo                # Marker for YOLO mode
├── recordings/          # From /apex:5-browser-test
│   ├── success/
│   └── errors/
└── tasks/               # Optional: from /apex:tasks
    ├── index.md         # Task list with dependencies
    ├── task-01.md       # Individual task
    ├── task-02.md
    └── ...
```

---

## Key Patterns

### ULTRA THINK

All APEX commands mandate deep thinking before action:
- **Analyze**: Plan search strategy before launching agents
- **Plan**: Design complete strategy before writing
- **Execute**: Think through each change before editing
- **Tasks**: Consider dependencies and size balance

### BLUF (Bottom Line Up Front)

Structure for `seed.md`:
1. 🎯 Objectif - Most important, shown first
2. 📂 Point de départ - Critical files to start with
3. ⚠️ Pièges à éviter - Gotchas to avoid
4. 📋 Spécifications - Requirements and decisions
5. 🔍 Contexte technique - Background (lazy load)

### Parallel Notation

Execution strategy uses arrows and pipes:
- `→` sequential dependency
- `‖` parallel execution possible

Example: `Task 1 → [Task 2 ‖ Task 3] → Task 4`

---

## Usage Examples

```bash
# Full workflow example
/apex:0-brainstorm "Implement user notifications"  # Research first
/apex:1-analyze 01-brainstorm-notifications         # Analyze codebase
/apex:2-plan 01-user-notifications                  # Create plan
/apex:tasks 01-user-notifications                   # Divide into tasks
/apex:3-execute 01-user-notifications               # Execute first task
/apex:3-execute 01-user-notifications 2,3           # Execute tasks 2 & 3 in parallel
/apex:4-examine 01-user-notifications               # Validate all changes
/apex:5-browser-test 01-user-notifications          # Browser test with GIF

# YOLO mode (autonomous)
/apex:1-analyze "Add JWT auth" --yolo               # Auto-continues through phases

# Quick iteration
/apex:next                                          # Run next pending task
/apex:status 01-user-notifications                  # Check progress

# Context transfer
/apex:handoff "Continue with refresh tokens" --from 01-auth
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| YOLO doesn't continue | Verify `.yolo` file exists in task folder |
| File not found errors | Use `./.claude/tasks/<folder>/file.md` (NOT `tasks/<folder>/...`) |
| Parallel tasks conflict | Check `index.md` for dependency violations |
| Phase 2 not running | Phase 2 requires Phase 1 to pass (or user skip) |
| GIF recording fails | Ensure browser tab context exists first |

---

## Best Practices

1. **Always brainstorm vague tasks** - Use `/apex:0-brainstorm` for exploratory work
2. **Trust the process** - Don't skip phases, each builds on the previous
3. **Use YOLO wisely** - Great for well-defined tasks, risky for exploratory work
4. **Leverage parallel execution** - Use `3,4` or `--parallel` when tasks are independent
5. **Review implementation.md** - Contains valuable context for future sessions
6. **Use /apex:handoff** - Transfer knowledge between workflow sessions
