---
description: Task creation - divide plan into small, actionable task files
argument-hint: <task-folder-path> [--yolo]
---

You are a task breakdown specialist. Transform implementation plans into small, focused task files.

**You need to ULTRA THINK about how to divide the work effectively.**

## Argument Parsing

Parse the argument for flags:
- `--yolo` flag → **YOLO MODE** (autonomous workflow - auto-continues to next phase)

## Workflow

1. **DETECT TASKS DIRECTORY**: Find correct path
   ```bash
   # Check which tasks directory exists (use /bin/ls to bypass eza alias)
   /bin/ls .claude/tasks 2>/dev/null || /bin/ls tasks 2>/dev/null
   ```
   - Use `.claude/tasks` for project directories
   - Use `tasks` only if running from `~/.claude` directory

2. **VALIDATE INPUT**: Verify task folder is ready
   - Check that `$TASKS_DIR/<task-folder>/` exists
   - Verify `plan.md` file is present
   - **CRITICAL**: If missing, instruct user to run `/apex:plan` first
   - **YOLO MODE**: If `--yolo` flag detected, ensure `$TASKS_DIR/<task-folder>/.yolo` file exists
     ```bash
     touch $TASKS_DIR/<task-folder>/.yolo
     ```

2. **READ PLAN**: Load implementation strategy
   - Read `$TASKS_DIR/<task-folder>/plan.md` completely
   - Identify all file changes and major implementation steps
   - Look for natural boundaries between tasks

3. **ULTRA THINK BREAKDOWN**: Plan task division strategy
   - **CRITICAL**: Think through how to divide work logically
   - Consider:
     - Dependencies between changes
     - Natural groupings (e.g., all auth-related changes)
     - Size balance (avoid huge tasks or tiny tasks)
     - Independent vs dependent work
   - **GOAL**: Create small, focused tasks that can be completed in 1-2 hours

4. **DIVIDE INTO TASKS**: Create task breakdown
   - **Task size**: Small enough to be focused, large enough to be meaningful
   - **Task scope**: Each task should have clear problem and solution
   - **Dependencies**: Note what must be done before each task
   - **NO CONCRETE STEPS**: Tasks describe WHAT and WHY, not HOW

5. **CREATE TASK FILES**: Write individual task files
   - Create `$TASKS_DIR/<task-folder>/tasks/` subdirectory
   - Create numbered task files: `task-01.md`, `task-02.md`, etc.
   - **CRITICAL**: Order tasks by dependencies (dependent tasks come after their prerequisites)
   - **Structure for each task file**:
     ```markdown
     # Task: [Clear, concise task name]

     ## Problem
     [What needs to be solved or implemented]

     ## Proposed Solution
     [High-level approach - WHAT to do, not HOW]

     ## Dependencies
     - Task #N: [Description] (if applicable)
     - External: [Any external dependencies like API docs]

     ## Context
     [Brief relevant information from analysis/plan]
     - Key files: `path/to/file.ts:line`
     - Patterns to follow: [Reference to similar code]

     ## Success Criteria
     - [What does "done" look like]
     - [Tests that should pass]
     ```

6. **CREATE INDEX**: Generate tasks overview
   - Create `$TASKS_DIR/<task-folder>/tasks/index.md`
   - List all tasks with status tracking
   - **CRITICAL**: Include explicit execution strategy with parallel notation
   - **Structure**:
     ```markdown
     # Tasks: [Task Folder Name]

     ## Overview
     [Brief description of the overall goal]

     ## Task List

     | Task | Name | Dependencies |
     |------|------|--------------|
     | 1 | [Task name] | None |
     | 2 | [Task name] | Task 1 |
     | 3 | [Task name] | Task 1 |
     | 4 | [Task name] | Tasks 2, 3 |

     - [ ] **Task 1**: [Name] - `task-01.md`
     - [ ] **Task 2**: [Name] - `task-02.md` (depends on Task 1)
     - [ ] **Task 3**: [Name] - `task-03.md` (depends on Task 1)
     - [ ] **Task 4**: [Name] - `task-04.md` (depends on Tasks 2, 3)

     ## Execution Strategy

     Task 1 → [Task 2 ‖ Task 3] → Task 4

     **Parallelization opportunity**: Tasks 2 and 3 can be executed simultaneously after Task 1 completes.

     ## Recommended Commands

     ```bash
     # Sequential execution
     /apex:3-execute [folder-name] 1
     /apex:3-execute [folder-name] 2
     /apex:3-execute [folder-name] 3
     /apex:3-execute [folder-name] 4

     # Parallel execution (after Task 1)
     /apex:3-execute [folder-name] 2,3

     # Auto-detect parallel tasks
     /apex:3-execute [folder-name] --parallel
     ```

     **Start with**: Task 1 - it has no dependencies.
     ```

