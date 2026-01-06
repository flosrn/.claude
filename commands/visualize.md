---
description: Generate architecture visualization (ASCII, Mermaid, or Sketch infographic) from any code path
argument-hint: <path> [--style ascii|mermaid|sketch] [--output readme|claude] [--task <folder>] [--model ...]
allowed-tools: Bash, Read, Glob, Grep, Write, Task, Skill
---

You are an architecture visualization specialist. Analyze code structure and generate clear visual representations.

<critical>
## ⚠️ EXHAUSTIVE ANALYSIS IS MANDATORY

**The quality of your visualization depends entirely on the depth of your analysis.**

Before generating ANY diagram:
1. **READ EVERY FILE** in the target directory - no exceptions
2. **CREATE A COMPLETE INVENTORY** of all components found
3. **VERIFY 100% COVERAGE** before proceeding to rendering
4. **DO NOT SKIP files** because they "seem less important"

**Common failure modes to avoid:**
- Running `tree -L 3` and stopping there (misses deep files)
- Reading only "key" files like index.ts (misses utilities, helpers, variants)
- Assuming you understand the system after reading 2-3 files
- Generating the visualization before completing the inventory

**If the resulting diagram is incomplete, it's because you didn't read enough files.**
</critical>

## Argument Parsing

Parse `$ARGUMENTS` to extract:

1. **Path** (required): First non-flag argument - directory or file to analyze
2. **--style** or **-s** (optional): Output format
   - `ascii` - Box-drawing terminal diagram
   - `mermaid` - GitHub-renderable flowchart (default)
   - `sketch` - AI-generated infographic via Gemini
   - `all` - Generate all 3 formats
3. **--output** or **-o** (optional): Injection target
   - `readme` - Inject into README.md
   - `claude` - Inject into CLAUDE.md
   - *(none)* - Save to task folder or `docs/assets/`
4. **--task** or **-t** (optional): APEX task folder name
   - Example: `--task 21-visualize-architecture`
   - Saves outputs to `.claude/tasks/<task-folder>/assets/`
   - Auto-detected from conversation context if not specified
5. **--model** or **-m** (optional): Gemini model for sketch style
   - `gemini-3-pro-image-preview` - Best quality, superior text rendering (default)
   - `gemini-2.5-flash-image` - Faster, cheaper, good for simple diagrams

**Default behavior**: `--style mermaid` (best for LLM comprehension)

## Slug Generation

