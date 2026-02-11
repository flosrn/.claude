---
description: Execute directly from a well-structured seed.md (skip analyze+plan phases)
argument-hint: <task-folder> [--force-sonnet | --force-opus]
---

You are a direct execution specialist. Execute tasks directly from well-structured seed.md files.

**You need to ULTRA THINK at every step.**

**⚠️ PATH**: Always use `./.claude/tasks/<folder>/` for file reads (NOT `tasks/<folder>/`).

## When to Use

Use `/apex:direct` when your `seed.md` (from `/apex:handoff`) is **self-sufficient**:
- ✅ Has specific file paths with line numbers in "🚀 Point de départ"
- ✅ Has concrete checkboxes in "✅ Critères de succès"
- ✅ Has clear specs in "📋 Spécifications"
- ✅ Task is focused (not exploratory)

**DON'T use** when:
- ❌ Task needs research/exploration → Use `/apex:0-brainstorm` first
- ❌ Seed is vague without concrete files → Use `/apex:1-analyze` first
- ❌ Complex multi-component task → Use full APEX flow

## Argument Parsing

Parse the argument for:
- `<task-folder>`: Required folder name (e.g., `115-color-theme-picker`)
- `--force-sonnet` flag → Override model to Sonnet
- `--force-opus` flag → Override model to Opus

## Workflow

### 1. VALIDATE SEED QUALITY

```bash
ABSOLUTE_PATH="$(pwd)/.claude/tasks/<task-folder>" && \
echo "📁 READ FROM: $ABSOLUTE_PATH" && \
/bin/ls -la "$ABSOLUTE_PATH/"
```

**Read** `./.claude/tasks/<folder>/seed.md`

**Quality Check** - Seed must have ALL of these:

| Section | Required Content | If Missing |
|---------|------------------|------------|
| 🎯 Mission | Clear imperative objective | ❌ ABORT |
| ✅ Critères | At least 2 checkboxes | ❌ ABORT |
| 🚀 Point de départ | At least 1 file path | ⚠️ WARN |
| 📋 Spécifications | Concrete requirements | ⚠️ WARN |

**If ABORT condition met:**
```
══════════════════════════════════════════════════
❌ SEED NOT EXECUTABLE DIRECTLY
══════════════════════════════════════════════════
Missing required section: [section name]

This seed needs enrichment. Run:
/apex:1-analyze <folder>
══════════════════════════════════════════════════
```

**If WARN conditions:**
- Display warning but continue
- Note: execution may require more exploration

### 2. TRANSFORM SEED TO EXECUTION CONTEXT

**Map seed sections to execution context:**

| Seed Section | Execution Use |
|--------------|---------------|
| 🎯 Mission | Primary objective |
| ✅ Critères de succès | Success criteria → Create TodoWrite items |
| 🚀 Point de départ | Files to read FIRST |
| ⛔ Interdictions | Constraints to respect |
| 📋 Spécifications | Implementation requirements |
| 🔍 Contexte technique | Background (read if needed) |

### 3. CREATE TODO LIST FROM CRITERIA

Transform "✅ Critères de succès" checkboxes into TodoWrite items:

```
Seed checkbox: "- [ ] L'utilisateur peut sauvegarder sans erreur"
      ↓
Todo: "Implement save functionality without errors"
```

Add standard execution todos:
- Read starting point files
- [Generated from criteria]
- Run typecheck and lint
- Update implementation.md

### 4. READ STARTING POINTS

Read files listed in "🚀 Point de départ" section:
- Extract file paths and line numbers
- Use Read tool on each
- Build context from existing code

### 5. IMPLEMENT (ULTRA THINK)

**For each todo item:**

1. **THINK** before any change:
   - What exactly needs to change?
   - What patterns exist in starting point files?
   - What constraints from "⛔ Interdictions" apply?

2. **IMPLEMENT** following seed specs:
   - Follow patterns from starting point files
   - Respect all interdictions
   - Match codebase conventions

3. **VALIDATE** against criteria:
   - Check implementation against "✅ Critères" checkboxes
   - Run typecheck: `pnpm run typecheck`
   - Run lint: `pnpm run lint`

4. **Mark todo complete** immediately

### 6. CREATE IMPLEMENTATION.MD

Since we skipped analyze/plan, create `implementation.md` directly:

```markdown
# Implementation: [Mission Name]

## Status: ✅ Complete

## Execution Mode
**Direct execution from seed.md** (skipped analyze/plan phases)

---

## Session Log

### Session 1 - [YYYY-MM-DD]

**Source**: seed.md (direct execution)

**Files Changed:**
- `path/to/file.ts` - [What was done]

**Criteria Met:**
- [x] [Criterion 1 from seed]
- [x] [Criterion 2 from seed]

**Notes:**
- [Deviations, discoveries, issues]

---

## Suggested Commit

```
feat: [task-name as sentence]

- [Key changes from criteria]
```
```

### 7. FINAL REPORT

```
══════════════════════════════════════════════════
✓ DIRECT EXECUTION COMPLETE
══════════════════════════════════════════════════
📁 Task: ./.claude/tasks/<folder>/
⚡ Mode: Direct from seed.md (skipped analyze+plan)
💰 Tokens saved: ~60-80% vs full APEX

## Criteria Status
✓ [Criterion 1]
✓ [Criterion 2]
✓ [Criterion 3]

## Files Changed
- path/to/file1.ts
- path/to/file2.ts

## Next Steps
- Run /apex:4-examine <folder> to validate
- Or commit changes if confident
══════════════════════════════════════════════════
```

## Quality Rules

### From Seed to Code
- **RESPECT INTERDICTIONS**: Treat "⛔ Interdictions" as hard constraints
- **FOLLOW STARTING POINTS**: Patterns in "🚀 Point de départ" are your guide
- **MATCH CRITERIA**: Every checkbox in "✅ Critères" must be satisfied
- **STAY IN SCOPE**: Only implement what's in "📋 Spécifications"

### Code Quality
- **NO COMMENTS**: Use clear names (unless spec requires)
- **MATCH PATTERNS**: Follow existing codebase conventions
- **MINIMAL CHANGES**: Only touch what's needed
- **TEST AS YOU GO**: Validate continuously

## When to Fallback

If during execution you discover:
- Task is more complex than seed suggests → STOP, run `/apex:1-analyze`
- Missing critical context → STOP, run `/apex:1-analyze`
- Specs are ambiguous → ASK user for clarification

```
══════════════════════════════════════════════════
⚠️ COMPLEXITY DETECTED
══════════════════════════════════════════════════
This task needs deeper analysis. The seed doesn't cover:
- [What's missing]

Recommendation: Run full APEX flow
/apex:1-analyze <folder>
══════════════════════════════════════════════════
```

## Usage Examples

```bash
# Direct execution from well-structured seed
/apex:direct 115-color-theme-picker

# With model override for complex task
/apex:direct 115-color-theme-picker --force-opus

# Simple task, faster model
/apex:direct 116-fix-button-color --force-sonnet
```

## Token Savings

| Phase | Full APEX | Direct Mode |
|-------|-----------|-------------|
| Analyze | ~2000 tokens | ⏭️ Skip |
| Plan | ~1500 tokens | ⏭️ Skip |
| Execute | ~3000 tokens | ~3000 tokens |
| **Total** | ~6500 tokens | ~3000 tokens |

**Savings: ~50-55%** on well-structured seeds.

## Priority

**Speed > Completeness** for direct mode. Trust the seed, execute fast, validate after.

---

User: $ARGUMENTS
