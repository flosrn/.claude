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

## Workflow

### 0. CHECK FOR SEED CONTEXT (if folder provided)

If the argument is an **existing task folder** (e.g., `84-optimize-flow`):

**Step 0a**: Detect tasks directory and check for seed.md in ONE command
```bash
# Auto-detect TASKS_DIR: use 'tasks' if in ~/.claude, else '.claude/tasks'
TASKS_DIR=$(if [ -d "tasks" ] && [ "$(basename $(pwd))" = ".claude" ]; then echo "tasks"; else echo ".claude/tasks"; fi) && \
/bin/ls "$TASKS_DIR/<provided-folder>/seed.md" 2>/dev/null && echo "SEED FOUND in $TASKS_DIR" || echo "NO SEED (checked $TASKS_DIR)"
```

**Remember the TASKS_DIR** value from output for all subsequent commands!

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

**Step 1a**: Detect TASKS_DIR and find next folder number
```bash
# Auto-detect TASKS_DIR and find last folder number
TASKS_DIR=$(if [ -d "tasks" ] && [ "$(basename $(pwd))" = ".claude" ]; then echo "tasks"; else echo ".claude/tasks"; fi) && \
echo "TASKS_DIR=$TASKS_DIR" && \
/bin/ls -1 "$TASKS_DIR" 2>/dev/null | /usr/bin/grep -E '^[0-9]+-' | sort -t- -k1 -n | tail -1
```

**Step 1b**: Based on output, calculate NEXT number:
- If last folder is `06-something` → NEXT is `07`
- If empty → NEXT is `01`

**Step 1c**: Create the folder using the detected TASKS_DIR
```bash
# Use the TASKS_DIR from Step 1a output (replace <NN> and <KEBAB-NAME>)
mkdir -p <TASKS_DIR>/<NN>-<KEBAB-NAME>
```

**KEBAB-CASE RULE**: Convert task description to lowercase, replace spaces/special chars with `-`
- "Add user authentication" → `add-user-authentication`
- "Fix AI campaign creator bug" → `fix-ai-campaign-creator-bug`

**YOLO MODE**: If `--yolo` flag, also run:
```bash
touch <TASKS_DIR>/<NN>-<KEBAB-NAME>/.yolo
```

2. **ULTRA THINK**: Plan analysis strategy
   - **CRITICAL**: Know EXACTLY what to search for before launching agents
   - Identify key concepts, files, patterns to find
   - Determine which sources need analysis (codebase/docs/web)
   - List specific questions each agent should answer

3. **LAUNCH PARALLEL ANALYSIS**: Gather context from all sources

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
   Task(subagent_type="explore-codebase", run_in_background=true, ...)
   Task(subagent_type="explore-docs", run_in_background=true, ...)
   Task(subagent_type="websearch", run_in_background=true, ...)
   ```

   - **CRITICAL**: Launch ALL agents in a SINGLE message

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
   - Save to `$TASKS_DIR/nn-task-name/analyze.md`
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
