# Task: Create /apex:next Command

## Problem

Running the next task requires knowing the task folder path and task number. Users must manually check `index.md` to find the next pending task.

## Proposed Solution

Create `/apex:next` command that:
1. Auto-detects the most recent task folder (or uses provided path)
2. Finds the first incomplete task in `index.md`
3. Launches apex-executor agent to execute that task

## Dependencies

- Task 1: apex-executor agent must exist

## Context

- New file: `commands/apex/next.md`
- YAML frontmatter with description and optional argument-hint
- Workflow: find folder → read index.md → find first `- [ ]` → launch agent
- Should work with no arguments for convenience
- Auto-detect: list `.claude/tasks/` and find most recently modified folder

## Success Criteria

- Command file exists at `commands/apex/next.md`
- Valid YAML frontmatter with description
- Auto-detects task folder when no argument provided
- Correctly identifies first incomplete task from index.md
- Launches apex-executor with the identified task
- Reports result when agent completes
