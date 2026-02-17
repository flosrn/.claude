---
name: step-04-action
description: Action crystallization phase - transform insights into clear recommendations and actions
---

# Phase 4: Action Crystallization

**Role: STRATEGIC ADVISOR** - Transform insight into clear, actionable recommendations

---

<available_state>
From previous steps:

- `{topic}` - The research topic
- `{economy_mode}` - If true, used direct tool calls instead of subagents
- `{fast_mode}` - If true, skipped Phase 2 and used 3 perspectives in Phase 3
- `{save_file}` - If true, save session to file
- `{session_path}` - Path to session file (if saving)
- `{phase_1_discoveries}` - Broad findings from Phase 1
- `{phase_2_challenges}` - Challenges from Phase 2 (empty if fast_mode)
- `{phase_3_synthesis}` - Multi-perspective analysis from Phase 3
</available_state>

---

<mandatory_rules>
## MANDATORY EXECUTION RULES (READ FIRST)

- 🎯 FORM clear, defensible recommendations - no wishy-washy conclusions
- 📊 ASSIGN confidence levels HONESTLY - admit uncertainty
- ⚔️ PRESENT the strongest contrarian view - steelman the opposition
- 📋 CREATE actionable next steps - specific, not vague
- 🔗 CITE sources for key claims
- 🚫 FORBIDDEN: Vague conclusions like "it depends" without specifics
- 🚫 FORBIDDEN: Hiding uncertainty behind confident language
</mandatory_rules>

---

<execution_sequence>

<ultra_think>
**1. ULTRA THINK: Deep Synthesis**

Before producing output, deeply consider:

**What do the phases tell us?**
- Phase 1 (Exploration): The landscape is...
- Phase 2 (Challenge): After stress-testing, the strongest findings are... *(skip if fast_mode)*
- Phase 3 (Multi-lens): Across perspectives, the clearest signals are...

**What's my honest recommendation?**
- If I had to advise someone today, I would say...
- The confidence I have in this is... because...

**What would change my mind?**
- If [evidence/event], I would reconsider
- The weakest part of my reasoning is...

**What's the strongest argument against my recommendation?**
- The best counter-argument is...
- Why someone might reasonably disagree...
</ultra_think>

<generate_output>
**2. Generate Final Output**

Produce the final brainstorm output in this format:

```markdown
## 🧠 Brainstorm: {topic}

### Research Summary

**Process completed:**
- **Phase 1 (Exploration):** [# of sources], [breadth of coverage]
- **Phase 2 (Challenge):** [# of findings challenged], [# revised] *(skipped if fast_mode)*
- **Phase 3 (Synthesis):** [3 or 5] perspectives analyzed, [key patterns found]
- **Mode:** [Standard / Economy / Fast / Economy+Fast]

**Key areas investigated:**
- [Area 1]
- [Area 2]
- [Area 3]

---

### Key Insights

1. **[Insight 1]** - Confidence: **High/Medium/Low**
   - [Supporting evidence and reasoning]

2. **[Insight 2]** - Confidence: **High/Medium/Low**
   - [Supporting evidence and reasoning]

3. **[Insight 3]** - Confidence: **High/Medium/Low**
   - [Supporting evidence and reasoning]

4. **[Insight 4]** - Confidence: **High/Medium/Low**
   - [Supporting evidence and reasoning]

5. **[Insight 5]** - Confidence: **High/Medium/Low**
   - [Supporting evidence and reasoning]

---

### Recommendation

**Primary recommendation:**
[Clear, specific recommendation]

**Rationale:**
[Why this recommendation based on all research]

**Key tradeoffs accepted:**
- [Tradeoff 1]: We're choosing [X] over [Y] because...
- [Tradeoff 2]: We're accepting [risk] for [benefit]

**Overall Confidence: [High/Medium/Low]**
- Would change to higher if: [evidence needed]
- Would change to lower if: [counter-evidence]

---

### Contrarian View

**The strongest argument against this recommendation:**

[Steelman the opposing view - present it as compellingly as possible]

**Why someone might reasonably choose differently:**
- [Reason 1]
- [Reason 2]

**When the contrarian view might be right:**
- If [condition], then [alternative] would be better

---

### Open Questions

**Still needs investigation:**
1. [Question 1] - Why it matters: [impact]
2. [Question 2] - Why it matters: [impact]
3. [Question 3] - Why it matters: [impact]

**Assumptions that need validation:**
- [Assumption] - How to validate: [method]

---

### Immediate Actions

**This week:**
1. [Specific action 1]
2. [Specific action 2]
3. [Specific action 3]

**Before committing fully:**
- [Validation step or experiment to run]

---

### Sources

**Key references:**
- [Source 1]: [What it contributed]
- [Source 2]: [What it contributed]
- [Source 3]: [What it contributed]

**Perspectives consulted:**
- [Expert/Source] on [topic]
- [Expert/Source] on [topic]
```
</generate_output>

