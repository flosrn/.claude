---
name: step-08-run-tests
description: Run tests in a loop - fix issues until all pass
prev_step: ./step-07-tests.md
next_step: conditional (05-examine | 09-finish | complete)
---

# Step 8: Run Tests (Fix Loop)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER give up after first failure
- 🛑 NEVER start services without permission
- 🛑 NEVER infinite loop on same failure (max 3 attempts)
- ✅ ALWAYS loop until all tests pass
- ✅ ALWAYS auto-skip after 3 failures
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
| `{examine_mode}` | Auto-proceed to review after |
| `{pr_mode}` | Create pull request |
| `{output_dir}` | Path to output |
| Tests created | From step-07 |
| Test command | Discovered in step-07 |
</available_state>

---

## EXECUTION SEQUENCE:

### 1. Initialize Save Output

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

If services are missing, attempt automatic start with PID tracking:
```bash
pnpm run dev &
DEV_SERVER_PID=$!
sleep 5
echo "Dev server started (PID: $DEV_SERVER_PID)"
```

Log decision:
```
ℹ️ Auto-started services: {service_names}
```

If auto-start fails, skip tests that require services and log:
```
⚠️ Could not start required services. Running tests that don't need services.
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

After 3 failures on the same test, skip the test and continue:

Log decision:
```
⚠️ Auto-skipped test after 3 failures: {test_name} — {error_summary}
```

### 7. Handle Config Errors

| Error | Solution |
|-------|----------|
| Cannot find module | Check imports, pnpm install |
| Connection refused | DB/server not running |
| Timeout | Increase timeout, check async |

Attempt automatic fix. Log decision:
```
ℹ️ Auto-fixed config: {description}
```

If auto-fix fails:
```
⚠️ Could not auto-fix config issue: {description}. Skipping affected tests.
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

### 10. Complete Save Output

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

IF {examine_mode} = true AND examine not yet completed:
    → next_step = 05-examine

ELSE IF {pr_mode} = true:
    → next_step = 09-finish

ELSE:
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
❌ Not cleaning up background processes
❌ Ignoring config errors

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

Determine {next_step_num} and {next_step_description} from the decision tree above.

IF workflow complete (next_step = "complete"):
  Run session boundary:
  ```bash
  bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "08" "run-tests" \
    "All {count} tests passing. Workflow complete." "complete" "Workflow Complete" \
    "**08-run-tests:** All tests passing ({count} tests)" "" "{branch_mode}" "commit"
  ```

IF workflow not complete:
  Run session boundary:
  ```bash
  bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "08" "run-tests" \
    "{count} tests passing in {attempts} attempts" "{next_step_num}" "{next_step_description}" \
    "**08-run-tests:** All tests passing ({count} tests)" "{gotcha_or_empty}" "{branch_mode}" "commit"
  ```

→ STOP — session ends here. User must run `/apex -r {task_id}` to continue.

<critical>
Remember: Loop until ALL tests pass - don't give up after first failure!
ALWAYS STOP after displaying the resume command.
</critical>
