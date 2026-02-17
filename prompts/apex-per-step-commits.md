# APEX Workflow: Per-Step Commits & Worktree Fix

<context>
The APEX workflow skill at `skills/workflow-apex/` has a git integration problem. When using `-pr` (pull request) and/or `-wt` (worktree) flags, the workflow creates a branch at init time but then:

1. **No commits between steps** - Only 2 commits exist: a safety checkpoint before step-03 (`git add -u && git commit --allow-empty`) and a final catch-all commit at step-09. This produces a single giant commit in the PR, making code review difficult.

2. **Worktree created but never used** - `step-00b-worktree.md:101-103` explicitly says "The APEX workflow continues in the CURRENT directory." The worktree is created with its branch, but all work happens in the main repo. The `-wt` flag is functionally useless.

3. **`session-boundary.sh` is the perfect commit hook** - This script runs at every step boundary (end of each step). It already calls `update-progress.sh` and `update-state-snapshot.sh`. Adding a conditional commit here would give per-step atomic commits for free.

**Key files involved:**
- `scripts/session-boundary.sh` - Runs at every step boundary
- `scripts/update-state-snapshot.sh` - Updates 00-context.md state
- `steps/step-00-init.md` - Flag parsing, branch/worktree setup flow
- `steps/step-00b-branch.md` - Branch creation
- `steps/step-00b-worktree.md` - Worktree creation (currently broken)
- `steps/step-03-execute.md` - Has safety checkpoint commit
- `steps/step-03b-team-execute.md` - Has team safety checkpoint commit
- `steps/step-09-finish.md` - Final commit + push + PR creation
- `steps/step-04-validate.md` - May modify code (fixes)
- `steps/step-06-resolve.md` - May modify code (review fixes)
- `steps/step-07-tests.md` - Creates test files
- `steps/step-08-run-tests.md` - May modify code (test fixes)
- `SKILL.md` - Documents flags and workflow
</context>

<objective>
Implement three improvements to APEX git workflow, in order:

**R1** - Per-step commits when `branch_mode=true`
**R2** - Fix or remove the broken worktree support
**R3** - Simplify step-09-finish since commits already happened per-step
</objective>

<instructions>
## Phase 0: MANDATORY - Complete Workflow Analysis

Before making ANY changes, you MUST read and understand the entire APEX workflow. This is a complex multi-file system where changes to one file can break others.

**Read ALL of these files (use parallel reads):**

Batch 1 - Scripts:
- `skills/workflow-apex/scripts/session-boundary.sh`
- `skills/workflow-apex/scripts/update-progress.sh`
- `skills/workflow-apex/scripts/update-state-snapshot.sh`
- `skills/workflow-apex/scripts/setup-templates.sh`
- `skills/workflow-apex/scripts/generate-task-id.sh`

Batch 2 - Init flow:
- `skills/workflow-apex/SKILL.md`
- `skills/workflow-apex/steps/step-00-init.md`
- `skills/workflow-apex/steps/step-00b-branch.md`
- `skills/workflow-apex/steps/step-00b-worktree.md`
- `skills/workflow-apex/steps/step-00b-interactive.md`
- `skills/workflow-apex/steps/step-00b-economy.md`

Batch 3 - Steps that modify code:
- `skills/workflow-apex/steps/step-03-execute.md`
- `skills/workflow-apex/steps/step-03b-team-execute.md`
- `skills/workflow-apex/steps/step-04-validate.md`
- `skills/workflow-apex/steps/step-06-resolve.md`
- `skills/workflow-apex/steps/step-07-tests.md`
- `skills/workflow-apex/steps/step-08-run-tests.md`

Batch 4 - Steps that DON'T modify code:
- `skills/workflow-apex/steps/step-01-analyze.md`
- `skills/workflow-apex/steps/step-01b-team-analyze.md`
- `skills/workflow-apex/steps/step-02-plan.md`
- `skills/workflow-apex/steps/step-05-examine.md`
- `skills/workflow-apex/steps/step-05b-team-examine.md`

Batch 5 - Finish:
- `skills/workflow-apex/steps/step-09-finish.md`

Batch 6 - Templates:
- `skills/workflow-apex/templates/README.md`
- `skills/workflow-apex/templates/00-context.md`

After reading, confirm your understanding by answering these questions (to yourself, in thinking):
1. How does `session-boundary.sh` get called? What are its arguments?
2. Which steps call `session-boundary.sh` vs calling `update-progress.sh` + `update-state-snapshot.sh` directly?
3. How does the auto_mode=true path differ from auto_mode=false for git operations?
4. Where does `{branch_mode}` get stored and how is it accessible from bash scripts?
5. What is the current commit flow? (checkpoint in step-03, final in step-09, anything else?)

## Phase 1: Implement R1 - Per-Step Commits

### 1.1 Design Decision

Steps that modify code and should commit: `03-execute`, `04-validate`, `06-resolve`, `07-tests`, `08-run-tests`
Steps that do NOT modify code (no commit needed): `00-init`, `01-analyze`, `02-plan`, `05-examine`, `09-finish`