<design_bridge>
**3. Design Bridge** (conditional - only if topic is about building/implementing something)

**DETECT:** Is `{topic}` about building, implementing, creating, or modifying something concrete (a feature, tool, component, system)?

- If **YES** → Execute the Design Bridge below
- If **NO** (pure research, comparison, decision-making) → Skip to step 4 (Save)

**WHY:** Research without design leaves a gap. The best research in the world is useless if it doesn't translate into a clear, validated design before implementation. This bridge absorbs the interactive design validation from brainstorming best practices.

---

**3a. Propose 2-3 Approaches**

Based on ALL research findings (Phases 1-3), propose concrete implementation approaches:

```markdown
---

### Design: Implementation Approaches

Based on the research above, here are the concrete approaches:

#### Approach A: [Name] (Recommended)
- **Architecture:** [High-level structure]
- **Key components:** [What to build]
- **Tradeoffs:** [What you gain vs what you accept]
- **Confidence:** [High/Medium/Low] based on research
- **Why recommended:** [Grounded in specific research findings]

#### Approach B: [Name]
- **Architecture:** [High-level structure]
- **Key components:** [What to build]
- **Tradeoffs:** [What you gain vs what you accept]
- **When to prefer:** [Conditions where B beats A]

#### Approach C: [Name] (optional - only if genuinely different)
- **Architecture:** [High-level structure]
- **Key components:** [What to build]
- **When to prefer:** [Niche conditions]
```

**3b. Validate Approach with User**

Use `AskUserQuestion` to let the user choose before diving into design details:

```yaml
questions:
  - header: "Approach"
    question: "Which approach should we design in detail?"
    options:
      - label: "Approach A: {name} (Recommended)"
        description: "{1-line rationale grounded in research}"
      - label: "Approach B: {name}"
        description: "{1-line rationale}"
      - label: "Approach C: {name}"
        description: "{1-line rationale} (only if genuinely different)"
      - label: "Just the research, no implementation"
        description: "Keep research output only, skip design"
    multiSelect: false
```

Store chosen approach in `{chosen_approach}`.

If user chose "Just the research" → skip to Save step.

**3c. Present Design Section by Section**

For the chosen approach, present the design **incrementally** — one section at a time, validating as you go. This prevents wasting effort on sections the user disagrees with.

**Section 1: Architecture**

```markdown
### Architecture

[2-5 sentences - how the system is structured, key decisions]
```

```yaml
questions:
  - header: "Architecture"
    question: "Does this architecture direction look right?"
    options:
      - label: "Yes, continue"
        description: "Architecture makes sense, show me the details"
      - label: "Adjust this"
        description: "The direction is mostly right but I want to change something"
      - label: "Wrong approach"
        description: "This architecture doesn't fit, let's rethink"
    multiSelect: false
```

If user wants adjustment → ask what to change, revise, re-present.

**Section 2: Components & Data Flow**

```markdown
### Components & Data Flow

[What pieces exist, how data moves between them]
```

```yaml
questions:
  - header: "Components"
    question: "Components and data flow look correct?"
    options:
      - label: "Yes, continue"
        description: "Makes sense, continue to error handling"
      - label: "Missing a component"
        description: "There's a piece you haven't accounted for"
      - label: "Data flow is wrong"
        description: "The data should flow differently"
    multiSelect: false
```

**Section 3: Error Handling, Edge Cases & Testing**

```markdown
### Error Handling & Edge Cases

[Key failure modes identified by the Skeptic lens]

### Testing Strategy

[What to test, informed by research findings]
```

```yaml
questions:
  - header: "Design"
    question: "Design overview complete. Ready to finalize?"
    options:
      - label: "Looks good, finalize"
        description: "Save the design and prepare for implementation"
      - label: "Revise something"
        description: "I want to go back and change a section"
    multiSelect: false
```

If user wants to revise → ask which section, loop back to that section.
</design_bridge>

<save_final>
**4. Save Final Output** (if `{save_file}` is true)

Append to `{session_path}`:
```markdown
## Phase 4: Action Crystallization

[Complete final output above]

[If Design Bridge was executed:]
## Design Decision

**Chosen approach:** [Approach name]
**Rationale:** [Why this approach was selected]

---

## Session Complete

**Total research phases:** 4
**Research completed:** {current_date}
```

Also announce: "Session saved to `{session_path}`"
</save_final>

