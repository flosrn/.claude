---
name: step-03-execute
description: Todo-driven implementation - execute the plan file by file
prev_step: steps/step-02-plan.md
next_step: steps/step-04-validate.md
---

# Step 3: Execute (Implementation)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER deviate from the approved plan
- 🛑 NEVER add features not in the plan (scope creep)
- 🛑 NEVER modify files without reading them first
- ✅ ALWAYS follow the plan file-by-file
- ✅ ALWAYS mark todos complete immediately after each task
- ✅ ALWAYS read files BEFORE editing them
- 📋 YOU ARE AN IMPLEMENTER following a plan, not a designer
- 💬 FOCUS on executing the plan exactly as approved
- 🚫 FORBIDDEN to add "improvements" not in the plan

## EXECUTION PROTOCOLS:

- 🎯 Create todos from plan before starting
- 💾 Mark todos complete immediately after each task
- 📖 Read each file BEFORE modifying it
- 🚫 FORBIDDEN to have multiple todos in_progress simultaneously

## CONTEXT BOUNDARIES:

- Plan from step-02 is approved and must be followed
- Files to modify are known from the plan
- Patterns to follow are documented from step-01
- Don't add features - stick to the plan

## CONTEXT RESTORATION (resume mode):

<critical>
If this step was loaded via `/apex -r {task_id}` resume:

1. Read `{output_dir}/00-context.md` → restore flags, task info, acceptance criteria
2. Read `{output_dir}/02-plan.md` → restore the implementation plan
3. **Partial work detection:** Run `git diff --name-only` to check what files have already been modified
4. Cross-reference modified files with the plan → skip already-completed items when creating todos
5. Proceed with normal execution below (only remaining plan items)
</critical>

## TEAM MODE BRANCHING:

<critical>
IF {team_mode} = true:
  → Do NOT execute this file.
  → Load `./step-03b-team-execute.md` instead.
  → That file handles parallel execution via Agent Teams.
</critical>

## YOUR TASK:

Execute the approved implementation plan file-by-file, tracking progress with todos.

---

<available_state>
From previous steps:

| Variable | Description |
|----------|-------------|
| `{task_description}` | What to implement |
| `{task_id}` | Kebab-case identifier |
| `{auto_mode}` | Skip confirmations |
| `{save_mode}` | Save outputs to files |
| `{output_dir}` | Path to output (if save_mode) |
| Implementation plan | File-by-file changes from step-02 |
| Patterns | How to implement from step-01 |
</available_state>

---

## EXECUTION SEQUENCE:

### 1. Initialize Save Output (if save_mode)

**If `{save_mode}` = true:**

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "03" "execute" "in_progress"
```

Append logs to `{output_dir}/03-execute.md` as you work.

### 2. Git Checkpoint (safety net)

Create a lightweight checkpoint before making changes:

```bash
git add -A && git commit --allow-empty -m "apex: checkpoint before execute ({task_id})"
```

This enables `git reset HEAD~1` to rollback if execution breaks the codebase.

### 3. Create Todos from Plan

Convert each file change from the plan into todos:

```
Plan entry:
#### `src/auth/handler.ts`
- Add `validateToken` function
- Handle error case: expired token

Becomes:
- [ ] src/auth/handler.ts: Add validateToken function
- [ ] src/auth/handler.ts: Handle expired token error
```

Use TodoWrite to create the full list.

### 4. Execute File by File

For each todo:

**3.1 Mark In Progress**
- Only ONE todo in_progress at a time

**3.2 Read Before Edit**
```
ALWAYS read the file before modifying:
- Understand current structure
- Find exact insertion points
- Verify patterns match expectations
```

**3.3 Implement Changes**
```
Make changes specified in the plan:
- Follow patterns from step-01 analysis
- Use exact names from plan
- Handle error cases as specified
- NO comments unless truly necessary
```

**3.4 Mark Complete Immediately**
- Mark todo complete RIGHT AFTER finishing
- Don't batch completions

**3.5 Log Progress (if save_mode)**
```markdown
### ✓ src/auth/handler.ts
- Added `validateToken` function (lines 45-78)
- Added error handling for expired tokens
**Timestamp:** {ISO}
```

### 5. Handle Blockers

**If `{auto_mode}` = true:**
→ Make reasonable decision and continue

**If `{auto_mode}` = false:**

```yaml
questions:
  - header: "Blocker"
    question: "Encountered an issue. How should we proceed?"
    options:
      - label: "Use alternative approach (Recommended)"
        description: "Description of alternative"
      - label: "Skip this part"
        description: "Continue without this change"
      - label: "Stop for discussion"
        description: "I want to discuss before continuing"
    multiSelect: false
