---
name: step-06b-team-resolve
description: Agent Team parallel resolution - fix findings across multiple resolvers by file group
prev_step: ./step-05-examine.md OR ./step-05b-team-examine.md
next_step: conditional (07-tests | 09-finish | complete)
load_condition: team_mode = true
---

# Step 6b: Team Resolve (Parallel Finding Resolution)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER auto-fix Noise or Uncertain findings
- 🛑 NEVER skip validation after fixes
- 🛑 NEVER allow resolvers to modify files outside their assigned group
- 🛑 NEVER fix code yourself - delegate to resolvers
- ✅ ALWAYS use TeamCreate, TaskCreate, and Task tools
- ✅ ALWAYS launch all resolvers in parallel
- ✅ ALWAYS validate globally after all resolvers complete
- ✅ ALWAYS provide clear completion summary
- 📋 YOU ARE A RESOLUTION COORDINATOR, not a resolver
- 💬 FOCUS on "How do we fix these issues across parallel resolvers?"
- 🚫 FORBIDDEN to use Edit, Write tools directly (resolvers do the work)
- 🚫 FORBIDDEN to proceed with failing validation

## EXECUTION PROTOCOLS:

- 🎯 Partition findings by primary file before spawning
- 💾 Monitor task completion via TaskList
- 📖 Approve resolver plans before they modify code
- 🚫 FORBIDDEN to have resolvers working on overlapping files

## CONTEXT BOUNDARIES:

- Findings from step-05 are classified (Real, Noise, Uncertain)
- team_mode = true (validated in step-00)
- This step replaces step-06-resolve.md entirely
- Resolvers fix code — they are NOT read-only

## CONTEXT RESTORATION (resume mode):

<critical>
If this step was loaded via `/apex -r {task_id}` resume:

