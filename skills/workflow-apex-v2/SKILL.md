---
name: apex-v2
description: "APEX v2 — Single-session implementation workflow. Analyze-Plan-Execute-eXamine with 1M context optimization, GitHub issue integration, and smart model selection. Use when implementing features or fixing bugs."
argument-hint: "[-x] [-t] [-w] [-wt] [-b] [-pr] [-a] [-p] [-i] [-r <task-id>] <task description or #issue>"
---

# APEX v2 — Analyze-Plan-Execute-eXamine

Single-session implementation workflow. All 7 phases run sequentially without stopping (default). Pause between phases with `-p` for multi-day work or context pollution risk.

## Critical Rules

- **Single-session by default** — all phases run in order without stopping
- **Pause mode (`-p`)** — legacy behavior, stops between phases (one phase per session)
- **FIRST ACTION:** Load `phases/phase-00-init.md`
- **Human checkpoint** — after phase 02 (plan), before phase 03 (implement)
- **ULTRA THINK** before major decisions (plan, architecture, review)
- **Per-phase commits** (when branch_mode): `apex-v2({task_id}): phase NN - name`
- **Persist all state** to `00-context.md` — this is the cross-phase transfer mechanism

---

## Quick Start

```bash
/apex-v2 add authentication middleware              # Standard: analyze → plan → [checkpoint] → implement → validate
/apex-v2 -x fix login bug                          # Review: adds phase 04 (examine)
/apex-v2 -x -t add auth middleware                 # Full: review + tests (phases 04-05)
/apex-v2 -w -x implement dashboard API             # Team: parallel agents in analyze, implement, review
/apex-v2 -wt -pr add auth middleware               # Worktree isolation + PR creation
/apex-v2 -a add auth middleware                    # Auto: skip plan checkpoint (go straight to implement)
/apex-v2 -p add auth middleware                    # Pause: stop after each phase (legacy multi-session)
/apex-v2 -i add auth middleware                    # Interactive: configure flags via AskUserQuestion
/apex-v2 -r 01-auth-middleware                     # Resume from phase 01 context
/apex-v2 #123 -x                                   # GitHub issue #123 with review
```

## Flags

**Enable (lowercase):**

| Flag | Description |
|------|-------------|
| `-x` | Examine: adversarial code review (phase 04) |
| `-t` | Test: create and run tests (phase 05) |
| `-w` | Team: parallel Agent Teams for research, execution, review |
| `-wt` | Worktree: isolate in git worktree (enables `-b`) |
| `-b` | Branch: verify not on main, create branch if needed |
| `-pr` | PR: create pull request at end (enables `-b`) |
| `-a` | Auto: skip human checkpoint after plan (default: ask) |
| `-p` | Pause: stop between phases for multi-session work (legacy) |
| `-i` | Interactive: configure flags via AskUserQuestion |
| `-r` | Resume: continue from previous task |

**Disable (uppercase):** `-X`, `-T`, `-W`, `-WT`, `-B`, `-PR`, `-A`, `-P`, `-I`

**Parsing:** Defaults from `phases/phase-00-init.md`. CLI flags override. Flags removed from input → remainder = `{task_description}`. Task ID = `NN-kebab-case-description`.

**GitHub Issue Detection:** If input contains `#NNN` or a GitHub issue URL, auto-populate context from issue. Examples: `/apex-v2 #456`, `/apex-v2 https://github.com/owner/repo/issues/123`

---

## Phase Routing

**FIRST ACTION:** Load `phases/phase-00-init.md`

### Default Flow (Single-Session)

| Phase | File | Purpose | Runs |
|-------|------|---------|------|
| 00 | `phase-00-init.md` | Parse flags, detect GitHub issue, create output, init state | Always |
| 00b | `phase-00b-branch.md` | Branch verification/creation | `-b`, skipped if `-wt` |
| 00c | `phase-00c-worktree.md` | Worktree creation + env setup | `-wt` (replaces 00b-branch) |
| 01 | `phase-01-context.md` | Context gathering (1-10 agents) | Always |
| 02 | `phase-02-plan.md` | File-by-file strategy | Always |
| [checkpoint] | — | Human approval or auto-proceed (`-a`) | Always |
| 03 | `phase-03-implement.md` | Todo-driven implementation | Always |
| 04 | `phase-04-review.md` | Adversarial code review | `-x` |
| 05 | `phase-05-test.md` | Test analysis and creation | `-t` |
| 06 | `phase-06-ship.md` | Create PR + final summary | `-pr` |

