# Implementation Plan: /apex:handoff - Context Transfer Command

## Overview

Create a two-file system for transferring session context to new APEX tasks:
1. **Slash command** (`handoff.md`) - Claude generates the handoff prompt with ULTRA THINK
2. **Action script** (`handoff-action.ts`) - Bun script shows macOS popup and executes chosen action

The command captures current session learnings (files explored, patterns discovered, decisions made) and generates an optimized prompt for starting a new APEX workflow. The popup offers 3 actions: Copy to clipboard, Open in Zed, or Save to session-prompts.

## Dependencies

**Order**: Script first (used by command), then command.

- No external dependencies blocking implementation
- Requires macOS (osascript, pbcopy)
- Zed editor optional (graceful fallback)

## File Changes

### `~/.claude/scripts/handoff-action.ts` (CREATE)

**Purpose**: Standalone Bun script that reads a prompt file and shows action popup.

- Add shebang `#!/usr/bin/env bun` for direct execution
- Parse command line arguments: `argv[2]` = path to prompt file
- Implement `showChoicePopup()` using osascript `choose from list`:
  - Options: "Copier", "Éditer dans Zed", "Sauvegarder"
  - Title: "Claude Handoff"
  - Handle cancel (return "CANCEL")
- Implement `copyToClipboard()` following pattern from `hook-apex-clipboard.ts:122-133`:
  - Use `Bun.spawn(["pbcopy"], { stdin: ... })`
  - Return boolean for success
- Implement `showNotification()` using osascript `display notification`:
  - Parameters: title, message, sound (optional)
- Implement `openInZed()`:
  - Execute `zed <filepath>`
  - Handle case where Zed not installed (notification + copy fallback)
- Implement `saveToSessionPrompts()`:
  - Target: `~/.claude/session-prompts/YYYY-MM-DD-handoff-[timestamp].md`
  - Create directory if needed
  - Move file from temp to permanent location
  - Show notification with saved path
- Main switch on popup choice to execute appropriate action
- Clean error handling with user-friendly notifications

### `~/.claude/commands/apex/handoff.md` (CREATE)

**Purpose**: Slash command that generates context-rich handoff prompts.

- Add frontmatter following APEX pattern:
  - description: "Generate handoff prompt for new APEX session"
  - allowed-tools: Read, Write, Bash, AskUserQuestion, Glob, Grep
  - argument-hint: "[next-task-description] [--task-folder]"

- Section: "Argument Parsing"
  - Parse `$ARGUMENTS` for task description
  - Parse optional `--task-folder <folder>` flag to specify source context
  - If no task description, use `AskUserQuestion` to gather

- Section: "Workflow" with 6 steps:

  **Step 1: DETECT CONTEXT SOURCE**
  - If `--task-folder` provided, use that folder
  - Otherwise, auto-detect most recent task folder in `$TASKS_DIR`
  - Bash: `ls -1t "$TASKS_DIR" | head -1` for most recent
  - Read available context files: `analyze.md`, `plan.md`, `implementation.md`

  **Step 2: GATHER SESSION LEARNINGS (ULTRA THINK)**
  - Extract from analyze.md: Key files discovered, patterns identified
  - Extract from plan.md: Architecture decisions, implementation approach
  - Extract from implementation.md: Work completed, current state
  - Filter: Only include learnings NOT already in CLAUDE.md
  - Think: What would be most valuable for the next session?

  **Step 3: STRUCTURE HANDOFF PROMPT**
  - Use condensed template (not full new-session-prompt template):
    ```markdown
    # Nouvelle session : [Task Name]

    ## Contexte hérité
    ### Projet
    ### Fichiers clés
    ### Décisions importantes
    ### Learnings

    ## Tâche demandée
    [Next task description]

    ## Démarrage recommandé
    /apex:1-analyze "[task]" --yolo

    ### Fichiers à lire en premier
    ```
  - Be concise: Dense with information, not verbose

  **Step 4: WRITE TEMP FILE**
  - Path: `/tmp/handoff-{timestamp}.md`
  - Write generated prompt content

  **Step 5: EXECUTE ACTION SCRIPT**
  - Run: `bun ~/.claude/scripts/handoff-action.ts /tmp/handoff-xxx.md`
  - Script handles popup and user action

  **Step 6: REPORT RESULT**
  - Display APEX-style output showing what action was taken
  - If saved, show path to saved file
  - If copied, confirm in clipboard

- Section: "Execution Rules"
  - ULTRA THINK before generating: Quality over speed
  - CONCISE: The prompt should be actionable, not exhaustive
  - RELEVANT: Only include context useful for the next task
  - STRUCTURED: Follow template exactly for consistency

- Section: "Priority"
  - Actionability > Completeness. The new session should be productive from message #1.

## Testing Strategy

- Manual verification steps:
  1. Run `/apex:handoff "New task description"` from task folder
  2. Verify popup appears with 3 options
  3. Test "Copier" → confirm clipboard has content
  4. Test "Éditer dans Zed" → confirm Zed opens file
  5. Test "Sauvegarder" → confirm file in `~/.claude/session-prompts/`
  6. Test with `--task-folder` flag pointing to specific folder
  7. Test auto-detection when no folder specified

## Documentation

- No external documentation needed
- Commands are self-documenting via `argument-hint` in frontmatter

## Rollout Considerations

- No migration needed - new feature
- Script must be made executable after creation: `chmod +x ~/.claude/scripts/handoff-action.ts`
- Works only on macOS (osascript requirement)
- Graceful degradation: If SSH/headless, clipboard-only fallback
