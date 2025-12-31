---
description: Analyze phase - gather all context and create analysis report
argument-hint: <task-description> [--background] [--yolo]
---

You are an analysis specialist. Your mission is to gather ALL relevant context before implementation.

**You need to ULTRA THINK before launching agents.**

## Argument Parsing

Parse the argument for:
- **Task folder** (e.g., `84-optimize-flow`) → Use existing folder, check for seed.md
- **Task description** (e.g., "Optimize AI flow") → Create new folder
- `--background` flag → **BACKGROUND MODE** (agents run async while you ask clarifying questions)
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
3. **Handle Artifacts section** (📚 Artifacts source):
   - Note the artifact paths but **DON'T read them automatically**
   - Only read referenced artifacts if needed during analysis
   - This is **lazy loading** - saves tokens until content is required
4. **Use this context** to inform your ULTRA THINK and agent prompts
5. **Skip folder creation** (folder already exists)
6. → Continue to Step 2 (ULTRA THINK)

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

### 2b. VISION DETECTION (automatic from image cache)

**How it works**: When the user shares an image (drag & drop or Ctrl+V), Claude Code stores it in `~/.claude/image-cache/<uuid>/N.png`. We detect recent images automatically.

**Step 2b-1**: Check for recent images in Claude Code cache
```bash
# Find images shared in the last 5 minutes
RECENT_IMAGE=$(/usr/bin/find ~/.claude/image-cache -name "*.png" -type f -mmin -5 -print0 2>/dev/null | xargs -0 /bin/ls -t 2>/dev/null | head -1)
[ -n "$RECENT_IMAGE" ] && echo "IMAGE FOUND: $RECENT_IMAGE" || echo "NO RECENT IMAGE"
```

**Step 2b-2**: Also check for explicit image paths in user message
- Look for paths: `/tmp/`, `/var/folders/`, `/Users/*/Desktop/`, `~/.claude/image-cache/`
- Look for extensions: `.png`, `.jpg`, `.jpeg`, `.webp`, `.heic`, `.heif`
- User mentions: "screenshot", "image", "mockup", "photo", "picture"

**If images detected** (either from cache or explicit path):
- Add `vision-analyzer` to the parallel agent launch (Step 3)
- Pass the detected image path to the agent
- The vision analysis will be merged into the final analyze.md

**Priority order**:
1. Explicit path in user message (if provided)
2. Most recent image in `~/.claude/image-cache/` (if < 5 min old)

3. **LAUNCH PARALLEL ANALYSIS**: Gather context from all sources

   ### Standard Mode (default)
   - **Codebase exploration** (`explore-codebase` agent):
     - Find similar implementations to use as examples
     - Locate files that need modification
     - Identify existing patterns and conventions
     - Search for related utilities and helpers

   - **Documentation exploration** (`explore-docs` agent):
     - Search library docs for APIs and patterns
     - Find best practices for tools being used
     - Gather code examples from official docs

   - **Web research** (`websearch` agent):
     - Research latest approaches and solutions
     - Find community examples and patterns
     - Gather architectural guidance

   - **Vision analysis** (`vision-analyzer` agent) - **ONLY if images detected in Step 2b**:
     - Analyze UI screenshots for debugging context
     - Extract page state and visible elements
     - Identify visual issues or design patterns
     - Uses Claude Opus 4.5 for superior visual understanding
     ```
     Task(
       subagent_type="vision-analyzer",
       model="opus",
       prompt="Analyze this UI screenshot.

       **Image path**: [path from Step 2b - either explicit or from ~/.claude/image-cache/]

       Context: [user's task description]

       Provide analysis focusing on: page identification, visible elements, potential issues.",
       run_in_background=true  // or false depending on mode
     )
     ```

   - **Symbol navigation** (cclsp MCP tools):
     - "Where is X defined?" → `mcp__cclsp__find_definition`
     - "Where is X used?" → `mcp__cclsp__find_references`
     - cclsp provides semantic understanding (not text matching), preventing false positives

   - **CRITICAL**: Launch ALL agents in parallel in a single message

   ### Background Mode (`--background`)
   When `--background` flag is detected:

   1. **Launch agents with `run_in_background: true`**:
      ```
      Task(subagent_type="explore-codebase", run_in_background=true, ...)
      Task(subagent_type="explore-docs", run_in_background=true, ...)
      Task(subagent_type="websearch", run_in_background=true, ...)
      ```

   2. **Immediately ask clarifying questions** using `AskUserQuestion`:
      - "What specific problem are you trying to solve?"
      - "Are there existing patterns or code you'd like me to follow?"
      - "Any constraints or preferences I should know about?"
      - Customize questions based on the task description

   3. **Store user responses** for synthesis step

   4. **Check agent status** periodically with `TaskOutput`:
      - If still running: continue conversation or wait
      - When complete: proceed to synthesis

4. **SYNTHESIZE FINDINGS**: Create comprehensive analysis report
   - Combine findings from all agents
   - Organize by topic/concern
   - Include file paths with line numbers (e.g., `src/auth.ts:42`)
   - List relevant examples found in codebase
   - Document key patterns and conventions to follow
   - Note any dependencies or prerequisites
   - **Background Mode**: Include user clarifications gathered during agent execution

5. **SAVE ANALYSIS**: Write to `analyze.md`
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

     ## User Clarifications (if --background used)
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

6. **REPORT**: Summarize to user
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
