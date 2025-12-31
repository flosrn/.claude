---
description: Execution phase - implement the plan step by step with ultra thinking
argument-hint: <task-folder-path> [task-number(s) | --parallel]
---

You are an implementation specialist. Execute plans precisely while maintaining code quality.

**You need to ULTRA THINK at every step.**

## Workflow

1. **DETECT ENVIRONMENT**: Find paths and package manager
   ```bash
   # Check which tasks directory exists (use /bin/ls to bypass eza alias)
   /bin/ls .claude/tasks 2>/dev/null || /bin/ls tasks 2>/dev/null
   # Check package manager (use [ -f ] for file existence checks)
   [ -f pnpm-lock.yaml ] && echo "PM=pnpm"
   [ -f yarn.lock ] && echo "PM=yarn"
   [ -f bun.lockb ] && echo "PM=bun"
   [ -f package-lock.json ] && echo "PM=npm"
   ```
   - Use `.claude/tasks` for project directories, `tasks` if in `~/.claude`
   - Detect PM from lock file present

2. **VALIDATE INPUT**: Verify task folder is ready
   - Check that `$TASKS_DIR/<task-folder>/` exists
   - Verify `analyze.md` exists
   - **CRITICAL**: If missing files, instruct user to run analysis first

3. **DETECT EXECUTION MODE**: Check for individual task files and parallel execution
   - Check if `$TASKS_DIR/<task-folder>/tasks/` directory exists
   - If `tasks/` exists AND contains `task-XX.md` files → **USE TASK-BY-TASK MODE**
   - If `tasks/` does NOT exist → **USE PLAN MODE** (fallback to plan.md)

   **Parse argument for execution type**:
   - `--parallel` flag → **PARALLEL AUTO-DETECT MODE**
   - `--dry-run` flag → **DRY-RUN MODE** (preview only, no changes)
   - `--quick` flag → **QUICK VALIDATION MODE** (run typecheck+lint after task)
   - Comma-separated numbers (e.g., `3,4`) → **PARALLEL EXPLICIT MODE**
   - Single number (e.g., `3`) → **SEQUENTIAL MODE** (single task)
   - No number → **SEQUENTIAL MODE** (next incomplete task)

   **Note**: `--dry-run` and `--quick` can combine with sequential mode (e.g., `3 --dry-run`)

   **IMPORTANT**: Task-by-task mode is preferred when available because:
   - Individual tasks are smaller and more focused (~50 lines vs 400+ lines)
   - Each task has clear success criteria
   - Dependencies are explicitly defined
   - Progress tracking is more granular
   - **Parallel execution** is possible when dependencies allow

3. **LOAD CONTEXT**: Read planning artifacts based on mode

   ### Task-by-Task Mode (PREFERRED)
   - Read `$TASKS_DIR/<task-folder>/analyze.md` for overall context
   - Read `$TASKS_DIR/<task-folder>/tasks/index.md` to understand:
     - Complete task list with dependencies
     - Execution order (which tasks can be parallel)
     - Overall progress tracking

   #### Sequential Mode (default)
   - **IF specific task number provided** (e.g., `/apex:3-execute feature-name 3`):
     - Read ONLY `$TASKS_DIR/<task-folder>/tasks/task-03.md`
     - Focus exclusively on that single task
   - **IF no task number provided** (find next incomplete task):
     ```bash
     # Note: Use /usr/bin/grep to bypass rg alias, sed for portable extraction
     NEXT_TASK=$(/usr/bin/grep "^- \[ \]" "$TASKS_DIR/$FOLDER/tasks/index.md" 2>/dev/null | head -1 | sed 's/.*Task \([0-9]*\).*/\1/') && \
     echo "Next incomplete task: $NEXT_TASK"
     ```
     - Read that specific task file (e.g., `task-$NEXT_TASK.md`)
     - Execute only that task in this session

   #### Parallel Explicit Mode (e.g., `3,4` or `3,4,5`)
   - Parse comma-separated task numbers from argument
   - Read ALL specified task files (e.g., `task-03.md`, `task-04.md`)
   - **VALIDATE DEPENDENCIES**: Check index.md to ensure:
     - All specified tasks have their dependencies completed
     - Tasks don't depend on each other
   - If dependency conflict: WARN user and suggest correct order
   - → **GO TO STEP 3B: PARALLEL EXECUTION**

   #### Parallel Auto-Detect Mode (`--parallel`)
   **Method 1**: Look for explicit patterns in `index.md`
   - Parse `index.md` for "Execution Strategy" or parallel patterns
   - Look for patterns like:
     - `[Task X ‖ Task Y]` or `[Task X || Task Y]`
     - "can be executed simultaneously"
     - "Parallelization opportunity"

   **Method 2**: Analyze dependency table (fallback)
   If no explicit patterns found:
   - Parse the dependency table from `index.md` (look for `| Task | Name | Dependencies |`)
   - Identify ALL incomplete tasks (`- [ ]`)
   - For each incomplete task, check if ALL its dependencies are complete
   - Tasks with NO dependencies or ALL dependencies complete → **PARALLELIZABLE**
   - If multiple tasks qualify → propose parallel execution

   **Final step**:
   - Find the NEXT group of parallelizable incomplete tasks
   - Read ALL task files in that parallel group
   - → **GO TO STEP 3B: PARALLEL EXECUTION**

   ### Plan Mode (FALLBACK)
   - Read `$TASKS_DIR/<task-folder>/analyze.md` for context
   - Read `$TASKS_DIR/<task-folder>/plan.md` for implementation steps
   - Note dependencies and execution order

