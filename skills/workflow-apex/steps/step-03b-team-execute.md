---
name: step-03b-team-execute
description: Agent Team parallel implementation - execute the plan across multiple teammates by domain
prev_step: steps/step-02-plan.md
next_step: steps/step-04-validate.md
load_condition: team_mode = true
---

# Step 3b: Team Execute (Parallel Implementation)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER deviate from the approved plan
- 🛑 NEVER implement code yourself - delegate to teammates
- 🛑 NEVER skip plan approval for teammates
- ✅ ALWAYS use TeamCreate, TaskCreate, and Task tools
- ✅ ALWAYS approve each teammate's plan before they code
- ✅ ALWAYS verify no file conflicts after completion
- 📋 YOU ARE A COORDINATOR, not an implementer
- 💬 FOCUS on orchestrating teammates, not writing code
- 🚫 FORBIDDEN to use Edit, Write tools directly (teammates do the work)

## EXECUTION PROTOCOLS:

- 🎯 Extract domain partitions from plan before spawning
- 💾 Monitor task completion via TaskList
- 📖 Approve teammate plans via SendMessage plan_approval_response
- 🚫 FORBIDDEN to have teammates working on overlapping files

## CONTEXT BOUNDARIES:

- Plan from step-02 is approved and includes Domain Partitioning section
- team_mode = true (validated in step-00)
- auto_mode may be true or false (team_mode no longer requires auto_mode)
- This step replaces step-03-execute.md entirely

## CONTEXT RESTORATION (resume mode):

<critical>
If this step was loaded via `/apex -r {task_id}` resume:

