---
name: step-02-plan
description: Strategic planning - create detailed file-by-file implementation strategy
prev_step: ./step-01-analyze.md
next_step: ./step-03-execute.md
---

# Step 2: Plan (Strategic Design)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER start implementing - that's step 3
- 🛑 NEVER write or modify code in this step
- ✅ ALWAYS structure plan by FILE, not by feature
- ✅ ALWAYS include specific line numbers from analysis
- ✅ ALWAYS map acceptance criteria to file changes
- 📋 YOU ARE A PLANNER, not an implementer
- 💬 FOCUS on "What changes need to be made where?"
- 🚫 FORBIDDEN to use Edit, Write, or Bash tools

## EXECUTION PROTOCOLS:

- 🎯 ULTRA THINK before creating the plan
- 💾 Save plan to output file (if save_mode)
- 📖 Reference patterns from step-01 analysis

## CONTEXT BOUNDARIES:

- Context from step-01 (files, patterns, utilities) is available
- Implementation has NOT started
- User has NOT approved any changes yet
- Plan must be complete before execution

## CONTEXT RESTORATION (resume mode):

<critical>
If this step was loaded via `/apex -r {task_id}` resume:

1. Read `{output_dir}/00-context.md` → restore flags, task info, acceptance criteria
2. Read `{output_dir}/01-analyze.md` → restore analysis findings (Task Requirements, files, patterns, utilities)
3. If `00-context.md` Reference Documents section lists a file path → read it for full specification
4. All state variables are now available from the restored context
5. Proceed with normal execution below
</critical>

## YOUR TASK:

Transform analysis findings into a comprehensive, executable, file-by-file implementation plan.

---

<available_state>
From previous steps:

| Variable | Description |
|----------|-------------|
| `{task_description}` | What to implement |
| `{task_id}` | Kebab-case identifier |
| `{acceptance_criteria}` | Success criteria from step-01 |
| `{team_mode}` | Use Agent Teams (domain partitioning in section 4b) |
| `{output_dir}` | Path to output |
| Files found | From step-01 codebase exploration |
| Patterns | From step-01 pattern analysis |
| Utilities | From step-01 utility discovery |
</available_state>

---

## EXECUTION SEQUENCE:

### 1. Initialize Save Output (if save_mode)

**If `{save_mode}` = true:**

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "02" "plan" "in_progress"
```

Append plan to `{output_dir}/02-plan.md` as you work.

### 2. ULTRA THINK: Design Complete Strategy

**CRITICAL: Think through ENTIRE implementation before writing any plan.**

Mental simulation:
- Walk through the implementation step by step
- Identify all files that need changes
- Determine logical order (dependencies first)
- Consider edge cases and error handling
- Plan test coverage

### 3. Clarify Ambiguities

**If multiple valid approaches exist:**
→ Choose the recommended approach automatically.
→ Log decision:
```
ℹ️ Auto-selected approach: {approach_name}
Reason: {why this approach was recommended}
```

### 4. Create Detailed Plan

**Structure by FILE, not by feature:**

```markdown
## Implementation Plan: {task_description}

### Overview
[1-2 sentences: High-level strategy and approach]

### Prerequisites
- [ ] Prerequisite 1 (if any)
- [ ] Prerequisite 2 (if any)

---

### File Changes

#### `src/path/file1.ts`
- Add `functionName` that handles X
- Extract logic from Y (follow pattern in `example.ts:45`)
- Handle error case: [specific scenario]
- Consider: [edge case or important context]

#### `src/path/file2.ts`
- Update imports to include new module
- Call `functionName` in existing flow at line ~42
- Update types: Add `NewType` interface

#### `src/path/file3.ts` (NEW FILE)
- Create utility for Z
- Export: `utilityFunction`, `HelperType`
- Pattern: Follow `similar-util.ts` structure

---

### Testing Strategy

**New tests:**
- `src/path/file1.test.ts` - Test functionName with:
  - Happy path
  - Error case
  - Edge case

**Update existing:**
- `src/path/existing.test.ts` - Add test for new flow