---

## 3B. PARALLEL EXECUTION (only if parallel mode detected)

**CRITICAL**: This step REPLACES steps 4-9 for parallel execution.

### Step 1: Prepare Agent Prompts

For EACH task in the parallel group, prepare a detailed prompt:

```text
Execute Task [N]: [Task Name]

## Task Details
[Full content of task-XX.md]

## Context
- Project: [from analyze.md]
- Working directory: [project path]

## Instructions
1. Read all relevant files before making changes
2. Implement the task following existing patterns
3. Run typecheck and lint after changes
4. Report: files changed, test results, any issues

## Success Criteria
[From task file]
```

### Step 2: Launch Parallel Agents

**USE TASK TOOL**: Launch ALL agents in a SINGLE message with multiple Task tool calls.

Example for tasks 3 and 4:

```
Use the Task tool TWICE in the same message:

Task 1: subagent_type="apex-executor", description="Execute Task 3", prompt="[Task 3 prompt]"
Task 2: subagent_type="apex-executor", description="Execute Task 4", prompt="[Task 4 prompt]"
```

**IMPORTANT**:
- Send ALL Task calls in ONE message (not sequentially)
- This enables true parallel execution
- Each agent works independently
- Use `subagent_type: "apex-executor"` for full task execution capability
- apex-executor uses Sonnet model with validation built-in (typecheck/lint)

### Step 3: Wait for All Agents

- All agents run concurrently
- Wait for ALL to complete before proceeding
- Collect results from each agent

### Step 4: Aggregate Results

After all agents complete:
1. Collect files changed from each agent
2. Merge any conflicts (should be rare if tasks are independent)
3. Run global typecheck: `$PM run typecheck`
4. Run global lint: `$PM run lint`
5. If errors: fix them or report to user

### Step 5: Update Documentation

- Update `index.md`: Mark ALL completed tasks as `- [x]`
- Update `implementation.md`:
  - In Session entry, list ALL tasks completed: "Tasks 3, 4 - [Names]"
  - Note: "Executed in parallel"

### Then → GO TO STEP 12 (PROGRESS DASHBOARD)

---

## 3C. DRY-RUN MODE (only if --dry-run flag detected)

**CRITICAL**: This mode previews task actions WITHOUT executing them.

### Step 1: Identify Target Task
- Parse task number from argument (or find first incomplete task)
- Read the task file (e.g., `task-03.md`)

### Step 2: Analyze Task Actions
- Parse the task file for:
  - Files mentioned in Context section
  - Changes described in Proposed Solution
  - Success Criteria requirements

### Step 3: Display Preview
Output the preview in this format:

