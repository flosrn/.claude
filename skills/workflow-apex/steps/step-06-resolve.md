---
name: step-06-resolve
description: Resolve findings - interactively address review issues
prev_step: steps/step-05-examine.md
next_step: COMPLETE
---

# Step 6: Resolve Findings

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER auto-fix Noise or Uncertain findings
- 🛑 NEVER skip validation after fixes
- ✅ ALWAYS present resolution options to user (unless auto_mode)
- ✅ ALWAYS validate after applying fixes
- ✅ ALWAYS provide clear completion summary
- 📋 YOU ARE A RESOLVER, addressing identified issues
- 💬 FOCUS on "How do we fix these issues?"
- 🚫 FORBIDDEN to proceed with failing validation

## EXECUTION PROTOCOLS:

- 🎯 Present resolution options first
- 💾 Log each fix applied (if save_mode)
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

## YOUR TASK:

Address adversarial review findings interactively - fix real issues, dismiss noise, discuss uncertain items.

---

<available_state>
From previous steps:

| Variable | Description |
|----------|-------------|
| `{task_description}` | What was implemented |
| `{task_id}` | Kebab-case identifier |
| `{auto_mode}` | Auto-fix Real findings |
| `{save_mode}` | Save outputs to files |
| `{output_dir}` | Path to output (if save_mode) |
| Findings table | IDs, severity, validity |
| Finding todos | For tracking |
</available_state>

---

## EXECUTION SEQUENCE:

### 1. Initialize Save Output (if save_mode)

**If `{save_mode}` = true:**

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "06" "resolve" "in_progress"
```

Append logs to `{output_dir}/06-resolve.md` as you work.

### 2. Present Resolution Options

**If `{auto_mode}` = true:**
→ Auto-fix all "Real" findings, skip Noise/Uncertain

**If `{auto_mode}` = false:**

```yaml
questions:
  - header: "Resolution"
    question: "How would you like to handle these findings?"
    options:
      - label: "Auto-fix Real issues (Recommended)"
        description: "Fix 'Real' findings, skip noise/uncertain"
      - label: "Walk through each finding"
        description: "Decide on each finding individually"
      - label: "Fix only critical"
        description: "Only fix CRITICAL/BLOCKING issues"
      - label: "Skip all"
        description: "Acknowledge but don't change"
    multiSelect: false
```

### 3. Apply Fixes Based on Choice

**Auto-fix Real:**
1. Filter to Real findings only
2. For each: Read file → Apply fix → Verify
3. Log each fix

**Walk through each:**
For each finding in severity order:

```yaml
questions:
  - header: "F1"
    question: "How should we handle this finding?"
    options:
      - label: "Fix now (Recommended)"
        description: "Apply the suggested fix"
      - label: "Skip"
        description: "Acknowledge but don't fix"
      - label: "Discuss"
        description: "Need more context"
      - label: "Mark as noise"
        description: "Not a real issue"
    multiSelect: false
```

**Fix only critical:**
1. Filter to CRITICAL/BLOCKING only
2. Auto-fix those, skip others

**Skip all:**
1. Acknowledge findings
2. If Critical/High exist, confirm:

```yaml
questions:
  - header: "Confirm"
    question: "You have unresolved Critical/High findings. Proceed anyway?"
    options:
      - label: "Go back and fix"
        description: "Return to resolution options"
      - label: "Proceed anyway"
        description: "Accept risks, continue"
      - label: "Fix only critical"
        description: "Just fix critical issues"
    multiSelect: false
```

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

### 6. Complete Save Output (if save_mode)

**If `{save_mode}` = true:**

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

### 7. Completion Summary

```
**APEX Workflow Complete**

**Task:** {task_description}

**Implementation:**
- Files modified: {count}
- All checks passing: ✓

**Review:**
- Findings identified: {total}
- Findings resolved: {fixed}
- Findings skipped: {skipped}

**Next Steps:**
- [ ] Commit changes
- [ ] Run full test suite
- [ ] Deploy when ready
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
❌ **CRITICAL**: Not using AskUserQuestion for decisions

## RESOLUTION PROTOCOLS:

- Only auto-fix Real findings
- Validate after EVERY fix round
- Clear summary at the end
- User controls final decision

---

## NEXT STEP:

**Determine next step based on flags:**
- **If test_mode (and tests not yet done):** next = `07-tests`
- **If pr_mode:** next = `09-finish`
- **Otherwise:** Workflow complete

### Session Boundary

<critical>
THIS SECTION IS MANDATORY. Follow this session boundary logic regardless of what happened above.
</critical>

```
IF auto_mode = true:
  → Load the determined next step directly (chain all steps)

IF auto_mode = false AND workflow not complete:
  → Mark step complete in progress table (if save_mode):
    bash {skill_dir}/scripts/update-progress.sh "{task_id}" "06" "resolve" "complete"
  → Update State Snapshot in 00-context.md:
    1. Set next_step to the determined next step
    2. Append to Step Context: "- **06-resolve:** {fixed} fixed, {skipped} skipped"
  → Display:

    ═══════════════════════════════════════
      STEP 06 COMPLETE: Resolve
    ═══════════════════════════════════════
      Fixed: {count} | Skipped: {count}
      Resume: /apex -r {task_id}
      Next: Step {NN} - {description}
    ═══════════════════════════════════════

  → STOP. Do NOT load the next step. Do NOT proceed to the next step.
  → The session ENDS here. User must run /apex -r {task_id} to continue.

IF workflow complete:
  → Show final APEX WORKFLOW COMPLETE summary
  → STOP.
```

<critical>
Remember: Always validate after fixes - never proceed with failing checks!
In auto_mode=true, proceed directly without stopping.
In auto_mode=false, ALWAYS STOP after displaying the resume command.
</critical>
