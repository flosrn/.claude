---
name: step-00b-worktree
description: Create git worktree for isolated APEX workspace
returns_to: step-00-init.md
---

# Step 0b: Worktree Setup

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER create worktree on a branch that already has one
- 🛑 NEVER skip worktree verification
- ✅ ALWAYS verify we're in main repo (not already in a worktree)
- ✅ ALWAYS store {branch_name} and {worktree_path} before returning
- 📋 YOU ARE A WORKTREE MANAGER, not an implementer
- 💬 FOCUS on worktree setup only
- 🚫 FORBIDDEN to start any implementation work

## CONTEXT BOUNDARIES:

- Variables available: `{task_id}`, `{auto_mode}`, `{pr_mode}`, `{feature_name}`
- This sub-step sets: `{branch_name}`, `{worktree_path}`
- Return to step-00-init.md after completion

## YOUR TASK:

Create a git worktree for isolated workspace during the APEX workflow.

---

## EXECUTION SEQUENCE:

### 1. Verify Not Already in Worktree

```bash
git rev-parse --is-inside-work-tree
git worktree list
```

Check we're in the main worktree, not already in a secondary one.
Parse the output of `git worktree list` — the first entry is the main worktree. If the current directory does not match the first entry, abort with error:
```
Error: Already inside a worktree. Cannot create nested worktrees.
```

### 2. Determine Worktree Location

Default path: `../{project_dir_name}-wt-{task_id}/`

Where `{project_dir_name}` is the basename of the current directory.

Example: If in `/Users/flo/projects/myapp`, worktree goes to `/Users/flo/projects/myapp-wt-01-add-auth/`

```bash
PROJECT_DIR_NAME=$(basename "$(pwd)")
WORKTREE_PATH="../${PROJECT_DIR_NAME}-wt-${task_id}"
```

### 3. Create Worktree

**If `{auto_mode}` = true:**
→ Auto-create: `git worktree add -b feat/{task_id} {worktree_path}`

**If `{auto_mode}` = false:**
Use AskUserQuestion:
```yaml
questions:
  - header: "Worktree"
    question: "Create an isolated worktree for this task?"
    options:
      - label: "Create worktree (Recommended)"
        description: "Creates worktree at {worktree_path} on branch feat/{task_id}"
      - label: "Custom location"
        description: "I'll specify the worktree path"
      - label: "Fall back to branch"
        description: "Just create a branch instead (no worktree)"
    multiSelect: false
```

### 4. Execute Creation

**If user chose "Create worktree" or auto_mode:**
```bash
git worktree add -b feat/{task_id} {worktree_path}
```
→ `{branch_name}` = `feat/{task_id}`
→ `{worktree_path}` = the created path

**If user chose "Custom location":**
→ Ask for worktree path
```bash
git worktree add -b feat/{task_id} {custom_path}
```
→ `{branch_name}` = `feat/{task_id}`
→ `{worktree_path}` = `{custom_path}`

**If user chose "Fall back to branch":**
→ Load `steps/step-00b-branch.md` instead
→ Set `{worktree_path}` = "" (empty, no worktree created)

### 5. Important: Do NOT cd into worktree

The APEX workflow continues in the CURRENT directory. The worktree is created for later use or for the user to cd into manually. Display the path so the user knows where it is.

### 6. Confirm and Return

Display:
```
✓ Worktree: {worktree_path}
  Branch: {branch_name}
  To work in it: cd {worktree_path}
```

→ Return to step-00-init.md with `{branch_name}` and `{worktree_path}` set

---

## SUCCESS METRICS:

✅ Verified not already inside a worktree
✅ Worktree created at correct path
✅ Branch created on worktree
✅ `{branch_name}` variable set
✅ `{worktree_path}` variable set
✅ User informed of worktree location

## FAILURE MODES:

❌ Creating worktree inside another worktree
❌ Starting implementation before returning
❌ Not setting `{branch_name}` or `{worktree_path}` variables
❌ Creating worktree without user consent (when not auto_mode)
❌ Changing directory into the worktree
❌ **CRITICAL**: Using plain text prompts instead of AskUserQuestion

---

## RETURN:

After worktree setup complete, return to `./step-00-init.md` to continue initialization.

<critical>
Remember: This sub-step ONLY handles worktree setup. Return immediately after setting {branch_name} and {worktree_path}.
</critical>
