# Task: Add Background Mode to 4-examine

## Problem

The examine phase runs diagnostics synchronously, blocking the user during build/typecheck/lint operations that can take significant time.

## Proposed Solution

Add `--background` flag that runs the diagnostic phase asynchronously:
- Background phase: discover commands, run build, run diagnostics, analyze errors
- Foreground phase: create fix areas, parallel fix, format, verify, update, report

## Dependencies

- None (independent of other tasks)

## Context

- File: `commands/apex/4-examine.md`
- Split Steps 2-5 into background phase (can use `run_in_background`)
- Steps 6-11 remain in foreground (needs file writes)
- Keep Snipper for Step 7 (fixes) - simple edits where Haiku is appropriate
- Add status messaging for background mode

## Success Criteria

- `--background` flag is detected in argument parsing
- Diagnostic steps (2-5) can run with `run_in_background: true`
- Status message shows "Validation launched in background"
- Suggests "Use /tasks to see status"
- Foreground phase proceeds automatically when diagnostics complete
