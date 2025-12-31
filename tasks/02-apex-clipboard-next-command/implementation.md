# Implementation: APEX Clipboard - Next Command Auto-Copy

## Overview
PostToolUse hook that automatically copies the next APEX workflow command to clipboard when writing APEX files (analyze.md, plan.md, tasks/index.md).

## Status: ✅ Complete
**Progress**: 1/1 tasks completed

## Task Status

| Task | Description | Status | Session |
|------|-------------|--------|---------|
| 1 | Create hook-apex-clipboard.ts and add to settings.json | ✅ Complete | Session 1 |

---

## Session Log

### Session 1 - 2025-12-29

**Task(s) Completed**: Task 1 - Hook implementation and configuration

#### Changes Made
- Created `hook-apex-clipboard.ts` with performance-optimized early-exit strategy
- Added hook entry to `settings.json` PostToolUse array
- Implemented intelligent plan complexity detection (< 6 files → execute, >= 6 files → tasks)

#### Files Changed

**New Files:**
- `scripts/hook-apex-clipboard.ts` - APEX clipboard hook (~110 lines)

**Modified Files:**
- `settings.json` - Added PostToolUse hook entry for APEX clipboard

#### Test Results
- Typecheck: ✓
- Lint: ✓
- Manual tests: ✓
  - analyze.md → `/apex:2-plan <folder>`
  - plan.md (simple) → `/apex:3-execute <folder>`
  - plan.md (complex) → `/apex:5-tasks <folder> (N files detected)`
  - tasks/index.md → `/apex:3-execute <folder>`
  - Non-APEX files → silent exit (fast path)
  - Failed writes → silent exit

#### Notes
- Performance: ~15ms for non-APEX files (spawn only), ~20ms for APEX files
- Uses early-exit pattern: regex on raw JSON before JSON.parse()
- pbcopy failure handled gracefully (silent exit)

---

## Technical Notes
- **Early-exit strategy**: Extracts `file_path` via regex before parsing JSON for performance
- **Intelligent routing**: For `plan.md`, counts `### \`` patterns to detect complexity
- **Threshold**: >= 6 file sections → suggests `/apex:5-tasks`, otherwise `/apex:3-execute`

## Suggested Commit

```
feat: add APEX clipboard hook for next command auto-copy

- Auto-copies next APEX command when writing analyze.md, plan.md, tasks/index.md
- Performance-optimized with early-exit for non-APEX files (~15ms overhead)
- Intelligent plan complexity detection (>= 6 files → /apex:5-tasks)
- Rich feedback via systemMessage ("📋 Copied: /apex:...")
```
