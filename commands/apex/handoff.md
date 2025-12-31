---
description: Generate seed.md for next APEX workflow with context transfer
allowed-tools: Read, Write, Bash, AskUserQuestion, Glob, Grep
argument-hint: "next-task-description" [--from <source-folder>] [--edit]
---

You are a session context transfer specialist. Generate a `seed.md` that captures session learnings and seeds the next APEX workflow.

**You need to ULTRA THINK to extract valuable, non-redundant context.**

## Argument Parsing

Parse `$ARGUMENTS` for:
- **Task description**: Free text describing the next task (required, in quotes recommended)
- **`--from <folder>`**: Optional source folder for context (default: auto-detect most recent)
- **`--edit`**: Open seed.md in Zed for editing before finalizing

If no task description provided, use `AskUserQuestion` to gather it.

## Workflow

### 1. DETECT CONTEXT SOURCE

**If `--from <folder>` provided:**
- Use the specified folder as context source

**If no folder specified (auto-detect most recent):**
```bash
# Detect tasks directory
if [ -d "tasks" ] && [ "$(basename "$PWD")" = ".claude" ]; then
  TASKS_DIR="tasks"
else
  TASKS_DIR=".claude/tasks"
fi

# Find most recently modified folder (use /bin/ls to bypass eza alias)
RECENT_FOLDER=$(/bin/ls -1t "$TASKS_DIR" 2>/dev/null | head -1)
echo "Source context: $TASKS_DIR/$RECENT_FOLDER"
```

**Read available artifacts from source:**
- `analyze.md` - Task analysis and discoveries
- `plan.md` - Implementation strategy
- `implementation.md` - Work completed, current state

### 2. GENERATE TASK FOLDER NAME

**Step 2a**: Find next available number
```bash
# Find highest existing number (handles NN-name format)
# Note: Use /bin/ls to bypass eza alias, /usr/bin/grep to bypass rg alias
HIGHEST=$(/bin/ls -1 "$TASKS_DIR" | /usr/bin/grep -E '^[0-9]+-' | sed 's/-.*//' | sort -n | tail -1)
NEXT=$(expr "$HIGHEST" + 1)
echo "Next number: $NEXT"
```

**Step 2b**: Convert description to kebab-case
- Lowercase everything
- Replace spaces and special chars with `-`
- Max 40 chars
- Example: "Optimize AI conversation flow" → `optimize-ai-conversation-flow`

**Step 2c**: Combine
```bash
FOLDER_NAME="$NEXT-$KEBAB_NAME"
# Example: 84-optimize-ai-conversation-flow
```

### 3. GATHER SESSION LEARNINGS (ULTRA THINK)

**Extract from source folder artifacts:**

From `analyze.md`:
- Key files discovered and their roles
- Patterns identified in the codebase

From `plan.md`:
- Architecture decisions made
- Implementation approach chosen

From `implementation.md`:
- Work completed, current state
- Issues encountered and solutions

**CRITICAL FILTER - STRICT:**
- **NEVER** include project name/description - always in CLAUDE.md
- **NEVER** include generic architecture diagrams - usually in CLAUDE.md
- **SKIP** file paths without specific line numbers or discoveries
- **ONLY** include: bugs found, patterns discovered, gotchas, decisions made THIS session
- Ask: "Would the next session need to re-discover this?" If yes → include. If it's in CLAUDE.md → skip.

**Section mapping (BLUF order):**
- **📂 Point de départ** ← Critical files with specific line numbers
- **⚠️ Pièges à éviter** ← Gotchas, bugs encountered, things that wasted time
- **📋 Spécifications** ← Requirements, decisions made, constraints
- **🔍 Contexte technique** ← Architectural decisions, patterns discovered (OPTIONAL)

### 4. STRUCTURE SEED CONTENT (BLUF Pattern)

Generate a **condensed, actionable** seed prompt following **BLUF (Bottom Line Up Front)**:

```markdown
# 🔄 [Task Name from argument] - Seed

## 🎯 Objectif

[Next task description - clear, actionable, expanded if needed]

## 📂 Point de départ

**Fichiers critiques à lire:**
- `path/to/main-file.ts:L42-L89` - [What this file does, why start here]
- `path/to/pattern.ts:L15` - [Pattern to follow]

## ⚠️ Pièges à éviter

- [Gotcha 1]: [Ce qui aurait fait perdre du temps]
- [Bug rencontré]: [Comment on l'a résolu - `file.ts:42`]

## 📋 Spécifications

- [Exigence 1]: [Détails]
- [Décision prise]: [Pourquoi ce choix]

## 🔍 Contexte technique (optionnel)

> **Note**: Section optionnelle. Lire uniquement si besoin de comprendre l'historique.

[Brief technical context - patterns discovered, architectural decisions]

## 📚 Artifacts source

> **Lazy Load**: Ces fichiers sont disponibles pour référence. Ne les lire que si nécessaire.

| Artifact | Path | Quand lire |
|----------|------|------------|
| Analyse initiale | `$TASKS_DIR/NN-name/analyze.md` | Pour comprendre le contexte complet |
| Plan détaillé | `$TASKS_DIR/NN-name/plan.md` | Pour voir la stratégie d'implémentation |
| Implémentation | `$TASKS_DIR/NN-name/implementation.md` | Pour les décisions techniques passées |
```

### 5. CREATE TASK FOLDER AND SAVE SEED

**Step 5a**: Create the folder
```bash
mkdir -p .claude/tasks/NN-task-name
```
(Replace `NN-task-name` with the actual folder name from step 2)

**Step 5b**: Use the **Write tool** to create `seed.md`
- Path: `.claude/tasks/NN-task-name/seed.md`
- Content: The generated seed from step 4

**Step 5c**: Copy to clipboard
```bash
pbcopy < .claude/tasks/NN-task-name/seed.md
```

### 6. OPTIONAL: EDIT IN ZED

If `--edit` flag provided, open in editor:
```bash
zed .claude/tasks/NN-task-name/seed.md
```

### 7. REPORT RESULT

Display APEX-style output:

```
══════════════════════════════════════════════════
✓ SEED CREATED
══════════════════════════════════════════════════
📁 Created: .claude/tasks/84-optimize-ai-flow/seed.md
📋 Copied to clipboard

## Next step

/apex:1-analyze 84-optimize-ai-flow

The seed.md will be read automatically as initial context.
══════════════════════════════════════════════════
```

## Execution Rules

- **ULTRA THINK**: Quality over speed - the seed must be actionable
- **CONCISE**: Dense with information, not verbose
- **RELEVANT**: Only include context useful for the next task
- **FILTERED**: Exclude what's already in CLAUDE.md
- **BLUF**: Objectif FIRST, then context

## Output Quality Guidelines

### Be Specific, Not Vague
- **Bad**: "Learned about the auth module"
- **Good**: "AuthService uses JWT with refresh tokens, pattern in `src/services/auth.ts:42`"

### Include Why, Not Just What
- **Bad**: "Use the Card component"
- **Good**: "Use Card component for consistency - established pattern in dashboard"

### Anticipate Next Session Needs
- What files will they need immediately?
- What patterns should they follow?
- What mistakes should they avoid?

### Lazy Loading Decision
When to **reference** (in Artifacts table):
- Full analysis document (lengthy context)
- Implementation history (detailed logs)
- Previous session artifacts

When to **include inline** (in main sections):
- Critical gotchas that MUST be known immediately
- Essential file paths with line numbers
- Key decisions that affect implementation

## Priority

**Actionability > Completeness**. A focused, dense seed beats an exhaustive document.

## Usage Examples

```bash
# Basic: generate seed for next task (auto-detects source context)
/apex:handoff "Optimize the AI conversation flow"

# With specific source folder
/apex:handoff "Add error handling" --from 15-api-refactor

# Edit seed before finalizing
/apex:handoff "Implement dashboard widgets" --edit
```

---

User: $ARGUMENTS