1. Read `{output_dir}/00-context.md` → restore flags, task info, acceptance criteria
2. Read `{output_dir}/02-plan.md` → restore the implementation plan with domain partitioning
3. **Note:** Team mode cannot resume mid-execution (teammates don't survive sessions)
4. Check `git diff --name-only` for partial work from a previous attempt
5. If partial work exists, fall back to solo execution:
   → Set {team_mode} = false (disable for this session only)
   → Load step-03-execute.md (which will now execute solo since team_mode is false)
</critical>

## YOUR TASK:

Orchestrate parallel implementation by spawning Agent Team teammates, one per domain from the plan's Domain Partitioning section.

---

<available_state>
From previous steps:

| Variable | Description |
|----------|-------------|
| `{task_description}` | What to implement |
| `{task_id}` | Kebab-case identifier |
| `{auto_mode}` | true or false (team_mode no longer requires auto_mode) |
| `{save_mode}` | Save outputs to files |
| `{output_dir}` | Path to output (if save_mode) |
| Implementation plan | File-by-file changes from step-02 |
| Domain Partitioning | Domain groups with file assignments from step-02 |
| Patterns | How to implement from step-01 |
</available_state>

---

## EXECUTION SEQUENCE:

### Phase 1: PARTITION

#### 1.1 Initialize Save Output (if save_mode)

**If `{save_mode}` = true:**

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "03" "execute" "in_progress"
```

Append logs to `{output_dir}/03-execute.md` as you work.

#### 1.2 Extract Domain Groups

Read the plan from step-02 and extract the "Domain Partitioning" section:

```
For each domain in the plan:
  - Domain name (e.g., "backend", "frontend", "shared-types")
  - File list (files assigned to this domain)
  - Plan excerpt (the file-by-file changes for these files)
  - Dependencies (which domains must complete first)
```

#### 1.3 Validate Partitioning

```
VERIFY:
- [ ] No file appears in more than one domain
- [ ] All files from the plan are assigned to a domain
- [ ] Dependency order is clear (shared → dependent domains)

IF validation fails:
  → Log error and fall back to solo execution (load step-03-execute.md)
```

### Phase 2: SETUP TEAM

#### 2.1 Git Checkpoint

Create a lightweight checkpoint before making changes:

```bash
git add -A && git commit --allow-empty -m "apex: checkpoint before team-execute ({task_id})"
```

#### 2.2 Create Team

```
TeamCreate:
  team_name: "apex-{task_id}"
  description: "APEX parallel execution for {task_description}"
```

#### 2.3 Create Tasks

For each domain, create a task:

```
TaskCreate:
  subject: "Implement {domain_name} domain"
  description: |
    ## Domain: {domain_name}

    ## Files to modify:
    {file list}

    ## Plan:
    {plan excerpt for this domain's files}

    ## Patterns to follow:
    {relevant patterns from step-01}

    ## Rules:
    - Read each file BEFORE modifying it
    - Follow the plan EXACTLY - no scope creep
    - No modifications outside your assigned files
    - No comments unless truly necessary
    - Follow existing code patterns
  activeForm: "Implementing {domain_name}"
```

#### 2.4 Set Task Dependencies

If the plan specifies execution order (e.g., shared/types before frontend):

```
TaskUpdate:
  taskId: "{dependent_task_id}"
  addBlockedBy: ["{dependency_task_id}"]
```

### Phase 3: SPAWN TEAMMATES

#### 3.1 Spawn One Teammate Per Domain

For each domain, spawn a teammate:

```
Task:
  description: "Implement {domain_name} domain"
  subagent_type: "general-purpose"
  team_name: "apex-{task_id}"
  name: "{domain_name}-dev"
  mode: "plan"
  prompt: |
    You are a teammate in an APEX workflow team. Your job is to implement
    the {domain_name} domain.

    ## Your Task
    Check TaskList for your assigned task, claim it with TaskUpdate (set owner
    to your name), then implement the changes described in the task description.

    ## Critical Rules
    1. Read the task description carefully - it contains your file list and plan
    2. Read EVERY file before modifying it
    3. Follow the plan EXACTLY - no scope creep, no "improvements"
    4. Only modify files assigned to your domain
    5. After implementation, run typecheck/lint if available
    6. Mark your task as completed when done
    7. Send a message to the team lead summarizing what you did

    ## Plan Mode
    You are in plan mode. First, create a brief implementation plan showing
    the order you'll modify files and key changes. The team lead will approve
    your plan before you can proceed with implementation.
```

**Spawn dependency-free domains first.** If a domain has dependencies, wait for those to complete before spawning.

**Log each spawn (if save_mode):**
```markdown
### Teammate Spawned: {domain_name}-dev
- Domain: {domain_name}
- Files: {file list}
- Dependencies: {none or list}
**Timestamp:** {ISO}
```

### Phase 4: COORDINATE

#### 4.1 Lead Coordination Loop

The lead (you) enters coordination mode:

```
WHILE any tasks are not completed:
  1. Wait for teammate messages (they arrive automatically)

  2. Handle plan approval requests:
     - Review the teammate's proposed plan
     - Verify it matches the APEX plan for their domain
     - Verify no out-of-scope changes
     - Approve via SendMessage plan_approval_response (approve: true)
     - If issues found: reject with feedback (approve: false, content: "fix X")

  3. Handle teammate questions:
     - Answer questions about the plan or patterns
     - Keep responses focused - don't redesign

  4. Handle task completion messages:
     - Note which domain completed
     - Check if blocked domains can now be unblocked/spawned

  5. Check TaskList periodically for overall progress
```

#### 4.2 Handle Dependency Chains

```
WHEN a dependency domain completes:
  - Check if any blocked domains are now unblocked
  - Spawn teammates for newly unblocked domains
  - Update task dependencies via TaskUpdate
```

#### 4.3 Handle Failures

```
IF a teammate reports an error or gets stuck:
  1. Read their message carefully
  2. If it's a plan issue: provide guidance via SendMessage
  3. If it's a blocker: try to resolve it
  4. If unrecoverable:
     - Shutdown that teammate
     - Fall back to implementing that domain yourself
     - Log the fallback in 03-execute.md
```

### Phase 5: VERIFY & CLEANUP

#### 5.1 Verify All Tasks Complete

```
TaskList → Verify all domain tasks show status: "completed"
```

#### 5.2 Verify No File Conflicts

```bash
# Check for any merge conflicts or overlapping changes
git diff --name-only
```

Verify:
- [ ] No file was modified by multiple teammates
- [ ] All planned files were actually modified
- [ ] No unexpected files were changed

#### 5.3 Quick Validation

```bash
# Run typecheck and lint as quick sanity check
pnpm run typecheck 2>/dev/null || npx tsc --noEmit 2>/dev/null || echo "No typecheck available"
pnpm run lint --fix 2>/dev/null || echo "No lint available"
```

Fix any errors immediately (this is the lead's responsibility).

#### 5.4 Shutdown Teammates

For each teammate:

```
SendMessage:
  type: "shutdown_request"
  recipient: "{domain_name}-dev"
  content: "All tasks complete, shutting down the team. Great work!"
```

Wait for shutdown confirmations.

#### 5.5 Delete Team

```
TeamDelete
```

#### 5.6 Implementation Summary

```
**Team Implementation Complete**

**Team:** apex-{task_id}
**Domains:** {count} domains, {count} teammates

**Domain Results:**
- {domain_name}: {count} files modified by {teammate_name}
- {domain_name}: {count} files modified by {teammate_name}

**Total Files Modified:** {count}
**Total New Files:** {count}

**Todos:** All domain tasks completed
```

### 6. Complete Save Output (if save_mode)

**If `{save_mode}` = true:**

Append to `{output_dir}/03-execute.md`:
```markdown
---
## Step Complete
**Status:** ✓ Complete
**Mode:** Team execution (Agent Teams)
**Domains:** {count}
**Teammates:** {count}
**Files modified:** {total count}
**Next:** step-04-validate.md
**Timestamp:** {ISO timestamp}
```

---

## SUCCESS METRICS:

✅ All domain tasks completed by teammates
✅ No file conflicts between domains
✅ All planned files modified
✅ No scope creep from any teammate
✅ Typecheck and lint pass
✅ All teammates shutdown cleanly
✅ Team deleted
✅ Progress logged (if save_mode)

## FAILURE MODES:

❌ Implementing code directly instead of delegating
❌ Approving teammate plans that deviate from APEX plan
❌ Allowing file overlap between domains
❌ Not shutting down teammates after completion
❌ Not deleting the team
❌ Spawning all teammates at once when dependencies exist
❌ **CRITICAL**: Not approving teammate plans (they'll be stuck in plan mode)

## COORDINATION PROTOCOLS:

- Delegate, don't implement
- Approve plans carefully - they must match the APEX plan
- Spawn dependent domains only after dependencies complete
- Monitor progress via TaskList
- Handle failures gracefully with fallback to solo implementation
- Always cleanup: shutdown teammates + delete team

---

## NEXT STEP:

### Session Boundary

```
IF auto_mode = true:
  → Load ./step-04-validate.md directly (chain all steps)

IF auto_mode = false:
  → Mark step complete in progress table (if save_mode):
    bash {skill_dir}/scripts/update-progress.sh "{task_id}" "03" "execute" "complete"
  → Update State Snapshot in 00-context.md:
    1. Set next_step to 04-validate
    2. Append to Step Context: "- **03-execute:** {count} files modified across {count} domains"
  → Display:

    ═══════════════════════════════════════
      STEP 03 COMPLETE: Team Execute
    ═══════════════════════════════════════
      {count} files modified across {count} domains
      Resume: /apex -r {task_id}
      Next: Step 04 - Validate (Self-Check)
    ═══════════════════════════════════════

  → STOP. Do NOT load the next step.
```

<critical>
Remember: You are a COORDINATOR in this step. Your job is to:
1. Set up the team and tasks
2. Spawn teammates with clear instructions
3. Approve their plans
4. Monitor progress
5. Verify results
6. Clean up

You do NOT write implementation code. Teammates do the work.
</critical>
