---
description: Generate architecture visualization (ASCII, Mermaid, or Sketch infographic) from any code path
argument-hint: <path> [--style ascii|mermaid|sketch] [--detail overview|detailed|full] [--output readme|claude] [--task <folder>] [--model ...]
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
6. **--detail** or **-d** (optional): Level of detail for sketch style
   - `overview` - 5-7 key components max, single focused sketch (default)
   - `detailed` - Sketch with zoom regions OR multiple images for complex areas
   - `full` - Layered visualization: sketch overview + Mermaid detailed + Legend.md

**Default behavior**: `--style mermaid` (best for LLM comprehension)
**Sketch default**: `--detail overview` (prevents Gemini from losing components)

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

### Step 3b: Component Count Check (for Sketch mode)

**⚠️ This step determines sketch complexity handling.**

Count total components from your inventory:
```markdown
## Component Count

| Category | Count |
|----------|-------|
| Commands | X |
| Phases | Y |
| Artifacts | Z |
| Modes/Features | W |
| **TOTAL** | **X+Y+Z+W** |
```

**Auto-escalation rules** (when `--style sketch`):

| Total Components | `--detail` not set | `--detail overview` explicit |
|-----------------|-------------------|------------------------------|
| ≤7 | Normal sketch | Normal sketch |
| 8-12 | ⚠️ Warn, auto-escalate to `full` | ⚠️ Warn, respect choice (may omit) |
| >12 | ⚠️ Force `full` mode | ⚠️ Strong warn, respect choice |

**Display warnings**:
- If auto-escalating: `"⚠️ {N} components detected (>7). Auto-enabling layered visualization for completeness."`
- If respecting override: `"⚠️ {N} components exceeds optimal limit (7). Some elements may be omitted. Consider --detail full."`

**Component prioritization** (for `overview` mode with >7 components):
1. **Entry points** - How users start (highest priority)
2. **Main flow phases** - Core workflow steps
3. **Key artifacts** - Primary outputs
4. **Special features** - Distinctive behaviors (lowest priority)

Select top 7 using this order. Store remaining for Mermaid (if `--detail full`).

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

**⚠️ PREREQUISITE**: You MUST have completed Phase 1 with a full Architecture Summary AND the Component Count Check (Step 3b) before building the prompt.

#### Detail Mode Behaviors

| Mode | Behavior |
|------|----------|
| `overview` (default) | Single sketch with max 7 components, prioritized by importance |
| `detailed` | Sketch + zoom regions for complex areas |
| `full` | Layered: sketch (7 components) + Mermaid (all) + Legend.md |

**Build the prompt using your Architecture Summary from Step 6**:

1. **Check component count** from Step 3b
2. **If ≤7**: Include all components in sketch
3. **If >7**: Select top 7 using prioritization order (entry points > phases > artifacts > features)
4. **Group into max 3 columns** (2-3 items per column)
5. **Use short labels** (2 words max per component)

#### Gemini-Optimized Prompt Template

**⚠️ Order matters** - Gemini prioritizes early content. Structure: STYLE → MOOD → COLORS → LAYOUT → CONTENT → ANTI-PATTERNS

```
Create a hand-drawn architecture sketch for [SYSTEM NAME].

### STYLE (concrete descriptors - most important)
Graphite pencil strokes with cross-hatching shading on cream paper.
Ballpoint pen marks for text labels. Imperfect hand-drawn lines.
Like a developer's notebook doodle - spontaneous, warm, approachable.

### MOOD
Friendly and playful yet professional. A senior dev explaining on a whiteboard.
Warm, inviting, makes complex systems feel accessible.

### COLORS (explicit hex codes)
- Background: #FDF6E3 (warm cream paper)
- Primary elements: #6A9FB5 (soft blue)
- Accent/highlights: #D08770 (terracotta orange)
- Ink/text: #5B4636 (sepia brown)
- Annotations: #EBCB8B (warm yellow for callouts)

### LAYOUT
Max 3 columns, 2-3 items per column.
Curved arrows connecting related elements.
Title at top in hand-lettered style.

### CONTENT (max 7 elements, 2-word labels)
Column 1 - [CATEGORY]:
- [Component 1] with [icon], label: "[2 words]"
- [Component 2] with [icon], label: "[2 words]"

Column 2 - [CATEGORY]:
- [Component 3] with [icon], label: "[2 words]"
- [Component 4] with [icon], label: "[2 words]"

Column 3 - [CATEGORY]:
- [Component 5] with [icon], label: "[2 words]"
- [Component 6] with [icon], label: "[2 words]"
- [Component 7] with [icon], label: "[2 words]"

### FLOW
[Entry] → [Step 1] → [Step 2] → [Output]

### ANTI-PATTERNS (what NOT to do)
- NO neon colors
- NO dark backgrounds
- NO more than 7 distinct elements
- NO long text labels (keep under 15 characters)
- NO photorealistic rendering
- NO complex gradients
```

#### Component Selection Verification

Before generating, verify (for `overview` mode):
- [ ] Component count ≤7 (or top 7 selected if >7 total)
- [ ] Labels are ≤2 words each
- [ ] Main flow is clear (entry → process → output)
- [ ] Color palette uses hex codes only

