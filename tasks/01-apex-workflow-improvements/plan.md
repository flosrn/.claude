# Implementation Plan: APEX Workflow Improvements

## Overview

Enhance the APEX workflow with 14 improvements across 4 phases:
1. **Agent Infrastructure** - Create dedicated `apex-executor` agent as foundation
2. **Background Agents** - Enable async exploration and validation
3. **UX Improvements** - Progress visibility, shortcuts, and validation options
4. **New Commands** - `/apex:status` and `/apex:next` for better ergonomics

The implementation follows dependency order: agent creation → command updates → new commands.

## Dependencies

**External Dependencies:**
- Claude Code 2.0.60+ (for `run_in_background` support in Task tool)
- Existing agents: `Snipper`, `explore-codebase`, `explore-docs`, `websearch`
- Existing hooks: `SessionStart`, `Stop`

**Internal Dependencies:**
- `apex-executor` agent must be created before updating `3-execute.md`
- `3-execute.md` updates must complete before `/apex:next` can use the new agent

---

## Phase 1: Agent Infrastructure

### `agents/apex-executor.md` (NEW FILE)

**Purpose**: Replace Snipper (Haiku) with a capable agent (Sonnet) for complex task execution.

- Action: Create new agent file with YAML frontmatter
  - Set `name: apex-executor`
  - Set `model: sonnet` (capable model for complex tasks)
  - Set `permissionMode: acceptEdits` (same as Snipper)
  - Set `description` to explain task execution purpose

- Action: Define agent workflow in markdown body
  - Step 1: Read the task file completely
  - Step 2: Read relevant context files from task's Context section
  - Step 3: Implement the solution following existing patterns
  - Step 4: Run validation (`pnpm typecheck && pnpm lint`)
  - Step 5: Update `index.md` to mark task complete
  - Step 6: Add session entry to `implementation.md`
  - Step 7: Report changes made and validation results

- Action: Add execution rules
  - Follow existing code patterns exactly
  - Make minimal changes to achieve goal
  - Never add features not in the task
  - Stop on errors and report to caller

- Pattern: Follow `snipper.md` structure but with Sonnet model and expanded workflow

---

## Phase 2: Core Command Updates

### `commands/apex/3-execute.md`

**Improvement 4: Progress Dashboard (Priority High)**

- Action: Add progress display after completing each task
  - Location: Before Step 12 (FINAL REPORT), add Step 11.5
  - Read `tasks/index.md` and count completed vs total tasks
  - Display visual progress with checkmarks and pending indicators
  - Show "Next:" suggestion with the command to run next task

- Action: Define dashboard format
  ```
  ══════════════════════════════════════════════════
  PROGRESS: X/Y tasks completed (N%)
  ══════════════════════════════════════════════════
  ✓ Task 1: [Name]
  ✓ Task 2: [Name] ← JUST COMPLETED
  ○ Task 3: [Name]
  ○ Task 4: [Name]

  Next: /apex:3-execute <folder> 3
  ══════════════════════════════════════════════════
  ```

**Improvement 5: Dry-Run Mode (Priority High)**

- Action: Add `--dry-run` flag detection in workflow Step 2
  - Parse argument for `--dry-run` flag presence
  - If present, set `DRY_RUN_MODE = true`

- Action: Add dry-run execution path
  - Location: Between Step 3 (LOAD CONTEXT) and Step 4 (CREATE TODO LIST)
  - If `DRY_RUN_MODE`:
    - Read the task file(s)
    - Analyze what actions would be taken
    - Display preview without executing
    - Exit with message "Run without --dry-run to execute"
  - Skip Steps 4-11 in dry-run mode

**Improvement 8: Quick Validation (Priority Medium)**

- Action: Add `--quick` flag detection
  - Parse argument for `--quick` flag
  - If present, run `pnpm typecheck && pnpm lint` immediately after task completion
  - Display results inline before progress dashboard

**Improvement 7: Auto-Detect Parallel Tasks (Priority Medium)**

