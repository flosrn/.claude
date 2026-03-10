---
name: step-00c-worktree
description: Create isolated git worktree for APEX workflow
returns_to: step-00-init.md
---

# Step 0c: Worktree Setup

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER skip worktree creation when worktree_mode enabled
- 🛑 NEVER run implementation work in this sub-step
- ✅ ALWAYS capture MAIN_REPO_ROOT before entering worktree
- ✅ ALWAYS store {worktree_path} and {branch_name} before returning
- 📋 YOU ARE A WORKTREE MANAGER, not an implementer
- 💬 FOCUS on worktree setup only
- 🚫 FORBIDDEN to start any implementation work

## CONTEXT BOUNDARIES:

- Variables available: `{task_id}`, `{pr_mode}`
- This sub-step sets: `{worktree_path}`, `{branch_name}`
- Return to step-00-init.md after completion
- **This sub-step REPLACES step-00b-branch** — the worktree creates its own branch

## YOUR TASK:

Create an isolated git worktree using Claude Code's native `EnterWorktree`, then configure the environment with `setup-worktree.sh`.

---

## EXECUTION SEQUENCE:

### 0. Guard Against Nested Worktrees

**Before creating a worktree, check if we're already inside one:**

```bash
# Check if current directory is already a git worktree (not the main working tree)
IS_WORKTREE=$(git rev-parse --is-inside-work-tree 2>/dev/null && git rev-parse --git-common-dir 2>/dev/null)
MAIN_GIT=$(git rev-parse --git-dir 2>/dev/null)
```

If `MAIN_GIT` contains `/worktrees/` (i.e., we're already in a worktree):
→ **STOP** with error: "⚠️ Already inside a git worktree. Cannot create nested worktrees. Use `-b` (branch mode) instead of `-wt` (worktree mode) when running inside an existing worktree."

### 1. Capture Main Repo Root

**Before entering the worktree**, capture the current working directory:

```
{main_repo_root} = current working directory (pwd)
```

This is needed by `setup-worktree.sh` to copy .env files and create symlinks.

### 2. Enter Worktree

Use Claude Code's native `EnterWorktree` tool:

```
EnterWorktree(name: {task_id})
```

This creates a new git worktree with its own branch at `.claude/worktrees/{task_id}`.

After `EnterWorktree` completes:
- The session's working directory is now inside the worktree
- A new branch has been created automatically
- Store the new working directory as `{worktree_path}`

### 3. Capture Branch Name

```bash
git branch --show-current
```

→ Store result as `{branch_name}`

### 4. Run Environment Setup

```bash
bash {skill_dir}/scripts/setup-worktree.sh "{main_repo_root}" "{worktree_path}" "{task_id}"
```

This script:
- Copies `.env`, `.env.local`, `.env.*.local` from main repo
- Creates relative symlinks for `node_modules`, `.next/cache`, `vendor`, `target`, `.venv`
- Generates a deterministic `PORT_OFFSET` from `{task_id}` hash
- Detects project type

### 5. Confirm and Return

Display:
```
✓ Worktree: {worktree_path}
  Branch: {branch_name}
  Environment configured
```

→ Return to step-00-init.md with `{worktree_path}` and `{branch_name}` set

---

## SUCCESS METRICS:

✅ Main repo root captured before entering worktree
✅ Worktree created via EnterWorktree
✅ `{worktree_path}` variable set
✅ `{branch_name}` variable set
✅ Environment setup script ran successfully

## FAILURE MODES:

❌ Starting implementation before returning
❌ Not capturing main_repo_root before EnterWorktree
❌ Not setting `{worktree_path}` or `{branch_name}` variables
❌ Running step-00b-branch after this step (worktree already creates a branch)

---

## RETURN:

After worktree setup complete, return to `./step-00-init.md` to continue initialization.

<critical>
Remember: This sub-step ONLY handles worktree setup. Return immediately after setting {worktree_path} and {branch_name}.
The worktree will be cleaned up automatically when the Claude Code session ends.
</critical>
