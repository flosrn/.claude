---
description: Execution phase - implement the plan step by step with ultra thinking
argument-hint: <task-folder-path> [task-number(s)] [--force-sonnet | --force-opus] [--yolo]
---

You are an implementation specialist. Execute plans precisely while maintaining code quality.

**You need to ULTRA THINK at every step.**

**⚠️ PATH**: Always use `./.claude/tasks/<folder>/` for file reads (NOT `tasks/<folder>/`).

## Argument Parsing

Parse the argument for flags:
- `--yolo` flag → **YOLO MODE** (arrived via automated workflow from analyze/plan phases)
- `--force-sonnet` flag → Override model selection to Sonnet
- `--force-opus` flag → Override model selection to Opus

**YOLO Detection**: Also check if `.yolo` file exists in task folder (created by previous phases).

## Workflow

1. **DETECT ENVIRONMENT**: Get the ABSOLUTE path for file reads
   ```bash
   ABSOLUTE_PATH="$(pwd)/.claude/tasks/<task-folder>" && \
   echo "📁 READ FROM: $ABSOLUTE_PATH" && \
   /bin/ls -la "$ABSOLUTE_PATH/"
   ```

   **⚠️ Use the FULL path from output (starts with /Users/...) for Read calls.**

2. **VALIDATE INPUT**: Verify task folder is ready
   - Check output shows `analyze.md` exists
   - If missing, instruct user to run `/apex:1-analyze` first
   - **YOLO MODE**: If `--yolo` flag OR `.yolo` file exists in folder:
     - Display: `🔄 YOLO Mode: Automatic execution from previous phases`
     - Delete the `.yolo` file to stop the chain: `rm -f ./.claude/tasks/<folder>/.yolo`
     - YOLO stops here (execution is the final automated phase)

3. **DETECT EXECUTION MODE**: Check for individual task files and determine execution strategy
   - Check if `./.claude/tasks/<task-folder>/tasks/` directory exists
   - If `tasks/` exists AND contains `task-XX.md` files → **USE TASK-BY-TASK MODE**
   - If `tasks/` does NOT exist → **USE PLAN MODE** (fallback to plan.md)

   **Parse argument for execution type**:
   - `--force-sonnet` flag → **Override Smart Model Selection** (always use Sonnet)
   - `--force-opus` flag → **Override Smart Model Selection** (always use Opus)
   - Comma-separated numbers (e.g., `3,4`) → **PARALLEL EXPLICIT MODE**
   - Single number (e.g., `3`) → **SEQUENTIAL MODE** (single task)
   - No number → **AUTO MODE** (detect parallelizable tasks from `index.md`)

   **Auto-parallel detection** (when no task number provided):
   - Parse `index.md` dependency table to find ALL ready-to-execute tasks
   - If 1 task ready → Sequential execution
   - If 2+ tasks ready → Auto-parallel execution
   - This is the DEFAULT behavior (no flag needed)

3. **LOAD CONTEXT**: Read planning artifacts based on mode

   ### Task-by-Task Mode (PREFERRED)
   - Read `./.claude/tasks/<task-folder>/analyze.md` for overall context
   - Read `./.claude/tasks/<task-folder>/tasks/index.md` to understand:
     - Complete task list with dependencies
     - Execution order (which tasks can be parallel)
     - Overall progress tracking

   #### Sequential Mode (single task specified)
   - **IF specific task number provided** (e.g., `/apex:3-execute feature-name 3`):
     - Read ONLY `./.claude/tasks/<task-folder>/tasks/task-03.md`
     - Focus exclusively on that single task

   #### Parallel Explicit Mode (e.g., `3,4` or `3,4,5`)
   - Parse comma-separated task numbers from argument
   - Read ALL specified task files (e.g., `task-03.md`, `task-04.md`)
   - **VALIDATE DEPENDENCIES**: Check index.md to ensure:
     - All specified tasks have their dependencies completed
     - Tasks don't depend on each other
   - If dependency conflict: WARN user and suggest correct order
   - → **GO TO STEP 3B: PARALLEL EXECUTION**

   #### Auto Mode (no task number - DEFAULT)
   **Automatic parallelization based on `index.md` dependency table.**

   **Step 1**: Parse dependency table from `index.md`
   - Look for `| Task | Name | Dependencies |` table
   - Extract task numbers and their dependencies

   **Step 2**: Identify ready tasks
   - Find ALL incomplete tasks (`- [ ]` in task list)
   - For each incomplete task, check if ALL its dependencies are complete (`- [x]`)
   - Tasks with NO dependencies or ALL dependencies complete → **READY**

   **Step 3**: Determine execution strategy
   - If 1 task ready → Execute sequentially (read single task file)
   - If 2+ tasks ready → Execute in parallel (→ **GO TO STEP 3B**)

   ```bash
   # Find ready tasks (dependencies satisfied)
   # Note: Use /usr/bin/grep to bypass rg alias
   /usr/bin/grep -E "^\| [0-9]+ \|" "./.claude/tasks/$FOLDER/tasks/index.md"
   ```

   ### Plan Mode (FALLBACK)
   - Read `./.claude/tasks/<task-folder>/analyze.md` for context
   - Read `./.claude/tasks/<task-folder>/plan.md` for implementation steps
   - Note dependencies and execution order

