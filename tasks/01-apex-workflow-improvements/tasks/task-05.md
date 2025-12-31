# Task: Add Commit Template to Implementation Log

## Problem

After completing tasks, users manually craft commit messages. There's no suggested template based on what was actually changed during the session.

## Proposed Solution

When updating `implementation.md`, add a "Suggested Commit" section with a pre-formatted conventional commit message template based on the task folder name and session changes.

## Dependencies

- None (independent enhancement)

## Context

- File: `commands/apex/3-execute.md`
- Location: Step 11 (UPDATE IMPLEMENTATION.MD)
- Template format:
  ```
  feat: [Feature name from task folder]

  - [Summary of changes from session log]

  Implements: #issue-number (if applicable)
  ```

## Success Criteria

- Implementation.md updates include "Suggested Commit" section
- Commit message follows conventional commits format
- Feature name derived from task folder name
- Summary reflects actual changes made in session
