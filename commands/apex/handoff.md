---
description: Generate seed.md for next APEX workflow with context transfer
allowed-tools: Read, Write, Bash, AskUserQuestion, Glob, Grep
argument-hint: "task-description" [--vision] [--brainstorm]
---

You are a session context transfer specialist. Generate a `seed.md` that captures session learnings and seeds the next APEX workflow.

**You need to ULTRA THINK to extract valuable, non-redundant context.**

## Argument Parsing

Parse `$ARGUMENTS` for:
- **Task description**: Free text describing the next task (required)
- **`--vision`**: Detect shared image and include in seed for deep analysis
- **`--brainstorm`**: Ask clarifying questions before generating seed (for vague tasks)

If no task description provided, use `AskUserQuestion` to gather it.

## Workflow

### 1. DETECT CONTEXT SOURCE

```bash
TASKS_DIR="./.claude/tasks" && \
RECENT_FOLDER="$(/bin/ls -1t "$TASKS_DIR" 2>/dev/null | head -1)" && \
echo "Source: $TASKS_DIR/$RECENT_FOLDER"
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
# Note: Quotes around $() are required for zsh compatibility with pipes
HIGHEST="$(/bin/ls -1 "$TASKS_DIR" 2>/dev/null | /usr/bin/grep -E '^[0-9]+-' | sed 's/-.*//' | sort -n | tail -1)" && \
NEXT="$(expr "$HIGHEST" + 1)" && \
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

### 3b. DETECT SHARED IMAGE (only if `--vision` flag)

Skip this step if no `--vision` flag.

```bash
# Find images shared in the last hour
# Note: Quotes around $() are required for zsh compatibility with pipes
RECENT_IMAGE="$(/usr/bin/find ~/.claude/image-cache -name '*.png' -type f -mmin -60 -print0 2>/dev/null | xargs -0 /bin/ls -t 2>/dev/null | head -1)" && \
([ -n "$RECENT_IMAGE" ] && echo "IMAGE FOUND: $RECENT_IMAGE" || echo "NO IMAGE")
```

Include `📷 Image de référence` section in seed.md only if image found.

### 3c. GATHER CLARIFICATIONS (only if `--brainstorm` flag)

Skip this step if no `--brainstorm` flag.

**ULTRA THINK**: Analyze the task description to identify what needs clarification:
- **Vague adjectives** ("better", "faster", "improved") → Ask for specific metrics or outcomes
- **Multiple aspects** mentioned without priority → Ask which is most critical
- **Missing scope** → Ask what's explicitly excluded
- **Missing audience** → Ask who will use/benefit from this
- **Unclear approach** → Ask for preferred implementation style
- **Technical gaps** → Ask about error handling, edge cases, constraints
- **UX implications** → Ask about expected behavior, user feedback, loading states
- **Tradeoffs** → Ask about preferences between competing approaches

**Interview until complete** using `AskUserQuestion`:

Continue asking questions in rounds until the user signals satisfaction ("c'est bon", "let's proceed", "that's all", etc.). Each round should ask 2-3 focused questions, then wait for responses before continuing.

Use collaborative "What/How" framing (not accusatory "Why"). Questions should be **specific to the task description**, not generic.

**Good questions** (contextual):
- "You mentioned X, Y, and Z. Which aspect is most critical to get right first?"
- "Should this include [potential scope item] or is that out of scope?"
- "Is this for [user type A] or [user type B]?"
- "How should [component] handle [specific error case]?"
- "What's the expected behavior when [edge case] happens?"
- "Would you prefer [approach A] (faster) or [approach B] (more maintainable)?"
- "Should [feature] provide visual feedback during [async operation]?"

**Bad questions** (generic):
- "What are your requirements?" (too vague)
- "Why do you want this?" (accusatory framing)
- "Can you describe the feature?" (already have description)

**FORBIDDEN questions** (NEVER ask these):
- "What's the priority of this task?"
- "When should this be completed?"
- "What order should we tackle these in?"
- "What's the deadline?"
- "Should we do this before or after [other task]?"

**Rationale**: APEX handles task ordering automatically via dependency analysis. Project management questions are irrelevant and waste the user's time.

**Continuation loop**:
1. Ask 2-3 contextual questions
2. Wait for user responses
3. If user signals completion → proceed to Step 3d
4. If more clarity needed → ask 2-3 more questions and repeat

### 3d. SYNTHESIZE & CONFIRM (only if `--brainstorm` flag)

**After receiving answers**, provide a detailed synthesis of each point:

1. **Reformulate each response** with your interpretation
2. **Give a concrete example** of what you understood (ASCII mockup, pseudo-code, workflow)
3. **Highlight implications** for implementation
4. **Ask for confirmation**: "Est-ce bien ce que tu avais en tête ?"

**Example synthesis format:**

```
**[Topic from question]** - Je l'ai interprété comme :

[Detailed explanation of what you understood]

[Concrete example: ASCII mockup, pseudo-code, or workflow description]

**Implications pour l'implémentation:**
- [What this means for the technical approach]
- [Constraints or patterns this suggests]

Est-ce bien ça ? Ou tu voyais les choses différemment ?
```

**Why this step matters:**
- Prevents misalignment before seed generation
- Surfaces misunderstandings early
- Gives user chance to course-correct

**If user corrects understanding**: Update interpretation and re-confirm before proceeding.

**Store final confirmed responses** for inclusion in seed.md under `💬 Clarifications` section.

### 4. STRUCTURE SEED CONTENT (BLUF Pattern)

Generate a **condensed, actionable** seed prompt following **BLUF (Bottom Line Up Front)**.

**If `--brainstorm` was used**: Incorporate clarification responses into the relevant seed sections (Objectif, Spécifications) and include the `💬 Clarifications` section.

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

## 📷 Image de référence (si applicable)

> **Note**: Image partagée pendant `/apex:handoff`. Sera analysée par `vision-analyzer` lors de `/apex:1-analyze`.

| Image | Path |
|-------|------|
| Screenshot partagé | `[PATH_FROM_STEP_3b]` |

## 💬 Clarifications (si applicable)

> Questions posées via `--brainstorm` flag

| Question | Réponse |
|----------|---------|
| [Question posée] | [Réponse utilisateur] |

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
mkdir -p $TASKS_DIR/NN-task-name
```
(Replace `NN-task-name` with the actual folder name from step 2)

**Step 5b**: Use the **Write tool** to create `seed.md`
- Path: `$TASKS_DIR/NN-task-name/seed.md`
- Content: The generated seed from step 4

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
📁 Created: $TASKS_DIR/84-optimize-ai-flow/seed.md

## Next step (copied to clipboard)

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
# Standard
/apex:handoff "Optimize the AI conversation flow"

# With image for deep vision analysis (share image before running)
/apex:handoff "Implement this design" --vision

# With brainstorm for vague task descriptions
/apex:handoff "améliorer le système de tracking" --brainstorm

# Both flags together
/apex:handoff "implement the new design" --vision --brainstorm
```

---

User: $ARGUMENTS
