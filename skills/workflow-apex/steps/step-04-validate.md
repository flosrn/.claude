---
name: step-04-validate
description: Self-check - run tests, verify AC, audit implementation quality
prev_step: steps/step-03-execute.md
next_step: steps/step-05-examine.md
---

# Step 4: Validate (Self-Check)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER claim checks pass when they don't
- 🛑 NEVER skip any validation step
- ✅ ALWAYS run typecheck, lint, and tests
- ✅ ALWAYS verify each acceptance criterion
- ✅ ALWAYS fix failures before proceeding
- 📋 YOU ARE A VALIDATOR, not an implementer
- 💬 FOCUS on "Does it work correctly?"
- 🚫 FORBIDDEN to proceed with failing checks

## EXECUTION PROTOCOLS:

- 🎯 Run all validation commands
- 💾 Log results to output (if save_mode)
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
| `{auto_mode}` | Skip confirmations |
| `{save_mode}` | Save outputs to files |
| `{test_mode}` | Include test steps |
| `{examine_mode}` | Auto-proceed to review |
| `{output_dir}` | Path to output (if save_mode) |
| Implementation | Completed in step-03 |
</available_state>

---

## EXECUTION SEQUENCE:

### 1. Initialize Save Output (if save_mode)

**If `{save_mode}` = true:**

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "04" "validate" "in_progress"
```

Append results to `{output_dir}/04-validate.md` as you work.

### 2. Discover Available Commands

Check `package.json` for exact command names:
```bash
cat package.json | grep -A 20 '"scripts"'
```

Look for: `typecheck`, `lint`, `test`, `build`, `format`

### 3. Run Validation Suite

**3.1 Typecheck**
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

**If `{save_mode}` = true:** Log each result

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

Re-run all checks:
```bash
pnpm run typecheck && pnpm run lint
```

Both MUST pass.

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

**Decision tree:**

```
IF {test_mode} = true:
    → Load step-07-tests.md (test analysis and creation)

ELSE IF {examine_mode} = true:
    → Load step-05-examine.md (adversarial review)

ELSE IF {auto_mode} = false:
    → Ask user:
```

```yaml
questions:
  - header: "Next"
    question: "Validation complete. What would you like to do?"
    options:
      - label: "Run adversarial review"
        description: "Deep review for security, logic, and quality"
      - label: "Complete workflow"
        description: "Skip review and finalize"
      - label: "Add tests"
        description: "Create additional tests first"
    multiSelect: false
```

```
ELSE:
    → Complete workflow (show final summary)
```

### 9. Complete Save Output (if save_mode)

**If `{save_mode}` = true:**

Append to `{output_dir}/04-validate.md`:
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
❌ **CRITICAL**: Not using AskUserQuestion for next step

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
- **Otherwise:** Workflow complete

### Session Boundary

```
IF auto_mode = true:
  → Load the determined next step directly (chain all steps)

IF auto_mode = false AND workflow not complete:
  → Mark step complete in progress table (if save_mode):
    bash {skill_dir}/scripts/update-progress.sh "{task_id}" "04" "validate" "complete"
  → Update State Snapshot in 00-context.md:
    1. Set next_step to the determined next step
    2. Append to Step Context: "- **04-validate:** All checks passing, AC verified"
  → Display:

    ═══════════════════════════════════════
      STEP 04 COMPLETE: Validate
    ═══════════════════════════════════════
      Typecheck: ✓ | Lint: ✓ | Tests: ✓
      Resume: /apex -r {task_id}
      Next: Step {NN} - {description}
    ═══════════════════════════════════════

  → STOP. Do NOT load the next step.

IF workflow complete (no more steps):
  → Show final APEX WORKFLOW COMPLETE summary
  → STOP.
```

<critical>
Remember: NEVER proceed with failing checks - fix everything first!
In auto_mode, proceed directly without stopping.
</critical>
