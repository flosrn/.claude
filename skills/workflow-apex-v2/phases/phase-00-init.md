---
name: phase-00-init
description: Initialize APEX v2 workflow - parse flags, detect GitHub issues, setup state
next_phase: ./phase-01-context.md
---

# Phase 0: Initialization

Explorer (parse-only, no analysis)

---

## Default Configuration

```yaml
examine_mode: false       # -x: Auto-proceed to adversarial review
test_mode: false          # -t: Include test creation and validation
team_mode: false          # -w: Use Agent Teams for parallel work
branch_mode: false        # -b: Verify not on main, create branch
pr_mode: false            # -pr: Create pull request at end
worktree_mode: false      # -wt: Isolate in git worktree
auto_mode: false          # -a: Skip human checkpoints, auto-approve plans
pause_mode: false         # -p: Stop after each phase (legacy multi-session)
```

---

## EXECUTION SEQUENCE

### 1. Parse Flags and Input

**Load defaults, then override with flags:**

```
Enable (lowercase):
  -x → examine_mode = true
  -t → test_mode = true
  -w → team_mode = true
  -b → branch_mode = true
  -pr → pr_mode = true, branch_mode = true
  -wt → worktree_mode = true, branch_mode = true
  -a → auto_mode = true
  -p → pause_mode = true

Disable (UPPERCASE):
  -X, -T, -W, -B → set to false
  -A, -P → set to false
```

Extract {task_description} from remainder of input.

Generate {task_id} = kebab-case slug of first 3-4 words.

### 2. GitHub Issue Detection

**If {task_description} contains `#NNN` or `https://github.com/.../issues/NNN`:**

```bash
gh issue view NNN --json title,body,labels,assignees -t json > /tmp/issue.json
```

Parse JSON:
- Set {issue_url}, {issue_number}
- If no task_description beyond issue ref → use issue title
- Save issue body to `{output_dir}/issue-context.md`
- Set {reference_files} = `{output_dir}/issue-context.md`

### 3. Check Resume Mode

**Resume task matching strategy:**

If {resume_task} provided via `/apex -r {resume_task}`:

**Case 1: Exact match**
- Single task_dir matches {resume_task} exactly
- Offer: "Resume existing task?"
- If yes → proceed to next phase with restored context
- If no → create new {output_dir}

**Case 2: Multiple matches**
- Pattern matches multiple task_dirs (e.g., `/apex -r auth` matches `01-add-auth`, `03-fix-auth-bug`)
- Use AskUserQuestion: "Multiple tasks match '{resume_task}'. Which one?"
- List all matches with brief descriptions (from 00-init.md)
- User selects → resume that task or cancel
- If no selection → STOP

**Case 3: No matches**
- Pattern {resume_task} matches no existing task_dirs
- Use AskUserQuestion: "No tasks match '{resume_task}'. Available tasks:"
- List all existing task IDs with descriptions
- User either: picks existing task to resume, or starts new one with different pattern
- If user provides new task_id → create new {output_dir}, proceed

**If no resume_task provided:**
- Standard flow: create new {output_dir}

### 4. Pre-Flight Checks

```
✓ Git repo detected?
✓ Not in detached HEAD?
✓ Working directory clean? (if branch_mode)
✓ output_dir writable?
```

If any fail, explain and STOP.

### 5. Branch Setup (inline)

**IF branch_mode = true:**

```bash
# Check current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" = "main" ]; then
  echo "❌ Cannot branch from main. Checkout a feature branch first."
  exit 1
fi

# Create feature branch if needed
git checkout -b {task_id} 2>/dev/null || git checkout {task_id}
```

### 6. Interactive Sub-Step (inline)

**IF interactive_mode = true:**

Show form:
```
Task: {task_description}
Examine mode: {examine_mode}
Test mode: {test_mode}
Team mode: {team_mode}
Auto-approve plans: {auto_mode}
Pause between phases: {pause_mode}
Branch/PR: {branch_mode} / {pr_mode}
Worktree: {worktree_mode}

Press ENTER to proceed, or edit flags above:
```

Apply any edits.

### 7. Worktree Sub-Step (inline)

**IF worktree_mode = true:**

```bash
git worktree add .worktrees/{task_id} -b {task_id}
cd .worktrees/{task_id}
```

All subsequent operations in worktree.

### 8. Create Output Structure

```bash
bash {skill_dir}/scripts/setup-templates.sh "{task_id}" "{output_dir}"
```

Creates:
- `{output_dir}/00-init.md` (this phase's output)
- `{output_dir}/01-context.md` (placeholder)
- `{output_dir}/02-plan.md` (placeholder)
- `.env.local` (state file)

### 9. Show Summary and Proceed

**Compact table (one screen):**

```
╔═══════════════════════════════════════╗
║ APEX v2: Initialization Complete      ║
╠═══════════════════════════════════════╣
║ Task ID        │ {task_id}            ║
║ Description    │ {task_description}   ║
║ Output Dir     │ {output_dir}         ║
║ Branch         │ {CURRENT_BRANCH}     ║
║ Worktree       │ {worktree_mode}      ║
╠═══════════════════════════════════════╣
║ Mode           │ auto_mode={auto_mode}║
║                │ pause_mode={p_mode}  ║
║                │ team_mode={team_mode}║
╚═══════════════════════════════════════╝

→ Proceeding to phase-01-context...
```

Save flags to `.env.local`:
```bash
cat > {output_dir}/.env.local <<EOF
TASK_ID={task_id}
TASK_DESCRIPTION={task_description}
EXAMINE_MODE={examine_mode}
TEST_MODE={test_mode}
TEAM_MODE={team_mode}
BRANCH_MODE={branch_mode}
PR_MODE={pr_mode}
WORKTREE_MODE={worktree_mode}
AUTO_MODE={auto_mode}
PAUSE_MODE={pause_mode}
ISSUE_URL={issue_url}
REFERENCE_FILES={reference_files}
EOF
```

### 10. Proceed to Phase 01

Load and execute `./phase-01-context.md`.
