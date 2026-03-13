# APEX — Architecture

System design for the workflow-apex skill. Read this when you need to understand HOW APEX works internally, not just how to invoke it (that's SKILL.md).

## System Overview

APEX is a session-spanning workflow: each step runs in its own Claude Code session, with state persisted to disk (`00-context.md`) for cross-session transfer.

```
Session 1:  step-00-init → step-01-analyze → STOP (resume command shown)
Session 2:  /apex -r {task_id} → step-02-plan → STOP
Session 3:  /apex -r {task_id} → step-03-execute → STOP
Session N:  /apex -r {task_id} → step-NN → ... → workflow complete
```

### Why Per-Session Steps

- Clean context window per step (no accumulated bloat)
- Each step reads only what it needs from disk (progressive disclosure)
- Crashed steps can be restarted without losing prior work
- Code-process orchestrator can monitor progress between sessions

---

## Session Boundary Mechanics

At the end of each step, `scripts/session-boundary.sh` runs:

1. Auto-commits changes (if branch_mode + code-modifying step)
2. Marks step complete via `scripts/update-progress.sh`
3. Updates state snapshot via `scripts/update-state-snapshot.sh`
4. Displays session boundary box:

```
═══════════════════════════════════════
  STEP {NN} COMPLETE: {name}
═══════════════════════════════════════
  {summary}
  Resume: /apex -r {task_id}
  Next: Step {NN} - {description}
═══════════════════════════════════════
```

---

## State Management

### Source of Truth: `00-context.md`

```markdown
# APEX Task: {task_id}
## Configuration — flag table
## User Request — original input
## Progress — step status table (✓, ⏳, ⏭, pending)
## State Snapshot
  - feature_name, next_step
  - Acceptance Criteria
  - Step Context (summaries as steps complete)
  - Gotchas (surprises, workarounds, deviations)
  - User Choices (interactive decisions)
```

### Isolated per Worktree (NOT symlinked)

| File | Role |
|------|------|
| `.claude/apex-agent.pid` | Claude process PID in tmux |
| `.claude/apex-retry.state` | Per-step retry counter (`last_step=XX\ncount=N`) |
| `.claude/apex-cron-job-id` | Orchestrator cron job ID |
| `.claude/apex-last-step-count` | Completed step count |
| `.claude/output/apex/{task_id}/` | All step output files |

### Symlinked from Source Repo (shared, read-only)

`.claude/skills/`, `.claude/agents/`, `.claude/prompts/`, `.claude/rules/`

---

## Smart Agent Strategy (step-01-analyze)

Adaptive agent launching based on task complexity (unless economy_mode):

| Complexity | Agents | When | Example |
|------------|--------|------|---------|
| Simple | 1-2 | Bug fix, small tweak | 1× Explore |
| Medium | 2-4 | New feature, familiar stack | 2× Explore + 1× websearch |
| Complex | 4-7 | Unfamiliar libraries | 3× Explore + 2× explore-docs + 1× websearch |
| Major | 6-10 | Multiple systems | 4× Explore + 3× explore-docs + 2× websearch |

**Available agents:**
- `Explore` (built-in): find existing patterns, files, utilities
- `explore-docs` (custom, requires `.claude/agents/explore-docs.md`): library docs via Context7
- `websearch` (built-in): approaches, best practices, gotchas

**Review agents (step-05):** `Explore` with focus areas (security, logic, clean-code) — read-only.

---

## Mode Compatibility

| Mode | Enables | Conflicts | Notes |
|------|---------|-----------|-------|
| Team (`-w`) | — | Economy (`-e`) | Mutually exclusive |
| Economy (`-e`) | — | Team (`-w`) | No subagents, direct tools only |
| Worktree (`-wt`) | Branch (`-b`) | — | Replaces step-00b-branch with step-00c-worktree |
| PR (`-pr`) | Branch (`-b`) | — | Auto-enables branch mode |
| Branch (`-b`) | — | — | Per-step commits enabled |
| Interactive (`-i`) | — | — | AskUserQuestion for flag config |

### Team Mode Coordination

| Phase | Solo Step | Team Step | Parallel Strategy |
|-------|-----------|-----------|-------------------|
| Research | 01-analyze | 01b-team-analyze | Researchers share findings cross-domain |
| Execute | 03-execute | 03b-team-execute | Implement by file domain, no overlap |
| Review | 05-examine | 05b-team-examine | Reviewers cross-challenge findings |
| Resolve | 06-resolve | 06b-team-resolve | Fixers partition by file, global validation |

### Economy Mode Adjustments

- Skip typecheck (RAM-intensive, ~1.5GB on monorepos)
- Direct tools only: Glob, Grep, Read, minimal WebSearch
- Leaner validation: `lint --fix` only
- Minimal test strategy: essential tests only

---

## Worktree Setup (`step-00c-worktree.md` + `scripts/setup-worktree.sh`)

1. Create isolated git worktree via `EnterWorktree`
2. Copy `.env` files from main repo
3. Symlink heavy dirs: `node_modules`, `.next/cache`, `vendor`, `target`, `.venv`
4. Generate deterministic port offset from task_id
5. Detect project type (Node.js, Rust, Go, Python, PHP)

---

## Scripts

| Script | Purpose |
|--------|---------|
| `setup-templates.sh` | Init output files from `templates/` with variable substitution |
| `update-progress.sh` | Update step status in 00-context.md progress table |
| `update-state-snapshot.sh` | Set next_step, append step context, record gotchas |
| `session-boundary.sh` | Auto-commit + mark complete + display boundary box |
| `generate-task-id.sh` | Scan output dir for highest number → `NN-feature-name` |
| `setup-worktree.sh` | Copy .env, symlink heavy dirs, port offset |

---

## Output Structure

```
.claude/output/apex/{task_id}/
├── 00-context.md    # Config, progress table, state snapshot (source of truth)
├── 01-analyze.md    # Task requirements, codebase context, research findings
├── 02-plan.md       # File-by-file implementation strategy
├── 03-execute.md    # Implementation log, todos completed
├── 04-validate.md   # Typecheck, lint, tests, AC verification
├── 05-examine.md    # Review findings (if -x)
├── 06-resolve.md    # Resolution log (if -x + findings)
├── 07-tests.md      # Test analysis + creation (if -t)
├── 08-run-tests.md  # Test runner log (if -t)
└── 09-finish.md     # PR URL, final summary (if -pr)
```

---

## Anti-Patterns

- NEVER use `claude-run -p` → use tmux + claude interactive for remote-control
- NEVER use `ps aux | grep` to detect process → use tmux session status + PID file
- NEVER use `gh` without `--repo` in worktree → wrong remote
- NEVER `cd` into worktree for `git worktree remove` → run from main repo
- NEVER store retry state in `/tmp` → use `{worktree_path}/.claude/apex-retry.state`
- NEVER create worktree inside the project folder → use `{worktree_root}` (central)
- NEVER symlink entire `.claude/` directory → only symlink config subdirs
- NEVER read worktree files after removal → collect data before `git worktree remove`
- NEVER run without `OPENCLAW_ROOT` → fallback `.` creates worktree inside project
- NEVER forget tmux cleanup → `tmux kill-session -t apex-{feature_name}`

## Prerequisites (one-time VPS setup)

- `tmux` installed
- Claude Code authenticated (`claude auth login`, Plan Max required)
- Remote Control enabled: `claude` → `/config` → "Enable Remote Control for all sessions" → `true`

## Glossary

- **Step**: APEX implementation step (00–09). Each runs in its own session.
- **Phase**: Code-process orchestration step (external to APEX). See code-process skill.
- **Session boundary**: The stop point between steps. Saves state, shows resume command.
- **State snapshot**: Section in 00-context.md tracking next_step, gotchas, and step summaries.
- **Template system**: Pre-created output files from `templates/` → saves ~75% tokens.
- **Smart agents**: Adaptive 1-10 agent launching based on task complexity (step-01).
- **Team mode**: Agent Teams parallelizing 4 phases (research, execute, review, resolve).
- **Economy mode**: No subagents, direct tools — for limited plans or simple tasks.
