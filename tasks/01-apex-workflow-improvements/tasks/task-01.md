# Task: Create apex-executor Agent

## Problem

The current APEX workflow uses `Snipper` (Haiku model) for parallel task execution, but Haiku lacks the capability for complex multi-step tasks that require reading context, implementing solutions, running validation, and updating multiple tracking files.

## Proposed Solution

Create a new dedicated agent `apex-executor` that uses Sonnet model and has a comprehensive workflow for:
- Reading task files and context
- Implementing solutions following existing patterns
- Running validation (typecheck + lint)
- Updating `index.md` with task completion
- Logging session to `implementation.md`

## Dependencies

- None (foundation task - must complete first)

## Context

- Pattern to follow: `agents/snipper.md` structure
- Agent YAML frontmatter should include: `name`, `model: sonnet`, `permissionMode: acceptEdits`, `description`
- Workflow should be detailed markdown in body
- Key difference from Snipper: more capable model, expanded workflow with validation and documentation steps

## Success Criteria

- Agent file exists at `agents/apex-executor.md`
- YAML frontmatter is valid with correct model specification
- Workflow includes all 7 steps (read task, read context, implement, validate, update index, log session, report)
- Execution rules emphasize minimal changes and stopping on errors
