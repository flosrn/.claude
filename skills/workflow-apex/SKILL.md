---
name: apex
description: Systematic implementation using APEX methodology (Analyze-Plan-Execute-eXamine) with parallel agents, self-validation, and optional adversarial review. Use when implementing features, fixing bugs, or making code changes that benefit from structured workflow.
argument-hint: "[-x] [-t] [-w] [-wt] [-b] [-pr] [-i] [-r <task-id>] <task description>"
---

# APEX — Analyze-Plan-Execute-eXamine

Systematic implementation workflow. Runs one step per session with resume capability.

## Critical Rules

- **Load ONE step at a time** — never load multiple step files
- **ULTRA THINK** before major decisions (plan, architecture, review)
- **Session boundary:** each step STOPS after completion and displays resume command
- Steps 00+01 run together in the first session — all others run solo
- **Per-step commits** (when branch_mode): `apex({task_id}): step NN - name`
- **Persist all state** to `00-context.md` — this is the cross-session transfer mechanism

---

## Quick Start

```bash
/apex add authentication middleware          # Basic
/apex -x fix login bug                      # With adversarial review
/apex -x -t add auth middleware             # Review + tests
/apex -w -x implement dashboard API         # Team mode + review
/apex -wt -pr add auth middleware           # Worktree isolation + PR
/apex -e add auth middleware                # Economy (save tokens)
/apex -i add auth middleware                # Interactive flag config
/apex -r 01-auth-middleware                 # Resume previous task
/apex -r 01                                # Partial match resume
/apex -t -r 01                             # Resume + add tests mid-workflow
```

## Flags

**Enable (lowercase):**

| Flag | Description |
|------|-------------|
| `-x` | Examine: adversarial code review (steps 05+06) |
| `-t` | Test: create and run tests (steps 07+08) |
| `-w` | Team: parallel Agent Teams for research, execution, review, resolution |
| `-e` | Economy: no subagents, direct tools only (incompatible with `-w`) |
| `-wt` | Worktree: isolate in git worktree (enables `-b`) |
| `-b` | Branch: verify not on main, create branch if needed |
| `-pr` | PR: create pull request at end (enables `-b`) |
| `-i` | Interactive: configure flags via AskUserQuestion |
| `-r` | Resume: continue from previous task |

**Disable (uppercase):** `-X`, `-T`, `-W`, `-E`, `-WT`, `-B`, `-PR`, `-I`

**Parsing:** Defaults from `steps/step-00-init.md`. CLI flags override. Flags removed from input → remainder = `{task_description}`. Task ID = `NN-kebab-case-description`.

---

## Step Routing

**FIRST ACTION:** Load `steps/step-00-init.md`

| Step | File | Purpose | Condition |
|------|------|---------|-----------|
| 00 | `step-00-init.md` | Parse flags, create output, init state | Always |
| 00b | `step-00b-branch.md` | Branch verification/creation | `-b`, skipped if `-wt` |
| 00b | `step-00b-interactive.md` | Interactive flag config | `-i` |
| 00b | `step-00b-economy.md` | Economy mode adjustments | `-e` |
| 00c | `step-00c-worktree.md` | Worktree creation + env setup | `-wt` (replaces 00b-branch) |
| 01 | `step-01-analyze.md` | Context gathering (1-10 agents) | Always |
| 01b | `step-01b-team-analyze.md` | Team parallel research | `-w` |
| 02 | `step-02-plan.md` | File-by-file strategy | Always |
| 03 | `step-03-execute.md` | Todo-driven implementation | Always (solo) |
| 03b | `step-03b-team-execute.md` | Team parallel implementation | `-w` |
| 04 | `step-04-validate.md` | Self-check, typecheck, lint, AC | Always |
| 05 | `step-05-examine.md` | Adversarial code review | `-x` |
| 05b | `step-05b-team-examine.md` | Team parallel review | `-w -x` |
| 06 | `step-06-resolve.md` | Fix review findings | `-x` + findings |
| 06b | `step-06b-team-resolve.md` | Team parallel resolution | `-w -x` + findings |
| 07 | `step-07-tests.md` | Test analysis and creation | `-t` |
| 08 | `step-08-run-tests.md` | Run tests until green | `-t` |
| 09 | `step-09-finish.md` | Create PR + final summary | `-pr` |

### Multi-Path Flows

```
Standard:    00 → 01 → 02 → 03 → 04 → [complete]
Economy:     00 → 01 → 02 → 03 → 04 → 09 → [complete]
Review:      00 → 01 → 02 → 03 → 04 → 05 → 06 → 09 → [complete]
Full:        00 → 01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → [complete]
Team+Review: 00 → 01/01b → 02 → 03b → 04 → 05b → 06b → 09 → [complete]
```

---

## Resume (`-r {task-id}`)

1. Find task: `ls .claude/output/apex/ | grep {resume_task}` (exact or partial match)
2. Restore state from `00-context.md` (all flags, AC, step context)
3. Apply overrides (e.g., `/apex -t -r 01` adds test_mode)
4. Find resume target: `next_step` from State Snapshot (fallback: first non-Complete row)
5. "⏳ In Progress" = crashed step → restart it
6. Load target step — each step has a context restoration block

### Context Restoration per Step

| Step | Reads on Resume |
|------|-----------------|
| 01-analyze | 00-context.md only |
| 02-plan | 00-context.md + 01-analyze.md |
| 03-execute | 00-context.md + 02-plan.md (+ git diff for partial work) |
| 04-validate | 00-context.md + 03-execute.md |
| 05-examine | 00-context.md + 03-execute.md + 05-examine.md |
| 06-resolve | 00-context.md + 05-examine.md |
| 07-tests | 00-context.md + 03-execute.md |
| 08-run-tests | 00-context.md + 07-tests.md |
| 09-finish | 00-context.md only |

---

## State Variables

| Variable | Type | Description |
|----------|------|-------------|
| `{task_id}` | string | Full ID: `01-add-auth-middleware` |
| `{task_description}` | string | What to implement (flags removed) |
| `{feature_name}` | string | Kebab-case without number: `add-auth-middleware` |
| `{acceptance_criteria}` | list | Success criteria (inferred or explicit) |
| `{output_dir}` | string | `.claude/output/apex/{task_id}/` |
| `{next_step}` | string | Next step to execute |
| `{skill_dir}` | string | Absolute path to this skill directory |
| `{branch_name}` | string | Created branch name (if branch_mode) |
| `{base_branch}` | string | PR target for feature→feature PRs |
| `{worktree_path}` | string | Git worktree path (if worktree_mode) |
| `{issue_url}` | string | GitHub issue URL (if provided) |
| `{reference_files}` | string | Reference doc paths (e.g., brainstorm output) |
| `{resume_task}` | string | Task ID to resume (if -r) |
| All `{*_mode}` flags | boolean | examine, test, economy, team, branch, pr, interactive, worktree |

---

## Output & Templates

All outputs saved to `.claude/output/apex/{task_id}/`. Step-00 runs `scripts/setup-templates.sh` to initialize files from `templates/`.

Each step: `update-progress.sh` → append findings → `update-progress.sh` (complete).

Template system saves ~1,350 tokens per workflow (75% reduction). See `templates/README.md`.

---

## Reference Docs

| Doc | Content |
|-----|---------|
| `ARCHITECTURE.md` | System design, state management, agent strategy, mode compatibility, anti-patterns |
| `templates/README.md` | Template system, variables, maintenance |
| `steps/step-*.md` | Progressive step files (load one at a time) |
| `scripts/*.sh` | Automation (progress, templates, session boundary, worktree) |