### Multi-Path Flows

```
Standard:    00 → 01 → 02 → [checkpoint] → 03 → [complete]
Review:      00 → 01 → 02 → [checkpoint] → 03 → 04 → [complete]
Full:        00 → 01 → 02 → [checkpoint] → 03 → 04 → 05 → 06 → [complete]
Team:        00 → 01(team) → 02 → [checkpoint] → 03(team) → 04(team) → 06 → [complete]
Pause Mode:  00 → 01 → STOP → [user resumes] → 02 → STOP → [user resumes] → 03 → ...
```

---

## Resume (`-r {task-id}`)

1. Find task: `ls .claude/output/apex-v2/ | grep {resume_task}` (exact or partial match)
2. Restore state from `00-context.md` (all flags, AC, phase context)
3. Apply overrides (e.g., `/apex-v2 -t -r 01` adds test_mode)
4. Find resume target: `next_phase` from State Snapshot (fallback: first non-Complete row)
5. "⏳ In Progress" = crashed phase → restart it
6. Load target phase — each phase has a context restoration block

### Context Restoration per Phase

| Phase | Reads on Resume |
|-------|-----------------|
| 01-context | 00-context.md only |
| 02-plan | 00-context.md + 01-context.md |
| 03-implement | 00-context.md + 02-plan.md (+ git diff for partial work) |
| 04-review | 00-context.md + 03-implement.md |
| 05-test | 00-context.md + 03-implement.md |
| 06-ship | 00-context.md only |

---

## State Variables

| Variable | Type | Description |
|----------|------|-------------|
| `{task_id}` | string | Full ID: `01-add-auth-middleware` |
| `{task_description}` | string | What to implement (flags removed) |
| `{feature_name}` | string | Kebab-case without number: `add-auth-middleware` |
| `{acceptance_criteria}` | list | Success criteria (inferred or explicit) |
| `{output_dir}` | string | `.claude/output/apex-v2/{task_id}/` |
| `{next_phase}` | string | Next phase to execute |
| `{skill_dir}` | string | Absolute path to this skill directory |
| `{branch_name}` | string | Created branch name (if branch_mode) |
| `{base_branch}` | string | PR target for feature→feature PRs |
| `{worktree_path}` | string | Git worktree path (if worktree_mode) |
| `{issue_number}` | string | GitHub issue number (if detected) |
| `{issue_url}` | string | GitHub issue URL (if provided) |
| `{reference_files}` | string | Reference doc paths (e.g., brainstorm output) |
| `{resume_task}` | string | Task ID to resume (if -r) |
| All `{*_mode}` flags | boolean | examine, test, team, branch, pr, interactive, worktree, auto, pause |

---

## Output & Templates

All outputs saved to `.claude/output/apex-v2/{task_id}/`. Phase 00 runs `scripts/setup-templates.sh` to initialize files from `templates/`.

Each phase: progress table updated → append findings → mark complete.

Template system saves ~1,350 tokens per workflow (75% reduction). See `templates/README.md`.

---

## Model Selection for Subagents

When spawning subagents (step-01-context), use these hints:

| Model | Use Case | Complexity |
|-------|----------|------------|
| Opus | Research lead, code review lead, resolve findings | Complex decisions, synthesis |
| Sonnet | Feature implementation, test writing, validation | Execution, high volume |
| Haiku | Context gathering, file exploration, pattern matching | Fast, read-only exploration |

Economy mode: Sonnet for all (lowest cost).

---

## Reference Docs

| Doc | Content |
|-----|---------|
| `ARCHITECTURE.md` | System design, state management, agent strategy, GitHub issue flow, model selection, anti-patterns |
| `templates/README.md` | Template system, variables, maintenance |
| `phases/phase-*.md` | Progressive phase files (load in sequence by default) |
| `scripts/*.sh` | Automation (progress, templates, phase boundary, worktree) |
