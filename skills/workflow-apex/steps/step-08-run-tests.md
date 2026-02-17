---
name: step-08-run-tests
description: Run tests in a loop - fix issues until all pass
prev_step: ./step-07-tests.md
next_step: conditional (05-examine | 09-finish | complete)
---

# Step 8: Run Tests (Fix Loop)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER give up after first failure
- 🛑 NEVER start services without permission (unless auto_mode)
- 🛑 NEVER infinite loop on same failure (max 3 attempts)
- ✅ ALWAYS loop until all tests pass
- ✅ ALWAYS ask user when stuck (unless auto_mode)
- ✅ ALWAYS clean up background processes
- 📋 YOU ARE A TEST RUNNER, fixing until green
- 💬 FOCUS on "Run → Fail → Fix → Repeat until green"
- 🚫 FORBIDDEN to ignore configuration errors

## EXECUTION PROTOCOLS:

- 🎯 Check requirements before running
- 💾 Log each test run (if save_mode)
- 📖 Analyze failures before fixing
- 🚫 FORBIDDEN to proceed with failing tests (without explicit skip)

## CONTEXT BOUNDARIES:

- Tests were created in step-07
- Tests may require services (DB, server)
- Failures may be code bugs or test bugs
- Loop until all green or user decides to skip

## CONTEXT RESTORATION (resume mode):

<critical>
If this step was loaded via `/apex -r {task_id}` resume:

1. Read `{output_dir}/00-context.md` → restore flags, task info, acceptance criteria
2. Read `{output_dir}/07-tests.md` → restore test file list and test plan
3. All state variables are now available from the restored context
4. Proceed with normal execution below
</critical>

## YOUR TASK:

Run tests, fix any failures, and loop until ALL tests pass.

---

<available_state>
From previous steps:

| Variable | Description |
|----------|-------------|
| `{task_description}` | What was implemented |
| `{task_id}` | Kebab-case identifier |
| `{auto_mode}` | Auto-start servers, auto-retry |
| `{examine_mode}` | Auto-proceed to review after |
| `{save_mode}` | Save outputs to files |
| `{pr_mode}` | Create pull request |
| `{output_dir}` | Path to output (if save_mode) |
| Tests created | From step-07 |
| Test command | Discovered in step-07 |
</available_state>

---

## EXECUTION SEQUENCE:

### 1. Initialize Save Output (if save_mode)

**If `{save_mode}` = true:**

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "08" "run-tests" "in_progress"
```

Append logs to `{output_dir}/08-run-tests.md` as you work.

### 2. Check Requirements

**Identify required services:**
```bash
cat package.json | grep -A 10 '"scripts"'
```

Common: Database, dev server, Redis

**Check if running:**
```bash
curl -s http://localhost:3000 > /dev/null 2>&1 && echo "Server running"
```

### 3. Handle Missing Services

**If `{auto_mode}` = true:**
→ Start services automatically with PID tracking:
```bash
pnpm run dev &
DEV_SERVER_PID=$!
sleep 5
echo "Dev server started (PID: $DEV_SERVER_PID)"
```

**If `{auto_mode}` = false:**

```yaml
questions:
  - header: "Services"
    question: "Tests require services that aren't running. How proceed?"
    options:
      - label: "I'll start manually"
        description: "Give me a moment to start them"
      - label: "Start automatically"
        description: "Try to start services automatically"
      - label: "Skip tests needing services"
        description: "Only run tests that don't need services"
      - label: "Skip test step"
        description: "Continue without running tests"
    multiSelect: false
```

### 4. Run Test Loop

**CRITICAL: Loop until all pass**

```
max_attempts = 10
attempt = 0

WHILE attempt < max_attempts:
    attempt += 1

    1. Run tests
    2. If all pass → EXIT (success)
    3. If failure:
       a. Analyze failure
       b. Determine: code bug or test bug?
       c. Fix the issue
       d. CONTINUE LOOP
    4. If same failure 3x → ASK USER
```

**Run tests:**
```bash
pnpm run test 2>&1
```

**Log each run:**
```
**Run #{attempt}:**
- Total: 5, Passed: 3, Failed: 2
- Fixing: {description}
```

### 5. Handle Failures

For each failing test:

```
**Analyzing:**
Test: "creates user with valid data"
File: src/auth/register.test.ts:25
Error: Expected 201, got 500
Stack: TypeError: Cannot read 'email' of undefined

