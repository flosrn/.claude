# Analysis: Optimize APEX Seed/Handoff Document Structure

**Analyzed**: 2025-12-30
**Command**: `/apex:1-analyze "Créer une tache dédiee pour faire tout cela"`
**Status**: Complete

## Objective

Restructure the APEX `seed.md` generation (via `/apex:handoff`) to follow research-backed best practices for LLM document consumption, maximizing comprehension while minimizing token usage through lazy loading.

## Research Findings

### 1. Document Structure Patterns (from 4 parallel research agents)

| Framework | Key Insight | Application |
|-----------|-------------|-------------|
| **BLUF** (Bottom Line Up Front) | Most important info first | Objective at top |
| **Inverted Pyramid** | Important → Details → Background | Action before context |
| **CO-STAR** | Context, Objective, Style, Tone, Action, Response | Structured sections |
| **Progressive Disclosure** | 3 layers: metadata, details, source | Lazy loading |
| **Diátaxis** | Tutorials, How-tos, Reference, Explanation | Separate action from reference |

### 2. LLM-Specific Behaviors

- **Recency Bias**: LLMs weight content appearing later in context more heavily
- **Attention Patterns**: First and last sections get highest attention
- **Token Economics**: Lazy loading reduces costs by ~60%
- **Information Scent**: Clear section titles with emojis improve navigation

### 3. Current Problem with seed.md

The current structure in `handoff.md` places "Contexte hérité" (inherited context) BEFORE actionable content:

```
Current Order (problematic):
1. Contexte hérité ❌ (reference material first)
2. Fichiers à lire
3. Objectif
4. Spécifications
```

This violates BLUF and Inverted Pyramid principles.

## Proposed Optimal Structure

```markdown
# 🔄 [Task Name] - Seed

## 🎯 Objectif ← BLUF (FIRST - what to accomplish)
[Clear, actionable goal statement]

## 📂 Point de départ ← ACTIONABLE (SECOND - where to start)
**Fichiers critiques à lire:**
- `path/to/main-file.ts:L42-L89` - Description

## ⚠️ Pièges à éviter ← WARNINGS (THIRD - prevent mistakes)
- [Gotcha 1]
- [Gotcha 2]

## 📋 Spécifications ← REQUIREMENTS (FOURTH)
- [Spec 1]
- [Spec 2]

## 🔍 Contexte technique ← REFERENCE (OPTIONAL - only if complex)
> **Note**: Section optionnelle. Lire uniquement si besoin de comprendre l'historique.

[Brief technical context]

## 📚 Artifacts source ← LAZY LOAD (LAST - read on demand)
> **Lazy Load**: Ces fichiers sont disponibles pour référence. Ne les lire que si nécessaire.

| Artifact | Path | Quand lire |
|----------|------|------------|
| Analyse initiale | `tasks/XX/analyze.md` | Pour comprendre le contexte complet |
| Plan détaillé | `tasks/XX/plan.md` | Pour voir la stratégie d'implémentation |
| Implémentation | `tasks/XX/implementation.md` | Pour les décisions techniques |
```

## Key Changes Required

### 1. Update `handoff.md` Template

**File**: `~/.claude/commands/apex/handoff.md`

Changes:
- Reorder sections to follow BLUF pattern
- Add emoji visual markers for navigation
- Implement lazy loading pattern for artifact references
- Add conditional "read only if needed" markers

### 2. Update `1-analyze.md` (Optional Enhancement)

**File**: `~/.claude/commands/apex/1-analyze.md`

Changes:
- Add instruction for lazy loading when `seed.md` detected
- Reference artifacts instead of copying content

### 3. Document Principles

Create documentation for the reasoning behind structure:
- Why BLUF matters for LLMs
- Progressive disclosure layers
- When to include vs reference content

## Technical Specifications

### Section Priority (1=highest)

| Priority | Section | Content | Token Budget |
|----------|---------|---------|--------------|
| 1 | 🎯 Objectif | Goal statement | ~100 tokens |
| 2 | 📂 Point de départ | Critical files | ~200 tokens |
| 3 | ⚠️ Pièges à éviter | Warnings | ~150 tokens |
| 4 | 📋 Spécifications | Requirements | ~300 tokens |
| 5 | 🔍 Contexte technique | Background | ~500 tokens (optional) |
| 6 | 📚 Artifacts source | References | ~100 tokens (paths only) |

### Lazy Loading Pattern

```markdown
## 📚 Artifacts source

> **Lazy Load**: Ces fichiers sont disponibles pour référence.
> Ne les lire que si nécessaire pour comprendre le contexte.

- **Analyse**: `tasks/XX/analyze.md` - Lire pour comprendre le "pourquoi"
- **Plan**: `tasks/XX/plan.md` - Lire pour voir la stratégie
- **Code modifié**: `src/file.ts` - Lire pour voir l'implémentation actuelle
```

### Visual Navigation (Information Scent)

| Emoji | Section Type | Purpose |
|-------|--------------|---------|
| 🎯 | Objective | Primary goal |
| 📂 | Files | Starting point |
| ⚠️ | Warnings | Pitfalls to avoid |
| 📋 | Specs | Requirements |
| 🔍 | Context | Background info |
| 📚 | Artifacts | References |

## Success Criteria

1. **seed.md follows BLUF**: Objective appears first
2. **Actionable content before reference**: Files/specs before context
3. **Lazy loading implemented**: Artifacts referenced, not copied
4. **Visual navigation**: Emoji markers on all sections
5. **Token efficiency**: ~60% reduction through lazy loading
6. **Documentation**: Principles documented for future reference

## Files to Modify

| File | Changes |
|------|---------|
| `~/.claude/commands/apex/handoff.md` | Restructure template |
| `~/.claude/commands/apex/1-analyze.md` | Add lazy loading instructions |

## Dependencies

- None - standalone improvement

## Risk Assessment

- **Low risk**: Changes are additive/structural
- **Reversible**: Can revert handoff.md if needed
- **Testing**: Generate seed.md before/after to compare

---

*Analysis complete. Ready for `/apex:2-plan`*
