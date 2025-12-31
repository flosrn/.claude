# Implementation: /apex:handoff - Context Transfer Command

## Overview

The `/apex:handoff` command transfers session context to a new APEX workflow by generating a `seed.md` file in the next task folder. This creates a seamless chain between sessions.

**Flow:**
```
Session 1 → /apex:handoff "New task" → creates .claude/tasks/XX-new-task/seed.md
Session 2 → /apex:1-analyze XX-new-task → reads seed.md automatically
```

## Status: ✅ Complete
**Progress**: Full implementation with architectural refinements

---

## Session Log

### Session 1 - 2025-12-30

**Task(s) Completed**: Initial implementation

#### Changes Made
- Created `handoff-action.ts` Bun script with macOS popup integration
- Created `handoff.md` slash command following APEX patterns

#### Notes
- Initial approach used popup with 3 choices (Copier/Éditer/Sauvegarder)
- Saved to `/tmp/` or `~/.claude/session-prompts/`

---

### Session 2 - 2025-12-30

**Task(s) Completed**: Template refinement based on user feedback

#### Problem Identified
First handoff output included redundant info already in CLAUDE.md:
- "Projet: Gapila - /Users/flo/Code/nextjs/gapila" ← Always in CLAUDE.md
- Generic architecture diagrams ← Usually in CLAUDE.md

#### Changes Made
- **BLUF reorder**: `## Objectif` now FIRST, context second
- Removed `### Projet` section - always redundant with CLAUDE.md
- Added stricter filtering rules (NEVER project info, ONLY discoveries)

---

### Session 3 - 2025-12-30

**Task(s) Completed**: Major architectural refactor

#### Problems Identified
1. **Naming**: "handoff" jargon for file → renamed to `seed.md`
2. **Disconnected flow**: Generated prompt wasn't used by next session
3. **Unnecessary complexity**: Popup script not needed

#### Architectural Changes

**Before (v1):**
```
/apex:handoff → /tmp/handoff-xxx.md → popup → choose action → manual copy/paste
```

**After (v3):**
```
/apex:handoff "task" → .claude/tasks/XX-task/seed.md → /apex:1-analyze XX-task (reads seed.md)
```

#### Changes Made

1. **handoff.md completely rewritten**:
   - Creates task folder automatically (next available number)
   - Generates `seed.md` directly in task folder
   - Copies to clipboard as convenience
   - `--from <folder>` to specify source context
   - `--edit` to open in Zed before finalizing

2. **1-analyze.md updated**:
   - New Step 0: Check for `seed.md` in task folder
   - If found, read and use as initial context
   - Supports folder name as argument (e.g., `84-optimize-flow`)

3. **handoff-action.ts removed**:
   - Popup no longer needed
   - Direct file access is simpler

#### Files Changed

**Modified Files:**
- `~/.claude/commands/apex/handoff.md` - Complete rewrite for seed.md workflow
- `~/.claude/commands/apex/1-analyze.md` - Added Step 0 for seed.md reading

**Deleted Files:**
- `~/.claude/scripts/handoff-action.ts` - No longer needed

---

## Final Architecture

```
/apex:handoff "Optimize AI flow"
        │
        ├── 1. Detect source context (--from or auto-detect recent)
        ├── 2. Generate folder name: 84-optimize-ai-flow
        ├── 3. ULTRA THINK: Extract session learnings
        ├── 4. Create folder + write seed.md
        └── 5. Copy to clipboard + report

        ▼
.claude/tasks/84-optimize-ai-flow/
└── seed.md  ← Contains: Objectif + Contexte hérité + Fichiers à lire

        ▼
/apex:1-analyze 84-optimize-ai-flow
        │
        └── Step 0: Read seed.md → Informs ULTRA THINK + agent prompts
```

## seed.md Template

```markdown
# [Task Name]

## Objectif
[Clear, actionable task description]

## Contexte hérité

### Découvertes clés
- [Bug résolu]: [Comment - `file.ts:42`]
- [Pattern découvert]: [Explication]

### Fichiers critiques
- `path/to/file.ts:ligne` - [Découverte spécifique]

### Décisions prises
- [Décision]: [Pourquoi]

## Fichiers à lire en premier
- `path/to/start.ts` - [Pourquoi commencer ici]
```

## Technical Notes
- No external dependencies (removed Bun script)
- Uses pbcopy for clipboard (macOS)
- Folder naming: Highest existing number + 1
- Detection rule: Argument starting with `\d+-` = folder name
- Bash commands use POSIX `[ ]` syntax (not `[[ ]]`) for zsh compatibility
- Variables are not shared between bash calls - use explicit paths

## Suggested Commit

```
feat: add /apex:handoff command with seed.md workflow

- /apex:handoff creates task folder with seed.md for context transfer
- /apex:1-analyze reads seed.md automatically as initial context
- BLUF template: Objectif first, then context
- Strict filtering: only session discoveries, not CLAUDE.md content
- Seamless chaining between APEX sessions

Modified files:
- commands/apex/handoff.md (new)
- commands/apex/1-analyze.md (Step 0 added)
```
