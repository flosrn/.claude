---
description: Analyze phase - gather all context and create analysis report
argument-hint: <task-description> [--yolo]
---

You are an analysis specialist. Your mission is to gather ALL relevant context before implementation.

**You need to ULTRA THINK before launching agents.**

## Argument Parsing

Parse the argument for:
- **Task folder** (e.g., `84-optimize-flow`) → Use existing folder, check for seed.md
- **Task description** (e.g., "Optimize AI flow") → Create new folder
- `--yolo` flag → **YOLO MODE** (autonomous workflow - auto-continues to next phase after completion)

**Detection rule**: If argument starts with a number followed by `-`, it's a folder name.

**⚠️ PATH**: Always use `./.claude/tasks/<folder>/` for file reads (NOT `tasks/<folder>/`).

## Workflow

### 0. CLARITY CHECK (before everything)

**Analyze `$ARGUMENTS` for vagueness indicators:**

Vague patterns to detect:
- **Vague adjectives**: "améliorer", "optimiser", "mieux", "better", "improve", "enhance"
- **Missing specifics**: No file paths, no concrete outcome mentioned
- **Exploratory language**: "explorer", "réfléchir", "brainstorm", "explore", "investigate"
- **Question framing**: "comment faire", "quelle approche", "how to", "what's the best way"

**If 2+ vagueness indicators detected:**

Use `AskUserQuestion`:
- **Question**: "Cette tâche semble exploratoire. Veux-tu clarifier l'approche d'abord ?"
- **Header**: "Clarify?"
- **Options**:
  1. **Label**: "Lancer /apex:0-brainstorm"
     **Description**: "Phase d'exploration interactive avant l'analyse"
  2. **Label**: "Q&A rapide (2-3 questions)"
     **Description**: "Quelques questions de clarification inline"
  3. **Label**: "Continuer directement"
     **Description**: "Passer à l'analyse sans clarification"

**Based on user's choice:**

- **Option 1 (Brainstorm)**: Display:
  ```
  ══════════════════════════════════════════════════
  💡 Pour explorer cette tâche en profondeur, lance :

     /apex:0-brainstorm $ARGUMENTS

  Cela générera un seed.md que tu pourras ensuite
  analyser avec /apex:1-analyze <folder>
  ══════════════════════════════════════════════════
  ```
  Then **STOP** - do not continue to Step 0a.

- **Option 2 (Q&A rapide)**: Ask 2-3 focused clarifying questions using `AskUserQuestion`:
  - Questions should target the vague aspects detected
  - Adapt to context (tech vs product vs problem-solving)
  - After receiving answers, store them and continue to Step 0a
  - Include answers in the "User Clarifications" section of analyze.md

- **Option 3 (Continue)**: Skip directly to Step 0a

**If task is CLEAR (fewer than 2 indicators):** Skip this step, proceed to Step 0a.

---

### 0a. CHECK FOR SEED CONTEXT (if folder provided)

If the argument is an **existing task folder** (e.g., `84-optimize-flow`):

**Step 0a**: Check for seed.md and get ABSOLUTE path
```bash
# ⚠️ DO NOT SIMPLIFY: .claude/tasks is INSIDE the .claude project folder (intentional nesting)
APEX_TASKS_DIR="$(pwd)/.claude/tasks" && \
TASK_FOLDER="$APEX_TASKS_DIR/<provided-folder>" && \
echo "📁 APEX TASKS DIR: $APEX_TASKS_DIR" && \
echo "📁 READ FROM: $TASK_FOLDER" && \
/bin/ls -la "$TASK_FOLDER/"
```

**Step 0b**: Read seed.md using the FULL path from output (starts with /Users/...)

