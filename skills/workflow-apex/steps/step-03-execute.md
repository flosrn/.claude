---
name: step-03-execute
description: Todo-driven implementation - execute the plan file by file
prev_step: ./step-02-plan.md
next_step: ./step-04-validate.md
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
3. If `00-context.md` Reference Documents section lists a file path → read it for full specification
4. **Partial work detection:** Run `git diff --name-only` to check what files have already been modified
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
| `{team_mode}` | Use Agent Teams for parallel execution |
| `{output_dir}` | Path to output |
| Implementation plan | File-by-file changes from step-02 |
| Patterns | How to implement from step-01 |
</available_state>

---

## EXECUTION SEQUENCE:

### 1. Initialize Save Output

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "03" "execute" "in_progress"
```

Append logs to `{output_dir}/03-execute.md` as you work.

### 2. Git Checkpoint (safety net)

Create a lightweight checkpoint before making changes:

```bash
git add -A && git commit -m "apex: checkpoint before execute ({task_id})" || true
```

Uses `git add -A` to include all files (new and tracked). The `|| true` prevents failure if there's nothing to commit. This enables `git reset HEAD~1` to rollback if execution breaks the codebase.

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

Track progress with markdown checkboxes (in conversation and in `{output_dir}/03-execute.md`).

### 4. Execute File by File

For each todo:

**4.1 Mark In Progress**
- Only ONE todo in_progress at a time

**4.2 Read Before Edit**
```
ALWAYS read the file before modifying:
- Understand current structure
- Find exact insertion points
- Verify patterns match expectations
```

**4.3 Implement Changes**
```
Make changes specified in the plan:
- Follow patterns from step-01 analysis
- Use exact names from plan
- Handle error cases as specified
- NO comments unless truly necessary
```

**4.4 Mark Complete Immediately**
- Mark todo complete RIGHT AFTER finishing
- Don't batch completions

**4.5 Log Progress**
```markdown
### ✓ src/auth/handler.ts
- Added `validateToken` function (lines 45-78)
- Added error handling for expired tokens
**Timestamp:** {ISO}
```

### 5. Handle Blockers

If a blocker is encountered, use the recommended alternative approach automatically.
Log decision:
```
ℹ️ Auto-unblocked: {description of alternative used}
```

### 6. Verify Implementation

After completing all todos:

**IF `{economy_mode}` = true:**
```bash
# Economy mode: lint only (typecheck skipped — too RAM-intensive for VPS)
pnpm run lint --fix
```

**IF `{economy_mode}` = false:**
```bash
pnpm run typecheck && pnpm run lint --fix
```

Fix any errors immediately. In economy mode, note that typecheck was skipped — it will be caught in step-04-validate if applicable.

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

Implementation is automatically confirmed. Continue to section 8 (save output) then follow the session boundary.

### 8. Complete Save Output

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
✅ Progress logged

## FAILURE MODES:

❌ Adding features not in the plan
❌ Modifying files without reading first
❌ Not updating todos as you work
❌ Multiple todos in_progress simultaneously
❌ Ignoring type or lint errors

## EXECUTION PROTOCOLS:

- Follow the plan EXACTLY
- Read before write
- One file at a time
- Update todos in real-time
- Fix errors immediately

---

## NEXT STEP:

### Session Boundary

Run session boundary:
```bash
bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "03" "execute" \
  "{count} files modified, {count} todos completed" "04-validate" "Validate (Self-Check)" \
  "**03-execute:** {count} files modified, all todos complete" "{gotcha_or_empty}" \
  "{branch_mode}" "commit"
```
→ STOP — session ends here. User must run `/apex -r {task_id}` to continue.

<critical>
Remember: Execution is about following the plan - don't redesign or add features!
ALWAYS STOP after displaying the resume command.
</critical>
