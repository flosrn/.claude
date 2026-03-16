# APEX v2 — Architecture

System design for the workflow-apex-v2 skill. Read this when you need to understand HOW APEX v2 works internally, not just how to invoke it (that's SKILL.md).

## System Overview

APEX v2 is **single-session-first**: all 7 phases run sequentially in one Claude Code session by default. Pause mode (`-p`) reverts to per-phase sessions (legacy v1 behavior).

```
Single-Session (Default):
  Load phase-00 → 01 → 02 → [checkpoint] → 03 → 04(if -x) → 05(if -t) → 06(if -pr) → [complete]

Pause Mode (-p):
  Session 1:  phase-00 → phase-01 → STOP (resume command shown)
  Session 2:  phase-02 → STOP
  Session 3:  phase-03 → [complete]
```

### Why Single-Session by Default

- **Context efficiency:** Keep plan and implementation in same session (avoid re-reading)
- **Faster feedback:** No resume ceremony between correlated phases
- **Better state sync:** All phases see consistent 00-context.md
- **Fewer tokens:** No context re-entry overhead between 01→02→03

### When to Use Pause Mode (`-p`)

- Multi-day features where you can't hold context
- Large codebases where context pollution risk is high
- Splitting research from implementation (analyze today, implement tomorrow)
- Debugging complex bugs over time

---

## Phase Boundary Mechanics

In single-session mode, after each phase completes:

1. Update progress table in `00-context.md`
2. Append phase summary to State Snapshot
3. Continue to next phase (no session break)

In pause mode, at the end of each phase, `scripts/phase-boundary.sh` runs:

1. Auto-commits changes (if branch_mode + code-modifying phase)
2. Marks phase complete via progress table
3. Updates state snapshot with next_phase
4. **STOPS** and displays resume command:

```
═══════════════════════════════════════════
  PHASE {NN} COMPLETE: {name}
═══════════════════════════════════════════
  {summary}
  Resume: /apex-v2 -p -r {task_id}
  Next: Phase {NN+1} - {description}
═══════════════════════════════════════════
```

---

## State Management

### Source of Truth: `00-context.md`

```markdown
# APEX v2 Task: {task_id}
## Configuration — flag table (single-session, pause, examine, test, team, etc.)
## GitHub Issue — detected issue #NNN or URL (if any)
## User Request — original input
## Progress — phase status table (✓, ⏳, ⏭, pending)
## State Snapshot
  - feature_name, next_phase
  - Acceptance Criteria
  - Phase Context (summaries as phases complete)
  - Gotchas (surprises, workarounds, deviations)
  - User Choices (interactive decisions)
```

### Isolated per Worktree (NOT symlinked)

| File | Role |
|------|------|
| `.claude/apex-v2-agent.pid` | Claude process PID in tmux (pause mode) |
| `.claude/apex-v2-retry.state` | Per-phase retry counter (`last_phase=XX\ncount=N`) |
| `.claude/apex-v2-cron-job-id` | Orchestrator cron job ID |
| `.claude/apex-v2-last-phase-count` | Completed phase count |
| `.claude/output/apex-v2/{task_id}/` | All phase output files |

### Symlinked from Source Repo (shared, read-only)

`.claude/skills/`, `.claude/agents/`, `.claude/prompts/`, `.claude/rules/`

---

## GitHub Issue Integration (phase-00-init)

When input contains `#NNN` or a GitHub issue URL:

1. Parse: extract issue number or repo/owner from URL
2. Fetch: `gh issue view {number} --json body,title,labels`
3. Populate: 00-context.md with issue details
4. Inference: extract acceptance criteria from issue body
5. Reference: link back to issue in 04-review (if phase runs)

```bash
# Examples
/apex-v2 #123                                       # Repo issue
/apex-v2 https://github.com/owner/repo/issues/456  # Full URL
/apex-v2 #123 -x -t                                # Issue + review + tests
```

---

## Smart Agent Strategy (phase-01-context)

Adaptive agent launching based on task complexity and available models:

| Complexity | Agents | Model Mix | When | Example |
|------------|--------|-----------|------|---------|
| Simple | 1-2 | 1× Haiku | Bug fix, small tweak | 1× Explore (Haiku) |
| Medium | 2-4 | 1× Sonnet + 1-2× Haiku | New feature, familiar stack | 2× Explore (Haiku), 1× websearch (Sonnet) |
| Complex | 4-7 | 1× Opus + 2× Sonnet + 2× Haiku | Unfamiliar libraries | 3× Explore (Haiku), 2× explore-docs (Sonnet), 1× websearch (Opus) |
| Major | 6-10 | 1× Opus + 3× Sonnet + 3× Haiku | Multiple systems | 4× Explore (Haiku), 3× explore-docs (Sonnet), 2× websearch (Opus) |

**Model Guidelines:**
- **Opus:** Research lead, discovery-heavy, cross-domain synthesis, review lead
- **Sonnet:** Feature implementation, test writing, validation, explore-docs
- **Haiku:** Fast exploration, file scanning, pattern matching, minor tweaks

**Available agents:**
- `Explore` (built-in): find existing patterns, files, utilities
- `explore-docs` (custom): library docs via Context7
- `websearch` (built-in): approaches, best practices, gotchas

**Economy mode:** Sonnet for all tasks (cost optimization).

**Team mode:** Each agent team member gets Sonnet primary + Haiku secondary.

---

## Human Checkpoint (between phase-02 and phase-03)

After planning, before implementation:

**Checkpoint Options:**
1. **Approve**: proceed to implement with current plan
2. **Revise**: modify plan, then implement
3. **Abort**: cancel workflow, preserve state for resume

**Bypass with `-a` (auto mode):** Skips checkpoint, proceeds directly to implementation.

**Checkpoint in pause mode:** Still prompted (not skipped), lets user think overnight.

---

## Model Selection Table

For context optimization in 1M token environment:

| Phase | Default | With `-x` | With `-t` | Notes |
|-------|---------|-----------|-----------|-------|
| 01-context | Haiku×N or Sonnet | Sonnet (lead) | Sonnet | Research—use Opus/Sonnet for synthesis |
| 02-plan | Sonnet | Sonnet | Sonnet | High-stakes—review-lead uses Opus if available |
| 03-implement | Sonnet | Sonnet | Sonnet | Execution—Haiku for isolated changes |
| 04-review | — | Opus (lead) + Sonnet | Opus | Adversarial—use Opus for critical eyes |
| 05-test | — | — | Sonnet | Test writing—familiar pattern, Sonnet |
| 06-ship | Sonnet | Sonnet | Sonnet | PR creation + summary |

---

## Worktree Setup (`phase-00c-worktree.md` + `scripts/setup-worktree.sh`)

1. Create isolated git worktree via `EnterWorktree`
2. Copy `.env` files from main repo
3. Symlink heavy dirs: `node_modules`, `.next/cache`, `vendor`, `target`, `.venv`
4. Generate deterministic port offset from task_id
5. Detect project type (Node.js, Rust, Go, Python, PHP)
6. Set `APEX_WORKTREE_PATH` for all subagents

---

## Scripts

| Script | Purpose |
|--------|---------|
| `setup-templates.sh` | Init output files from `templates/` with variable substitution |
| `update-progress.sh` | Update phase status in 00-context.md progress table |
| `update-state-snapshot.sh` | Set next_phase, append phase context, record gotchas |
| `phase-boundary.sh` | Auto-commit + mark complete + display boundary box (pause mode only) |
| `generate-task-id.sh` | Scan output dir for highest number → `NN-feature-name` |
| `setup-worktree.sh` | Copy .env, symlink heavy dirs, port offset |
| `detect-github-issue.sh` | Parse #NNN or URL from input, fetch issue details |

---

## Output Structure

```
.claude/output/apex-v2/{task_id}/
├── 00-context.md      # Config, progress table, state snapshot (source of truth)
├── 01-context.md      # Task requirements, codebase context, research findings
├── 02-plan.md         # File-by-file implementation strategy
├── 03-implement.md    # Implementation log, todos completed
├── 04-review.md       # Review findings (if -x)
├── 05-test.md         # Test analysis + creation (if -t)
└── 06-ship.md         # PR URL, final summary (if -pr)
```

---

## Comparison: v1 vs v2

| Aspect | v1 | v2 |
|--------|----|----|
| Session model | Per-step (10 steps, resume after each) | Single-session (7 phases, no stops) |
| Context pollution | High (rebuilt each resume) | Low (all phases in memory) |
| Pause capability | Always (per-step) | Opt-in with `-p` |
| Economy mode | Yes (`-e`) | No (absorbed into smart agents) |
| GitHub issue | Not supported | Integrated (parse, fetch, link) |
| Model selection | Fixed (Sonnet) | Adaptive (Opus/Sonnet/Haiku) |
| Steps/Phases | 10 (`00–09`) | 7 (`00–06`) |
| Resume mechanism | Per-step resume | Task-level resume |
| Checkpoint | After step 02 (built-in) | After phase 02 (configurable with `-a`) |
| Team mode | Yes (`-w`) | Yes (`-w`) |
| Worktree | Yes (`-wt`) | Yes (`-wt`) |

---

## Anti-Patterns

- NEVER use `claude-run -p` → use tmux + claude interactive for remote-control
- NEVER use `ps aux | grep` to detect process → use tmux session status + PID file
- NEVER use `gh` without `--repo` in worktree → wrong remote
- NEVER `cd` into worktree for `git worktree remove` → run from main repo
- NEVER store retry state in `/tmp` → use `{worktree_path}/.claude/apex-v2-retry.state`
- NEVER create worktree inside the project folder → use `{worktree_root}` (central)
- NEVER symlink entire `.claude/` directory → only symlink config subdirs
- NEVER read worktree files after removal → collect data before `git worktree remove`
- NEVER run without `OPENCLAW_ROOT` → fallback `.` creates worktree inside project
- NEVER forget tmux cleanup → `tmux kill-session -t apex-v2-{feature_name}`
- NEVER skip phase-00-init → flags and state initialization are non-negotiable
- NEVER mix single-session and pause modes in one task → pick one mode, commit to it
- NEVER load multiple phase files in one session → load sequentially, never in parallel

---

## Prerequisites

### One-Time VPS Setup

- `tmux` installed
- Claude Code authenticated (`claude auth login`, Plan Max required)
- Remote Control enabled: `claude` → `/config` → "Enable Remote Control for all sessions" → `true`

### Per-Repo (first APEX v2 workflow)

- `.claude/output/apex-v2/` directory created automatically
- GitHub issue detection requires `gh` CLI (pre-installed on most VPS)

---

## Glossary

- **Phase**: APEX v2 implementation step (00–06). Single-session: all run in order. Pause mode: each stops for resume.
- **Single-session**: All phases in one Claude session (default).
- **Pause mode**: Legacy per-phase sessions (`-p` flag).
- **Human checkpoint**: Decision point after phase-02 (plan), before phase-03 (implement).
- **State snapshot**: Section in 00-context.md tracking next_phase, gotchas, and phase summaries.
- **Template system**: Pre-created output files from `templates/` → saves ~75% tokens.
- **Smart agents**: Adaptive Haiku/Sonnet/Opus distribution based on task complexity.
- **Team mode**: Agent Teams parallelizing 3 phases (research, execute, review).
- **GitHub issue integration**: Auto-detect #NNN or issue URLs, fetch context, populate AC.
- **Model selection**: Strategy to optimize for 1M context window (Opus for decisions, Sonnet for execution, Haiku for exploration).
