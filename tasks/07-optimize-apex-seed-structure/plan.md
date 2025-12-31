# Implementation Plan: Optimize APEX Seed/Handoff Document Structure

## Overview

Restructure the APEX `seed.md` generation to follow research-backed LLM document consumption best practices:
1. **BLUF (Bottom Line Up Front)**: Objective appears first, not buried after context
2. **Progressive Disclosure**: Actionable content before reference material
3. **Lazy Loading**: Reference artifacts instead of duplicating content (~60% token reduction)
4. **Visual Navigation**: Emoji markers for improved information scent

## Dependencies

- None - standalone improvement to `/apex:handoff` command

## File Changes

### `~/.claude/commands/apex/handoff.md`

**Primary changes - Template restructure (Section 4: STRUCTURE SEED CONTENT)**

- Action 1: Reorder the seed.md template to follow BLUF pattern
  - Move "Objectif" to FIRST position (currently after "Contexte hérité")
  - Move "Fichiers à lire" to SECOND position (actionable, not reference)
  - Add "Pièges à éviter" as THIRD section (prevent mistakes)
  - Move context/discoveries to LATER positions

- Action 2: Add emoji visual markers to all section headers
  - `## 🎯 Objectif` - Primary goal (attention-grabbing)
  - `## 📂 Point de départ` - Critical files to start with
  - `## ⚠️ Pièges à éviter` - Gotchas and warnings
  - `## 📋 Spécifications` - Requirements/specs if any
  - `## 🔍 Contexte technique` - Background (optional section)
  - `## 📚 Artifacts source` - Lazy load references

- Action 3: Implement lazy loading pattern for artifact references
  - Add "Artifacts source" section at END with reference table
  - Format: `| Artifact | Path | Quand lire |`
  - Include: analyze.md, plan.md, implementation.md paths
  - Add blockquote: `> **Lazy Load**: Ces fichiers sont disponibles pour référence. Ne les lire que si nécessaire.`

- Action 4: Add conditional "read only if needed" markers
  - Context section becomes optional: `## 🔍 Contexte technique (optionnel)`
  - Add guidance text: `> Section optionnelle. Lire uniquement si besoin de comprendre l'historique.`

- Action 5: Update the template example in section 4 to match new structure
  - Replace the entire ```markdown block with new BLUF-ordered structure
  - Ensure all emoji markers are present
  - Include lazy loading artifact table at end

**Secondary changes - Update filter guidelines (Section 3: GATHER SESSION LEARNINGS)**

- Action 6: Add guidance for what belongs in which new section
  - "Pièges à éviter" ← Gotchas, bugs encountered, things that wasted time
  - "Contexte technique" ← Architectural decisions, patterns discovered
  - "Point de départ" ← Critical files with specific line numbers

**Output quality update (Section: Output Quality Guidelines)**

- Action 7: Add guideline for lazy loading decision
  - **When to reference**: Full analysis, lengthy context, implementation details
  - **When to include inline**: Critical gotchas, must-know warnings, essential patterns

### `~/.claude/commands/apex/1-analyze.md`

**Minor enhancement - Lazy loading awareness**

- Action 1: Update Step 0c (CHECK FOR SEED CONTEXT) to handle new structure
  - Add handling for "Artifacts source" section if present
  - Extract artifact paths for lazy loading if needed during analysis

- Action 2: Add instruction in SYNTHESIZE FINDINGS (Step 4) for BLUF awareness
  - Note that analyze.md output will be consumed via lazy loading
  - Ensure "Quick Summary (TL;DR)" remains at top for optimal consumption

## Testing Strategy

**Manual verification steps:**

1. Generate a seed.md using current handoff.md
2. Apply changes to handoff.md
3. Generate a new seed.md with same source folder
4. Compare:
   - Objective appears first (BLUF compliance)
   - Visual markers present on all sections
   - Artifacts table at end (lazy loading)
   - Token count reduction (aim for ~40-60% reduction)

5. Test consumption: Start new Claude session with generated seed.md
   - Verify Claude identifies objective immediately
   - Verify lazy loading artifacts are NOT auto-read unless needed

## Documentation

No external documentation needed - the template changes are self-documenting. The emoji markers and blockquote hints provide inline guidance.

## Rollout Considerations

- **No migration needed**: Existing seed.md files continue to work
- **Backwards compatible**: New structure is additive, not breaking
- **Immediate effect**: Changes apply to next `/apex:handoff` execution
