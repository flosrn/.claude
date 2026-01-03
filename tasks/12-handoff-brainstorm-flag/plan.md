# Implementation Plan: Add --brainstorm Flag to /apex:handoff

## Overview

Add a `--brainstorm` flag to `/apex:handoff` that triggers contextual clarifying questions via `AskUserQuestion` before generating the seed. The responses enrich the seed with user clarifications, making vague task descriptions actionable.

**Key principle**: Questions must be **contextual** (adapted to the task description), not generic hardcoded questions.

## Dependencies

None. The `AskUserQuestion` tool is already available. This is a self-contained change to `handoff.md`.

## File Changes

### `commands/apex/handoff.md`

#### Action 1: Add `--brainstorm` to argument-hint (line 4)
- **Current**: `argument-hint: "task-description" [--vision]`
- **Change to**: `argument-hint: "task-description" [--vision] [--brainstorm]`
- **Why**: Enables flag discovery in help text and argument parsing

#### Action 2: Document flag in Argument Parsing section (after line 15)
- Add new bullet point after `--vision` line:
  - `**\`--brainstorm\`**: Ask clarifying questions before generating seed (for vague tasks)`
- **Pattern**: Follow exact formatting of `--vision` entry

#### Action 3: Add step 3c after step 3b (after line 98)
- Create new conditional step: `### 3c. GATHER CLARIFICATIONS (only if \`--brainstorm\` flag)`
- **Structure** (follow step 3b pattern):
  1. "Skip this step if no `--brainstorm` flag." statement
  2. Instruction to ULTRA THINK and analyze task description for ambiguity types
  3. Guidance on question types (priority, scope, audience, approach)
  4. `AskUserQuestion` usage with 2-4 contextual questions
  5. Instruction to store responses for seed generation
- **Key guidance to include**:
  - Parse task description to identify what needs clarification
  - Vague adjectives → ask for metrics/specifics
  - Multiple aspects → ask for priority order
  - Missing scope → ask what's excluded
  - Max 3-4 questions, use collaborative "What/How" framing
- **Consider**: Include examples of good contextual questions vs. bad generic ones

#### Action 4: Add `💬 Clarifications` section to seed template (after line 138, before Artifacts)
- Add new section between `📷 Image de référence` and `📚 Artifacts source`
- **Structure**:
  ```markdown
  ## 💬 Clarifications (si applicable)

  > Questions posées via `--brainstorm` flag

  | Question | Réponse |
  |----------|---------|
  | [Question posée] | [Réponse utilisateur] |
  ```
- **Note**: Add "(si applicable)" since section only appears when `--brainstorm` used
- **Why before Artifacts**: Clarifications are more immediately actionable than lazy-loaded artifacts

#### Action 5: Add usage example (after line 232)
- Add new example showing `--brainstorm` usage:
  ```bash
  # With brainstorm for vague task descriptions
  /apex:handoff "améliorer le système de tracking" --brainstorm
  ```
- **Why**: Users need example syntax and use case indication

#### Action 6: Add instruction to include clarifications in step 4 context
- In step 4 (STRUCTURE SEED CONTENT), add note that clarification responses should inform the seed content
- **Location**: After the BLUF pattern description around line 101
- **Content**: "If `--brainstorm` was used, incorporate clarification responses into the relevant seed sections and add the `💬 Clarifications` section."

## Testing Strategy

**Manual verification steps**:
1. Run `/apex:handoff "vague task" --brainstorm` - verify questions appear
2. Answer questions, verify responses captured in seed
3. Run `/apex:handoff "clear specific task" --brainstorm` - verify fewer/simpler questions
4. Run `/apex:handoff "task" --vision --brainstorm` - verify both flags work together
5. Run `/apex:handoff "task"` (no flag) - verify no questions asked, normal behavior

**Quality checks**:
- Questions must be contextual to the description, not generic
- Max 3-4 questions per invocation
- `💬 Clarifications` section only appears when flag used
- Seed structure remains valid BLUF pattern

## Documentation

- **Update**: `commands/apex/CLAUDE.md` Quick Reference table - add `--brainstorm` flag to handoff row
- **Location**: In the Quick Reference table, handoff row currently shows `--vision`
- **Change**: `--vision` → `--vision`, `--brainstorm`

## Rollout Considerations

- **No breaking changes**: Flag is optional, default behavior unchanged
- **No migration needed**: Existing seeds unaffected
- **Feature flag not needed**: Low risk, simple addition
