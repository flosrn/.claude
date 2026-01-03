# Analysis: Refactor /apex:4-examine - Global Logical Analysis

**Analyzed**: 2026-01-03
**Status**: Complete

## Quick Summary (TL;DR)

> Refonte de `/apex:4-examine` pour ajouter une **Phase 2: Analyse Logique** après la validation technique (lint/typecheck).

**Key files to modify:**
- `commands/apex/4-examine.md` - Commande principale à refactorer (327 lines currently)
- `commands/apex/CLAUDE.md` - Documentation APEX à mettre à jour

**Patterns to follow:**
- Background mode pattern from `commands/apex/1-analyze.md:93-134`
- Smart Model Selection from `commands/apex/3-execute.md:117-175`
- Skill invocation via `Skill` in `allowed-tools` (pattern from `plugin-dev/commands/create-plugin.md`)

**⚠️ Gotchas discovered:**
1. **Skills are model-invoked, not explicitly callable** - Must add `Skill` to `allowed-tools` and write instructions that trigger semantic matching
2. **No cross-invocation** - Commands can't directly call skills; the trick is to include `Skill` tool and write prompts that Claude recognizes as matching the skill description
3. **Pattern validation is already in 4-examine** (lines 101-172) - Integrate, don't duplicate

**Dependencies:** None blocking

**Estimation:** ~3-4 tasks, ~2h total

---

## Codebase Context

### Current 4-examine.md Structure (327 lines)

| Section | Lines | Purpose |
|---------|-------|---------|
| Frontmatter | 1-5 | Metadata, allowed-tools |
| Workflow steps 1-5 | 16-98 | Env detection, validation, diagnostics |
| 5B. Background mode | 67-99 | Async execution pattern |
| 5C. Pattern validation | 101-172 | React 19 pattern checks |
| Steps 6-11 | 175-258 | Fix areas, parallel fix, format, verify |
| Area rules & examples | 260-327 | Snipper agent instructions |

### Key Observations

1. **Background mode exists** (5B) but is opt-in via `--background` flag
2. **Pattern validation exists** (5C) - Already checks `.Provider`, `useContext`, memoization
3. **Skill reference exists** (line 154): `Recommendation: Run /react19-patterns skill`
4. **No `Skill` in allowed-tools** - Current: `Bash(npm :*), Bash(pnpm :*), Read, Task, Grep, Edit, Write`

### Pattern from 1-analyze.md (Background by Default)

```markdown
3. **LAUNCH PARALLEL ANALYSIS**: Gather context from all sources
   **Launch ALL agents in background** with `run_in_background: true`:
   - Codebase exploration
   - Documentation exploration
   - Web research
```

The key is: **background by default, ask questions while waiting**.

### Smart Model Selection from 3-execute.md

Uses complexity scoring (0-10) to choose Sonnet vs Opus:
- 0-2 points → Sonnet
- 3+ points → Opus

Could apply similar logic to Phase 2 depth.

## Documentation Insights

### How Skills Work (from official docs + research)

1. **Semantic Matching**: Claude scans skill descriptions, auto-activates on match
2. **Progressive Disclosure**: Only ~100 tokens scanned initially, full SKILL.md loaded on activation
3. **Model-Invoked**: Skills are NOT explicitly callable - Claude decides autonomously
4. **SlashCommand Tool**: Only invokes OTHER commands, not skills

### How to Invoke a Skill from a Command

**Pattern from plugin-dev/commands/create-plugin.md:**

```yaml
---
allowed-tools: ["Read", "Write", "Grep", "Glob", "Bash", "TodoWrite", "AskUserQuestion", "Skill", "Task"]
---

**MUST load plugin-structure skill** using Skill tool before this phase.

Actions:
1. Load plugin-structure skill to understand component types
2. Load skill-development skill using Skill tool
```

**Key insights:**
1. Add `Skill` to `allowed-tools` frontmatter
2. Write explicit instructions like "Load [skill-name] skill using Skill tool"
3. Claude interprets this and activates the skill if description matches

### Skill Invocation Variants

```yaml
# Generic (any skill)
allowed-tools: Skill

# Specific skill
allowed-tools: Skill(react19-patterns)

# Array format
allowed-tools: ["Read", "Skill", "Task"]
```

## User Clarifications

- **Q**: Scope par défaut pour Phase 2 ?
  **A**: Modifiés + dépendances directes, avec `--global` flag pour analyse complète

- **Q**: Comment gérer les patterns React 19 ?
  **A**: Appeler automatiquement `/react19-patterns` skill

## Key Files

- `commands/apex/4-examine.md:1-5` - Frontmatter to update (add Skill)
- `commands/apex/4-examine.md:67-99` - Background mode pattern to make default
- `commands/apex/4-examine.md:101-172` - Pattern validation (integrate with skill)
- `commands/apex/1-analyze.md:93-134` - Background pattern to follow
- `skills/react19-patterns/SKILL.md` - Skill to invoke

## Patterns to Follow

### 1. Two-Phase Workflow

```
Phase 1: Technical Validation (fast)
├── pnpm typecheck
├── pnpm lint
└── If fail → Stop and fix

Phase 2: Logical Analysis (deep)
├── Read analyze.md, implementation.md
├── Read modified files + context
├── ULTRA THINK: coherence, edge cases
├── Load react19-patterns skill (if React)
└── Generate structured report
```

### 2. Scope Modes

| Mode | Flag | Files |
|------|------|-------|
| Standard | (default) | Modified + direct dependencies |
| Global | `--global` | All feature files |

### 3. Background by Default

Change from `--background` opt-in to **default behavior**:
- Phase 1 (typecheck/lint) runs in background
- Ask clarifying questions while waiting
- Phase 2 starts when Phase 1 completes

### 4. Skill Integration

```yaml
---
allowed-tools: Bash(npm :*), Bash(pnpm :*), Read, Task, Grep, Edit, Write, Skill
---

## Phase 2: Logical Analysis

If React project detected:
1. **Load react19-patterns skill** using Skill tool
2. Apply skill recommendations to analyze modified files
```

## Dependencies

- `skills/react19-patterns/SKILL.md` must exist (✅ confirmed)
- APEX workflow documentation (`commands/apex/CLAUDE.md`) needs update

## Proposed Changes Summary

### 1. Update Frontmatter
- Add `Skill` to allowed-tools
- Update description to mention logical analysis

### 2. Restructure Workflow
- Make Phase 1 (technical) run in background by default
- Add Phase 2 (logical analysis) after technical validation passes
- Add `--global` flag for full feature scope

### 3. Integrate Skill Invocation
- Replace pattern grep checks with skill invocation
- Pattern: "Load react19-patterns skill using Skill tool"
- Keep grep as fallback if skill unavailable

### 4. Add Report Structure
```markdown
## ✅ Technical Validation
## 🔍 Logical Analysis
### Coherence
### Edge Cases
### Code Quality
## ⚛️ React 19 Patterns
## 🚀 Next Steps / Improvements
```

### 5. Update Documentation
- Update `commands/apex/CLAUDE.md` with new flags and behavior