- Action: Enhance parallel auto-detect logic in Step 2
  - Location: "Parallel Auto-Detect Mode" section
  - Current: Only looks for `[Task X ‖ Task Y]` notation
  - Enhance: Also check dependency table in index.md
  - Find all incomplete tasks whose dependencies are ALL complete
  - If multiple tasks qualify, treat them as parallel candidates
  - Propose parallel execution to user

**Improvement 10: Commit Template (Priority Low)**

- Action: Add commit message template to implementation.md updates
  - Location: Step 11 (UPDATE IMPLEMENTATION.MD)
  - When updating implementation.md, add "Suggested Commit" section
  - Template:
    ```markdown
    ## Suggested Commit

    ```
    feat: [Feature name from task folder]

    - [Summary of changes from session log]

    Implements: #issue-number (if applicable)
    ```
    ```

**Improvement 13: Use apex-executor Agent (Priority High)**

- Action: Replace Snipper with apex-executor in parallel execution
  - Location: Step 3B, substep "Step 2: Launch Parallel Agents"
  - Change `subagent_type: "Snipper"` to `subagent_type: "apex-executor"`
  - Update description to reflect new agent capabilities

---

### `commands/apex/1-analyze.md`

**Improvement 1: Background Mode (Priority High)**

- Action: Add `--background` flag detection
  - Parse argument for `--background` flag
  - If present, launch agents with `run_in_background: true`

- Action: Modify Step 3 (LAUNCH PARALLEL ANALYSIS)
  - If `--background` mode:
    - Launch all three agents with `run_in_background: true`
    - Immediately after launching, proceed to ask clarifying questions
    - Use `TaskOutput` to check agent status periodically
    - When agents complete, integrate findings with user answers

- Action: Add interactive clarification loop
  - While agents run, use AskUserQuestion to clarify requirements
  - Example questions: "Which providers?", "Existing auth to extend?", "Scope boundaries?"
  - Store answers for synthesis after agents complete

- Action: Modify Step 4 (SYNTHESIZE FINDINGS)
  - Include user clarifications in the analysis
  - Add "User Clarifications" section to analyze.md template

**Improvement 3: Quick Summary Template (Priority High)**

- Action: Update analyze.md template in Step 5
  - Add "## Quick Summary (TL;DR)" section at the TOP of the template
  - Content includes:
    - Key files to modify (bulleted list)
    - Patterns to follow (1-2 examples with file:line)
    - Dependencies (blocking or none)
    - Estimation (task count, time range)

---

### `commands/apex/4-examine.md`

**Improvement 2: Background Mode (Priority High)**

- Action: Add `--background` flag detection
  - Parse argument for `--background` flag
  - If present, run diagnostic phase in background

- Action: Split workflow into foreground and background phases
  - **Background phase** (can use `run_in_background`):
    - Step 2: Discover commands
    - Step 3: Run build
    - Step 4: Run diagnostics
    - Step 5: Analyze errors
  - **Foreground phase** (needs file writes):
    - Step 6-7: Create fix areas and parallel fix
    - Step 8-11: Format, verify, update, report

- Action: Add status messaging for background mode
  - Display: "Validation launched in background"
  - Suggest: "Use /tasks to see status"
  - When complete, proceed to foreground phase automatically

- Note: Keep Snipper for Step 7 (fixes) - these are simple edits where Haiku is appropriate

---

## Phase 3: New Commands

### `commands/apex/next.md` (NEW FILE)

**Improvement 6 + 12: Quick Next Task Execution (Priority Medium)**

- Action: Create new command file with YAML frontmatter
  - Set `description: "Execute the next pending task automatically"`
  - Set `argument-hint: "[task-folder-path]"` (optional)

- Action: Define workflow
  - Step 1: Find most recent task folder
    - If argument provided, use that folder
    - If not, list `.claude/tasks/` and find most recently modified folder
  - Step 2: Read `tasks/index.md` in that folder
  - Step 3: Find first incomplete task (`- [ ]`)
  - Step 4: Launch `apex-executor` agent with that task
  - Step 5: Report result when agent completes

- Action: Add smart folder detection
  - Track "current" task folder from recent commands
  - Allow `/apex:next` with no arguments for convenience

---

### `commands/apex/status.md` (NEW FILE)

**Improvement 14: Status Overview Command (Priority Low)**