Generate a kebab-case slug from the path:
- Lowercase everything
- Replace `/`, `\`, spaces, special chars with `-`
- Remove leading `.` or `~`
- Max 40 characters
- Examples:
  - `src/auth` → `src-auth`
  - `~/.claude/commands` → `claude-commands`
  - `./apps/web/components` → `apps-web-components`

## Output Directory Detection

**APEX Task Context Detection**:
Before generating outputs, check if running within an APEX task context:

```bash
# Check for APEX task folder pattern in recent conversation context
# Look for: .claude/tasks/<task-folder>/
```

**Output directory priority**:
1. **If APEX task context detected** (e.g., `/apex:3-execute 21-visualize-architecture`):
   - Save to: `.claude/tasks/<task-folder>/assets/architecture-{slug}.{ext}`
   - Create `assets/` subfolder if needed
   - Example: `.claude/tasks/21-visualize-architecture/assets/architecture-apex.png`

2. **If `--output readme|claude`** specified:
   - Inject into target file (README.md or CLAUDE.md)
   - Still save standalone copy to task folder or `docs/assets/`

3. **Default (no APEX context, no --output)**:
   - Save to: `docs/assets/architecture-{slug}.{ext}` (project root)
   - Create `docs/assets/` if needed

**Detection heuristic**:
- Look for task folder path in conversation context
- Check if `.claude/tasks/*/analyze.md` or `plan.md` was recently read
- If found, extract `<task-folder>` name and use that path

---

## Phase 1: Deep Analysis Pipeline (CRITICAL)

**⚠️ EXHAUSTIVE ANALYSIS REQUIRED**: You MUST read and understand ALL files before generating any visualization. Superficial analysis leads to incomplete diagrams.

### Step 1: Full Directory Scan
```bash
# Get COMPLETE file inventory (no depth limit)
tree <path> --noreport -I "node_modules|.git|dist|build|__pycache__|.next|*.lock|*.log"

# Count total files to analyze
find <path> -type f \( -name "*.md" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.py" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) | wc -l
```

**Record the file count** - you will verify against this at the end.

### Step 2: Create File Inventory

**READ EVERY FILE** in the target directory. Create a structured inventory:

```markdown
## File Inventory: <path>

| # | File | Type | Purpose | Key Elements |
|---|------|------|---------|--------------|
| 1 | `file1.md` | Command | [1-line purpose] | [key concepts, flags, outputs] |
| 2 | `file2.ts` | Module | [1-line purpose] | [exports, dependencies] |
| ... | ... | ... | ... | ... |

**Total files read**: X / Y (must be 100%)
```

**File reading strategy**:
- Use `Glob` to find all files matching patterns
- Use `Read` on EVERY file (not just "key" files)
- For large directories (>20 files): Use `Task` with `subagent_type="Explore"` for parallel reading

### Step 3: Extract ALL Components

For each file read, extract:

1. **Commands/Entry Points**: What can be invoked? What are the triggers?
2. **Phases/Stages**: Is there a workflow? What are the steps?
3. **Artifacts/Outputs**: What files/data does it create?
4. **Dependencies**: What does it need? What does it call?
5. **Modes/Flags**: What variations exist? What options?
6. **Agents/Subagents**: What specialized tools does it use?

**Create a component checklist**:
```markdown
## Components Found

### Commands (X total)
- [ ] Command 1: purpose
- [ ] Command 2: purpose
...

### Phases (X total)
- [ ] Phase 1: purpose
- [ ] Phase 2: purpose
...

### Artifacts (X total)
- [ ] artifact1.md: created by X
- [ ] artifact2.md: created by Y
...

### Modes/Features (X total)
- [ ] Mode 1: description
- [ ] Mode 2: description
...
```

### Step 4: Map Relationships

Create explicit relationship mappings:

```markdown
## Relationships

### Flow (sequential)
A → B → C → D

### Branches (conditional)
A → {condition} → B or C

### Parallel
A → [B ‖ C ‖ D] → E

### Cycles
A → B → ... → A (via handoff/seed)
```

### Step 5: Verify Completeness

**CRITICAL CHECKPOINT** - Before proceeding to rendering:

```markdown
## Completeness Check

- [ ] All files read: X/X (100%)
- [ ] All commands documented: X/X
- [ ] All phases identified: X/X
- [ ] All artifacts mapped: X/X
- [ ] All relationships traced: X/X
- [ ] No orphan components (everything connected)

**Missing elements**: [list any gaps found]
```

**If completeness < 100%**: Go back and read missing files before continuing.

### Step 6: Build Comprehensive Mental Model

Synthesize into a **structured summary** (this will drive the visualization):

```markdown
## Architecture Summary: <system-name>

### Overview
[2-3 sentence description of what this system does]

### Entry Points
1. **[Entry 1]**: [how users start]
2. **[Entry 2]**: [alternative entry]

### Main Flow
[Describe the primary happy path through the system]

### Secondary Flows
- [Flow 1]: [when/why this path is taken]
- [Flow 2]: [when/why this path is taken]

### Components by Category

#### Category 1: [name]
| Component | Purpose | Inputs | Outputs |
|-----------|---------|--------|---------|
| ... | ... | ... | ... |

#### Category 2: [name]
| Component | Purpose | Inputs | Outputs |
|-----------|---------|--------|---------|
| ... | ... | ... | ... |

### Special Features
- **[Feature 1]**: [how it modifies behavior]
- **[Feature 2]**: [how it modifies behavior]

### File Artifacts
| Artifact | Created By | Purpose |
|----------|------------|---------|
| ... | ... | ... |
```

**This summary is your source of truth for Phase 2 rendering.**

---

## Phase 2: Rendering

### If style = `ascii`

Generate box-drawing diagram following this pattern:

```
┌─────────────────┐
│   Entry Point   │ Where execution starts
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Core Logic    │ Main functionality
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌────────┐ ┌────────┐
│ Dep A  │ │ Dep B  │ Supporting modules
└────────┘ └────────┘
```

**Rules**:
- Use `│`, `─`, `┌`, `┐`, `└`, `┘`, `┬`, `┴`, `├`, `┤`, `▼`, `▶` characters
- Include annotations on the right side
- Group related components visually
- Show direction of dependencies with arrows

**Output**: Display in terminal + save to `docs/assets/architecture-{slug}.txt`

---

### If style = `mermaid`

Generate Mermaid flowchart following this pattern:

```mermaid
flowchart TD
    subgraph "Layer Name"
        A[Component A]
        B[Component B]
    end

    subgraph "Another Layer"
        C[Component C]
        D[(Database)]
    end

    A --> C
    B --> C
    C --> D
```

**Node shapes**:
- `[Text]` - Standard component
- `(Text)` - Rounded (utilities, helpers)
- `[(Text)]` - Database/storage
- `{Text}` - Decision point
- `{{Text}}` - External service/API

**Rules**:
- Use `flowchart TD` (top-down) by default
- Use `flowchart LR` for wide architectures
- Group related components in `subgraph`
- Label arrows with relationship type when not obvious
- Keep node names short (max 20 chars)

**Output**: Save to `docs/assets/architecture-{slug}.md` with proper code fence

**💡 User tip**: After generation, suggest visualizing with:
```bash
mermaid-preview docs/assets/architecture-{slug}.md
```
This alias renders the diagram to PNG and opens it in Preview automatically.

---

### If style = `sketch`

**⚠️ PREREQUISITE**: You MUST have completed Phase 1 with a full Architecture Summary before building the prompt. The sketch will only be as complete as your analysis.

**Build the prompt using your Architecture Summary from Step 6**:

1. **Count total components** from your summary (commands + phases + artifacts + features)
2. **Group into 3-4 columns** by category (e.g., Entry, Phases, Utilities, Artifacts)
3. **Number ALL components** sequentially (1/, 2/, 3/... up to N)
4. **Include ALL elements** - nothing should be omitted

**Prompt template** (hand-drawn whiteboard cheatsheet style):

```
Create a hand-drawn infographic cheatsheet about [SYSTEM NAME from Architecture Summary].

STYLE: Hand-drawn whiteboard sketch, notebook doodle aesthetic, like a developer's personal notes
BACKGROUND: Warm cream/beige paper texture, slightly aged
LINE WORK: Imperfect hand-drawn lines, ballpoint pen strokes, casual sketchy feel
COLORS: Soft muted blues, warm browns, sepia tones - NO neon, NO dark backgrounds

TOTAL COMPONENTS: [X] items across [Y] columns
LAYOUT: [Y] columns with numbered sections (1/, 2/, 3/...), curved arrows connecting ideas

CONTENT (describe EVERY component from Architecture Summary):

Column 1 - [CATEGORY from Summary]:
- 1/ [COMPONENT] with [icon], '[purpose from summary]'
- 2/ [COMPONENT] with [icon], '[purpose]'
- 3/ [COMPONENT] with [icon], '[flags/options if any]'

Column 2 - [CATEGORY from Summary]:
- 4/ [COMPONENT] with [icon], '[purpose]'
- 5/ [COMPONENT] with [icon], '[sub-elements: a, b, c]'
- 6/ [COMPONENT] with [icon], '[outputs: file1, file2]'

Column 3 - [CATEGORY from Summary]:
- 7/ [COMPONENT] with [icon], '[purpose]'
- 8/ [COMPONENT] with [icon], '[purpose]'
- 9/ [COMPONENT] with [icon], '[purpose]'

Column 4 - [CATEGORY from Summary] (if needed):
- 10/ [COMPONENT] with [icon], '[purpose]'
- 11/ [COMPONENT] with [icon], '[purpose]'

[SPECIAL FEATURES from Summary]:
- Side element: [icon] labeled '[feature name]' (e.g., YOLO mode with lightning bolt)
- Another element: [icon] labeled '[feature name]'

FLOW ARROWS (from Relationships mapping):
- Show: [Entry] → [Phase 1] → [Phase 2] → ... → [End]
- Show branches: [Decision] splits to [Option A] or [Option B]
- Show cycles: [End] loops back to [Start] via [mechanism]

TOP: Title '[SYSTEM NAME] CHEATSHEET' in hand-written style
BOTTOM: Small legend explaining icons if >10 components

ICONS: Simple line drawings - magnifying glass (analyze), blueprint (plan), gears (execute), checkmark (validate), document (files), lightning (fast mode), etc.
ANNOTATIONS: Small handwritten notes next to each element explaining purpose
FEEL: Friendly, approachable, like a senior dev explaining on a whiteboard
```

**Completeness verification before generating**:
- [ ] All commands from inventory included
- [ ] All phases/stages included
- [ ] All artifacts/outputs included
- [ ] All modes/features included
- [ ] All relationships shown as arrows
- [ ] Component count matches Architecture Summary

**Execution**:
1. Run the ai-multimodal skill via wrapper script:
   ```bash
   cd ~/.claude/skills/ai-multimodal && ./scripts/run.sh gemini_batch_process.py \
     --task generate \
     --prompt "[YOUR PROMPT FROM ABOVE]" \
     --output docs/assets/architecture-{slug}.png \
     --model gemini-3-pro-image-preview \
     --aspect-ratio 16:9
   ```
   - The wrapper script auto-manages the Python venv
   - Use `--model gemini-2.5-flash-image` for faster/cheaper option

2. Generate legend backup at `docs/assets/architecture-{slug}-legend.md`:
   ```markdown
   # Architecture Legend: {slug}

   ## Components
   - **[Name]**: [Description]

   ## Connections
   - [A] → [B]: [Relationship]

   ## Style Notes
   - Hand-drawn whiteboard aesthetic
   - Cream/beige background with soft blue accents
   - Numbered sections with curved arrow flow
   ```

**Prompt tips for best results**:
- Describe the FEELING: "like a senior dev explaining on a whiteboard"
- Specify what you DON'T want: "NO neon, NO dark backgrounds"
- Use warm color words: "cream, beige, soft muted blues, sepia"
- Describe line quality: "imperfect, sketchy, ballpoint pen strokes"

---

### If style = `all`

Execute all three renderings sequentially:
1. Generate ASCII → save to `.txt`
2. Generate Mermaid → save to `.md`
3. Generate Sketch → save to `.png` + `-legend.md`

Report all output paths when complete.

---

## Phase 3: Output Routing

### If `--output readme`

1. Find `README.md` in project root (relative to analyzed path)
2. Search for existing architecture section:
   - Look for `## Architecture`, `## System Architecture`, `## Design`
3. If found: Replace content under that heading (until next `##`)
4. If not found: Append new section at end:
   ```markdown

   ## Architecture

   [Generated content here]
   ```
5. For Mermaid: Inject code block directly (GitHub renders it)
6. For ASCII: Wrap in triple-backtick code block
7. For Sketch: Add image reference `![Architecture](docs/assets/architecture-{slug}.png)`

### If `--output claude`

1. Find `CLAUDE.md` in project root (check both `./CLAUDE.md` and `./.claude/CLAUDE.md`)
2. **Important**: CLAUDE.md should be <200 lines - keep additions concise
3. Search for existing architecture section
4. If found: Replace with updated diagram
5. If not found: Add after initial project description (not at very top)
6. **Always prefer Mermaid** for `--output claude` (best LLM comprehension)
7. If user specified `--style ascii`, warn that Mermaid is recommended for CLAUDE.md

### If no `--output` (default)

1. Create `docs/assets/` directory if it doesn't exist
2. Save file(s) based on style:
   - ASCII: `docs/assets/architecture-{slug}.txt`
   - Mermaid: `docs/assets/architecture-{slug}.md`
   - Sketch: `docs/assets/architecture-{slug}.png` + `-legend.md`
3. Display result in terminal:
   - ASCII: Show the diagram directly
   - Mermaid: Show "Saved to {path}" + suggest `mermaid.live` for preview
   - Sketch: Show "Generated at {path}"

---

## Terminal Output

After completion, display:

```
✓ Architecture visualization complete

Style: [ascii|mermaid|sketch]
Path analyzed: [input path]
Output: [file path or "injected into README.md"]

[For ASCII: display the diagram]
[For Mermaid: show code block or file path]
[For Sketch: show file path]
```

---

## Error Handling

- **Path doesn't exist**: Error with "Path not found: {path}"
- **Empty directory**: Warn "No source files found in {path}"
- **Sketch mode fails**: Fall back to Mermaid + suggest checking API key
- **No write permission**: Show diagram in terminal only

---

## Examples

```bash
# Default: Mermaid diagram to docs/assets/
/visualize src/auth

# ASCII for terminal viewing
/visualize src/api --style ascii

# Sketch infographic (best quality - default model)
/visualize ./apps/web -s sketch

# Sketch with faster/cheaper model
/visualize ./apps/web -s sketch --model gemini-2.5-flash-image

# Save to APEX task folder (explicit)
/visualize ~/.claude/commands/apex -s sketch --task 21-visualize-architecture
# → Output: .claude/tasks/21-visualize-architecture/assets/architecture-apex.png

# Auto-detect task context (when running within /apex workflow)
/visualize src/auth -s mermaid
# → If in APEX task context, saves to task's assets/ folder

# Inject Mermaid into README
/visualize . --output readme

# All formats
/visualize src/core --style all
```

---

User input: $ARGUMENTS
