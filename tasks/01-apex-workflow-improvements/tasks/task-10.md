# Task: Create /apex:status Command

## Problem

Users have no quick way to see the overall status of a task folder - what phases are complete, how many tasks are done, and what to do next.

## Proposed Solution

Create `/apex:status` command that:
1. Shows visual tree of all APEX artifacts (analyze.md, plan.md, tasks/, implementation.md)
2. Displays task completion progress
3. Suggests the next action based on current state

## Dependencies

- None (independent new command)

## Context

- New file: `commands/apex/status.md`
- YAML frontmatter with description and argument-hint
- Check existence and parse content of: analyze.md, plan.md, tasks/, tasks/index.md, implementation.md
- Visual output uses tree characters (├──, └──)
- Smart suggestions based on what's missing/incomplete

## Success Criteria

- Command file exists at `commands/apex/status.md`
- Valid YAML frontmatter with description
- Visual tree shows all APEX artifacts with status indicators
- Progress shows X/Y tasks (N%) when tasks exist
- Suggests appropriate next command based on state:
  - No analyze.md → suggest /apex:1-analyze
  - No plan.md → suggest /apex:2-plan
  - No tasks/ → suggest /apex:5-tasks or /apex:3-execute
  - Tasks pending → suggest /apex:3-execute or /apex:next
  - All complete → suggest /apex:4-examine
