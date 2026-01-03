# Implementation: Refactor /apex:4-examine - Global Logical Analysis

## Overview
Transformed `/apex:4-examine` from a simple lint/typecheck validator into a two-phase validation system with technical checks (Phase 1) and logical analysis (Phase 2).

## Status: ✅ Complete
**Progress**: 13/13 tasks completed

## Task Status

| Task | Description | Status | Session |
|------|-------------|--------|---------|
| 1 | Update frontmatter (add Skill, update flags) | ✅ Complete | Session 1 |
| 2 | Rewrite argument parsing | ✅ Complete | Session 1 |
| 3 | Restructure Phase 1 header | ✅ Complete | Session 1 |
| 4 | Remove 5B, integrate background as default | ✅ Complete | Session 1 |
| 5 | Transform 5C into Phase 2 | ✅ Complete | Session 1 |
| 6 | Add scope logic for --global | ✅ Complete | Session 1 |
| 7 | Integrate Skill invocation | ✅ Complete | Session 1 |
| 8 | Update Phase 1 Results branching | ✅ Complete | Session 1 |
| 9 | Add Phase 2 Report Structure | ✅ Complete | Session 1 |
| 10 | Update FINAL REPORT section | ✅ Complete | Session 1 |
| 11 | Update usage examples | ✅ Complete | Session 1 |
| 12 | Update execution rules | ✅ Complete | Session 1 |
| 13 | Update CLAUDE.md documentation | ✅ Complete | Session 1 |

---

## Session Log

### Session 1 - 2026-01-03

**Task(s) Completed**: All 13 tasks - Full refactoring of examine phase

#### Changes Made

1. **Frontmatter updates**:
   - Added `Skill` to allowed-tools for react19-patterns integration
   - Changed flags from `--background` to `--foreground`, `--global`
   - Updated description to mention "two-phase validation"

2. **Argument parsing rewrite**:
   - `--foreground` for synchronous execution (background is now default)
   - `--global` for full feature scope analysis
   - `--skip-patterns` preserved for backwards compatibility

3. **Phase 1 restructuring**:
   - Added visual header with box art
   - Integrated background execution as default
   - Merged build/diagnostics into single "RUN VALIDATION" step
   - Added branching logic for error handling (fix/skip/stop)

4. **Phase 2 creation**:
   - Replaced 5C Pattern Validation with full Logical Analysis
   - Added scope detection (standard vs global)
   - Created 5-step workflow: context, files, analysis, patterns, report
   - Integrated Skill tool invocation for react19-patterns
   - Added ULTRA THINK analysis structure

5. **Report updates**:
   - New structured report combining Phase 1 and Phase 2 results
   - Clear scope and status indicators

#### Files Changed

**Modified Files:**
- `commands/apex/4-examine.md` - Complete refactoring (was 327 lines, now ~437 lines)
- `commands/apex/CLAUDE.md` - Updated flags, added Two-Phase Validation section, updated troubleshooting

#### Test Results
- Manual review: ✓ (no automated tests for APEX commands)
- Syntax validation: ✓ (YAML frontmatter valid, markdown structure intact)

#### Notes
- Breaking change: `--background` removed, now default behavior
- Users must use `--foreground` for synchronous execution
- Skill invocation uses semantic matching pattern from plugin-dev commands

---

## Technical Notes

**Patterns Used:**
- Background-by-default pattern from `1-analyze.md`
- Skill invocation via `Skill` in allowed-tools (semantic matching)
- Box art headers for visual phase separation
- Branching user choice pattern for error handling

**Key Architectural Decisions:**
- Phase 2 only runs if Phase 1 passes (or user explicitly skips)
- Scope modes provide flexibility: standard for speed, global for thoroughness
- ULTRA THINK analysis replaces simple grep checks with deeper coherence analysis

## Suggested Commit

```
refactor: add two-phase validation to /apex:4-examine

- Add Phase 2 (Logical Analysis) after technical validation
- Make background execution default, add --foreground flag
- Add --global flag for comprehensive file scope analysis
- Integrate Skill tool for react19-patterns invocation
- Update CLAUDE.md with new flags and troubleshooting

BREAKING CHANGE: --background removed, now default behavior
```

---

## Final Validation

**Validated**: 2026-01-03
**Command**: `/apex:4-examine 13-refactor-examine-global-analysis`

### Results

| Check | Status | Details |
|-------|--------|---------|
| Build | ⏭️ N/A | Documentation project (no package.json) |
| Typecheck | ⏭️ N/A | Markdown files only |
| Lint | ⏭️ N/A | No linting configured |
| Patterns | ⏭️ Skipped | No React files in scope |
| Format | ⏭️ Skipped | Markdown formatting manual |

### Phase 2: Logical Analysis

| Aspect | Status | Findings |
|--------|--------|----------|
| Coherence | ✅ Pass | All 13 tasks implemented correctly |
| Edge Cases | ✅ Pass | All edge cases covered (no pkg.json, no impl.md, non-React) |
| Quality | ✅ Pass | Clean structure, no duplication |
| Plan Alignment | ✅ Pass | 100% implementation of planned changes |

### Errors Fixed During Examine
- None (documentation project - no build/lint/typecheck errors possible)

### Remaining Issues
- None - ready for deployment
