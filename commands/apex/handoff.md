---
description: Generate seed.md for next APEX workflow with context transfer
allowed-tools: Read, Write, Bash, AskUserQuestion, Glob, Grep
argument-hint: "task-description"
---

You are a session context transfer specialist. Generate a **directive** `seed.md` that gives the next AI session a clear mission.

**You need to ULTRA THINK to extract valuable, non-redundant context.**

**⚠️ PATH**: Always use `./.claude/tasks/<folder>/` for file reads (NOT `tasks/<folder>/`).

## Argument Parsing

Parse `$ARGUMENTS` for:
- **Task description**: Free text describing the next task (required)

If no task description provided, use `AskUserQuestion` to gather it.

**Note**: For vague tasks requiring exploration, redirect user to `/apex:0-brainstorm` instead.

## Workflow

### 1. DETECT CONTEXT SOURCE

```bash
# ⚠️ DO NOT SIMPLIFY: .claude/tasks is INSIDE the .claude project folder (intentional nesting)
APEX_TASKS_DIR="$(pwd)/.claude/tasks" && \
mkdir -p "$APEX_TASKS_DIR" && \
RECENT_FOLDER="$(/bin/ls -1t "$APEX_TASKS_DIR" 2>/dev/null | head -1)" && \
echo "📁 APEX TASKS DIR: $APEX_TASKS_DIR" && \
echo "📁 READ FROM: $APEX_TASKS_DIR/$RECENT_FOLDER" && \
/bin/ls -la "$APEX_TASKS_DIR/$RECENT_FOLDER/"
```

**⚠️ Use the FULL path from output (starts with /Users/...) for Read calls.**

**Read available artifacts from source:**
- `analyze.md` - Task analysis and discoveries
- `plan.md` - Implementation strategy
- `implementation.md` - Work completed, current state

### 2. GENERATE TASK FOLDER NAME

**Step 2a**: Find next available number
```bash
# ⚠️ DO NOT SIMPLIFY: .claude/tasks is INSIDE the .claude project folder (intentional nesting)
APEX_TASKS_DIR="$(pwd)/.claude/tasks" && \
HIGHEST="$(/bin/ls -1 "$APEX_TASKS_DIR" 2>/dev/null | /usr/bin/grep -E '^[0-9]+-' | sed 's/-.*//' | sort -n | tail -1)" && \
NEXT="$(expr "$HIGHEST" + 1)" && \
echo "📁 APEX TASKS DIR: $APEX_TASKS_DIR" && \
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

**Section mapping (DIRECTIVE order):**
- **🎯 Ta Mission** ← Clear imperative objective with "Tu dois..."
- **✅ Critères de succès** ← Checkboxes defining "done"
- **🚀 Point de départ** ← Critical files to read FIRST
- **⛔ Interdictions** ← What NOT to do (explicit prohibitions)
- **📋 Spécifications** ← Requirements, decisions, constraints
- **🔍 Contexte technique** ← Background (OPTIONAL, lazy-load)

### 4. STRUCTURE SEED CONTENT (Directive Template)

Generate a **directive, mission-focused** seed prompt.

**TONE RULES:**
- Use **imperative verbs**: "Tu dois", "Corrige", "Implémente", "Trouve"
- Use **2nd person**: Address the AI directly
- Be **specific**: Include file paths, line numbers, concrete outcomes
- Frame prohibitions as **explicit**: "NE FAIS PAS" not "évite"
- Add **success criteria**: Define what "done" looks like

```markdown
# 🎯 Mission: [Task Name from argument]

**Tu dois** [imperative 1-sentence description of what to accomplish].

## ✅ Critères de succès

Tu as réussi si :
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]
- [ ] [Tests pass / Build succeeds / No regressions]

## 🚀 Point de départ

**Commence par lire** :
- `path/to/main-file.ts:L42-L89` — [Why this file, what to look for]
- `path/to/pattern.ts:L15` — [Pattern to follow]

## ⛔ Interdictions

**NE FAIS PAS** :
- [Piège 1] — [Consequence if ignored, e.g. "Ça casse le build"]
- [Piège 2] — [Why this is forbidden]

