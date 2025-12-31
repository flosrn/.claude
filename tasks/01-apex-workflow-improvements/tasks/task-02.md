# Task: Add Progress Dashboard to 3-execute

## Problem

After completing a task, users have no visibility into overall progress. They must manually check `index.md` to understand how many tasks remain and what to run next.

## Proposed Solution

Add a visual progress dashboard that displays automatically after each task completion, showing:
- Completed vs total task count with percentage
- Visual list with checkmarks for completed and circles for pending
- Explicit "Next:" suggestion with the command to run

## Dependencies

- None (can work with or without apex-executor)

## Context

- File: `commands/apex/3-execute.md`
- Location: Add as Step 11.5, before FINAL REPORT (Step 12)
- Dashboard format specified in plan with box-drawing characters
- Must read and parse `tasks/index.md` for completion status

## Success Criteria

- Progress dashboard displays after task completion
- Shows accurate count of completed/total tasks
- Visually distinguishes completed (✓) from pending (○) tasks
- Highlights just-completed task with indicator
- Shows "Next:" command suggestion for the next pending task
