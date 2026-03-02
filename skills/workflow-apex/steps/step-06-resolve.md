---
name: step-06-resolve
description: Resolve findings - interactively address review issues
prev_step: ./step-05-examine.md OR ./step-05b-team-examine.md
next_step: conditional (07-tests | 09-finish | complete)
---

# Step 6: Resolve Findings

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER auto-fix Noise or Uncertain findings
- 🛑 NEVER skip validation after fixes
- ✅ ALWAYS auto-fix Real findings, skip Noise/Uncertain
- ✅ ALWAYS validate after applying fixes
- ✅ ALWAYS provide clear completion summary
- 📋 YOU ARE A RESOLVER, addressing identified issues
- 💬 FOCUS on "How do we fix these issues?"
- 🚫 FORBIDDEN to proceed with failing validation

## EXECUTION PROTOCOLS:

- 🎯 Present resolution options first
- 💾 Log each fix applied
- 📖 Validate after all fixes
- 🚫 FORBIDDEN to skip post-fix validation

## CONTEXT BOUNDARIES:

- Findings from step-05 are classified
- Some are Real, some Noise, some Uncertain
- User may want different resolution strategies
- Must validate after any changes

## CONTEXT RESTORATION (resume mode):

<critical>
If this step was loaded via `/apex -r {task_id}` resume:

1. Read `{output_dir}/00-context.md` → restore flags, task info, acceptance criteria
2. Read `{output_dir}/05-examine.md` → restore findings table and todos
3. All state variables are now available from the restored context
4. Proceed with normal execution below
</critical>

## TEAM MODE BRANCHING:

<critical>
IF {team_mode} = true:
  → Do NOT execute this file.
  → Load `./step-06b-team-resolve.md` instead.
  → That file handles parallel finding resolution via Agent Teams.
</critical>

## YOUR TASK:

Address adversarial review findings interactively - fix real issues, dismiss noise, discuss uncertain items.

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

### 1. Initialize Save Output

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "06" "resolve" "in_progress"
```

Append logs to `{output_dir}/06-resolve.md` as you work.

### 2. Resolution Strategy

**Auto-fix Real findings, skip Noise/Uncertain.**

Log decision:
```
ℹ️ Auto-resolution: fixing {N} Real findings, skipping {M} Noise/Uncertain
```

### 3. Apply Fixes

For each Real finding (in severity order):
1. Read the file
2. Apply the fix
3. Verify the fix
4. Log: `✓ Fixed F{id}: {description}`

### 4. Post-Resolution Validation

After any fixes:

```bash
pnpm run typecheck && pnpm run lint
```

Both MUST pass.

### 5. Resolution Summary

```
**Resolution Complete**

**Fixed:** {count}
- F1: Parameterized SQL query in auth.ts:42
- F2: Added null check in handler.ts:78

**Skipped:** {count}
- F3: Complex function (uncertain)

**Validation:** ✓ Passed
```

### 6. Complete Save Output

Append to `{output_dir}/06-resolve.md`:
```markdown
---
## Step Complete
**Status:** ✓ Complete
**Findings fixed:** {count}
**Findings skipped:** {count}
**Validation:** ✓ Passed
**Timestamp:** {ISO timestamp}
```

---

## SUCCESS METRICS:

✅ User chose resolution approach
✅ All chosen fixes applied correctly
✅ Validation passes after fixes
✅ Clear summary of resolved/skipped
✅ User understands next steps

## FAILURE MODES:

❌ Auto-fixing Noise or Uncertain findings
❌ Not validating after fixes
❌ No clear completion summary
❌ Proceeding with failing validation

## RESOLUTION PROTOCOLS:

- Only auto-fix Real findings
- Validate after EVERY fix round
- Clear summary at the end

---

## NEXT STEP:

**Determine next step based on flags (check in order):**
- **If test_mode AND tests not yet completed:** next = `07-tests`
  - _Check: Read progress table in 00-context.md. If `08-run-tests` shows `✓ Complete`, tests are already done → skip to next rule._
- **If pr_mode:** next = `09-finish`
- **Otherwise:** next_step = complete

### Session Boundary

Determine {next_step_num} and {next_step_description} from the decision tree above.

IF workflow complete (next_step = "complete"):
  Run session boundary:
  ```bash
  bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "06" "resolve" \
    "All findings resolved. Workflow complete." "complete" "Workflow Complete" \
    "**06-resolve:** {fixed} fixed, {skipped} skipped" "" "{branch_mode}" "commit"
  ```

IF workflow not complete:
  Run session boundary:
  ```bash
  bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "06" "resolve" \
    "Fixed: {count} | Skipped: {count}" "{next_step_num}" "{next_step_description}" \
    "**06-resolve:** {fixed} fixed, {skipped} skipped" "{gotcha_or_empty}" "{branch_mode}" "commit"
  ```

→ STOP — session ends here. User must run `/apex -r {task_id}` to continue.

<critical>
Remember: Always validate after fixes - never proceed with failing checks!
ALWAYS STOP after displaying the resume command.
</critical>
