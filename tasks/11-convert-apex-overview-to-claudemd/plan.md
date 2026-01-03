# Implementation Plan: Convert APEX Commands to CLAUDE.md

## Overview

Transform 10 separate APEX command files (~100KB verbose documentation) into a single, concise `CLAUDE.md` file optimized for LLM consumption. The goal is actionable quick-reference, not comprehensive documentation.

**Core principle**: CLAUDE.md is read at every conversation start. Verbose = wasted tokens. Every line must be actionable.

## Dependencies

None - pure documentation consolidation task.

## File Changes

### `commands/apex/CLAUDE.md` (CREATE)

**Action 1**: Create the file with this structure:

```
# APEX Workflow System

## Quick Reference (table of commands with flags)
## Task Folder Structure (template tree)
## Mode Flags (YOLO, background, parallel - brief)
## File Artifacts (what each phase produces)
## Key Conventions (naming, patterns)
## Troubleshooting (bash portability notes)
```

**Action 2**: Extract simplified workflow diagram from `overview.md`
- Keep the 5-phase flow: Analyze → Plan → (Tasks) → Execute → eXamine
- Remove detailed step descriptions inside boxes
- Show only phase name, command, and primary output

**Action 3**: Create command quick-reference table
- Consolidate from `overview.md:8-18` (Quick Reference table)
- Include: Command | Purpose | Key Flags | Output
- One line per command, no multi-line descriptions

**Action 4**: Document task folder structure
- Simplify tree from `overview.md:374-386`
- Show: seed.md, analyze.md, plan.md, implementation.md, tasks/ subfolder
- Brief one-liner for each file's purpose

**Action 5**: Document mode flags (3 types)
- YOLO Mode: Auto-continues between phases (supported: 1-analyze, 2-plan, tasks)
- Background Mode: Agents run async while asking clarifying questions
- Parallel Mode: Execute multiple tasks concurrently (`3,4` or `--parallel`)

**Action 6**: List file artifacts lifecycle
- Table format: File | Created By | Purpose
- Extract from `overview.md:390-396`

**Action 7**: Document key conventions
- KEBAB-CASE naming for task folders
- File-centric planning (organized by file, not feature)
- ULTRA THINK before actions
- BLUF structure for seed.md

**Action 8**: Add troubleshooting section
- Bash portability: `/usr/bin/grep -E`, `/bin/ls -1t`
- Common issues from `overview.md:449-453`

**Writing style requirements**:
- Neutral tone: "Plan search strategy before launching agents" (not "CRITICAL: Never...")
- Bullet points and tables for scannability
- No code block examples (those belong in individual command files)
- No "See Also" references (the command files still exist)

### Verification

**Check 1**: Total file size under 5KB (vs 100KB source material)
**Check 2**: No emphatic language (CRITICAL, MUST, NEVER)
**Check 3**: All tables render correctly in markdown
**Check 4**: No duplicate information from individual command files

## Testing Strategy

**Manual verification**:
- Read CLAUDE.md and confirm it provides sufficient context to understand APEX
- Verify no essential workflow information is missing
- Confirm individual command files still work as before (no changes to them)

**Format check**:
- Ensure markdown tables are properly formatted
- Verify no orphaned code blocks

## Documentation

No additional documentation needed - this IS the documentation consolidation.

## Rollout Considerations

**No breaking changes** - the individual command files (`1-analyze.md`, `2-plan.md`, etc.) remain unchanged and fully functional. CLAUDE.md provides supplementary context that gets loaded automatically.

**Token budget**: The new CLAUDE.md will be read at every APEX session start, so staying under 5KB is important for efficiency.

## Task Breakdown

Given the scope (~1 file to create, extracting from 10 sources), this can be done in:
- **Task 1**: Create CLAUDE.md with all sections (core content)
- **Task 2**: Review and refine (ensure conciseness, remove emphatic language)

Estimated time: ~1 hour total.
