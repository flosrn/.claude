---
name: apex
description: Systematic implementation using APEX methodology (Analyze-Plan-Execute-eXamine) with parallel agents, self-validation, and optional adversarial review. Use when implementing features, fixing bugs, or making code changes that benefit from structured workflow.
argument-hint: "[-x] [-t] [-w] [-wt] [-b] [-pr] [-i] [-r <task-id>] <task description>"
---

<objective>
Execute systematic implementation workflows using the APEX methodology. This skill uses progressive step loading to minimize context usage and supports saving outputs for review and resumption.
</objective>

<quick_start>
**Step-by-step mode:** Each step runs in its own session. Resume with `/apex -r`.

```bash
/apex add authentication middleware
# → Runs step-00 + step-01, stops with resume command
# → /apex -r 01-add-authentication-middleware  (next session)
```

**With adversarial review:**

```bash
/apex -x fix login bug
```

**Flags:**

- `-x` (examine): Include adversarial code review
- `-t` (test): Create and run tests
- `-w` (team): Use Agent Teams for parallel research, execution, review, and resolution
- `-wt` (worktree): Isolate work in a git worktree (enables `-b`)
- `-pr` (pull-request): Create PR at end

Outputs always saved to `.claude/output/apex/` (required for resume between sessions).

See `<parameters>` for complete flag list.
</quick_start>

<parameters>

<flags>
**Enable flags (turn ON):**
| Short | Long | Description |
|-------|------|-------------|
| `-x` | `--examine` | Examine mode: proceed to adversarial review |
| `-t` | `--test` | Test mode: include test creation and runner steps |
| `-e` | `--economy` | Economy mode: no subagents, save tokens (for limited plans) |
| `-w` | `--team` | Team mode: use Agent Teams for parallel research, execution, review, and resolution (incompatible with `-e`) |
| `-r` | `--resume` | Resume mode: continue from a previous task |
| `-b` | `--branch` | Branch mode: verify not on main, create branch if needed |
| `-wt` | `--worktree` | Worktree mode: isolate work in a git worktree (enables -b) |
| `-pr` | `--pull-request` | PR mode: create pull request at end (enables -b) |
| `-i` | `--interactive` | Interactive mode: configure flags via AskUserQuestion |

**Disable flags (turn OFF):**
| Short | Long | Description |
|-------|------|-------------|
| `-X` | `--no-examine` | Disable examine mode |
| `-T` | `--no-test` | Disable test mode |
| `-E` | `--no-economy` | Disable economy mode |
| `-W` | `--no-team` | Disable team mode |
| `-B` | `--no-branch` | Disable branch mode |
| `-WT` | `--no-worktree` | Disable worktree mode |
| `-PR` | `--no-pull-request` | Disable PR mode |
| `-I` | `--no-interactive` | Disable interactive mode |
</flags>

<examples>
```bash
# Basic
/apex add auth middleware

# With adversarial review
/apex -x add auth middleware

# Full workflow with tests and review
/apex -x -t add auth middleware

# With PR creation
/apex -pr add auth middleware

# Resume previous task
/apex -r 01-auth-middleware
/apex -r 01  # Partial match

# Resume with additional flags (add tests mid-workflow)
/apex -t -r 01

# Economy mode (save tokens)
/apex -e add auth middleware

# Team mode (parallel execution with Agent Teams)
/apex -w implement full-stack feature
/apex -w -x implement dashboard with backend API

# Worktree isolation
/apex -wt add auth middleware

# Worktree + PR
/apex -wt -pr add auth middleware

# Interactive flag config
/apex -i add auth middleware
```
</examples>

<parsing_rules>
**Flag parsing:**

1. Defaults loaded from `steps/step-00-init.md` `<defaults>` section
2. Command-line flags override defaults (enable with lowercase `-x`, disable with uppercase `-X`)
3. Flags removed from input, remainder becomes `{task_description}`
4. Task ID generated as `NN-kebab-case-description`

For detailed parsing algorithm, see `steps/step-00-init.md`.
</parsing_rules>

</parameters>

