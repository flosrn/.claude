# Analysis: Add --brainstorm Flag to /apex:handoff

**Analyzed**: 2026-01-03
**Status**: Complete

## Quick Summary (TL;DR)

> This section is the PRIMARY content consumed by lazy loading.
> Keep it dense and actionable.

**Key file to modify:**
- `commands/apex/handoff.md` - Add `--brainstorm` flag with conditional step 3c

**Pattern to follow:**
- `--vision` flag implementation at lines 87-98 (conditional step 3b)
- `AskUserQuestion` usage in `1-analyze.md:160-176` (background mode)

**Implementation approach:**
1. Add `--brainstorm` to argument-hint in YAML frontmatter
2. Document flag in "Argument Parsing" section (lines 11-17)
3. Add new step "3c. GATHER CLARIFICATIONS (only if `--brainstorm` flag)"
4. Include responses in seed.md under new `💬 Clarifications` section

**⚠️ Gotchas discovered:**
- Questions must be **contextual** (adapt to task description), not generic
- Max 3-4 questions - brainstorm should clarify, not interrogate
- Use collaborative "What/How" framing, not accusatory "Why"
- Brainstorm runs BEFORE seed generation (enriches the seed)

**Dependencies:** None blocking

**Estimation:** ~2-3 tasks, ~30min total

---

## Codebase Context

### handoff.md Structure (target file)

**Current argument parsing** (lines 11-17):
```markdown
Parse `$ARGUMENTS` for:
- **Task description**: Free text describing the next task (required)
- **`--vision`**: Detect shared image and include in seed for deep analysis

If no task description provided, use `AskUserQuestion` to gather it.
```

**Current conditional step pattern** (lines 87-98):
```markdown
### 3b. DETECT SHARED IMAGE (only if `--vision` flag)

Skip this step if no `--vision` flag.

[bash command to detect image]

Include `📷 Image de référence` section in seed.md only if image found.
```

This pattern is **directly reusable** for `--brainstorm`:
- Clear heading with condition in parentheses
- "Skip this step if no flag" statement
- Conditional logic/tool usage
- Output section that only appears if condition met

### AskUserQuestion Pattern (from 1-analyze.md:160-176)

```markdown
2. **Immediately ask clarifying questions** using `AskUserQuestion`:
   - "What specific problem are you trying to solve?"
   - "Are there existing patterns or code you'd like me to follow?"
   - "Any constraints or preferences I should know about?"
   - Customize questions based on the task description
```

**Key insight**: Questions are customized to context (task description), not hardcoded generic questions.

### Flag Conventions Across APEX

| Flag | File | Purpose |
|------|------|---------|
| `--vision` | handoff.md | Include shared image in seed |
| `--background` | 1-analyze.md, 4-examine.md | Run agents async |
| `--yolo` | 1-analyze.md, 2-plan.md | Auto-continue to next phase |
| `--skip-patterns` | 4-examine.md | Skip React 19 pattern checks |
| `--url=<value>` | 5-demo.md | Parameterized flag |

**Convention**: All boolean flags use `--flag-name` format (no short flags).

---

## Research Findings

### Best Clarifying Questions (from web research)

**4 high-value question categories:**

1. **Priority/Goals**: "What aspect is most important to get right?"
   - Prevents building wrong solution
   - Forces prioritization of competing concerns

2. **Scope/Constraints**: "What's explicitly out of scope?"
   - Prevents scope creep
   - Surfaces hidden limitations early

3. **User/Audience**: "Who will use this and what task are they completing?"
   - Shifts from feature requests to user needs
   - Makes acceptance criteria concrete

4. **Approach/Mode**: "Should we analyze first or implement directly?"
   - Clarifies expected workflow
   - Prevents wasted effort on wrong approach

### Making Questions Contextual (not generic)

**Technique**: Parse task description to identify ambiguity types:
- Vague adjectives ("better", "faster", "cleaner") → Ask for metrics
- Multiple aspects mentioned → Ask for priority order
- Missing audience → Ask who benefits
- Missing scope → Ask what's excluded

**Example adaptation:**
- Task: "improve the AI tracking" → "Which aspect: accuracy, speed, or visibility?"
- Task: "add user authentication" → "What auth methods: OAuth, password, magic link?"
- Task: "refactor the dashboard" → "Full rewrite or incremental improvement?"

### When Brainstorm Adds Value

**Use brainstorm when:**
- Description is vague or uses subjective terms
- Multiple valid interpretations exist
- Task mentions multiple aspects without priority
- Scope boundaries are unclear

**Skip brainstorm when:**
- Description is already specific and actionable
- Clear technical requirement with obvious implementation
- User has already provided detailed specs

---

## Proposed Implementation

### Step 3c Structure

```markdown
### 3c. GATHER CLARIFICATIONS (only if `--brainstorm` flag)

Skip this step if no `--brainstorm` flag.

**Analyze the task description** to identify areas needing clarification:
- Vague terms that need definition
- Multiple aspects needing prioritization
- Missing scope or audience information
- Unclear approach preferences

**Ask 2-4 contextual questions** using `AskUserQuestion`:

Example question types (adapt based on task):
1. **Priority**: "You mentioned X, Y, and Z. Which is most critical?"
2. **Scope**: "Should this include [potential scope item] or exclude it?"
3. **Audience**: "Is this for [user type A] or [user type B]?"
4. **Approach**: "Would you prefer [approach A] or [approach B]?"

**Include responses in seed.md** under `💬 Clarifications` section.
```

### Seed.md Output Section

```markdown
## 💬 Clarifications

> Questions asked via `--brainstorm` flag

| Question | Response |
|----------|----------|
| [Question 1] | [User's answer] |
| [Question 2] | [User's answer] |
```

---

## Key Files

| File | Lines | Purpose |
|------|-------|---------|
| `commands/apex/handoff.md` | 4 | Add `--brainstorm` to argument-hint |
| `commands/apex/handoff.md` | 11-17 | Document flag in parsing section |
| `commands/apex/handoff.md` | ~99 | Add step 3c after vision step |
| `commands/apex/handoff.md` | seed template | Add `💬 Clarifications` section |

---

## Dependencies

- **AskUserQuestion tool**: Already available, no new dependencies
- **No blocking dependencies**: Can implement immediately

---

## Open Questions (resolved from seed)

From the seed file, the use case was demonstrated in a real session:
- Description: "améliorer le suivi de l'IA créateur, visualiser le contexte, analyse de l'interface"
- Questions asked: Priority (3 linked aspects), Audience (end user), Mode (analyze first)
- Result: Clarification that enriched the seed

This confirms the implementation approach is validated by real usage.
