# Implementation: APEX Workflow Consolidation

## Overview
Consolidate 6 improvement axes for the APEX workflow system, simplifying the codebase by removing legacy compatibility patterns and enhancing functionality.

## Status: ✅ Complete
**Progress**: 5/5 tasks completed

## Task Status

| Task | Description | Status | Session |
|------|-------------|--------|---------|
| 1 | Hardcode TASKS_DIR across all commands | ✅ Complete | Session 1 |
| 2 | Rename 5-demo to 5-browser-test | ✅ Complete | Session 2 |
| 3 | Add automatic port detection | ✅ Complete | Session 4 |
| 4 | Enhance brainstorm interview depth | ✅ Complete | Session 2 |
| 5 | Add documentation cross-links | ✅ Complete | Session 3 |

---

## Session Log

### Session 1 - 2026-01-05

**Task(s) Completed**: Task 1 - Hardcode TASKS_DIR

#### Changes Made
- Replaced auto-detection logic with hardcoded `TASKS_DIR="./.claude/tasks"` across all 10 APEX command files
- Removed unnecessary comments about "Remember the TASKS_DIR" and legacy directory explanations
- Simplified bash blocks by eliminating conditional logic
- Updated documentation examples in handoff.md to use `$TASKS_DIR` variable

#### Files Changed

**Modified Files:**
- `commands/apex/1-analyze.md` - Replaced 2 TASKS_DIR auto-detection blocks (lines 27-29, 57-60)
- `commands/apex/2-plan.md` - Replaced TASKS_DIR block (line 17-20)
- `commands/apex/3-execute.md` - Replaced TASKS_DIR block (line 12-20)
- `commands/apex/4-examine.md` - Replaced TASKS_DIR block (line 35-43)
- `commands/apex/5-demo.md` - Replaced TASKS_DIR block (line 19-22)
- `commands/apex/tasks.md` - Replaced TASKS_DIR block (line 17-20)
- `commands/apex/handoff.md` - Replaced TASKS_DIR block (line 22-27) + updated doc examples (lines 227-256)
- `commands/apex/next.md` - Replaced TASKS_DIR block (line 10-13)
- `commands/apex/status.md` - Replaced TASKS_DIR block (line 10-13)

#### Test Results
- Typecheck: N/A (markdown files)
- Lint: N/A (markdown files)
- Manual verification: ✓ All 10 files now use consistent `TASKS_DIR="./.claude/tasks"`

#### Notes
- The old auto-detection pattern `TASKS_DIR=$(if [ -d "tasks" ] && [ "$(basename $(pwd))" = ".claude" ]; then echo "tasks"; else echo ".claude/tasks"; fi)` was designed for legacy compatibility with a `tasks/` folder in `~/.claude`
- This legacy structure is now deprecated - all projects use `./.claude/tasks`
- The hardcoded path simplifies the codebase and reduces cognitive overhead

---

### Session 2 - 2026-01-05

**Task(s) Completed**: Tasks 2 & 4 (executed in parallel)

**Execution Mode**: Parallel via `--parallel` flag (Opus for Task 2, Sonnet for Task 4)

#### Task 2: Rename 5-demo to 5-browser-test

**Changes Made:**
- Renamed file via `git mv` to preserve history
- Updated description line and 6 self-references in the renamed file
- Updated cross-references in CLAUDE.md, overview.md, 4-examine.md

**Files Changed:**
- `commands/apex/5-demo.md` → `commands/apex/5-browser-test.md` (renamed)
- `commands/apex/5-browser-test.md` - Updated description and self-references
- `commands/apex/CLAUDE.md` - Updated quick reference table
- `commands/apex/overview.md` - Updated 4 references (table, section, examples, related docs)
- `commands/apex/4-examine.md` - Updated next step suggestion

**Validation:**
- Grep for "5-demo" returns no matches ✓
- Git history preserved via `git mv` ✓

#### Task 4: Enhance brainstorm interview depth

**Changes Made:**
- Removed question limit (was "2-4 questions", now "interview until complete")
- Added continuation loop: ask 2-3 questions per round, wait for responses, continue until user signals satisfaction
- Enhanced question quality guidance with deeper technical/UX examples (7 total, up from 3)
- Added FORBIDDEN questions section to prevent project management questions