<output_structure>
**Output structure (always saved):**

All outputs saved to PROJECT directory (where Claude Code is running):
```

.claude/output/apex/{task-id}/
├── 00-context.md # Params, user request, timestamp
├── 01-analyze.md # Analysis findings
├── 02-plan.md # Implementation plan
├── 03-execute.md # Execution log
├── 04-validate.md # Validation results
├── 05-examine.md # Review findings (if -x)
├── 06-resolve.md # Resolution log (if -x)
├── 07-tests.md # Test analysis and creation (if --test)
├── 08-run-tests.md # Test runner log (if --test)
└── 09-finish.md # Workflow finish and PR creation (if --pull-request)

```

**00-context.md structure:**
```markdown
# APEX Task: {task_id}

**Created:** {timestamp}
**Task:** {task_description}

## Configuration

| Flag | Value |
|------|-------|
| Examine mode (`-x`) | {examine_mode} |
| Test mode (`-t`) | {test_mode} |
| Economy mode (`-e`) | {economy_mode} |
| Team mode (`-w`) | {team_mode} |
| Branch mode (`-b`) | {branch_mode} |
| PR mode (`-pr`) | {pr_mode} |
| Interactive mode (`-i`) | {interactive_mode} |
| Worktree mode (`-wt`) | {worktree_mode} |

## User Request
{original user input}

## Progress
| Step | Status | Timestamp |
|------|--------|-----------|
| 00-init | ... | ... |
...

## State Snapshot
**feature_name:** ...
**next_step:** ...
### Acceptance Criteria
### Step Context
### Gotchas
```

</output_structure>

<resume_workflow>
**Resume mode (`-r {task-id}`):**

When provided, step-00 will:

1. **Find task folder:** `ls .claude/output/apex/ | grep {resume_task}` (exact or partial match)
2. **Restore state:** Read `00-context.md` → all flags, task info, acceptance criteria, step context
3. **Apply overrides:** Any flags passed with `-r` override stored values (e.g., `/apex -t -r 01` enables test_mode)
4. **Re-evaluate steps:** If flags changed (e.g., `-t` added), update Progress table Skip→Pending
5. **Find resume target:** Read `next_step` from State Snapshot (fallback: first non-Complete/non-Skip row in Progress table)
6. **Handle crashes:** "⏳ In Progress" status = crashed step → restart it
7. **Load target step:** Each step has a Context Restoration block that reads its required prior outputs

**Error handling:**
- `/apex -r` with no existing output dir → clear error message
- No match found → list available tasks, ask user to specify

Supports partial matching (e.g., `-r 01` finds `01-add-auth-middleware`).
</resume_workflow>

<workflow>
**Standard flow:**
1. Parse flags and task description
2. If `-r`: Execute resume workflow (restore state, load target step)
3. Create output folder and 00-context.md
4. Load step-01-analyze.md → gather context
5. Load step-02-plan.md → create strategy
6. Load step-03-execute.md → implement
7. Load step-04-validate.md → verify
8. If `--test`: Load step-07-tests.md → analyze and create tests
9. If `--test`: Load step-08-run-tests.md → run until green
10. If `-x` or user requests: Load step-05-examine.md → adversarial review
11. If findings: Load step-06-resolve.md → fix findings
12. If `-pr`: Load step-09-finish.md → create pull request

**Session behavior:**
- Each step stops after completion with a resume command. Steps 00+01 run together as the first session.
- Outputs always saved to `.claude/output/apex/` for cross-session state transfer.
</workflow>

<stop_resume>
**Step-by-step mode:**

APEX runs one step per session:

1. **First session:** step-00-init + step-01-analyze run together
   - After step-01 completes: saves state, shows resume command, **STOPS**
2. **Each subsequent session:** `/apex -r {task_id}` runs one step
   - Restores all state from `00-context.md` + previous step outputs
   - Executes the step
   - Saves state, shows resume command, **STOPS**