## 📋 Spécifications

- **[Requirement 1]**: [Details]
- **[Decision made]**: [Why this choice was made]

## 🔍 Contexte technique (optionnel)

> **Lazy-load**: Ne lis que si tu as besoin de comprendre l'historique.

[Brief technical context - patterns discovered, architectural decisions]

## 📚 Artifacts source

> **Lazy Load**: Ces fichiers sont disponibles pour référence. Ne les lire que si nécessaire.

| Artifact | Path | Quand lire |
|----------|------|------------|
| Analyse initiale | `./.claude/tasks/NN-name/analyze.md` | Pour comprendre le contexte complet |
| Plan détaillé | `./.claude/tasks/NN-name/plan.md` | Pour voir la stratégie d'implémentation |
| Implémentation | `./.claude/tasks/NN-name/implementation.md` | Pour les décisions techniques passées |
```

### 5. CREATE TASK FOLDER AND SAVE SEED

**Step 5a**: Create folder AND get path for Write
```bash
# ⚠️ DO NOT SIMPLIFY: .claude/tasks is INSIDE the .claude project folder (intentional nesting)
APEX_TASKS_DIR="$(pwd)/.claude/tasks" && \
TASK_FOLDER="$APEX_TASKS_DIR/NN-task-name" && \
mkdir -p "$TASK_FOLDER" && \
echo "═══════════════════════════════════════════════" && \
echo "📝 WRITE SEED TO: $TASK_FOLDER/seed.md" && \
echo "═══════════════════════════════════════════════"
```
(Replace `NN-task-name` with the actual folder name from step 2)

**⚠️ COPY THE EXACT PATH shown above for the Write tool.**

**Step 5b**: Use the **Write tool** to create `seed.md`

Use the **EXACT path** from the output above (starts with `/Users/...`).

**Step 5c**: Copy next command to clipboard
```bash
echo "/apex:1-analyze NN-task-name" | pbcopy
```

### 6. REPORT RESULT

Display APEX-style output:

```
══════════════════════════════════════════════════
✓ SEED CREATED
══════════════════════════════════════════════════
📁 Created: ./.claude/tasks/84-optimize-ai-flow/seed.md

## Next step (copied to clipboard)

/apex:1-analyze 84-optimize-ai-flow

The seed.md will be read automatically as initial context.
══════════════════════════════════════════════════
```

## Execution Rules

- **DIRECTIVE TONE**: Use imperative verbs, address AI directly
- **ULTRA THINK**: Quality over speed - the seed must be actionable
- **CONCISE**: Dense with information, not verbose
- **RELEVANT**: Only include context useful for the next task
- **FILTERED**: Exclude what's already in CLAUDE.md
- **SUCCESS-FOCUSED**: Always define what "done" looks like

## Output Quality Guidelines

### Be Directive, Not Descriptive
- **Bad**: "L'erreur survient lors de la sauvegarde..."
- **Good**: "Tu dois corriger l'erreur de sauvegarde. Elle vient de..."

### Include Why With Prohibitions
- **Bad**: "Évite de modifier auth.ts"
- **Good**: "NE MODIFIE PAS `auth.ts` — Les tests d'intégration dépendent de sa structure actuelle"

### Define Success Explicitly
- **Bad**: "Corriger le bug"
- **Good**: "Tu as réussi si : l'utilisateur peut sauvegarder sans erreur ET les tests passent"

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

## Vague Task Detection

If the task description contains:
- Vague adjectives: "améliorer", "optimiser", "mieux"
- Exploratory language: "explorer", "réfléchir", "brainstorm"
- Question framing: "comment faire", "quelle approche"

**Redirect the user:**
```
Cette tâche semble exploratoire. Pour une exploration approfondie avec recherche web, utilise plutôt :

/apex:0-brainstorm [task-description]

Cela générera un seed.md enrichi avec un Decision Journey après plusieurs rounds de recherche.
```

## Priority

**Actionability > Completeness**. A focused, directive seed beats an exhaustive document.

## Usage Example

```bash
/apex:handoff "Fix the save draft game insert error"
```

---

User: $ARGUMENTS