**Files Changed:**
- `commands/apex/handoff.md` - Enhanced Step 3c: GATHER CLARIFICATIONS (lines 101-148)
  - Expanded ULTRA THINK analysis to include technical gaps, UX implications, tradeoffs
  - Added 4-step continuation loop algorithm
  - Added FORBIDDEN questions section with 5 examples and rationale

**Validation:**
- Step 3d (SYNTHESIZE & CONFIRM) unchanged as required ✓

#### Test Results
- Typecheck: N/A (markdown files)
- Lint: N/A (markdown files)
- Manual verification: ✓ All references updated, no orphaned "5-demo" strings

#### Notes
- Parallel execution reduced total time by running independent tasks simultaneously
- Task 2 used Opus (complexity score 3: modifies 3+ existing files)
- Task 4 used Sonnet (complexity score 2: single file modification)
- Both tasks share dependency on Task 1 but don't depend on each other

---

### Session 3 - 2026-01-05

**Task(s) Completed**: Task 5 - Add documentation cross-links

#### Changes Made
- Added bidirectional cross-links between CLAUDE.md and overview.md
- CLAUDE.md: Added reference to overview.md after title (line 5)
- overview.md: Added CLAUDE.md as first item in Related Documentation section (line 476)

#### Files Changed

**Modified Files:**
- `commands/apex/CLAUDE.md` - Added blockquote link to overview.md
- `commands/apex/overview.md` - Added CLAUDE.md to Related Documentation list
- `tasks/14-apex-workflow-consolidation/tasks/index.md` - Marked Task 5 complete

#### Test Results
- Typecheck: N/A (markdown files)
- Lint: N/A (markdown files)
- Verification: ✓ All command references already use `5-browser-test` (no orphaned `5-demo` strings)

#### Notes
- Cross-links are unobtrusive but discoverable
- CLAUDE.md uses blockquote style for visibility
- overview.md places CLAUDE.md first in Related Documentation for prominence
- All references verified to use correct renamed command (`5-browser-test`)

---

### Session 4 - 2026-01-05

**Task(s) Completed**: Task 3 - Add automatic port detection to browser-test

#### Changes Made
- Added new section "3a. DETECT DEV SERVER PORT" with intelligent port detection
- Detection checks 5 sources in priority order:
  1. package.json dev script for `--port` flag
  2. vite.config.* for `server.port` setting
  3. next.config.* for port configuration
  4. Framework-specific defaults (Vite=5173, Next.js=3000)
  5. Final fallback to port 3000
- Updated URL construction to use `${PORT}` variable throughout workflow examples
- Preserved existing fallback to ask user if detection fails

#### Files Changed

**Modified Files:**
- `commands/apex/5-browser-test.md` - Added port detection section before "CHECK DEV SERVER" step
  - Line 64-87: New "DETECT DEV SERVER PORT" section with bash detection script
  - Line 61: Updated "DETERMINE TEST URL" step to reference port detection
  - Line 122: Updated NAVIGATE URL to use `${PORT}` variable
  - Line 145, 161: Updated parallel mode examples to use `${PORT}` variable
- `tasks/14-apex-workflow-consolidation/tasks/index.md` - Marked Task 3 complete

#### Test Results
- Typecheck: N/A (markdown files)
- Lint: N/A (markdown files)
- Manual verification: ✓ Port detection uses portable bash constructs (`/usr/bin/grep -oE`)

#### Notes
- Uses `/usr/bin/grep` with `-oE` flag to bypass shell aliases and ensure portability
- Detection pattern matches both TypeScript and JavaScript config files
- Supports both CommonJS (next.config.js) and ESM (next.config.mjs) formats
- Port variable follows standard shell parameter expansion: `${PORT:-3000}`

---

## Follow-up Tasks
- None discovered during implementation

## Technical Notes
- Pattern change: Complex conditional → Simple assignment (Task 1)
- File rename preserves git history via `git mv` (Task 2)
- Brainstorm interview now focuses on depth over breadth (Task 4)
- FORBIDDEN questions prevent wasted time on APEX-handled concerns (Task 4)

## Suggested Commit

```
refactor(apex): consolidate workflow improvements

- Hardcode TASKS_DIR across all commands (remove legacy auto-detection)
- Rename 5-demo to 5-browser-test for clarity
- Add automatic port detection to browser-test (Vite/Next.js/custom ports)
- Enhance brainstorm interview with deeper questions and continuation loop
- Add FORBIDDEN questions to prevent project management queries
- Add documentation cross-links between CLAUDE.md and overview.md
```