---

### Acceptance Criteria Mapping
- [ ] AC1: Satisfied by changes in `file1.ts`
- [ ] AC2: Satisfied by changes in `file2.ts`

---

### Risks & Considerations
- Risk 1: [potential issue and mitigation]
```

**If `{save_mode}` = true:** Append full plan to 02-plan.md

### 4b. Domain Partitioning (if team_mode)

**If `{team_mode}` = true, add a "Domain Partitioning" section to the plan:**

This section groups file changes into independent domains for parallel execution by Agent Team teammates. Each domain becomes one teammate's scope.

```markdown
### Domain Partitioning

**Domain 1: {domain_name}** (e.g., "backend", "frontend", "shared/types")
- `src/api/route.ts` - changes described above
- `src/api/handler.ts` - changes described above

**Domain 2: {domain_name}**
- `src/components/Form.tsx` - changes described above
- `src/components/Display.tsx` - changes described above

**Domain 3: {domain_name}** (if needed)
- `src/types/index.ts` - changes described above

**Execution Order:**
- Domain 3 (shared/types) → Domain 1, Domain 2 (can run in parallel after Domain 3)

**Partitioning Rules:**
- No file appears in more than one domain
- Shared dependencies (types, utils) are in their own domain and execute first
- Each domain is independently implementable
```

**Verification checklist for partitioning:**
- [ ] No file overlap between domains
- [ ] Shared dependencies identified and ordered first
- [ ] Each domain is self-contained (no cross-domain implementation dependencies)
- [ ] Domains are roughly balanced in size

### 5. Verify Plan Completeness

Checklist:
- [ ] All files identified - nothing missing
- [ ] Logical order - dependencies handled first
- [ ] Clear actions - every step specific and actionable
- [ ] Test coverage - all paths have test strategy
- [ ] In scope - no scope creep
- [ ] AC mapped - every criterion has implementation
- [ ] Domain partitioning valid (if team_mode) - no file overlap, dependencies ordered

### 6. Present Plan Summary

```
**Implementation Plan Ready**

**Overview:** [1 sentence summary]

**Files to modify:** {count} files
**New files:** {count} files
**Tests:** {count} test files

**Estimated changes:**
- `file1.ts` - Major changes (add function, handle errors)
- `file2.ts` - Minor changes (imports, single call)
- `file1.test.ts` - New test file
```

Plan is automatically approved. Continue to section 7 (save output) then follow the session boundary.

### 7. Complete Save Output (if save_mode)

**If `{save_mode}` = true:**

Append to `{output_dir}/02-plan.md`:
```markdown
---
## Step Complete
**Status:** ✓ Complete
**Files planned:** {count}
**Tests planned:** {count}
**Next:** step-03-execute.md
**Timestamp:** {ISO timestamp}
```

---

## SUCCESS METRICS:

✅ Complete file-by-file plan created
✅ Logical dependency order established
✅ All acceptance criteria mapped to changes
✅ Test strategy defined
✅ User approved plan (or auto-approved)
✅ NO code written or modified
✅ Output saved (if save_mode)

## FAILURE MODES:

❌ Organizing by feature instead of file
❌ Vague actions like "add feature" or "fix issue"
❌ Missing test strategy
❌ Not mapping to acceptance criteria
❌ Starting to write code (that's step 3!)

## PLANNING PROTOCOLS:

- Structure by FILE - each file is a section
- Include line number references from analysis
- Every action must be specific and actionable
- Map every AC to specific file changes
- Plan tests alongside implementation

---

## NEXT STEP:

### Session Boundary

Run session boundary:
```bash
bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "02" "plan" \
  "{count} files planned, {count} new files" "03-execute" "Execute (Implementation)" \
  "**02-plan:** {one-line summary of plan}" ["{gotcha if any}"]
```
→ STOP — session ends here. User must run `/apex -r {task_id}` to continue.

<critical>
Remember: Planning is ONLY about designing the approach - save all implementation for step-03!
ALWAYS STOP after displaying the resume command.
</critical>