```
══════════════════════════════════════════════════
DRY-RUN: Task N - [Task Name]
══════════════════════════════════════════════════

Would read:
  - src/path/to/context-file.ts
  - src/path/to/pattern-file.ts:45-67

Would modify:
  - src/path/to/file.ts: [description from task]

Would create:
  - [new files if any]

Would run:
  - $PM run typecheck
  - $PM run lint

══════════════════════════════════════════════════
Run without --dry-run to execute
══════════════════════════════════════════════════
```

### Then → END (no further execution)

---

## 3D. QUICK VALIDATION MODE (when --quick flag detected)

**Note**: `--quick` modifies normal execution, not a separate mode.

After completing task implementation (Step 9):
1. Run `$PM run typecheck` (or npm equivalent)
2. Run `$PM run lint` (or npm equivalent)
3. Display results:

```
══════════════════════════════════════════════════
QUICK VALIDATION
══════════════════════════════════════════════════
Typecheck: ✓ Pass (or ✗ N errors)
Lint:      ✓ Pass (or ✗ N warnings/errors)
══════════════════════════════════════════════════
```

4. If errors found: Display and ask user whether to continue to documentation update
5. If all pass: Continue to Step 10 (UPDATE TASK STATUS)

---

4. **CREATE TODO LIST**: Track implementation progress

   ### Task-by-Task Mode
   - **CRITICAL**: Create todos ONLY from the current task file
   - Each task file contains:
     - Problem statement
     - Proposed solution
     - Context (relevant files, patterns)
     - Success criteria
   - Create focused todos matching the task's success criteria

   ### Plan Mode
   - Use TodoWrite to create todos from the full plan
   - Break down each file change into separate todo items

5. **ULTRA THINK BEFORE EACH CHANGE**: Plan every modification
   - **BEFORE** editing any file:
     - Think through the exact changes needed
     - Review analysis findings for patterns to follow
     - Consider impact on other files
     - Identify potential edge cases
   - **NEVER** make changes without thinking first

6. **IMPLEMENT STEP BY STEP**: Execute methodically
   - **ONE TODO AT A TIME**: Mark in_progress, complete, then move to next
   - **Follow existing patterns**:
     - Match codebase style and conventions
     - Use clear variable/method names
     - Avoid comments unless absolutely necessary
   - **Stay strictly in scope**:
     - Change ONLY what's needed for this task
     - Don't refactor unrelated code
     - Don't add extra features
   - **Read before editing**:
     - Always use Read tool before Edit/Write
     - Understand context before modifying

7. **CONTINUOUS VALIDATION**: Verify as you go
   - After each significant change:
     - Check if code compiles/parses
     - Verify logic matches task requirements
     - Ensure pattern consistency
   - **STOP** if something doesn't work as expected
   - **RETURN TO TASK**: If implementation reveals issues with task definition

8. **FORMAT AND LINT**: Clean up code
   - Check `package.json` for available scripts
   - Run formatting: `npm run format` or similar
   - Fix linter warnings if reasonable
   - **CRITICAL**: Don't skip this step

9. **TEST PHASE**: Verify implementation works
   - **Check `package.json`** for available test commands:
     - Look for: `lint`, `typecheck`, `test`, `format`, `build`
   - **Run relevant checks**:
     - `npm run typecheck` - MUST pass
     - `npm run lint` - MUST pass
     - `npm run test` - Run ONLY tests related to changes
   - **STAY IN SCOPE**: Don't run entire test suite unless necessary
   - **If tests fail**:
     - Debug and fix issues
     - **NEVER** mark as complete with failing tests

10. **UPDATE TASK STATUS**: Mark completion in index.md

    ### Task-by-Task Mode
    - Edit `$TASKS_DIR/<task-folder>/tasks/index.md`
    - Change the completed task from `- [ ]` to `- [x]`
    - This tracks progress across sessions

    ### Plan Mode
    - Skip this step (no index.md exists)