- Action: Create new command file with YAML frontmatter
  - Set `description: "Show status overview of task folder"`
  - Set `argument-hint: "[task-folder-path]"`

- Action: Define workflow
  - Step 1: Find task folder (argument or auto-detect)
  - Step 2: Check what files exist:
    - `analyze.md` - exists/not exists
    - `plan.md` - exists/not exists
    - `tasks/` directory - exists/not exists
    - `tasks/index.md` - parse completion status
    - `implementation.md` - exists/not exists

- Action: Generate visual status report
  ```
  📊 Status: [folder-name]
  ├── analyze.md ✓ (X insights found)
  ├── plan.md ✓ (Y file changes planned)
  ├── tasks/
  │   ├── index.md ✓
  │   ├── task-01.md ✓ completed
  │   ├── task-02.md ✓ completed
  │   ├── task-03.md ○ pending
  │   └── task-04.md ○ pending
  └── implementation.md ✓ (2 sessions)

  📋 Progress: 2/4 tasks (50%)

  🔜 Next: /apex:3-execute [folder] 3
  ```

- Action: Suggest next action based on current state
  - If no analyze.md: suggest `/apex:1-analyze`
  - If no plan.md: suggest `/apex:2-plan`
  - If no tasks/: suggest `/apex:5-tasks` or `/apex:3-execute`
  - If tasks pending: suggest `/apex:3-execute` or `/apex:next`
  - If all complete: suggest `/apex:4-examine`

---

## Phase 4: Polish & Notifications

### `settings.json`

**Improvement 9: System Notification (Priority Low)**

- Action: Modify the `Stop` hook configuration
  - Current: plays sound on completion
  - Add: macOS notification for background task completion
  - Command: `osascript -e 'display notification "APEX task completed" with title "Claude Code"'`

- Consider: Only trigger for background tasks (may need hook condition)

---

## Testing Strategy

### Manual Testing for Each File

**agents/apex-executor.md:**
- Launch via Task tool and verify it executes a test task
- Confirm typecheck/lint runs automatically
- Verify index.md and implementation.md get updated

**commands/apex/3-execute.md:**
- Test `--dry-run` flag shows preview without changes
- Test `--quick` flag runs validation after task
- Test progress dashboard displays correctly
- Test parallel execution uses apex-executor

**commands/apex/1-analyze.md:**
- Test `--background` flag launches agents asynchronously
- Verify clarifying questions appear while agents run
- Confirm Quick Summary appears at top of analyze.md

**commands/apex/4-examine.md:**
- Test `--background` flag runs diagnostics async
- Verify foreground phase fixes errors correctly

**commands/apex/next.md:**
- Test auto-detection of task folder
- Test execution of next pending task

**commands/apex/status.md:**
- Test visual output format
- Test all status scenarios (no files, partial, complete)

---

## Documentation

### Update README or CLAUDE.md

- Document new command options: `--background`, `--dry-run`, `--quick`
- Document new commands: `/apex:next`, `/apex:status`
- Add usage examples for each new feature

---

## Rollout Considerations

**Breaking Changes:**
- None - all changes are additive or opt-in via flags

**Feature Flags:**
- `--background` is opt-in, default behavior unchanged
- `--dry-run` is opt-in, default behavior unchanged
- `--quick` is opt-in, default behavior unchanged

**Migration:**
- apex-executor replaces Snipper in parallel mode
- Snipper continues to be used in 4-examine for simple fixes
- No changes required to existing task folders

**Backward Compatibility:**
- All existing APEX workflows continue to work unchanged
- New features are accessible via optional flags

---

## File Summary

| File | Action | Priority |
|------|--------|----------|
| `agents/apex-executor.md` | **CREATE** | Phase 1 |
| `commands/apex/3-execute.md` | MODIFY | Phase 2 |
| `commands/apex/1-analyze.md` | MODIFY | Phase 2 |
| `commands/apex/4-examine.md` | MODIFY | Phase 2 |
| `commands/apex/next.md` | **CREATE** | Phase 3 |
| `commands/apex/status.md` | **CREATE** | Phase 3 |
| `settings.json` | MODIFY | Phase 4 |

**Estimated Effort:** 3-4 hours total across all phases
