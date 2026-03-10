---
name: step-04-validate
description: Self-check - run tests, verify AC, audit implementation quality
prev_step: ./step-03-execute.md
next_step: conditional (07-tests | 05-examine | 09-finish | complete)
---

# Step 4: Validate (Self-Check)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER claim checks pass when they don't
- 🛑 NEVER skip any validation step
- ✅ ALWAYS run lint and tests (typecheck skipped in economy mode)
- ✅ ALWAYS verify each acceptance criterion
- ✅ ALWAYS fix failures before proceeding
- 📋 YOU ARE A VALIDATOR, not an implementer
- 💬 FOCUS on "Does it work correctly?"
- 🚫 FORBIDDEN to proceed with failing checks

## EXECUTION PROTOCOLS:

- 🎯 Run all validation commands
- 💾 Log results to output
- 📖 Check each AC against implementation
- 🚫 FORBIDDEN to mark complete with failures

## CONTEXT BOUNDARIES:

- Implementation from step-03 is complete
- Tests may or may not pass yet
- Type errors may exist
- Focus is on verification, not new implementation

## CONTEXT RESTORATION (resume mode):

<critical>
If this step was loaded via `/apex -r {task_id}` resume:

1. Read `{output_dir}/00-context.md` → restore flags, task info, acceptance criteria
2. Read `{output_dir}/03-execute.md` → restore execution log (files modified, todos)
3. All state variables are now available from the restored context
4. Proceed with normal execution below
</critical>

## YOUR TASK:

Validate the implementation by running checks, verifying acceptance criteria, and ensuring quality.

---

<available_state>
From previous steps:

| Variable | Description |
|----------|-------------|
| `{task_description}` | What was implemented |
| `{task_id}` | Kebab-case identifier |
| `{acceptance_criteria}` | Success criteria |
| `{test_mode}` | Include test steps |
| `{examine_mode}` | Auto-proceed to review |
| `{pr_mode}` | Create pull request |
| `{output_dir}` | Path to output |
| Implementation | Completed in step-03 |
</available_state>

---

## EXECUTION SEQUENCE:

### 1. Initialize Save Output

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "04" "validate" "in_progress"
```

**Immediately overwrite the template with a live results skeleton** (replace placeholder content):

Write to `{output_dir}/04-validate.md`:
```markdown
# Step 04: Validate

**Task:** {task_description}
**Started:** {ISO timestamp}

---

## Validation Suite

| Check | Status | Notes |
|-------|--------|-------|
| Typecheck | ⏳ Running... | |
| Lint | ⏳ Running... | |
| Tests | ⏳ Running... | |

## Acceptance Criteria

{acceptance_criteria from 00-context.md — list each AC as unchecked}
- [ ] AC1: ...

## Files Modified (vs main)

{list from 03-execute.md}
```

Update this file in-place as each check completes (replace ⏳ with ✓/❌).

### 2. Discover Available Commands

Check `package.json` for exact command names:
```bash
cat package.json | grep -A 20 '"scripts"'
```

Look for: `typecheck`, `lint`, `test`, `build`, `format`

### 3. Run Validation Suite

**3.1 Typecheck**

**IF `{economy_mode}` = true:**
```
⚡ ECONOMY MODE — Typecheck skipped (full tsc --noEmit is RAM-intensive, ~1.5GB on monorepos).
   Log in 04-validate.md: "Typecheck: ⏭ Skipped (economy mode)"
