# Implementation: APEX Examine Skills + Live Browser Testing

## Overview
Enhanced the APEX workflow with React 19 pattern validation in `/apex:4-examine` and created a new `/apex:test-live` command for browser-based testing with GIF recording.

## Status: ✅ Complete
**Progress**: 2/2 tasks completed

## Task Status

| Task | Description | Status | Session |
|------|-------------|--------|---------|
| 1 | Enhance 4-examine.md with React 19/Next.js pattern validation | ✅ Complete | Session 1 |
| 2 | Create new test-live.md command for browser testing | ✅ Complete | Session 1 |

---

## Session Log

### Session 1 - 2025-12-29

**Task(s) Completed**: Tasks 1 & 2 - Pattern Validation + Test Live Command

#### Changes Made

**Task 1: Pattern Validation in `/apex:4-examine`**
- Updated frontmatter description to include pattern checks
- Added `--skip-patterns` flag for non-React projects
- Created new section `5C. PATTERN VALIDATION` with:
  - grep-based detection for Context.Provider, useContext(), useMemo/useCallback/memo
  - Clear output format showing violations by category
  - Blocking behavior with user options (fix, skip, proceed)
- Updated Results table in implementation.md template to include Patterns row
- Updated FINAL REPORT to include pattern validation status
- Added usage examples with new flag

**Task 2: New `/apex:test-live` Command**
- Created `commands/apex/test-live.md` (303 lines)
- Implements browser-based live testing using claude-in-chrome MCP
- Key features:
  - GIF recording with screenshot strategy (before/after each action)
  - 13-step workflow from context reading to final report
  - Folder structure for recordings (success/errors)
  - Integration with implementation.md
  - Error handling for common issues
- Flags: `--url=<url>` and `--no-gif`

#### Files Changed

**Modified Files:**
- `commands/apex/4-examine.md` - Added pattern validation step (5C), updated args, final report

**New Files:**
- `commands/apex/test-live.md` - New browser testing command with GIF recording

#### Test Results
- N/A (documentation changes only)

#### Notes
- Pattern validation is blocking by design per user's request
- Test-live command uses claude-in-chrome MCP (not Playwright) for GIF support
- Both features are additive and opt-in

---

### Session 2 - 2025-12-30

**Task(s) Completed**: Bug fix + Explore agent for test flows

#### Changes Made

**Bug Fix: GIF not copying to task folder**
- Issue: `gif_creator` downloads to browser's Downloads folder, not task folder
- Solution: Added explicit bash commands in step 11 to:
  - Create `recordings/success/` and `recordings/errors/` directories
  - Move GIF from `~/Downloads/` to task folder
  - Verify move succeeded

**Explore agent for test flow identification (`test-live.md`)**
- Added Option B in step 2: use `explore-codebase` agent to analyze implementation
- Agent identifies testable flows with steps and success criteria
- Reduces manual identification effort for complex features

#### Files Changed

**Modified Files:**
- `commands/apex/test-live.md` - Added:
  - Explicit bash commands for GIF move (step 11)
  - Explore agent option for test flow identification (step 2)

**Parallel test execution (`test-live.md`)**
- Added `--parallel` flag for concurrent test scenarios
- Uses `apex-executor` agents (Sonnet) instead of Snipper (Haiku)
- Each scenario runs on a separate browser tab
- GIF disabled in parallel mode (agents take screenshots instead)

#### Notes
- `explore-codebase` agent for test flow identification
- `apex-executor` agents for parallel test execution (Sonnet, more capable than Snipper)
- Pattern violations → user fixes manually with `/react19-patterns` skill
- Test failures → user fixes manually, GIF provides context

---

## Follow-up Tasks
- Test pattern validation on a real React 19 project
- Test live testing command with running dev server
- Consider adding ViewTransition pattern detection

## Technical Notes
- Skills cannot be programmatically invoked from slash commands
- Pattern detection uses grep instead of skill invocation
- GIF recording requires claude-in-chrome MCP extension

## Suggested Commit

```
feat(apex): add React 19 pattern validation and live browser testing

- Add step 5C to examine command for React 19/Next.js pattern detection
- Detect Context.Provider, useContext(), manual memoization anti-patterns
- Add --skip-patterns flag for non-React projects
- Create new /apex:test-live command for browser-based testing
- Support GIF recording with screenshot strategy for visual documentation
- Add recordings folder structure (success/errors) for test artifacts
- Add explicit bash commands to move GIF from Downloads to task folder
- Add explore-codebase agent option for test flow identification
- Add --parallel flag for concurrent test execution with apex-executor agents

Implements: APEX workflow improvements for React 19 projects
```