---

## 3A. SMART MODEL SELECTION

**CRITICAL**: Before launching any agent, analyze task complexity to select the optimal model.

### Skip Conditions
- If `--force-sonnet` flag → Use Sonnet, skip analysis
- If `--force-opus` flag → Use Opus, skip analysis
- Otherwise → Perform complexity analysis below

### Complexity Scoring

For EACH task file, calculate a complexity score:

| Criterion | Points | Detection Method |
|-----------|--------|------------------|
| Modifies **existing** files | +2 | Look for files without "(new)" in plan/task |
| Modifies **3+ existing** files | +1 | Count files without "(new)" |
| Contains "integration" or "integrate" | +2 | Grep task file |
| Contains "API", "SDK", "callback" | +1 | Grep task file |
| Contains "refactor" or "migration" | +1 | Grep task file |
| Contains "breaking change" | +2 | Grep task file |
| Has 3+ dependencies | +1 | Check Dependencies section |
| Mentions gotchas/risks/warnings | +1 | Look for ⚠️ or "gotcha" or "risk" |

### Model Selection Threshold

| Score | Model | Reasoning |
|-------|-------|-----------|
| 0-2 | **Sonnet** | Simple task, clear patterns, new files |
| 3-4 | **Opus** | Moderate complexity, some integration |
| 5+ | **Opus** | High complexity, critical integration |

### Display Selection

Before launching agent(s), display:

```
┌─────────────────────────────────────────────────┐
│ MODEL SELECTION                                 │
├─────────────────────────────────────────────────┤
│ Task 3: Add token tracking                      │
│ Score: 4/10 → Opus                              │
│ Reasons:                                        │
│   • Modifies existing files (+2)                │
│   • Contains "integration" (+2)                 │
├─────────────────────────────────────────────────┤
│ Task 4: Create UI component                     │
│ Score: 1/10 → Sonnet                            │
│ Reasons:                                        │
│   • New files only                              │
│   • Clear patterns to follow                    │
└─────────────────────────────────────────────────┘
```

### Store Selection

Remember the selected model for each task:
- `task_models = { 3: "opus", 4: "sonnet", ... }`
- Use this mapping when launching agents in step 3B or sequential execution

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

**CRITICAL**: Use the model selected in step 3A for each task.

Example for tasks 3 (Opus) and 4 (Sonnet):

```
Use the Task tool TWICE in the same message:

Task 1: subagent_type="apex-executor", model="opus", description="Execute Task 3", prompt="[Task 3 prompt]"
Task 2: subagent_type="apex-executor", model="sonnet", description="Execute Task 4", prompt="[Task 4 prompt]"
```

**IMPORTANT**:
- Send ALL Task calls in ONE message (not sequentially)
- This enables true parallel execution
- Each agent works independently
- Use `subagent_type: "apex-executor"` for full task execution capability
- **Use `model` parameter from Smart Model Selection** (step 3A)
- If `--force-sonnet`: all tasks use `model="sonnet"`
- If `--force-opus`: all tasks use `model="opus"`

### Step 3: Wait for All Agents

