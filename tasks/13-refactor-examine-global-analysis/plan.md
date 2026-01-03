# Implementation Plan: Refactor /apex:4-examine - Global Logical Analysis

## Overview

Transform `/apex:4-examine` from a simple lint/typecheck validator into a **two-phase validation system**:
1. **Phase 1 (Technical)**: Fast, blocking - build/lint/typecheck
2. **Phase 2 (Logical)**: Deep analysis - coherence, edge cases, patterns

Key changes:
- Add `Skill` to allowed-tools for react19-patterns integration
- Make background mode default (not opt-in)
- Add `--global` flag for comprehensive scope analysis
- Restructure workflow into clear Phase 1 / Phase 2 separation
- Add structured report output with logical analysis findings

## Dependencies

- `skills/react19-patterns/SKILL.md` already exists ✅
- `commands/apex/CLAUDE.md` must be updated after main file changes

## File Changes

### `commands/apex/4-examine.md`

#### 1. Update Frontmatter (lines 1-5)
- Add `Skill` to allowed-tools list
- Update description to mention "logical analysis"
- Update argument-hint: replace `--background` with `--global`, add `--foreground`
- New allowed-tools: `Bash(npm :*), Bash(pnpm :*), Read, Task, Grep, Edit, Write, Skill`

#### 2. Rewrite Argument Parsing (lines 9-14)
- Remove `--background` flag (now default behavior)
- Add `--foreground` flag for synchronous execution
- Add `--global` flag for full feature scope analysis
- Keep `--skip-patterns` for backwards compatibility
- Update flag descriptions to reflect new behavior

#### 3. Restructure Workflow - Phase 1 Section (lines 16-65)
- Rename current steps 1-5 as "Phase 1: Technical Validation"
- Add clear section header with box art
- Keep environment detection (step 1) unchanged
- Keep input validation (step 2) unchanged
- Keep command discovery (step 3) unchanged
- Merge build + diagnostics (steps 4-5) into single "Run Validation"
- Make background execution the default (not opt-in)
- Pattern: Follow `1-analyze.md:93-134` background-by-default pattern

#### 4. Remove Section 5B (lines 67-99)
- Delete dedicated "BACKGROUND MODE" section
- Integrate background logic into main workflow
- Default behavior now runs validation in background
- Add `--foreground` handling to run synchronously instead

#### 5. Transform Section 5C into Phase 2 (lines 101-172)
- Rename to "Phase 2: Logical Analysis"
- Add section header with box art matching Phase 1
- **CRITICAL**: Phase 2 only runs if Phase 1 passes (no lint/typecheck errors)
- Structure Phase 2 sub-steps:
  1. Read task context (analyze.md, implementation.md)
  2. Read modified files + their dependencies
  3. ULTRA THINK coherence analysis (use extended thinking block)
  4. Invoke react19-patterns skill via Skill tool (if React project)
  5. Generate structured report

#### 6. Add Scope Logic for --global Flag
- Standard scope (default): Modified files + direct dependencies
- Global scope (`--global`): All files in feature/task directory
- Add detection logic to determine file scope based on flag
- Use git diff or implementation.md to identify modified files

#### 7. Integrate Skill Invocation (replace grep-based checks)
- Replace hardcoded grep commands with Skill tool call
- Add instruction: "Load react19-patterns skill using Skill tool"
- Keep grep as detection-only (to decide IF skill should be invoked)
- Let skill handle the detailed analysis and recommendations
- Update the blocking behavior to match skill output

#### 8. Update Error Analysis Section (lines 59-64 area)
- Rename step 6 "ANALYZE ERRORS" to "PHASE 1 RESULTS"
- Add branching logic:
  - If errors → Stop and report, offer to fix or skip to Phase 2
  - If clean → Automatically proceed to Phase 2
- Keep error grouping and counting logic

#### 9. Preserve Fix Areas Logic (lines 175-207)
- Keep CREATE FIX AREAS (step 6 → renumber as step 6)
- Keep PARALLEL FIX with snipper agents (step 7 → renumber as step 7)
- Keep FORMAT CODE (step 8 → renumber as step 8)
- These are still valid for Phase 1 error fixing

#### 10. Add Phase 2 Report Structure (new section after current step 9)
- Add logical analysis report template
- Structure:
  ```markdown
  ## 🔍 Logical Analysis Report

  ### Coherence
  - [Consistency findings between files]

  ### Edge Cases
  - [Missing edge case handling]

  ### Code Quality
  - [Overengineering, simplification opportunities]

  ### React 19 Patterns (if applicable)
  - [Findings from react19-patterns skill]

  ### Recommended Improvements
  - [ ] [Actionable item 1]
  - [ ] [Actionable item 2]
  ```

#### 11. Update FINAL REPORT Section (current step 11, lines 249-258)
- Keep technical validation summary
- Add logical analysis summary
- Add scope indicator (standard vs global)
- Update next step suggestions

#### 12. Update Usage Examples (lines 299-317)
- Add `--global` flag example
- Replace `--background` with `--foreground` examples
- Add combined flag examples
- Update comments to reflect new behavior

#### 13. Update Execution Rules (lines 288-296)
- Add Phase 2 execution rules
- Document Phase 1 → Phase 2 flow
- Add skill invocation guidelines
- Update background mode documentation

---

### `commands/apex/CLAUDE.md`

#### 1. Update Quick Reference Table (lines 7-17)
- Change `/apex:4-examine` flags from `--skip-patterns, --background` to `--skip-patterns, --foreground, --global`
- Update purpose text to mention "two-phase validation"

#### 2. Update Mode Flags Section (lines 33-39)
- Update Background Mode description: "Default on analyze and examine phases"
- Add Foreground Mode: `--foreground` for synchronous execution
- Add Global Scope: `--global` for comprehensive file analysis

#### 3. Add Two-Phase Validation Section (new section after Mode Flags)
- Document Phase 1 (Technical) vs Phase 2 (Logical)
- Explain when each phase runs
- Document Phase 2 scope behavior (standard vs global)

#### 4. Update Troubleshooting Table (lines 97-101)
- Add row for Phase 2 issues
- Add row for skill invocation issues
- Update background mode entry to reflect new default

## Testing Strategy

### Manual Verification Steps
1. Run `/apex:4-examine <task-folder>` - verify background by default
2. Run `/apex:4-examine <task-folder> --foreground` - verify synchronous
3. Run `/apex:4-examine <task-folder> --global` - verify expanded scope
4. Verify Phase 2 only runs when Phase 1 passes
5. Verify react19-patterns skill is invoked on React projects
6. Verify report structure matches specification

### Edge Case Verification
- Task folder without implementation.md
- Non-React project (no skill invocation)
- Phase 1 failures (should not run Phase 2)
- --skip-patterns with --global combination

## Documentation

- Primary: `commands/apex/CLAUDE.md` (updated in this plan)
- Secondary: Consider updating `commands/apex/overview.md` if it references examine behavior

## Rollout Considerations

### Breaking Changes
- `--background` flag removed (now default behavior)
- Users must use `--foreground` for synchronous execution
- This is a behavioral change that may surprise users expecting foreground by default

### Migration Notes
- Existing scripts using `--background` will see warning about deprecated flag
- Consider adding deprecation warning for `--background` that maps to default behavior
