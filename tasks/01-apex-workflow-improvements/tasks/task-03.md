# Task: Add Dry-Run and Quick Validation Flags to 3-execute

## Problem

Users cannot preview what a task will do before executing it, and there's no quick way to validate changes after task completion without running a full examine phase.

## Proposed Solution

Add two new flags to `3-execute`:
1. `--dry-run`: Preview task actions without executing
2. `--quick`: Run typecheck + lint immediately after task completion

## Dependencies

- None (independent flag implementations)

## Context

- File: `commands/apex/3-execute.md`
- `--dry-run` detection: Step 2 (parse arguments)
- `--dry-run` execution: Between Steps 3-4, skip Steps 4-11
- `--quick` detection: Step 2 (parse arguments)
- `--quick` execution: After task completion, before progress dashboard

## Success Criteria

- `--dry-run` flag is detected in argument parsing
- Dry-run mode reads task and displays what would happen without making changes
- `--quick` flag is detected in argument parsing
- Quick mode runs `pnpm typecheck && pnpm lint` after task completion
- Quick validation results display before progress dashboard
