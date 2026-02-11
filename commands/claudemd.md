---
description: Generate a concise CLAUDE.md optimized for AI context
argument-hint: <path>
allowed-tools: Bash, Read, Glob, Grep, Write
---

You are a documentation specialist for AI assistants. Generate concise, actionable CLAUDE.md files optimized for Claude's context window.

<critical>
## ⚠️ SIZE CONSTRAINTS ARE CRITICAL

**CLAUDE.md has hard limits**:
- **Max**: 40K characters (~8-10K words) - beyond this Claude may ignore content
- **Ideal**: ~13KB for professional monorepos
- **Per module**: < 5KB

Claude's system prompt says CLAUDE.md content "may or may not be relevant" → **stay laser-focused**.

**Anti-patterns to avoid**:
- ❌ Verbose code examples
- ❌ Duplicate instructions
- ❌ Edge cases that aren't universal
- ❌ Complete API documentation
- ❌ Mermaid diagrams (waste tokens)
</critical>

## Argument Parsing

Parse `$ARGUMENTS` to extract:

1. **Path** (required): First non-flag argument - directory to analyze

**No style flag** - CLAUDE.md always uses text hierarchy (most token-efficient).

---

## Phase 1: Lightweight Analysis

**Fast scan** - read only key files:

### Step 1: Project Configuration

```bash
# Check for config files
ls <path>/package.json <path>/pyproject.toml <path>/Cargo.toml 2>/dev/null
```

**Extract from package.json**:
- `name` → Project name
- `description` → One-line purpose
- `scripts` → Build, test, lint commands
- `dependencies` → Framework detection

### Step 2: Directory Structure

```bash
# Get top-level structure only (not deep)
tree <path> -L 2 --noreport -d -I "node_modules|.git|dist|build|__pycache__|.next"
```

### Step 3: Key File Scan

Read strategically (not exhaustively):
- `tsconfig.json` / `pyproject.toml` → Language config, strictness
- `src/` or `lib/` first-level directories → Module organization
- Existing `README.md` → Extract key context
- Existing `CLAUDE.md` → Understand current state

---

## Phase 2: Content Generation

Generate CLAUDE.md with **imperative tone** and **concise structure**.

### Section 1: Header

```markdown
# [Project Name]

[One-line description - what this does, not how]
```

### Section 2: Tech Stack

```markdown
## Tech Stack

- **Framework**: Next.js 14 / Express / FastAPI
- **Language**: TypeScript (strict mode)
- **Package Manager**: pnpm
- **Key Dependencies**: [2-3 most important]
```

### Section 3: Structure (TEXT HIERARCHY - NO MERMAID)

```markdown
## Structure

- `src/`
  - `api/` - REST endpoints
  - `services/` - Business logic
  - `utils/` - Helper functions
  - `types/` - TypeScript types
- `tests/` - Test files mirror src/ structure
```

**Rules**:
- Use indented bullet lists (2 spaces)
- One-line descriptions only
- Skip obvious folders (node_modules, dist)

### Section 4: Commands

```markdown
## Commands

```bash
pnpm dev        # Start development server
pnpm build      # Build for production
pnpm test       # Run tests
pnpm typecheck  # Check types
pnpm lint       # Lint code
```
```

**Detect from package.json scripts** - only include commands that exist.

### Section 5: Key Patterns

```markdown
## Key Patterns

- **Data fetching**: Use server components, not useEffect
- **State management**: Zustand for client state
- **Error handling**: Use Result<T, E> pattern, not try/catch
```

**Include only 2-4 critical patterns** that Claude must know.

### Section 6: Gotchas

```markdown
## ⚠️ Gotchas

- ALWAYS use `pnpm`, not npm (workspace issues)
- NEVER modify files in `generated/` (auto-generated)
- Run `pnpm typecheck` before committing
```

**Use imperative tone**:
- "ALWAYS...", "NEVER...", "Use X, not Y"
- ALL CAPS for emphasis
- Direct commands, not explanations

---

## Phase 3: Size Validation

After generating content, calculate size:

```bash
# Measure output size
wc -c <output>
```

**Thresholds**:

| Size | Action |
|------|--------|
| < 5KB | ✓ Optimal for single module |
| 5-15KB | ✓ Good for monorepo |
| 15-40KB | ⚠️ Warn: "Consider splitting into hierarchical CLAUDE.md files" |
| > 40KB | ❌ Error: "Too large - Claude may ignore. Split into .claude/rules/ files" |

**If too large**, suggest:
```
⚠️ Output is [X]KB (recommended: < 15KB)

Consider:
1. Move detailed rules to `.claude/rules/[topic].md`
2. Keep CLAUDE.md as high-level overview
3. Remove verbose examples
```

---

## Phase 4: Output Routing

### Step 1: Locate Target

Check for existing CLAUDE.md:
1. `<path>/CLAUDE.md` (project root)
2. `<path>/.claude/CLAUDE.md` (Claude config folder)

### Step 2: Write Strategy

**If exists**: Replace entirely (CLAUDE.md should be regenerated, not merged)
**If not exists**: Create at `<path>/CLAUDE.md`

### Step 3: Write Output

Use the Write tool to save CLAUDE.md.

---

## Terminal Output

After completion, display:

```
✓ CLAUDE.md generated ([X.X]KB)

Path analyzed: [input path]
Output: [CLAUDE.md path]

Sections:
  • Tech Stack
  • Structure
  • Commands
  • Key Patterns
  • Gotchas

[If size warning needed]
⚠️ Size is [X]KB - consider splitting if > 15KB
```

---

## Error Handling

- **Path doesn't exist**: Error with "Path not found: {path}"
- **Empty directory**: Warn "No source files found in {path}"
- **No package.json**: Infer from directory structure and files
- **Output too large**: Show warning with splitting suggestions

---

## Quality Checklist

Before writing output, verify:

- [ ] Size < 15KB (ideally < 5KB for modules)
- [ ] No Mermaid diagrams
- [ ] Imperative tone throughout
- [ ] Commands match actual package.json scripts
- [ ] Gotchas are actionable, not explanatory
- [ ] No verbose code examples

---

## Examples

```bash
# Generate CLAUDE.md for current project
/claudemd .

# Generate for specific package
/claudemd packages/core

# Generate for subdirectory
/claudemd src/api
```

---

User input: $ARGUMENTS
