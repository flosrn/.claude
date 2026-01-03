# Implementation: Add --brainstorm Flag to /apex:handoff

## Overview
Added a `--brainstorm` flag to `/apex:handoff` that triggers contextual clarifying questions before generating the seed, with a synthesis step to confirm understanding.

## Status: ✅ Complete
**Progress**: All changes implemented

---

## Session Log

### Session 1 - 2026-01-03

**Task(s) Completed**: Full implementation of --brainstorm flag

#### Changes Made
- Added `--brainstorm` to argument-hint in YAML frontmatter
- Documented flag in Argument Parsing section
- Created step 3c "GATHER CLARIFICATIONS":
  - ULTRA THINK guidance for analyzing task descriptions
  - Ambiguity detection patterns (vague adjectives, missing scope, etc.)
  - Good vs bad question examples
  - Max 3-4 questions constraint
- **Added step 3d "SYNTHESIZE & CONFIRM"**:
  - Reformulates each answer with concrete example (ASCII mockup, pseudo-code)
  - Highlights implications for implementation
  - Asks "Est-ce bien ce que tu avais en tête ?" before proceeding
- Added `💬 Clarifications` section to seed template
- Added instruction in step 4 to incorporate clarifications
- Added usage examples including `--brainstorm` alone and combined with `--vision`
- Updated CLAUDE.md Quick Reference table

#### Files Changed

**Modified Files:**
- `commands/apex/handoff.md` - Added --brainstorm flag, step 3c, step 3d
- `commands/apex/CLAUDE.md` - Updated Quick Reference table

#### Test Results
- No automated tests (markdown skill file)
- Manual verification: Skill file syntax is valid

#### Notes
- Implementation follows exact pattern of existing `--vision` flag
- Questions are contextual (adapted to task description), not generic
- Max 3-4 questions prevents interrogation feel
- Synthesis step ensures alignment before seed generation

---

## Suggested Commit

```
feat: add --brainstorm flag to /apex:handoff

- Add step 3c GATHER CLARIFICATIONS with AskUserQuestion
- Add step 3d SYNTHESIZE & CONFIRM for alignment before seed
- Support contextual questions based on task description ambiguity
- Add 💬 Clarifications section to seed template
- Include usage examples for --brainstorm and combined flags

Implements: tasks/12-handoff-brainstorm-flag
```