**If `seed.md` exists:**
1. **Read it** - This contains context from a previous session via `/apex:handoff`
2. **Extract from BLUF structure**:
   - 🎯 Objectif (the task description - FIRST section)
   - 📂 Point de départ (critical files to explore FIRST)
   - ⚠️ Pièges à éviter (gotchas - don't repeat these mistakes)
   - 📋 Spécifications (requirements and decisions)
   - 🔍 Contexte technique (optional background - read if needed)
3. **Handle Image section** (📷 Image de référence) - if present:
   - Extract the image path from the table
   - This image will be passed to `vision-analyzer` in Step 3
4. **Handle Artifacts section** (📚 Artifacts source):
   - Note the artifact paths but **DON'T read them automatically**
   - Only read referenced artifacts if needed during analysis
   - This is **lazy loading** - saves tokens until content is required
5. **Use this context** to inform your ULTRA THINK and agent prompts
6. **Skip folder creation** (folder already exists)
7. → Continue to Step 2 (ULTRA THINK)

**If no seed.md or new description provided:**
→ Continue to Step 1 (SETUP TASK FOLDER)

### 1. SETUP TASK FOLDER (skip if folder already exists)

Create organized workspace in **separate steps**:

**Step 1a**: Find next folder number
```bash
# ⚠️ DO NOT SIMPLIFY: .claude/tasks is INSIDE the .claude project folder (intentional nesting)
APEX_TASKS_DIR="$(pwd)/.claude/tasks" && \
mkdir -p "$APEX_TASKS_DIR" && \
echo "📁 APEX TASKS DIR: $APEX_TASKS_DIR" && \
/bin/ls -1 "$APEX_TASKS_DIR" 2>/dev/null | /usr/bin/grep -E '^[0-9]+-' | sort -t- -k1 -n | tail -1
```

**Step 1b**: Based on output, calculate NEXT number:
- If last folder is `06-something` → NEXT is `07`
- If empty → NEXT is `01`

**Step 1c**: Create folder AND get path for Write
```bash
# ⚠️ DO NOT SIMPLIFY: .claude/tasks is INSIDE the .claude project folder (intentional nesting)
APEX_TASKS_DIR="$(pwd)/.claude/tasks" && \
TASK_FOLDER="$APEX_TASKS_DIR/<NN>-<KEBAB-NAME>" && \
mkdir -p "$TASK_FOLDER" && \
echo "═══════════════════════════════════════════════" && \
echo "📁 TASK FOLDER: $TASK_FOLDER" && \
echo "📝 WRITE TO:    $TASK_FOLDER/analyze.md" && \
echo "═══════════════════════════════════════════════"
```

**⚠️ COPY THE EXACT PATH shown above for the Write tool.**

**KEBAB-CASE RULE**: Convert task description to lowercase, replace spaces/special chars with `-`
- "Add user authentication" → `add-user-authentication`
- "Fix AI campaign creator bug" → `fix-ai-campaign-creator-bug`

**YOLO MODE**: If `--yolo` flag, also run:
```bash
touch ./.claude/tasks/<NN>-<KEBAB-NAME>/.yolo
```

2. **ULTRA THINK**: Plan analysis strategy
   - **CRITICAL**: Know EXACTLY what to search for before launching agents
   - Identify key concepts, files, patterns to find
   - Determine which sources need analysis (codebase/docs/web)
   - List specific questions each agent should answer

3. **LAUNCH PARALLEL ANALYSIS**: Gather context from all sources

   **First, determine analysis mode based on seed.md content:**

   ### Mode A: Post-Brainstorm (seed.md has "Brainstorm Summary")

   If seed.md exists AND contains `## 🔍 Brainstorm Summary` or `### Brainstorm Summary`:
   - Brainstorm already performed web research and docs exploration
   - **SKIP**: `websearch` agent (already done)
   - **SKIP**: `explore-docs` agent (already done)
   - **LAUNCH ONLY**:
     - `explore-codebase` - Focus on locating specific files to modify
     - `vision-analyzer` - If image provided

   ```
   # Post-brainstorm mode - targeted analysis only
   Task(subagent_type="explore-codebase", run_in_background=true, ...)
   Task(subagent_type="vision-analyzer", run_in_background=true, ...)  # if image
   ```

   **Why skip?** Brainstorm Round 1-3 already did comprehensive web + docs research.
   Re-running wastes tokens and time. The seed.md contains all insights needed.

   ---

   ### Mode B: Full Analysis (no brainstorm or fresh task)

   If NO seed.md OR seed.md lacks brainstorm sections:

   **Launch ALL agents in background** with `run_in_background: true`:

   - **Codebase exploration** (`explore-codebase` agent):
     - Find similar implementations to use as examples
     - Locate files that need modification
     - Identify existing patterns and conventions

   - **Documentation exploration** (`explore-docs` agent):
     - Search library docs for APIs and patterns
     - Find best practices for tools being used

   - **Web research** (`websearch` agent):
     - Research latest approaches and solutions
     - Find community examples and patterns

   - **Vision analysis** (`vision-analyzer` agent) - **ONLY if image provided**:
     - From seed.md `📷 Image de référence` section (via `--vision` flag)
     - Or drag & drop with the `/apex:1-analyze` command
     - Analyze UI screenshots for debugging context

   ```
   # Full analysis mode - all agents
   Task(subagent_type="explore-codebase", run_in_background=true, ...)
   Task(subagent_type="explore-docs", run_in_background=true, ...)
   Task(subagent_type="websearch", run_in_background=true, ...)
   Task(subagent_type="vision-analyzer", run_in_background=true, ...)  # if image
   ```

   ---

   - **CRITICAL**: Launch all required agents in a SINGLE message

   **While agents run**:
   - Wait for agent completion using `TaskOutput`
   - Do NOT ask generic questions here (they belong in step 4)

4. **CLARIFICATION**: Ask questions based on context

   **Behavior depends on seed.md presence:**

   ### If seed.md EXISTS (from `/apex:handoff`)

   The seed already contains answers to basic questions (Objectif, Spécifications, Clarifications).

   **Only ask about NEW discoveries from agents:**

   Based on **codebase exploration**:
   - "J'ai trouvé un pattern similaire dans `path/file.ts:42`. Tu veux suivre cette approche ou faire différemment ?"
   - "Il existe déjà une solution partielle dans `module/`. On l'étend ou on repart de zéro ?"

   Based on **web research**:
   - "La doc recommande [approach A], mais j'ai aussi trouvé [approach B] qui semble plus adapté à ton cas. Préférence ?"
   - "Il y a un gotcha connu avec cette lib : [issue]. Tu veux qu'on le contourne comment ?"

   **Rules for seed.md present**:
   - Skip generic questions (already in seed)
   - Only ask about discoveries that contradict or extend the seed
   - Max 1-2 questions focused on new findings
   - If discoveries align with seed → skip this step entirely

   ### If NO seed.md (new task description)

   Ask initial clarifying questions AND discovery-based questions:

   **Initial questions** (pick 2-3 relevant ones):
   - "What specific problem are you trying to solve?"
   - "Are there existing patterns or code you'd like me to follow?"
   - "Any constraints or preferences I should know about?"

   **Discovery-based questions** (from agent findings):
   - "En analysant le code, je vois une opportunité d'améliorer [X] en même temps. Ça t'intéresse ?"
   - "Le pattern actuel a [limitation]. Tu veux qu'on en profite pour refactorer ?"

   **Rules for no seed.md**:
   - Max 3-4 questions total
   - Mix of initial + discovery-based
   - Questions must include concrete file paths or findings

   **Store all responses** for final synthesis.

5. **SYNTHESIZE FINDINGS**: Create comprehensive analysis report
   - Combine findings from all agents
   - Organize by topic/concern
   - Include file paths with line numbers (e.g., `src/auth.ts:42`)
   - List relevant examples found in codebase
   - Document key patterns and conventions to follow
   - Note any dependencies or prerequisites
   - Include user clarifications gathered during agent execution

6. **SAVE ANALYSIS**: Write to `analyze.md`
   - **⚠️ Use the EXACT path from Step 1c output** (starts with `/Users/...`)
   - Path format: `<TASK_PATH>/analyze.md` where TASK_PATH was displayed earlier
   - **Note**: This file is consumed via **lazy loading** from seed.md
   - Keep "Quick Summary (TL;DR)" at TOP for optimal LLM consumption
   - **Structure**:
     ```markdown
     # Analysis: [Description]

     **Analyzed**: [Date]
     **Status**: Complete

     ## Quick Summary (TL;DR)

     > This section is the PRIMARY content consumed by lazy loading.
     > Keep it dense and actionable.

     **Key files to modify:**
     - `path/to/main-file.ts` - [Brief purpose]
     - `path/to/other-file.ts` - [Brief purpose]

     **Patterns to follow:**
     - Pattern example in `path/to/example.ts:42`

     **⚠️ Gotchas discovered:**
     - [Pitfall to avoid]

     **Dependencies:** [None blocking / List any blockers]

     **Estimation:** ~N tasks, ~Xh total

     ---

     ## Codebase Context
     [Findings from codebase exploration]

     ## Documentation Insights
     [Key information from docs]

     ## Research Findings
     [Web research results]

     ## User Clarifications
     - Q: [Question asked]
       A: [User's answer]

     ## Vision Analysis (if images provided)
     [Include the full output from vision-analyzer agent here]
     - Image type detected: [Debugging/Context/Inspiration]
     - Key findings summarized

     ## Key Files
     - `path/to/file.ts:line` - Purpose

     ## Patterns to Follow
     [Existing conventions]

     ## Dependencies
     [Prerequisites and related systems]
     ```

7. **REPORT**: Summarize to user
   - Confirm task folder created
   - Highlight key findings
   - Note any concerns or blockers discovered
   - **STANDARD MODE**: Suggest next step: Run `/apex:plan <task-folder>` to create implementation plan
   - **YOLO MODE**: Say "YOLO mode: Session will exit. Next phase will start automatically in a new split." then **STOP IMMEDIATELY** - do NOT continue to the next phase. The hooks will handle automation.

## Execution Rules

- **PARALLEL EXECUTION**: All agents must run simultaneously for speed
- **ULTRA THINK FIRST**: Never launch agents without clear search strategy
- **SMART SKIP**: If seed.md contains brainstorm results, skip redundant web/docs research
- **COMPREHENSIVE**: Gather more context than seems necessary
- **ORGANIZED**: Structure findings for easy planning phase
- **FILE REFERENCES**: Always include file paths with line numbers

## Priority

Context depth > Speed. Missing context causes failed implementations.

## See Also

- [APEX Overview](./overview.md) - Complete system documentation
- [2-plan](./2-plan.md) - Next phase: create implementation plan

---

User: $ARGUMENTS