- All agents run concurrently
- Wait for ALL to complete before proceeding
- Collect results from each agent

### Step 4: Aggregate Results

After all agents complete:
1. Collect files changed from each agent
2. Merge any conflicts (should be rare if tasks are independent)
3. Run global typecheck: `pnpm run typecheck`
4. Run global lint: `pnpm run lint`
5. If errors: fix them or report to user

### Step 5: Update Documentation

- Update `index.md`: Mark ALL completed tasks as `- [x]`
- Update `implementation.md`:
  - In Session entry, list ALL tasks completed: "Tasks 3, 4 - [Names]"
  - Note: "Executed in parallel"

### Then → GO TO STEP 11 (PROGRESS DASHBOARD)

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

8. **CODE SIMPLIFICATION**: Polish the implementation

   After completing task implementation, launch `code-simplifier` agent on modified files:
   - Use Task tool with `subagent_type: "code-simplifier:code-simplifier"` and `model: "opus"`
   - Agent reviews for clarity, consistency, maintainability (preserves functionality)

   **Skip if**: config-only changes or trivial fixes.

9. **UPDATE TASK STATUS**: Mark completion in index.md

    ### Task-by-Task Mode
    - Edit `./.claude/tasks/<task-folder>/tasks/index.md`
    - Change the completed task from `- [ ]` to `- [x]`
    - This tracks progress across sessions

    ### Plan Mode
    - Skip this step (no index.md exists)

10. **UPDATE IMPLEMENTATION.MD**: Document work done

    **CRITICAL**: Check if `implementation.md` already exists
    - If **EXISTS** → **APPEND** a new session entry (don't overwrite!)
    - If **NOT EXISTS** → **CREATE** with full template

    ### If `implementation.md` does NOT exist (CREATE)

    Create `./.claude/tasks/<task-folder>/implementation.md` with this template:

    ```markdown
    # Implementation: [Feature Name]

    ## Status: 🔄 In Progress
    **Progress**: X/Y tasks completed

    ---

    ## Session Log

    ### Session 1 - [YYYY-MM-DD]

    **Task(s) Completed**: Task N - [Name]

    **Files Changed:**
    - `path/to/file.ts` - [What was done]

    **Notes:**
    - [Deviations, discoveries, issues]

    ---

    ## Suggested Commit

    ```
    feat: [kebab-name to sentence]

    - [Key changes]
    ```
    ```

    ### If `implementation.md` EXISTS (APPEND)

    1. **Read the existing file**
    2. **Update the Status section**:
       - Change progress count (X/Y tasks)
       - If all complete, change status to `## Status: ✅ Complete`
    3. **APPEND a new Session entry** at the end of "## Session Log":
       ```markdown
       ### Session N - [YYYY-MM-DD]

       **Task(s) Completed**: Task X - [Name]

       **Files Changed:**
       - [List files with descriptions]

       **Notes:**
       - [Session-specific notes]
       ```
    4. **Update Suggested Commit** when ALL tasks complete

11. **SHOW PROGRESS DASHBOARD**: Display visual progress summary

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

12. **FINAL REPORT**: Summarize to user
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
- **AUTO-PARALLEL**: System automatically detects and runs independent tasks in parallel
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
# AUTO MODE: Detects next tasks and parallelizes if possible
/apex:3-execute 68-ai-template-creator

# Execute specific task by number
/apex:3-execute 68-ai-template-creator 3

# Explicit parallel: Execute specific tasks simultaneously
/apex:3-execute 72-rename-feature 3,4

# Plan mode fallback (if no tasks/ folder)
/apex:3-execute 10-advent-won-prize-id-bug

# Force model override
/apex:3-execute 68-ai-template-creator 5 --force-opus
/apex:3-execute 68-ai-template-creator 2 --force-sonnet
```

## Auto-Parallel Example

Given this dependency structure in `index.md`:
```
Task 1 → Task 2 → [Task 3 ‖ Task 4] → Task 5
```

After Tasks 1-2 complete, running:
```bash
/apex:3-execute feature-name
```
Will automatically detect Tasks 3 & 4 as parallelizable and launch 2 agents.

---

User: $ARGUMENTS