7. **VERIFY QUALITY**: Check task breakdown
   - **All work covered**: Nothing from plan is missing
   - **Logical order**: Dependencies are respected
   - **Right size**: Tasks are small but meaningful
   - **Clear**: Each task is understandable standalone
   - **No HOW**: Tasks don't prescribe implementation details

8. **REPORT**: Summarize to user
   - Confirm number of tasks created
   - Show task list with dependencies table
   - **Show Execution Strategy** with parallel notation: `Task 1 → [Task 2 ‖ Task 3] → Task 4`
   - Highlight parallelization opportunities
   - **STANDARD MODE**: Suggest commands:
     - Sequential: `/apex:3-execute [folder] 1`
     - Parallel: `/apex:3-execute [folder] 2,3` or `/apex:3-execute [folder] --parallel`
     - Suggest starting with tasks that have no dependencies
   - **YOLO MODE**: Say "YOLO mode: Session will exit. Execute phase requires manual review - run `/apex:3-execute [folder]` to start." then **STOP IMMEDIATELY**. YOLO stops at execute phase for safety.

## Task Quality Guidelines

### Good Task Example
```markdown
# Task: Add JWT Token Validation Middleware

## Problem
We need to protect API routes by validating JWT tokens in incoming requests. Currently, routes are unprotected.

## Proposed Solution
Create middleware that extracts JWT from Authorization header, validates signature and expiration, and attaches user info to request context.

## Dependencies
- None (can start immediately)

## Context
- Similar pattern exists in `src/api/auth.ts:45-67`
- Use jsonwebtoken library (already in dependencies)
- Follow error handling pattern from `src/middleware/error.ts`

## Success Criteria
- Middleware rejects invalid/expired tokens with 401
- Valid tokens attach user info to request
- Unit tests pass for valid/invalid/expired tokens
```

### Bad Task Example
```markdown
# Task: Fix authentication

## Problem
Auth doesn't work

## Proposed Solution
Make it work

## Dependencies
None

## Context
In the auth files

## Success Criteria
Works
```

## Task File Rules

### What to Include
- **Clear problem statement**: What needs to be solved
- **High-level solution**: WHAT to build, not HOW
- **Dependencies**: What must be done first
- **Context**: Relevant files and patterns
- **Success criteria**: How to know when done

### What to AVOID
- **Concrete implementation steps**: No step-by-step instructions
- **Code snippets**: No actual code in task files
- **Technical details**: Just enough to understand, not to implement
- **Huge tasks**: If >2 hours of work, split further

## Size Guidelines

### Too Small (avoid)
- "Add import statement to file X"
- "Rename variable Y to Z"
- Single line changes

### Too Large (split up)
- "Implement entire authentication system"
- "Build user dashboard with all features"
- Tasks that touch >10 files

### Just Right
- "Add token validation middleware"
- "Create user profile API endpoint"
- "Implement password reset flow"

## Dependency Management

### Independent Tasks (can be parallel)
- Different features
- Different parts of codebase
- Different layers (frontend/backend)

### Dependent Tasks (must be sequential)
- Task B uses code from Task A
- Task B tests functionality from Task A
- Task B extends/modifies Task A's work

**CRITICAL**: Order tasks so dependencies come first

## Execution Rules

- **SMALL AND FOCUSED**: Each task should be completable in 1-2 hours
- **TEXT ONLY**: Simple markdown, easy to read
- **NO IMPLEMENTATION**: Describe WHAT and WHY, never HOW
- **LOGICAL ORDER**: Respect dependencies in numbering
- **CLEAR CONTEXT**: Reference analysis findings
- **TESTABLE**: Clear success criteria

## Priority

Clarity and Independence > Completeness. Small, clear, independent tasks beat comprehensive but complex ones.

---

User: $ARGUMENTS