The commit should happen:
- **auto_mode=true path**: In the step file itself, right before calling `update-progress.sh` + `update-state-snapshot.sh` (since session-boundary.sh is NOT called in auto_mode)
- **auto_mode=false path**: In `session-boundary.sh` (which is called at the end of every step in non-auto mode)

### 1.2 Modify `session-boundary.sh`

Add a conditional git commit BEFORE the progress/state updates. The script needs:
- A new optional argument: `COMMIT_FLAG` (e.g., "commit" or empty)
- When `COMMIT_FLAG` is "commit": run `git add -u && git commit -m "apex({TASK_ID}): step {STEP_NUM} - {STEP_NAME}"` (only if there are staged changes)
- When `COMMIT_FLAG` is empty or missing: skip the commit (for non-code steps)
- The commit MUST be non-blocking: if nothing to commit, silently continue

**Commit message format:** `apex({task_id}): step {NN} - {step_name}`
Example: `apex(01-add-auth): step 03 - execute`

### 1.3 Update Step Files That Modify Code

For each of these steps: `step-03-execute.md`, `step-04-validate.md`, `step-06-resolve.md`, `step-07-tests.md`, `step-08-run-tests.md`:

**auto_mode=false path (session boundary call):**
Add the commit flag argument to the existing `session-boundary.sh` call.

**auto_mode=true path (direct script calls):**
Add a git commit command before the `update-progress.sh` call:
```bash
git add -u && git diff --cached --quiet || git commit -m "apex({task_id}): step {NN} - {step_name}"
```

**Also for team variants:** `step-03b-team-execute.md`

### 1.4 Handle the Existing Checkpoint in step-03

The existing safety checkpoint (`git add -u && git commit --allow-empty -m "apex: checkpoint before execute"`) should remain. It serves a different purpose (rollback safety net). The per-step commit at the END of step-03 will capture the actual implementation work.

### 1.5 Guard All Commits with branch_mode Check

Every commit (both in session-boundary.sh and in auto_mode paths) MUST be conditional on `{branch_mode} = true`. When branch_mode is false, users are working on their current branch and may not want automatic commits.

**Important:** In bash scripts, `{branch_mode}` is NOT directly available as a variable. You need to either:
- Pass it as an argument to session-boundary.sh, OR
- Read it from `00-context.md` (grep the Configuration table), OR
- Add a new script argument

Choose the cleanest approach. Passing as argument is simplest.

## Phase 2: Implement R2 - Fix or Remove Worktree

Evaluate and decide:

**Option A - Remove `-wt` flag entirely:**
- Remove `step-00b-worktree.md`
- Remove worktree flag parsing from `step-00-init.md`
- Remove worktree references from `step-00b-interactive.md`
- Remove `{worktree_mode}`, `{worktree_path}` from state variables
- Add a note in SKILL.md: "For worktree isolation, use the `using-git-worktrees` skill before running /apex"
- This is the SIMPLER option and avoids maintaining complex worktree logic

**Option B - Make worktree actually work:**
- After creating worktree in step-00b-worktree.md, ALL subsequent file operations must happen in `{worktree_path}`
- This is EXTREMELY complex because every Read, Write, Edit, Glob, Grep call would need path prefixing
- Not recommended

**Use AskUserQuestion to let the user choose between Option A and Option B.**

## Phase 3: Implement R3 - Simplify step-09-finish

Since per-step commits now handle most git operations:

1. The "commit uncommitted changes" section in step-09 should become a safety net, not the primary commit
2. Change the commit message to: `apex({task_id}): final changes` (instead of the full task description)
3. The primary commit message with the full task description should be on the PR title only
4. Keep the push and PR creation logic unchanged

## Phase 4: Update Documentation

- Update `SKILL.md` to document the per-step commit behavior when `branch_mode=true`
- Update `templates/README.md` if any new variables or behaviors are added
- Update `session-boundary.sh` header comment to document new arguments
</instructions>

<constraints>
- NEVER modify files without reading them first
- NEVER break the existing workflow for users who do NOT use `-pr` or `-b` flags
- All commits MUST be conditional on `branch_mode=true` - when false, zero git operations should be added
- The `git add -u` pattern MUST be preserved (tracked files only, never stage .env or secrets)
- Per-step commits MUST be non-blocking: if there's nothing to commit, the step continues normally
- session-boundary.sh MUST remain backward compatible: existing callers without the new argument should work (use default empty value)
- Do NOT refactor unrelated code while making these changes
- Test your changes mentally by tracing through a full auto_mode=true and auto_mode=false execution path
</constraints>

<success_criteria>
After implementation, a full APEX run with `-pr` flag should produce this git history:
```
apex(01-add-auth): step 03 - execute       ← implementation
apex(01-add-auth): step 04 - validate      ← validation fixes (if any)
apex(01-add-auth): step 07 - tests         ← test files
apex(01-add-auth): step 08 - run-tests     ← test fixes (if any)
```

And for steps that don't change code (01-analyze, 02-plan, 05-examine), NO commit should be created.

Without `-b` or `-pr` flag, the workflow MUST behave exactly as before (zero commits added).

Worktree flag is either properly functional or cleanly removed with migration guidance.
</success_criteria>