<implementation_handoff>
**5. Implementation Handoff** (only if Design Bridge was completed and user chose an approach)

**CRITICAL:** This is the bridge between research and implementation. The brainstorm output becomes APEX input.

**5a. Save design context file:**

Write to `.claude/output/brainstorm/{topic-slug}-{date}-design.md`:
```markdown
# Design Context: {topic}

> **Source:** Brainstorm session ({current_date})
> **Approach:** {chosen_approach}
> **Confidence:** {overall_confidence}

## Research-Backed Design

[Architecture, components, data flow from Design Overview]

## Key Constraints (from research)

- [Constraint from Skeptic's warnings]
- [Constraint from Expert's priorities]
- [Constraint from Pragmatist's 80/20]

## Acceptance Criteria

- [ ] [Derived from research insights + design]
- [ ] [Derived from research insights + design]
- [ ] [Derived from research insights + design]

## What to Watch Out For

- [Risk identified in contrarian view]
- [Open question that needs validation during implementation]
```

**5b. Offer APEX handoff:**

Present the user with the next step:

```
---

**Research + Design complete.** Ready to implement.

**Design context saved to:** `.claude/output/brainstorm/{topic-slug}-{date}-design.md`

**To implement with APEX:**
`/apex -a {topic-slug}` — then reference the design context file during the Analyze phase.

Or start APEX manually and point it to the design file for a head start on step-01 (Analyze).
```

**DO NOT automatically invoke APEX.** The user decides when and how to start implementation.
</implementation_handoff>

<completion>
**6. Completion Message**

```
---

**✅ Brainstorm Complete**

This research covered:
- Broad exploration with parallel agents
- Skeptical challenge of all findings
- Analysis through [3 or 5] expert perspectives
- Crystallization into actionable recommendations
[If Design Bridge completed:]
- Design validation with [2-3] approaches evaluated
- Implementation handoff prepared for APEX

**Confidence summary:**
- [# High confidence] insights
- [# Medium confidence] insights
- [# Low confidence] insights

**Next steps are clear:** [summarize top 1-2 actions]
[If design completed:] **Implementation ready:** Use `/apex` with the saved design context.
[If research only:] **Open for follow-up:** Ask me to dig deeper on any specific area.
```
</completion>

</execution_sequence>

---

<confidence_calibration>
## Confidence Level Guidelines

**High Confidence:**
- Multiple independent sources agree
- Survived skeptical challenge
- Multiple perspectives converge
- Clear evidence, minimal assumptions

**Medium Confidence:**
- Good evidence but some gaps
- Some perspectives diverge
- Reasonable assumptions required
- More investigation would help

**Low Confidence:**
- Limited evidence
- Significant uncertainty
- Conflicting perspectives
- Important assumptions untested
</confidence_calibration>

---

<success_metrics>

- Clear, specific recommendations (not "it depends")
- Honest confidence levels with calibration
- Strongest contrarian view presented fairly
- Actionable next steps (specific, not vague)
- Open questions acknowledge what we don't know
- Sources cited for key claims
- Complete output format followed
- [If implementable topic:] 2-3 approaches proposed with tradeoffs
- [If implementable topic:] Design presented section-by-section with user validation at each step
- [If implementable topic:] User validated chosen approach AND each design section
- [If implementable topic:] Design context file saved for APEX handoff
</success_metrics>

<failure_modes>

- Vague recommendations that don't commit
- Overconfident conclusions hiding uncertainty
- Weak strawman of contrarian view
- "Next steps" that are too generic to act on
- Forgetting to cite sources
- Rushing the synthesis without ULTRA THINK
- [Design Bridge:] Proposing approaches not grounded in research findings
- [Design Bridge:] Skipping design for "simple" implementable topics
- [Design Bridge:] Auto-invoking APEX without user consent
- [Design Bridge:] Presenting entire design at once instead of section-by-section
- [Design Bridge:] Not letting user validate architecture before diving into components
- [Design Bridge:] Design overview too vague (must include architecture + components + error handling)
</failure_modes>

---

<workflow_complete>
## Workflow Complete

The brainstorm-skills workflow has completed all phases:

1. ✅ **Expansive Exploration** - Cast wide net
2. ✅ **Critical Challenge** - Stress-tested findings
3. ✅ **Multi-Lens Synthesis** - [3 or 5] perspectives analyzed
4. ✅ **Action Crystallization** - Clear recommendations
5. ✅ **Design Bridge** - Approaches evaluated, design validated *(if implementable topic)*
6. ✅ **Implementation Handoff** - Design context ready for APEX *(if user chose to implement)*

The user now has battle-tested insights — and a clear path to implementation if needed.
</workflow_complete>