**Diagnosis:** Code bug - null handling
**Fix:** Add null check in handler
```

**Fix location:**
| Error Type | Fix |
|------------|-----|
| Assertion failed | Usually code bug |
| TypeError in code | Code bug |
| TypeError in test | Test bug |
| Timeout | async/await issue |
| Import error | Missing dep |

### 6. Handle Stuck (3x same failure)

**If `{auto_mode}` = true:**
→ Try different approach once, then continue

**If `{auto_mode}` = false:**

```yaml
questions:
  - header: "Stuck"
    question: "Test keeps failing. How proceed?"
    options:
      - label: "I'll debug manually"
        description: "Let me investigate"
      - label: "Skip this test"
        description: "Mark as skip, continue others"
      - label: "Delete test"
        description: "Remove this test entirely"
      - label: "Keep trying"
        description: "Try more approaches"
    multiSelect: false
```

### 7. Handle Config Errors

| Error | Solution |
|-------|----------|
| Cannot find module | Check imports, pnpm install |
| Connection refused | DB/server not running |
| Timeout | Increase timeout, check async |

**If `{auto_mode}` = false:**

```yaml
questions:
  - header: "Config"
    question: "Configuration issue detected. How proceed?"
    options:
      - label: "I'll fix manually"
        description: "Let me handle config"
      - label: "Try automatic fix"
        description: "Attempt suggested fix"
      - label: "Skip tests"
        description: "Continue without tests"
    multiSelect: false
```

### 8. Success - All Passing

```
**✓ All Tests Passing**

**Results:**
- Total: {count}
- Passed: {count}
- Failed: 0

**Attempts:** {count}

**Tests:**
- src/auth/register.test.ts - 3 tests
- src/utils/validation.test.ts - 2 tests
```

### 9. Cleanup Background Services

**If any background services were started:**

```bash
# Kill dev server if we started it
if [[ -n "$DEV_SERVER_PID" ]]; then
  kill $DEV_SERVER_PID 2>/dev/null
  echo "Dev server stopped (PID: $DEV_SERVER_PID)"
fi
```

<critical>
ALWAYS clean up background processes, even if tests fail or the step is interrupted.
</critical>

### 10. Complete Save Output (if save_mode)

**If `{save_mode}` = true:**

Append to `{output_dir}/08-run-tests.md`:
```markdown
---
## Step Complete
**Status:** ✓ Complete
**Tests passed:** {count}
**Attempts:** {count}
**Next:** {next step}
**Timestamp:** {ISO timestamp}
```

### 11. Determine Next Step

**If `{examine_mode}` = true AND examine not yet completed:**
→ next_step = 05-examine
  - _Check: If save_mode, read progress table in 00-context.md:_
    - _If `06-resolve` shows `✓ Complete` OR `⏭ Skip`, examine is already done → skip to next rule._
    - _If `05-examine` shows `✓ Complete` but `06-resolve` is NOT `✓ Complete` and NOT `⏭ Skip`, route to `06-resolve` instead (don't re-run examine)._
  - _If auto_mode chain (no save), examine is done if step-06 already ran in this session → skip to next rule._

**Else if `{pr_mode}` = true:**
→ next_step = 09-finish

**Else if `{auto_mode}` = false:**

```yaml
questions:
  - header: "Next"
    question: "All tests passing. What should the next step be?"
    options:
      - label: "Adversarial review"
        description: "Queue deep review for next session"
      - label: "Complete workflow"
        description: "No more steps needed"
      - label: "Create PR"
        description: "Queue pull request creation for next session"
    multiSelect: false
```

**Map user choice to next_step:**
```
"Adversarial review" → next_step = 05-examine
"Create PR"          → next_step = 09-finish
"Complete workflow"   → next_step = complete
```

**Flag Sync (if save_mode):** After mapping the user's choice, ensure the corresponding flag, output files, and progress table are consistent:

```
IF user chose "Adversarial review" AND {examine_mode} = false:
  → Set {examine_mode} = true
  → Update 00-context.md: change examine_mode row to "true"
  → Create output files from templates:
    (copy from {skill_dir}/templates/05-examine.md and 06-resolve.md to {output_dir}/)
  → Update progress table in 00-context.md: change 05-examine and 06-resolve from "⏭ Skip" to "⏸ Pending"