```

### 6. Verify Implementation

After completing all todos:

```bash
pnpm run typecheck && pnpm run lint --fix
```

Fix any errors immediately.

### 7. Implementation Summary

```
**Implementation Complete**

**Files Modified:**
- `src/auth/handler.ts` - Added validateToken, error handling
- `src/api/auth/route.ts` - Integrated token validation

**New Files:**
- `src/types/auth.ts` - Auth type definitions

**Todos:** {X}/{Y} complete
```

**If `{auto_mode}` = true:**
→ Continue to section 8 (save output)

**If `{auto_mode}` = false:**

```yaml
questions:
  - header: "Execute"
    question: "Implementation complete. Review the summary above."
    options:
      - label: "Looks good (Recommended)"
        description: "Mark step complete and finish this session"
      - label: "Review changes"
        description: "I want to review what was changed"
      - label: "Make adjustments"
        description: "I want to modify something"
    multiSelect: false
```

<critical>
After user confirms, continue to section 8 (save output) then follow the NEXT STEP session boundary logic.
User confirmation does NOT mean "load step-04 now". The session boundary controls whether to stop or continue.
</critical>

### 8. Complete Save Output (if save_mode)

**If `{save_mode}` = true:**

Append to `{output_dir}/03-execute.md`:
```markdown
---
## Step Complete
**Status:** ✓ Complete
**Files modified:** {count}
**Todos completed:** {count}
**Next:** step-04-validate.md
**Timestamp:** {ISO timestamp}
```

---

## SUCCESS METRICS:

✅ All plan items implemented
✅ All todos marked complete
✅ No scope creep - only plan items
✅ Files read before modification
✅ Typecheck and lint pass
✅ Progress logged (if save_mode)

## FAILURE MODES:

❌ Adding features not in the plan
❌ Modifying files without reading first
❌ Not updating todos as you work
❌ Multiple todos in_progress simultaneously
❌ Ignoring type or lint errors
❌ **CRITICAL**: Not using AskUserQuestion for blockers

## EXECUTION PROTOCOLS:

- Follow the plan EXACTLY
- Read before write
- One file at a time
- Update todos in real-time
- Fix errors immediately

---

## NEXT STEP:

### Session Boundary

<critical>
THIS SECTION IS MANDATORY. Even if the user confirmed above, you MUST follow this session boundary logic.
User confirmation does NOT mean "skip to step-04". It means the step is validated and can be marked complete.
</critical>

```
IF auto_mode = true:
  → Load ./step-04-validate.md directly (chain all steps)

IF auto_mode = false:
  → Mark step complete in progress table (if save_mode):
    bash {skill_dir}/scripts/update-progress.sh "{task_id}" "03" "execute" "complete"
  → Update State Snapshot in 00-context.md:
    1. Set next_step to 04-validate
    2. Append to Step Context: "- **03-execute:** {count} files modified, all todos complete"
  → Display:

    ═══════════════════════════════════════
      STEP 03 COMPLETE: Execute
    ═══════════════════════════════════════
      {count} files modified, {count} todos completed
      Resume: /apex -r {task_id}
      Next: Step 04 - Validate (Self-Check)
    ═══════════════════════════════════════

  → STOP. Do NOT load the next step. Do NOT proceed to step-04-validate.
  → The session ENDS here. User must run /apex -r {task_id} to continue.
```

<critical>
Remember: Execution is about following the plan - don't redesign or add features!
In auto_mode=true, proceed directly without stopping.
In auto_mode=false, ALWAYS STOP after displaying the resume command — even if the user said "looks good".
</critical>