```

**IF `{economy_mode}` = false:**
```bash
pnpm run typecheck  # or npm run typecheck
```
**MUST PASS.** If fails:
1. Read error messages
2. Fix type issues
3. Re-run until passing

**3.2 Lint**
```bash
pnpm run lint
```

**MUST PASS.** If fails:
1. Try auto-fix: `pnpm run lint --fix`
2. Manually fix remaining
3. Re-run until passing

**3.3 Tests**
```bash
pnpm run test -- --filter={affected-area}
```

**MUST PASS.** If fails:
1. Identify failing test
2. Determine if code bug or test bug
3. Fix the root cause
4. Re-run until passing

Log each result.

### 4. Self-Audit Checklist

Verify each item:

**Tasks Complete:**
- [ ] All todos from step-03 marked complete
- [ ] No tasks skipped without reason
- [ ] Any blocked tasks have explanation

**Tests Passing:**
- [ ] All existing tests pass
- [ ] New tests written for new functionality
- [ ] No skipped tests without reason

**Acceptance Criteria:**
- [ ] Each AC demonstrably met
- [ ] Can explain how implementation satisfies AC
- [ ] Edge cases considered

**Patterns Followed:**
- [ ] Code follows existing patterns
- [ ] Error handling consistent
- [ ] Naming conventions match

### 5. Format Code

If format command available:
```bash
pnpm run format
```

### 6. Final Verification

**IF `{economy_mode}` = true:**
```bash
# Economy mode: lint only
pnpm run lint
```

**IF `{economy_mode}` = false:**
```bash
pnpm run typecheck && pnpm run lint
```

MUST pass.

### 7. Present Validation Results

```
**Validation Complete**

**Typecheck:** ✓ Passed
**Lint:** ✓ Passed
**Tests:** ✓ {X}/{X} passing
**Format:** ✓ Applied

**Acceptance Criteria:**
- [✓] AC1: Verified by [how]
- [✓] AC2: Verified by [how]

**Files Modified:** {list}

**Summary:** All checks passing, ready for next step.
```

### 8. Determine Next Step

**Decision tree (determines next_step for State Snapshot, NOT immediate loading):**

```
IF {test_mode} = true:
    → next_step = 07-tests

ELSE IF {examine_mode} = true:
    → next_step = 05-examine

ELSE IF {pr_mode} = true:
    → next_step = 09-finish

ELSE:
    → next_step = complete
```

### 9. Complete Save Output

**MANDATORY before calling session-boundary.sh** — write the final state to `{output_dir}/04-validate.md`.

The file must contain real results (not the ⏳ placeholders). Update it now with:
- Final status for each check (✓ Pass / ❌ Fail + details)
- Each AC ticked `[x]` or `[ ]` with a one-line explanation of how it was verified
- Full list of modified files

Then append the step complete footer:
```markdown
---
## Step Complete
**Status:** ✓ Complete
**Typecheck:** ✓
**Lint:** ✓
**Tests:** ✓
**Next:** {next step based on flags}
**Timestamp:** {ISO timestamp}
```

⚠️ Do NOT call session-boundary.sh with ⏳ placeholders still in the file.

---

## SUCCESS METRICS:

✅ Typecheck passes
✅ Lint passes
✅ All tests pass
✅ All AC verified
✅ Code formatted
✅ User informed of status

## FAILURE MODES:

❌ Claiming checks pass when they don't
❌ Not running all validation commands
❌ Skipping tests for modified code
❌ Missing AC verification
❌ Proceeding with failures

## VALIDATION PROTOCOLS:

- Run EVERY validation command
- Fix failures IMMEDIATELY
- Don't proceed until all green
- Verify EACH acceptance criterion
- Document all results

---

## NEXT STEP:

**Determine next step based on flags (check in order):**
- **If test_mode:** next = `07-tests`
- **If examine_mode OR user requests examine:** next = `05-examine`
- **If pr_mode:** next = `09-finish`
- **Otherwise:** next_step = complete

### Session Boundary

Determine {next_step_num} and {next_step_description} from the decision tree above.

IF workflow complete (next_step = "complete"):
  Run session boundary:
  ```bash
  bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "04" "validate" \
    "All checks passing, AC verified. Workflow complete." "complete" "Workflow Complete" \
    "**04-validate:** All checks passing, AC verified" "" "{branch_mode}" "commit"
  ```

IF workflow not complete:
  Run session boundary:
  ```bash
  bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "04" "validate" \
    "Typecheck: pass | Lint: pass | Tests: pass" "{next_step_num}" "{next_step_description}" \
    "**04-validate:** All checks passing, AC verified" "{gotcha_or_empty}" "{branch_mode}" "commit"
  ```

→ STOP — session ends here. User must run `/apex -r {task_id}` to continue.

<critical>
Remember: NEVER proceed with failing checks - fix everything first!
ALWAYS STOP after displaying the resume command.
</critical>
