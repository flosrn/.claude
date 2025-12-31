# Implementation Plan: Integrate cclsp into APEX Workflow

## Overview

Integrate cclsp (LSP tools) into APEX phases to ensure semantic code navigation during task execution. The approach combines:
1. **Embedding instructions** directly in APEX phase files (visible in active context)
2. **Simplifying CLAUDE.md language** (removing "CRITICAL/MUST" that backfires on Claude 4.5)
3. **Keeping lsp-navigation skill** as fallback trigger

This hybrid approach should improve cclsp compliance from ~20% to ~65-90%.

## Dependencies

None. All infrastructure is already in place:
- cclsp MCP server configured
- Permissions whitelisted in settings.json
- lsp-navigation skill exists

## File Changes

### `commands/apex/3-execute.md` (HIGHEST IMPACT)

**Location**: After line 275 (after "ULTRA THINK BEFORE EACH CHANGE" section)

- **Action 1**: Add new section "### Symbol Navigation & Refactoring" after line 275
- **Content to add**:
  - Introductory line: "Use cclsp MCP tools for code navigation during implementation"
  - Table with 3 rows: find_definition, find_references, rename_symbol (with "Why" column)
  - Ordered list of "Before editing code" steps (find → references → rename)
  - Short example showing mcp__cclsp__find_definition and mcp__cclsp__find_references calls
- **Why**: This phase is where refactoring happens — without cclsp guidance here, Claude defaults to Grep
- **Pattern**: Follow the table format already used in CLAUDE.md lines 35-40

### `commands/apex/1-analyze.md` (MEDIUM IMPACT)

**Location**: After line 133 (after the "Standard Mode" exploration section)

- **Action**: Add brief "### Symbol Navigation" subsection
- **Content to add**:
  - Decision arrows: "Where is X defined?" → find_definition, "Where is X used?" → find_references
  - One-line explanation: cclsp provides semantic understanding (not text matching)
- **Why**: Analysis phase benefits from precise symbol lookup; prevents false positives from grep
- **Keep minimal**: Analysis focuses on exploration, not heavy refactoring — brief is better

### `CLAUDE.md` (MEDIUM IMPACT)

**Location**: Lines 31-78 (LSP Tools section)

- **Action 1**: Change section header from `## LSP Tools (cclsp) - MANDATORY` to `## LSP Tools (cclsp)`
- **Action 2**: Replace lines 32-33 emphatic opener:
  - From: `⚠️ **CRITICAL REQUIREMENT**: You MUST use cclsp MCP tools instead of Grep/Glob for these operations:`
  - To: `Use cclsp MCP tools for finding symbol definitions and references. LSP provides semantic code understanding rather than text matching.`
- **Action 3**: Change line 42 header from `### Trigger Patterns - When You MUST Use cclsp` to `### Trigger Patterns`
- **Action 4**: Change line 52 header from `### Why cclsp > Grep (Non-negotiable)` to `### Why cclsp > Grep`
- **Action 5**: Change line 61 header from `### Mandatory Workflow` to `### Workflow`
- **Keep unchanged**: The tables (lines 35-40, 54-59) and examples (lines 70-78) — these work well
- **Why**: Claude Opus 4.5 responds worse to emphatic language; simpler phrasing increases compliance

## Testing Strategy

**Test 1: Phase 1 (Analyze)**
- Run `/apex:1-analyze` on a TypeScript codebase task
- Verify: cclsp guidance appears in the analyze.md output
- Check: `find_definition` or `find_references` used instead of Grep for symbols

**Test 2: Phase 3 (Execute)**
- Run `/apex:3-execute` on a task requiring symbol renaming
- Verify: cclsp section is visible in execution context
- Check: `rename_symbol` is used instead of manual Edit calls

**Test 3: Skill Fallback**
- Direct query: "Where is the handleSubmit function defined?"
- Verify: lsp-navigation skill triggers correctly

**Manual verification command**:
```bash
# Check if cclsp instructions appear in phase files
/usr/bin/grep -l "cclsp" commands/apex/*.md
```

## Documentation

No external documentation updates needed. Changes are internal to APEX workflow.

## Rollout Considerations

- **No migration needed**: Changes are additive (new sections) or simplifying (less emphatic)
- **No breaking changes**: Existing APEX workflows continue to work
- **Immediate effect**: Next APEX execution will see new instructions
- **Rollback**: Revert the 3 file changes if compliance doesn't improve

## Success Criteria

1. cclsp instructions visible in `/apex:3-execute` context
2. cclsp instructions visible in `/apex:1-analyze` context
3. CLAUDE.md no longer contains "MUST/CRITICAL/MANDATORY" in cclsp section
4. Claude uses cclsp tools during APEX refactoring tasks (observable in tool calls)
