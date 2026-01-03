# Analysis: Convert APEX Commands to CLAUDE.md

**Analyzed**: 2025-12-31
**Status**: Complete

## Quick Summary (TL;DR)

> Task: Consolidate 10 APEX command files (~100KB) into a single concise `CLAUDE.md` file for the `commands/apex/` directory.

**Key files to modify:**
- `commands/apex/CLAUDE.md` - New file to create (target)

**Source files to consolidate:**
- `commands/apex/overview.md` (18KB) - Main reference, already has good structure
- `commands/apex/1-analyze.md` (10KB) - Analysis phase
- `commands/apex/2-plan.md` (5KB) - Planning phase
- `commands/apex/3-execute.md` (20KB) - Execution phase (largest)
- `commands/apex/4-examine.md` (12KB) - Validation phase
- `commands/apex/5-demo.md` (12KB) - Browser testing phase
- `commands/apex/handoff.md` (7KB) - Context transfer
- `commands/apex/next.md` (3KB) - Auto-execute utility
- `commands/apex/status.md` (4KB) - Progress display
- `commands/apex/tasks.md` (8KB) - Task division

**Patterns to follow:**
- Similar CLAUDE.md in `plugins/cache/every-marketplace/compound-engineering/2.18.0/CLAUDE.md` - Uses concise sections, tables, checklists

**Gotchas from seed.md:**
1. Emphatic language ("CRITICAL", "MUST", "NEVER") backfires on Claude 4.5 - use neutral declarations
2. Don't copy-paste - CLAUDE.md should be actionable instructions, not verbose documentation
3. Keep concise - CLAUDE.md is read at every conversation start, verbose = wasted tokens

**Dependencies:** None - pure documentation task

**Estimation:** ~2 tasks, ~1h total

---

## Codebase Context

### Current File Structure
```
commands/apex/
├── 1-analyze.md     # Phase 1: Context gathering with parallel agents
├── 2-plan.md        # Phase 2: Implementation strategy design
├── 3-execute.md     # Phase 3: Code implementation (task-by-task or plan mode)
├── 4-examine.md     # Phase 4: Build/lint/typecheck validation + auto-fix
├── 5-demo.md        # Phase 5: Browser testing with GIF recording
├── handoff.md       # Utility: Generate seed.md for next workflow
├── next.md          # Utility: Run next pending task
├── overview.md      # Full system documentation (reference)
├── status.md        # Utility: Show progress tree
└── tasks.md         # Phase 3.5: Divide plan into task files
```

### Key Concepts to Document

1. **APEX Workflow**: Analyze → Plan → Execute → eXamine (+ optional Demo)
2. **YOLO Mode**: Auto-continue between phases via hooks
3. **Task Folder Structure**: `tasks/NN-kebab-name/` with analyze.md, plan.md, etc.
4. **BLUF Pattern**: Bottom Line Up Front (Objectif first, context later)
5. **Parallel Execution**: `3,4` or `--parallel` flag in execute phase
6. **Lazy Loading**: Reference artifacts in seed.md, read only when needed

### Commands Quick Reference

| Command | Purpose | Flags |
|---------|---------|-------|
| `/apex:1-analyze` | Gather context | `--yolo`, `--background` |
| `/apex:2-plan` | Design strategy | `--yolo` |
| `/apex:tasks` | Divide into task files | `--yolo` |
| `/apex:3-execute` | Implement changes | `--parallel`, `--dry-run`, `--quick` |
| `/apex:4-examine` | Validate & fix | `--skip-patterns`, `--background` |
| `/apex:5-demo` | Browser testing | `--url=`, `--no-gif`, `--parallel` |
| `/apex:next` | Run next task | - |
| `/apex:status` | Show progress | - |
| `/apex:handoff` | Transfer context | `--from`, `--edit` |

### File Artifacts

| File | Created By | Purpose |
|------|------------|---------|
| `seed.md` | `/apex:handoff` | Prior context for new workflow |
| `analyze.md` | `/apex:1-analyze` | Research findings |
| `plan.md` | `/apex:2-plan` | File-centric change plan |
| `tasks/` | `/apex:tasks` | Individual task files |
| `implementation.md` | `/apex:3-execute` | Session log, changes made |

### Mode Flags

- **YOLO Mode** (`--yolo`): Creates `.yolo` marker, auto-continues to next phase via hooks
- **Background Mode** (`--background`): Run agents async, ask clarifying questions meanwhile
- **Parallel Mode** (`--parallel` or `3,4`): Execute multiple tasks concurrently

---

## Content Analysis

### What to Include in CLAUDE.md

Based on the seed specifications:

**Include:**
- Workflow overview (5 phases)
- Task folder structure
- Naming conventions (kebab-case)
- Mode flags (YOLO, background, parallel)
- When to use each phase
- Commands with brief descriptions

**Exclude:**
- Detailed phase implementation steps
- Full slash command syntax
- Verbose explanations
- Bash command examples

### Recommended Structure

```markdown
# APEX System

## Workflow Overview
[ASCII diagram from overview.md - simplified]

## Commands
[Quick reference table]

## Task Folder Structure
[Template tree]

## Mode Flags
[Brief description of YOLO, background, parallel]

## Conventions
[Naming, file structure, patterns]
```

---

## Key Patterns

### From overview.md
- Uses ASCII diagrams for workflow visualization
- Tables for quick reference
- Phase-by-phase documentation

### From CLAUDE.md examples
- Bullet points for rules
- Tables for reference
- Checklists for validation
- Concise 1-2 sentence explanations

### Neutral Language Examples

**Before (emphatic):**
> CRITICAL: Never launch agents without clear search strategy

**After (neutral):**
> Plan search strategy before launching agents.

---

## Implementation Notes

1. **Start with overview.md**: It has the best structure (workflow diagram, tables)
2. **Condense, don't copy**: Transform verbose docs into actionable bullets
3. **Remove emphatic language**: Replace CRITICAL/MUST/NEVER with neutral statements
4. **Keep tables**: They're compact and scannable
5. **Simplify workflow diagram**: Keep the phases, remove details

---

## Next Steps

Run `/apex:2-plan 11-convert-apex-overview-to-claudemd` to create implementation plan.