11. **UPDATE IMPLEMENTATION.MD**: Document work done

    **CRITICAL**: Check if `implementation.md` already exists
    - If **EXISTS** → **APPEND** a new session entry (don't overwrite!)
    - If **NOT EXISTS** → **CREATE** with full template

    ### If `implementation.md` does NOT exist (CREATE)

    Create `$TASKS_DIR/<task-folder>/implementation.md` with this template:

    ```markdown
    # Implementation: [Feature Name]

    ## Overview
    [Brief description of what this feature does - 1-2 sentences]

    ## Status: 🔄 In Progress
    **Progress**: X/Y tasks completed

    ## Task Status

    | Task | Description | Status | Session |
    |------|-------------|--------|---------|
    | 1 | [Task name from index.md] | ✅ Complete | Session 1 |
    | 2 | [Task name] | ⏳ Pending | - |
    | ... | ... | ... | ... |

    ---

    ## Session Log

    ### Session 1 - [YYYY-MM-DD]

    **Task(s) Completed**: Task N - [Name]

    #### Changes Made
    - [List specific changes]
    - `path/to/file.ts` - [What was done]

    #### Files Changed

    **New Files:**
    - `path/to/new-file.ts` - [Purpose]

    **Modified Files:**
    - `path/to/modified-file.ts` - [What changed]

    #### Test Results
    - Typecheck: ✓
    - Lint: ✓
    - Tests: ✓ [which tests ran]

    #### Notes
    - [Any deviations from plan]
    - [Discoveries or learnings]

    ---

    ## Follow-up Tasks
    - [Items discovered during implementation]

    ## Technical Notes
    - [Important patterns used]
    - [Breaking changes or migrations]

    ## Suggested Commit

    ```
    feat: [Feature name from task folder, kebab-case to sentence]

    - [Summary of key changes from session log]
    - [Additional bullet points for major changes]

    Implements: #issue-number (if applicable)
    ```
    ```

    ### If `implementation.md` EXISTS (APPEND)

    1. **Read the existing file**
    2. **Update the Status section**:
       - Change progress count (X/Y tasks)
       - If all complete, change status to `## Status: ✅ Complete`
    3. **Update the Task Status table**:
       - Mark completed task(s) as `✅ Complete`
       - Add session number
    4. **APPEND a new Session entry** at the end of "## Session Log":
       ```markdown
       ### Session N - [YYYY-MM-DD]

       **Task(s) Completed**: Task X - [Name]

       #### Changes Made
       - [List specific changes]

       #### Files Changed
       **New Files:**
       - [List new files]

       **Modified Files:**
       - [List modified files]

       #### Test Results
       - Typecheck: ✓/✗
       - Lint: ✓/✗

       #### Notes
       - [Session-specific notes]
       ```
    5. **Update Follow-up Tasks** if new items discovered
    6. **Update Suggested Commit** when ALL tasks complete:
       - Find or create `## Suggested Commit` section
       - Generate commit message based on all changes:
         ```
         feat: [Feature name from folder]

         - [Key change 1 from session logs]
         - [Key change 2 from session logs]
         - ...

         Implements: #issue-number (if applicable)
         ```

12. **SHOW PROGRESS DASHBOARD**: Display visual progress summary

    ### Task-by-Task Mode
    After task completion, read `tasks/index.md` and display progress:

    ```
    ══════════════════════════════════════════════════
    PROGRESS: X/Y tasks completed (N%)
    ══════════════════════════════════════════════════
    ✓ Task 1: [Name from index.md]
    ✓ Task 2: [Name from index.md]
    ✓ Task 3: [Name from index.md] ← JUST COMPLETED
    ○ Task 4: [Name from index.md]
    ○ Task 5: [Name from index.md]

    Next: /apex:3-execute <folder> 4
    ══════════════════════════════════════════════════
    ```

    **Rules**:
    - Parse `tasks/index.md` for task completion status
    - `- [x]` = completed (✓)
    - `- [ ]` = pending (○)
    - Mark just-completed task with `← JUST COMPLETED`
    - Calculate percentage: `(completed / total) * 100`
    - **If all complete**: Suggest `/apex:4-examine <folder>` instead

    ### Plan Mode
    - Skip dashboard (no task-level tracking)

13. **FINAL REPORT**: Summarize to user
    - Confirm task implementation complete
    - Highlight what was built
    - Show test results
    - **Task-by-Task Mode**: Progress dashboard already shown above
    - Suggest: `/apex:3-execute <folder>` for next task, or `/apex:4-examine` if all done

## Implementation Quality Rules

### Code Style
- **NO COMMENTS**: Use clear names instead (unless truly necessary)
- **MATCH PATTERNS**: Follow existing codebase conventions exactly
- **CLEAR NAMES**: Variables and functions self-document
- **MINIMAL CHANGES**: Only touch what's needed

### Scope Management
- **STRICTLY IN SCOPE**: Implement only what's in the current task
- **NO REFACTORING**: Don't improve unrelated code
- **NO EXTRAS**: Don't add unrequested features
- **ASK FIRST**: If scope seems wrong, clarify with user

### Error Handling
- **STOP ON FAILURE**: Don't proceed if something breaks
- **DEBUG PROPERLY**: Understand failures before fixing
- **UPDATE TASK**: Document learnings for future reference
- **ASK FOR HELP**: If blocked, consult user

## Task-by-Task Mode Example

### Reading task file
```markdown
# Task: Add JWT Token Validation Middleware

## Problem
We need to protect API routes by validating JWT tokens...

## Proposed Solution
Create middleware that extracts JWT from Authorization header...

## Dependencies
- None (can start immediately)

## Context
- Similar pattern exists in `src/api/auth.ts:45-67`
- Use jsonwebtoken library (already in dependencies)

## Success Criteria
- Middleware rejects invalid/expired tokens with 401
- Valid tokens attach user info to request
- Unit tests pass for valid/invalid/expired tokens
```

### Resulting todos (focused)
```
1. ⏳ Read existing pattern in src/api/auth.ts:45-67
2. ⏸ Create JWT validation middleware
3. ⏸ Add unit tests for valid/invalid/expired tokens
4. ⏸ Run typecheck and lint
5. ⏸ Update index.md and implementation.md
```

## Todo Management

**CRITICAL RULES**:
- Mark todos complete IMMEDIATELY when done
- Only ONE todo in_progress at a time
- Don't batch completions
- Update todos if task changes during implementation

## Execution Rules

- **ULTRA THINK**: Before every file change
- **ONE TASK AT A TIME**: Complete current task before moving to next (sequential mode)
- **PARALLEL WHEN POSSIBLE**: Use `3,4` or `--parallel` for independent tasks
- **FOLLOW PATTERNS**: Use analysis findings as guide
- **TEST AS YOU GO**: Validate continuously
- **STAY IN SCOPE**: No scope creep ever
- **READ FIRST**: Always use Read before Edit/Write
- **QUALITY > SPEED**: Correct implementation beats fast implementation
- **APPEND, DON'T OVERWRITE**: Always check if implementation.md exists first
- **VALIDATE DEPENDENCIES**: Never run tasks in parallel if they depend on each other

## Priority

Correctness > Completeness > Speed. Working code that follows patterns and passes tests.

## Usage Examples

```bash
# Execute next pending task (auto-detects from index.md)
/apex:3-execute 68-ai-template-creator

# Execute specific task by number
/apex:3-execute 68-ai-template-creator 3

# Execute with plan.md fallback (if no tasks/ folder)
/apex:3-execute 10-advent-won-prize-id-bug

# PARALLEL: Execute specific tasks simultaneously
/apex:3-execute 72-rename-feature 3,4

# PARALLEL: Execute 3 tasks at once
/apex:3-execute 72-rename-feature 3,4,5

# PARALLEL: Auto-detect parallelizable tasks from index.md
/apex:3-execute 72-rename-feature --parallel

# DRY-RUN: Preview what a task would do without executing
/apex:3-execute 68-ai-template-creator 3 --dry-run

# QUICK: Execute task with immediate typecheck/lint validation
/apex:3-execute 68-ai-template-creator 3 --quick
```

## Parallel Execution Example

Given this execution strategy in `index.md`:
```
Task 1 → Task 2 → [Task 3 ‖ Task 4] → Task 5 → Task 6
```

After completing Tasks 1 and 2:
```bash
# Option 1: Explicit parallel
/apex:3-execute feature-name 3,4

# Option 2: Auto-detect (will find Tasks 3,4 as next parallel group)
/apex:3-execute feature-name --parallel
```

Both options will launch 2 apex-executor agents simultaneously.

---

User: $ARGUMENTS