IF user chose "Create PR" AND {pr_mode} = false:
  → Set {pr_mode} = true
  → Update 00-context.md: change pr_mode row to "true"
  → Create output file from template:
    (copy from {skill_dir}/templates/09-finish.md to {output_dir}/)
  → Update progress table in 00-context.md: change 09-finish from "⏭ Skip" to "⏸ Pending"
```

<critical>
The user's choice determines which step is saved as next_step in the State Snapshot.
It does NOT mean "load that step now". The session boundary below controls when to stop.
</critical>

**Else (no examine, no pr):**
→ next_step = complete

---

## SUCCESS METRICS:

✅ All tests passing
✅ No stuck failures without user decision
✅ Config issues resolved
✅ Services cleaned up
✅ Clear summary

## FAILURE MODES:

❌ Giving up after first failure
❌ Infinite loop on same failure
❌ Starting services without permission
❌ Not cleaning up background processes
❌ Ignoring config errors
❌ **CRITICAL**: Not using AskUserQuestion when stuck

## RUN PROTOCOLS:

- Loop until green
- Analyze before fixing
- Ask user when stuck (3x)
- Clean up services
- Clear summary at end

---

## NEXT STEP:

**Determine next step based on flags (check in order):**
- **If examine_mode AND examine not yet completed:** next = `05-examine`
  - _Check: If save_mode, read progress table:_
    - _If `06-resolve` shows `✓ Complete` OR `⏭ Skip`, examine already done → skip._
    - _If `05-examine` shows `✓ Complete` but `06-resolve` NOT `✓ Complete` and NOT `⏭ Skip` → route to `06-resolve` instead._
- **If pr_mode:** next = `09-finish`
- **Otherwise:** next_step = complete

### Session Boundary

<critical>
THIS SECTION IS MANDATORY. Even if the user chose a next step above, you MUST follow this session boundary logic.
The user's choice determines what is saved as next_step, NOT whether to load it now.
</critical>

```
IF auto_mode = true:
  → If {branch_mode} = true, commit step changes:
    ```bash
    git add -u && git diff --cached --quiet || git commit -m "apex({task_id}): step 08 - run-tests"
    ```
  → If save_mode = true, update progress and state:
    ```bash
    bash {skill_dir}/scripts/update-progress.sh "{task_id}" "08" "run-tests" "complete"
    bash {skill_dir}/scripts/update-state-snapshot.sh "{task_id}" "{next_step}" "**08-run-tests:** All tests passing ({count} tests)" ["{gotcha if any}"]
    ```
  → If next_step = "complete": Display workflow complete message → STOP.
  → Otherwise: Load the determined next step directly (chain all steps)

IF auto_mode = false AND workflow not complete:
  → Determine {next_step_num} and {next_step_description} from the decision tree above
  → Run (if save_mode):
    ```bash
    bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "08" "run-tests" "{count} tests passing in {attempts} attempts" "{next_step_num}" "{next_step_description}" "**08-run-tests:** All tests passing ({count} tests)" "{gotcha_or_empty}" "{branch_mode}" "commit"
    ```
    (Pass empty string "" for gotcha if none, to preserve positional args for branch_mode and commit flag)
  → Display the output to the user
  → STOP. Do NOT load the next step.
  → The session ENDS here. User must run /apex -r {task_id} to continue.

IF auto_mode = false AND workflow complete:
  → Run (if save_mode):
    ```bash
    bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "08" "run-tests" "All {count} tests passing. Workflow complete." "complete" "Workflow Complete" "**08-run-tests:** All tests passing ({count} tests)" "" "{branch_mode}" "commit"
    ```
  → Display the output to the user
  → STOP.
```

<critical>
Remember: Loop until ALL tests pass - don't give up after first failure!
In auto_mode=true, proceed directly without stopping.
In auto_mode=false, ALWAYS STOP after displaying the resume command — even if the user chose a next step.
</critical>