**Session boundary display:**
```
═══════════════════════════════════════
  STEP {NN} COMPLETE: {name}
═══════════════════════════════════════
  {summary}
  Resume: /apex -r {task_id}
  Next: Step {NN} - {description}
═══════════════════════════════════════
```

**Context restoration per step:**

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

**State Snapshot** (in 00-context.md): tracks `next_step`, acceptance criteria, per-step context summaries, and **gotchas** (surprises, workarounds, deviations from plan) for reliable cross-session state transfer.
</stop_resume>

<state_variables>
**Persist throughout all steps:**

| Variable                | Type    | Description                                            |
| ----------------------- | ------- | ------------------------------------------------------ |
| `{task_description}`    | string  | What to implement (flags removed)                      |
| `{feature_name}`        | string  | Kebab-case name without number (e.g., `add-auth-middleware`) |
| `{task_id}`             | string  | Full identifier with number (e.g., `01-add-auth-middleware`) |
| `{acceptance_criteria}` | list    | Success criteria (inferred or explicit)                |
| `{examine_mode}`        | boolean | Auto-proceed to adversarial review                     |
| `{test_mode}`           | boolean | Include test steps (07-08)                             |
| `{economy_mode}`        | boolean | No subagents, direct tool usage only                   |
| `{team_mode}`           | boolean | Use Agent Teams for parallel research (01), execution (03), review (05), and resolution (06) |
| `{branch_mode}`         | boolean | Verify not on main, create branch if needed            |
| `{pr_mode}`             | boolean | Create pull request at end                             |
| `{interactive_mode}`    | boolean | Configure flags interactively                          |
| `{worktree_mode}`       | boolean | Isolate work in a git worktree (enables branch_mode)   |
| `{worktree_path}`       | string  | Path to git worktree (if worktree_mode)                |
| `{next_step}`           | string  | Next step to execute (persisted in State Snapshot)     |
| `{reference_files}`     | string  | Path(s) to reference documents (e.g., brainstorm output) |
| `{resume_task}`         | string  | Task ID to resume (if -r provided)                     |
| `{output_dir}`          | string  | Full path to output directory                          |
| `{branch_name}`         | string  | Created branch name (if branch_mode)                   |
| `{base_branch}`         | string  | PR target branch for feature→feature PRs (empty = default branch) |
| `{issue_url}`           | string  | GitHub issue URL (if passed in task description or 00-context.md) |
| `{skill_dir}`           | string  | Absolute path to this skill's directory (auto-resolved) |

</state_variables>

<entry_point>

**FIRST ACTION:** Load `steps/step-00-init.md`

Step 00 handles:

- Flag parsing (-x, -t, -e, -w, -wt, -b, -pr, -i, -r)
- Resume mode detection and task lookup
- Output folder creation
- 00-context.md creation
- State variable initialization

After initialization, step-00 loads step-01-analyze.md.

</entry_point>

<step_files>
**Progressive loading - only load current step:**

| Step | File                         | Purpose                                              |
| ---- | ---------------------------- | ---------------------------------------------------- |
| 00   | `steps/step-00-init.md`      | Parse flags, create output folder, initialize state  |
| 00b  | `steps/step-00b-branch.md`   | Branch verification and creation (if branch_mode, skipped if worktree_mode) |
| 00b  | `steps/step-00b-interactive.md` | Interactive flag configuration via AskUserQuestion (if interactive_mode) |
| 00b  | `steps/step-00b-economy.md`  | Economy mode adjustments (if economy_mode)           |
| 00c  | `steps/step-00c-worktree.md` | Worktree creation and environment setup (if worktree_mode, replaces 00b-branch) |
| 01   | `steps/step-01-analyze.md`   | Smart context gathering with 1-10 parallel agents (built-in + custom) |
| 01b  | `steps/step-01b-team-analyze.md` | Agent Team parallel research (if team_mode)         |
| 02   | `steps/step-02-plan.md`      | File-by-file implementation strategy                 |
| 03   | `steps/step-03-execute.md`   | Todo-driven implementation (solo)                    |
| 03b  | `steps/step-03b-team-execute.md` | Agent Team parallel implementation (if team_mode)  |
| 04   | `steps/step-04-validate.md`  | Self-check and validation                            |
| 05   | `steps/step-05-examine.md`   | Adversarial code review (optional)                   |
| 05b  | `steps/step-05b-team-examine.md` | Agent Team parallel adversarial review (if team_mode) |
| 06   | `steps/step-06-resolve.md`   | Finding resolution (optional)                        |
| 06b  | `steps/step-06b-team-resolve.md` | Agent Team parallel finding resolution (if team_mode) |
| 07   | `steps/step-07-tests.md`     | Test analysis and creation (if --test)               |
| 08   | `steps/step-08-run-tests.md` | Test runner loop until green (if --test)             |
| 09   | `steps/step-09-finish.md`    | Create pull request (if --pull-request)              |