1. Read `{output_dir}/00-context.md` → restore flags, task info, acceptance criteria
2. Read `{output_dir}/05-examine.md` → restore findings table and todos
3. If 06-resolve progress is "⏳ In Progress" (resolution crashed mid-execution):
   → Team mode cannot resume mid-resolution (teammates don't survive sessions)
   → Fall back to solo: set {team_mode} = false, load step-06-resolve.md
4. If 06-resolve progress is "⏸ Pending" (arriving here for the first time):
   → Proceed normally with team resolution (teammates are fresh)
5. All state variables are now available from the restored context
</critical>

## YOUR TASK:

Orchestrate parallel finding resolution by spawning Agent Team resolvers, one per file group, to fix Real findings concurrently.

---

<available_state>
From previous steps:

| Variable | Description |
|----------|-------------|
| `{task_description}` | What was implemented |
| `{task_id}` | Kebab-case identifier |
| `{test_mode}` | Include test steps |
| `{pr_mode}` | Create pull request |
| `{output_dir}` | Path to output |
| Findings table | IDs, severity, validity |
| Finding todos | For tracking |
</available_state>

---

## EXECUTION SEQUENCE:

### Phase 1: PARTITION FINDINGS

#### 1.1 Initialize Save Output

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "06" "resolve" "in_progress"
```

Append logs to `{output_dir}/06-resolve.md` as you work.

#### 1.2 Collect Findings

Read findings from step-05 (examine output). Extract:
- Finding ID, severity, category, validity
- Primary file (the file that needs modification)
- Issue description and suggested approach

#### 1.3 Filter Findings

```
Remove findings where validity = "Noise"
Remove findings where validity = "Uncertain" (unless user explicitly chose to fix them)
Keep only findings that will actually be fixed (based on Phase 2 strategy)
```

**If 0 Real findings remain:**
→ Skip resolution entirely, go to NEXT STEP section

#### 1.4 Group by Primary File

```
For each finding:
  → Assign to group based on its primary file (e.g., all findings in auth.ts → group "auth")

Merge small groups:
  → If a group has only 1 finding AND another group touches a closely related file → merge
  → Target: 2-4 resolver groups maximum

IF only 1 group remains:
  → Fall back to solo: set {team_mode} = false, load step-06-resolve.md
  → (No benefit to parallelizing a single group)
```

### Phase 2: RESOLUTION STRATEGY

**Auto-fix Real findings, skip Noise/Uncertain.**

Log decision:
```
ℹ️ Auto-resolution: fixing {N} Real findings, skipping {M} Noise/Uncertain
```

After filtering:
- Re-filter findings to keep only Real (and optionally CRITICAL/HIGH Uncertain)
- Remove groups that have no remaining findings
- If 0 groups remain → skip resolution, go to NEXT STEP
- If 1 group remains → fall back to solo (load step-06-resolve.md)

### Phase 3: SETUP TEAM

#### 3.1 Create Team

```
TeamCreate:
  team_name: "apex-resolve-{task_id}"
  description: "APEX parallel finding resolution for {task_description}"
```

#### 3.2 Create Tasks

For each file group, create a task:

```
TaskCreate:
  subject: "Resolve findings in {group_name} ({count} findings)"
  description: |
    ## Group: {group_name}

    ## Files you may modify:
    {list of files in this group}

    ## Findings to fix:
    | ID | Severity | Location | Issue | Suggested Fix |
    |----|----------|----------|-------|---------------|
    | F1 | CRITICAL | auth.ts:42 | SQL injection | Use parameterized query |
    | F3 | HIGH | auth.ts:78 | Missing null check | Add guard clause |

    ## Strategy: {auto-fix Real / fix only critical}

    ## Rules:
    - Read each file BEFORE modifying it
    - Fix ONLY the listed findings - no scope creep
    - Do NOT modify files outside your assigned list
    - Verify each fix doesn't break surrounding code
    - Follow existing code patterns
  activeForm: "Resolving {group_name} findings"
```

**No task dependencies needed** — groups are independent by design (no file overlap).

### Phase 4: SPAWN RESOLVERS

Launch ALL resolvers in a SINGLE message block (parallel spawn):

For each group:

```
Task:
  description: "Resolve {group_name} findings"
  subagent_type: "general-purpose"
  team_name: "apex-resolve-{task_id}"
  name: "resolver-{group_name}"
  mode: "plan"
  prompt: |
    You are a resolver in an APEX workflow team. Your job is to fix
    identified code issues in your assigned file group.

    ## Your Task
    Check TaskList for your assigned resolution task, claim it with TaskUpdate
    (set owner to "resolver-{group_name}"), then fix the findings described.

    ## Critical Rules
    1. Read the task description CAREFULLY - it contains your findings and files
    2. Read EVERY file before modifying it
    3. Fix ONLY the listed findings - no scope creep, no "improvements"
    4. Only modify files assigned to your group
    5. After fixes, run typecheck/lint if available
    6. Mark your task as completed when done
    7. Send a message to the team lead summarizing what you fixed

    ## Plan Mode
    You are in plan mode. First, create a brief fix plan showing
    the order you'll fix findings and key changes. The team lead will approve
    your plan before you can proceed with fixes.
```

**Log each spawn (if save_mode):**
```markdown
### Resolver Spawned: resolver-{group_name}
- Group: {group_name}
- Files: {file list}
- Findings: {count}
**Timestamp:** {ISO}
```

### Phase 5: COORDINATE

#### 5.1 Lead Coordination Loop

```
WHILE any tasks are not completed:
  1. Wait for resolver messages (they arrive automatically)

  2. Handle plan approval requests:
     - Review the resolver's proposed fix plan
     - Verify fixes match the assigned findings
     - Verify no out-of-scope changes
     - Approve via SendMessage plan_approval_response (approve: true)
     - If issues found: reject with feedback (approve: false, content: "fix X")

  3. Handle resolver questions:
     - Answer questions about the findings or context
     - Keep responses focused - don't redesign

  4. Handle task completion messages:
     - Note which group completed
     - Track fixes applied vs skipped

  5. Check TaskList periodically for overall progress
```

#### 5.2 Handle Failures

```
IF a resolver reports an error or gets stuck:
  1. Read their message carefully
  2. If it's a plan issue: provide guidance via SendMessage
  3. If it's a blocker: try to resolve it
  4. If unrecoverable:
     - Shutdown that resolver
     - Fall back to fixing that group yourself (lead fallback)
     - Log the fallback in 06-resolve.md
```

### Phase 6: VALIDATE & CLEANUP

#### 6.1 Global Validation

After ALL resolvers complete, run global validation:

```bash
pnpm run typecheck && pnpm run lint
```

Both MUST pass.

#### 6.2 Handle Validation Failures

```
IF validation fails:
  1. Parse the error output to identify which file(s) caused the failure
  2. Map failing file(s) back to the responsible resolver
  3. Send the error to that resolver:

  SendMessage:
    type: "message"
    recipient: "resolver-{group_name}"
    content: |
      Validation failed with errors in your files:
      {error output}

      Please fix these issues.
    summary: "Validation errors in your files"

  4. Wait for the resolver to fix and report back
  5. Re-run validation
  6. If still failing after 2 attempts: fix it yourself (lead fallback)
```

#### 6.3 Shutdown Resolvers

For each resolver:

```
SendMessage:
  type: "shutdown_request"
  recipient: "resolver-{group_name}"
  content: "Resolution complete, shutting down. Thanks for the fixes!"
```

Wait for shutdown confirmations.

#### 6.4 Delete Team

```
TeamDelete
```

#### 6.5 Resolution Summary

```
**Team Resolution Complete**

**Team:** apex-resolve-{task_id}
**Resolvers:** {count} resolvers ({list of group names})

**Resolution Results:**
- resolver-{group_name}: {count} fixed, {count} skipped
- resolver-{group_name}: {count} fixed, {count} skipped

**Fixed:** {total_count}
- F1: Parameterized SQL query in auth.ts:42
- F2: Added null check in handler.ts:78

**Skipped:** {total_count}
- F3: Complex function (uncertain)

**Validation:** ✓ Passed
```

### 7. Complete Save Output

Append to `{output_dir}/06-resolve.md`:
```markdown
---
## Step Complete
**Status:** ✓ Complete
**Mode:** Team resolution (Agent Teams)
**Resolvers:** {count}
**Findings fixed:** {count}
**Findings skipped:** {count}
**Validation:** ✓ Passed
**Timestamp:** {ISO timestamp}
```

---

## SUCCESS METRICS:

✅ Findings partitioned by file with no overlap
✅ Resolution strategy applied (auto-fix Real)
✅ All resolver tasks completed
✅ No file conflicts between resolvers
✅ All chosen fixes applied correctly
✅ Global validation passes after all fixes
✅ All resolvers shutdown cleanly
✅ Team deleted
✅ Clear summary of resolved/skipped
✅ Progress logged

## FAILURE MODES:

❌ Fixing code directly instead of delegating to resolvers
❌ Allowing file overlap between resolver groups
❌ Approving resolver plans that deviate from assigned findings
❌ Not validating globally after all fixes (only per-resolver validation misses cross-file issues)
❌ Not shutting down resolvers after completion
❌ Not deleting the team
❌ Launching resolvers sequentially instead of in parallel
❌ Auto-fixing Noise or Uncertain findings
❌ Offering "Walk through each" option (incompatible with parallel resolution)
❌ **CRITICAL**: Not approving resolver plans (they'll be stuck in plan mode)

## COORDINATION PROTOCOLS:

- Delegate, don't fix
- Partition by file to guarantee no conflicts
- Approve plans carefully - they must match assigned findings only
- All resolvers launch in parallel (no dependencies between groups)
- Global validation catches cross-file issues that per-resolver checks miss
- Handle failures gracefully with fallback to lead fixing
- Always cleanup: shutdown resolvers + delete team

---

## NEXT STEP:

**Determine next step based on flags (check in order):**
- **If test_mode AND tests not yet completed:** next = `07-tests`
  - _Check: If save_mode, read progress table in 00-context.md. If `08-run-tests` shows `✓ Complete`, tests are already done → skip to next rule._
- **If pr_mode:** next = `09-finish`
- **Otherwise:** next_step = complete

### Session Boundary

Determine {next_step_num} and {next_step_description} from the decision tree above.

IF workflow complete (next_step = "complete"):
  Run session boundary:
  ```bash
  bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "06" "resolve" \
    "All findings resolved (team). Workflow complete." "complete" "Workflow Complete" \
    "**06-resolve (team):** {fixed} fixed, {skipped} skipped across {resolver_count} resolvers" "" "{branch_mode}" "commit"
  ```

IF workflow not complete:
  Run session boundary:
  ```bash
  bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "06" "resolve" \
    "Fixed: {count} | Skipped: {count} (team: {resolver_count} resolvers)" "{next_step_num}" "{next_step_description}" \
    "**06-resolve (team):** {fixed} fixed, {skipped} skipped across {resolver_count} resolvers" "{gotcha_or_empty}" "{branch_mode}" "commit"
  ```

→ STOP — session ends here. User must run `/apex -r {task_id}` to continue.

<critical>
Remember: You are a COORDINATOR in this step. Your job is to:
1. Partition findings into non-overlapping file groups
2. Apply auto-resolution strategy (fix Real, skip Noise/Uncertain)
3. Set up the team and tasks
4. Spawn resolvers with clear instructions
5. Approve their fix plans
6. Monitor progress
7. Validate globally
8. Clean up

You do NOT fix code yourself. Resolvers do the work.
Always validate GLOBALLY after all resolvers complete — per-resolver validation misses cross-file issues.
</critical>
