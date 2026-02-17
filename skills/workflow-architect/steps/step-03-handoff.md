---
name: step-03-handoff
description: Save design context and offer APEX handoff for implementation
prev_step: steps/step-02-design.md
next_step: null
---

# Step 3: HANDOFF (Design Context + APEX Bridge)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER execute any restructuring — that's APEX's job
- 🛑 NEVER auto-invoke `/apex` — the user decides when to start
- ✅ ALWAYS save design context file (if save_mode)
- ✅ ALWAYS present the handoff options clearly
- 📋 YOU ARE A BRIDGE between architect design and APEX execution

## CONTEXT BOUNDARIES:

- Audit findings from step-01 are available (smells, dependency map, metrics)
- Restructuring plan from step-02 is approved
- No restructuring has started
- User has approved the design plan

## YOUR TASK:

Save the architect's design context as a file that APEX can consume, then offer the user clear next steps.

---

## EXECUTION SEQUENCE:

### 1. Compile Design Context

Combine the audit findings and approved design plan into a single design context document:

```markdown
# Architect Design Context: {task_id}

> **Source:** Architect audit + design ({current_date})
> **Scope:** {scope}

## Architecture Audit Summary

### Smells Detected
| # | Smell | Severity | Location |
|---|-------|----------|----------|
{For each smell from step-01 findings}

### Key Metrics
- Total files analyzed: {from step-01}
- Smells found: {count} ({critical_count} critical, {high_count} high)
- Circular dependencies: {count}

## Restructuring Plan

### Overview
{High-level strategy from step-02}

{For each phase from the approved move plan:}

### Phase N: {phase_name}
| # | Operation | Source | Destination |
|---|-----------|--------|-------------|
{Operations from step-02 move plan}

## Acceptance Criteria

- [ ] All files moved to target structure
- [ ] All imports updated and validated
- [ ] No circular dependencies introduced
- [ ] Build passes
- [ ] Tests pass
- [ ] Git history preserved for moved files
{Additional criteria derived from specific smells}

## Risks & Gotchas

{From step-02 impact assessment}

## Implementation Notes

{Any constraints, patterns to follow, special handling required}
```

### 2. Save Design Context (if save_mode)

```bash
# Ensure output directory exists
mkdir -p .claude/output/architect/{task_id}
```

Write the compiled design context to:
`.claude/output/architect/{task_id}/design-context.md`

### 3. Present Handoff

Display the following to the user:

```
---

Architecture design complete.

Design context saved to: `.claude/output/architect/{task_id}/design-context.md`

To implement with APEX:
  /apex -s {scope_description}
  → Reference the design context file during the Analyze phase for a head start.

To implement standalone (without APEX):
  /architect --standalone {scope}
  → Uses built-in RESTRUCTURE + VERIFY steps.
```

**If `{save_mode}` = false:**
→ Still display the design context summary inline (don't save to file)
→ Suggest the user re-runs with `-s` if they want to persist the design for APEX

### 4. Summary

Present a brief summary of what was designed:

```markdown
### Architect Summary

| Metric | Value |
|--------|-------|
| Smells detected | {count} |
| Phases planned | {count} |
| Files to move | {count} |
| Files to create | {count} |
| Files to delete | {count} |
| Estimated commits | {count} |
| Risk level | {Low/Medium/High} |
```

---

## SUCCESS METRICS:

- Design context file saved with complete audit + plan data
- File follows the standard format (parseable by APEX)
- User presented with clear next step options
- No restructuring executed

## FAILURE MODES:

- Executing any file moves or edits
- Auto-invoking APEX without user consent
- Saving incomplete design context (missing audit or plan data)
- Not offering the `--standalone` alternative

---

## WORKFLOW COMPLETE

The architect workflow ends here. Implementation is delegated to APEX or triggered separately with `--standalone`.