#### Execution by Mode

##### If `--detail overview` (default)

1. **Generate single sketch** (max 7 components):
   ```bash
   cd ~/.claude/skills/ai-multimodal && ./scripts/run.sh gemini_batch_process.py \
     --task generate \
     --prompt "[YOUR PROMPT FROM ABOVE]" \
     --output docs/assets/architecture-{slug}.png \
     --model gemini-3-pro-image-preview \
     --aspect-ratio 16:9
   ```

2. **Generate legend** at `docs/assets/architecture-{slug}-legend.md`:
   ```markdown
   # Architecture Legend: {slug}

   ## Components (7 shown in sketch)
   - **[Name]**: [Description]
   ...

   ## Omitted Components (if >7 total)
   - **[Name]**: [Description] *(not in sketch - use --detail full to see all)*

   ## Connections
   - [A] → [B]: [Relationship]
   ```

##### If `--detail detailed`

1. Generate overview sketch as above
2. For complex areas (identified in analysis), generate **zoom sketches**:
   - `architecture-{slug}-zoom-{area}.png` for each complex subsystem
   - OR generate a second sketch focusing on internal structure

##### If `--detail full` (Layered Visualization)

Generate **three complementary outputs**:

1. **Sketch Overview** (`architecture-{slug}-sketch.png`):
   - Max 7 key components using prioritization
   - Visual "wow factor" for presentations/docs

2. **Mermaid Detailed** (`architecture-{slug}-detailed.md`):
   - ALL components from Architecture Summary
   - Full relationship mapping
   - 100% complete, machine-readable
   ```mermaid
   flowchart TD
       subgraph "All Components"
           [Generate complete Mermaid from Architecture Summary]
       end
   ```

3. **Legend** (`architecture-{slug}-legend.md`):
   - Complete text descriptions for all components
   - Searchable, version-controllable
   - Maps sketch elements to detailed elements
   ```markdown
   # Architecture Legend: {slug}

   ## Overview (in sketch)
   Components 1-7 shown in visual overview...

   ## Complete Reference (in Mermaid)
   All N components with full descriptions...

   ## Style Notes
   - Sketch: Warm cream (#FDF6E3), graphite strokes
   - Mermaid: Full technical detail
   ```

#### Fallback on Failure

**If sketch generation fails** (API error, timeout, content filter):

1. **First retry**: Simplify prompt to 3-4 components only
   - Keep: Entry point, main flow (2 steps), output
   - Remove: Features, secondary artifacts

2. **If retry fails**: Auto-generate Mermaid instead
   - Display: `"⚠️ Sketch generation failed. Generating Mermaid diagram instead."`
   - Save Mermaid to: `architecture-{slug}.md`
   - Suggest: `"Consider using inpainting to enhance manually, or retry with --model gemini-2.5-flash-image"`

3. **Never leave user without output** - Mermaid is 100% reliable fallback

#### Prompt Tips (Reference)

| Goal | Technique |
|------|-----------|
| Warm feeling | Use hex: #FDF6E3, #D08770, #EBCB8B |
| Hand-drawn look | "graphite strokes", "cross-hatching", "ballpoint pen" |
| Avoid AI generic | Explicit ANTI-PATTERNS section |
| Reliable rendering | Max 7 components, 2-word labels |

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
2. Save file(s) based on style and detail mode:

   **ASCII**:
   - `docs/assets/architecture-{slug}.txt`

   **Mermaid**:
   - `docs/assets/architecture-{slug}.md`

   **Sketch** (varies by `--detail`):
   | Detail Mode | Files Generated |
   |------------|-----------------|
   | `overview` | `architecture-{slug}.png` + `architecture-{slug}-legend.md` |
   | `detailed` | Above + `architecture-{slug}-zoom-{area}.png` (per complex area) |
   | `full` | `architecture-{slug}-sketch.png` + `architecture-{slug}-detailed.md` + `architecture-{slug}-legend.md` |

3. Display result in terminal:
   - ASCII: Show the diagram directly
   - Mermaid: Show "Saved to {path}" + suggest `mermaid.live` for preview
   - Sketch (`overview`): Show "Generated at {path}"
   - Sketch (`full`): Show summary of all 3 files generated

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

# Sketch infographic (overview mode - default, max 7 components)
/visualize ./apps/web -s sketch
# → Generates: architecture-apps-web.png + architecture-apps-web-legend.md

# Sketch with faster/cheaper model
/visualize ./apps/web -s sketch --model gemini-2.5-flash-image

# Sketch with explicit overview mode (same as default)
/visualize src/complex-system -s sketch --detail overview
# → If >7 components: warns but respects choice, may omit elements

# Full layered visualization (sketch + mermaid + legend)
/visualize ~/.claude/commands -s sketch --detail full
# → Generates 3 files:
#   - architecture-claude-commands-sketch.png (top 7 components)
#   - architecture-claude-commands-detailed.md (ALL components in Mermaid)
#   - architecture-claude-commands-legend.md (text reference)

# Detailed mode with zoom regions
/visualize src/auth -s sketch --detail detailed
# → Generates: overview sketch + zoom sketches for complex areas

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