</step_files>

<execution_rules>

- **Load one step at a time** - Only load the current step file
- **ULTRA THINK** before major decisions
- **Persist state variables** across all steps
- **Follow next_step directive** at end of each step
- **Save outputs** to step files (always enabled)
- **Use parallel agents** for independent exploration tasks
- **Session boundary:** Each step STOPS after completion and displays a resume command. See `<stop_resume>` for details.
- **Per-step commits:** When `branch_mode=true`, each code-modifying step (03, 04, 06, 07, 08) automatically commits changes with message `apex({task_id}): step NN - name`. This gives PRs granular commit history.
- **Worktree isolation:** Use `-wt` flag to isolate work in a git worktree. This auto-enables branch mode, creates a worktree via `EnterWorktree`, copies `.env` files, symlinks `node_modules` and other heavy directories, and generates a deterministic port offset. The worktree is cleaned up when the Claude Code session ends.
- **Team mode:** When `{team_mode}=true`, Agent Teams parallelize four phases: research (`step-01b-team-analyze.md`), implementation (`step-03b-team-execute.md`), adversarial review (`step-05b-team-examine.md`), and finding resolution (`step-06b-team-resolve.md`). Researchers share findings cross-domain; reviewers challenge each other's findings; resolvers fix findings by file group. Incompatible with `-e` (economy mode).

## 🧠 Smart Agent Strategy in Analyze Phase

The analyze phase (step-01) uses **adaptive agent launching** (unless economy_mode):

**Available agents:**
- `Explore` (built-in) - Find existing patterns, files, utilities
- `explore-docs` (custom, requires `.claude/agents/explore-docs.md`) - Research library docs via Context7 (use when unfamiliar with API)
- `websearch` (built-in) - Find approaches, best practices, gotchas

**Review agents (step-05):**
- `Explore` (built-in) - Adversarial review with focus areas (security, logic, clean-code) — read-only, fast

**Launch 1-10 agents based on task complexity:**

| Complexity | Agents | When |
|------------|--------|------|
| Simple | 1-2 | Bug fix, small tweak |
| Medium | 2-4 | New feature in familiar stack |
| Complex | 4-7 | Unfamiliar libraries, integrations |
| Major | 6-10 | Multiple systems, many unknowns |

**BE SMART:** Analyze what you actually need before launching. Don't over-launch for simple tasks, don't under-launch for complex ones.

</execution_rules>

<save_output_pattern>
**Output pattern (always active):**

Step-00 runs `scripts/setup-templates.sh` to initialize all output files from `templates/` directory.

**Each step then:**

1. Run `scripts/update-progress.sh {task_id} {step_num} {step_name} "in_progress"`
2. Append findings/outputs to the pre-created step file
3. Run `scripts/update-progress.sh {task_id} {step_num} {step_name} "complete"`

**Template system benefits:**

- Reduces token usage by ~75% (1,350 tokens saved per workflow)
- Templates in `templates/` directory (not inline in steps)
- Scripts handle progress tracking automatically
- See `templates/README.md` for details

</save_output_pattern>

<success_criteria>

- Each step loaded progressively
- All validation checks passing
- Outputs saved to `.claude/output/apex/`
- Tests passing if `{test_mode}` enabled
- Clear completion summary provided
  </success_criteria>
