---
name: phase-02-plan
description: Strategic planning - file-by-file implementation strategy with human checkpoint
prev_phase: ./phase-01-context.md
next_phase: ./phase-03-implement.md
---

# Phase 2: Plan

Planner (no code, no Edit/Write/Bash)

---

## EXECUTION SEQUENCE

### 1. Initialize

```bash
source {output_dir}/.env.local
bash {skill_dir}/scripts/update-progress.sh "{TASK_ID}" "02" "plan" "in_progress"
```

Mark phase in progress.

### 2. Context Restoration (resume mode)

**If resumed via `/apex -r {TASK_ID}`:**

1. Read `{output_dir}/00-init.md` → restore flags, task info
2. Read `{output_dir}/01-context.md` → restore analysis findings
3. Extract acceptance criteria section
4. All state variables now available

### 3. ULTRA THINK: Design Complete Strategy

**Before writing plan, mentally simulate entire implementation:**

- Walk through step-by-step
- Identify all files that need changes (with line numbers)
- Determine logical order (dependencies first)
- Consider edge cases and error handling
- Plan test structure (if test_mode)
- Verify against acceptance criteria

### 4. Create Detailed Plan

**Structure by FILE, not by feature. Save to `{output_dir}/02-plan.md`:**

```markdown
# Implementation Plan: {task_description}

## Overview
[1-2 sentences: high-level strategy and approach]

## Prerequisites
- [ ] Prerequisite 1 (if any)

---

## File Changes

### `path/to/file1.ts`
- Add `functionName()` that handles X
- Follow pattern from `reference.ts:45`
- Lines: NEW (insert after line 50)

### `path/to/file2.tsx`
- Update `ComponentName` props interface
- Add {prop_name} property
- Lines: 23-28 (modify)

### `path/to/new-file.ts`
- Create new utility file
- Type-safe wrapper around API
- ~30-40 lines

---

## Test Coverage (if test_mode)

### Tests to add
- `test("should handle X")` in file1.test.ts
- `test("should reject invalid Y")` in file1.test.ts

---

## Verification Checklist

- [ ] All acceptance criteria addressed
- [ ] No TypeScript errors
- [ ] Follows existing code style
- [ ] Tests pass (if test_mode)
```

### 5. Domain Partitioning (if team_mode)

**IF team_mode = true:**

Add section to plan:

```markdown
## Domain Partitioning (Team Mode)

For parallel execution, partition work by domain:

| Domain | Files | Owner | Dependencies |
|--------|-------|-------|--------------|
| API layer | file1.ts, file2.ts | Agent 1 | None |
| State | file3.ts | Agent 2 | After API |
| UI | file4.tsx, file5.tsx | Agent 3 | After State |
| Tests | test files | Agent 4 | After all |
```

Plan tasks for:
1. TaskCreate for each domain
2. Assign via TaskUpdate (owner)
3. Track blockedBy dependencies

### 6. Verify Plan Completeness

**Checklist before human checkpoint:**

- [ ] All acceptance criteria explicitly mapped to file changes
- [ ] Implementation order is logical (dependencies first)
- [ ] No gaps or missing files
- [ ] Complexity assessment matches scope
- [ ] Test coverage aligns with changes
- [ ] No conflicts with existing patterns

If gaps found → update plan, re-verify.

### 7. Mark Plan Complete

```bash
bash {skill_dir}/scripts/update-progress.sh "{TASK_ID}" "02" "plan" "complete"
```

### 8. CRITICAL: Human Checkpoint

**Display plan summary:**

```
╔═══════════════════════════════════════╗
║ PLAN READY FOR APPROVAL               ║
╠═══════════════════════════════════════╣
║ Task: {task_description}              ║
║ Files to modify: N                     ║
║ Files to create: N                     ║
║ Estimated complexity: {small|medium|  ║
║                      large}            ║
║ Tests included: {yes|no}              ║
║ Team mode: {yes|no}                   ║
╚═══════════════════════════════════════╝

Plan saved to: {output_dir}/02-plan.md
```

**IF auto_mode = false (default):**

Ask user via markdown prompt:

```
## Approval Required

✏️ **Plan ready.** What would you like to do?

- **✅ Approve** — Proceed to implementation
- **✏️ Edit plan** — Describe changes needed
- **❌ Cancel** — Stop workflow
```

**Response handling:**

**If "Approve":**
→ proceed to phase-03-implement

**If "Edit plan":**
1. Use AskUserQuestion: "What would you like to change?" (free text)
2. Apply requested changes to `{output_dir}/02-plan.md`
3. Show updated plan summary (changed sections only, not full re-display):
   ```
   ✏️ Updated sections:
   - {changed_section_1}: {brief_summary}
   - {changed_section_2}: {brief_summary}
   ```
4. Re-present checkpoint: "Updated plan. Approve?"
5. If user approves → proceed to phase-03
6. If user wants more edits → loop back to step 1

**If "Cancel":**
→ log and STOP workflow (gracefully exit)

**IF auto_mode = true:**

```
ℹ️ Auto-approved (auto_mode=true)
→ Proceeding to phase-03...
```

### 9. Handle Phase Boundary

**IF pause_mode = true:**

```bash
bash {skill_dir}/scripts/session-boundary.sh "{TASK_ID}"
echo "ℹ️ Session paused. Resume with: /apex -r {TASK_ID}"
```

STOP execution. User resumes next session.

**IF pause_mode = false (default):**

Proceed directly to phase-03-implement.
