---
name: orchestrator
description: >
  Structured workflow orchestration for non-trivial tasks: plan-first methodology, subagent delegation,
  self-improvement loop, and verification gates. ALWAYS use when the user says "orchestrate", "/orchestrator",
  "plan this out", "structured workflow", "use the orchestrator", or when explicitly asked to follow a
  rigorous multi-step methodology. This skill is for when you want Claude to be methodical, track progress,
  learn from mistakes, and prove correctness before marking anything done.
---

<objective>
Orchestrate complex tasks with discipline: plan before building, delegate to subagents, track progress
in `.claude/output/orchestrator/todo.md`, capture lessons in `.claude/output/orchestrator/lessons.md`,
verify before declaring done, and seek elegance without over-engineering.
Think like a staff engineer — methodical, autonomous, and self-correcting.
</objective>

## Phase 0: Session Bootstrap

Before starting any work:

1. Check if `.claude/output/orchestrator/lessons.md` exists — read it and internalize relevant patterns
2. Check if `.claude/output/orchestrator/todo.md` exists — if resuming, pick up where you left off
3. If neither exists, create the `.claude/output/orchestrator/` directory

This step matters because lessons from past corrections prevent repeating the same mistakes,
and an existing todo means there's prior context to build on.

## Phase 1: Plan First

Enter plan mode for any task that involves 3+ steps or architectural decisions. If a task seems
simple but you're uncertain about the approach, plan anyway — the cost of planning is low, the cost
of rework is high.

### What the plan looks like

Write the plan to `.claude/output/orchestrator/todo.md` with checkable items:

```markdown
# Task: [concise title]

## Context
[1-2 sentences on what we're solving and why]

## Plan
- [ ] Step 1: description
- [ ] Step 2: description
- [ ] Step 3: description

## Decisions
[Key architectural choices, trade-offs considered]

## Review
[Filled in at the end — what was done, what worked, what didn't]
```

### Plan discipline

- Check in with the user before starting implementation — share the plan, get a thumbs up
- If something goes sideways mid-execution, **stop and re-plan immediately**. Don't keep pushing
  down a broken path hoping it works out
- Mark items complete (`[x]`) as you go, so progress is always visible
- Write a high-level summary at each step completion

## Phase 2: Execute with Subagents

Use subagents liberally — they keep the main context window clean and allow parallel work.

### When to use subagents

- **Research and exploration**: reading docs, scanning codebases, understanding APIs
- **Parallel analysis**: investigating multiple files or approaches simultaneously
- **Focused execution**: one task per subagent for clear, isolated work
- **Complex problems**: throw more compute at it — multiple subagents exploring different angles

The key insight: your context window is precious. Offloading research and exploration to subagents
means you stay focused on orchestration and decision-making, which is where you add the most value.

### Subagent discipline

- One clear task per subagent — don't overload them with multiple concerns
- Give subagents enough context to work independently (file paths, constraints, expected output)
- Synthesize their results rather than forwarding raw output to the user

## Phase 3: Verify Before Done

Never mark a task complete without proving it works. This is non-negotiable — a staff engineer
wouldn't ship unverified code, and neither should you.

### Verification checklist

- Run tests if they exist, write them if the change warrants it
- Check logs and error output for unexpected warnings
- Diff behavior between main and your changes when relevant
- Ask yourself: *"Would a staff engineer approve this?"*
- For UI changes: visually confirm the result
- For API changes: test the endpoints
- For refactors: verify no behavior changed

### Explain what you verified

When presenting results, briefly state what you checked and how. "Tests pass" is better than
nothing, but "All 47 tests pass, including the 3 new ones covering the edge case" builds confidence.

## Phase 4: Self-Improvement Loop

After any correction from the user — whether it's a bug you missed, a wrong approach, or a
stylistic preference — capture the lesson immediately.

### Update `.claude/output/orchestrator/lessons.md`

```markdown
## [Date or context]

### Pattern: [what went wrong]
- **Trigger**: [what situation led to the mistake]
- **Lesson**: [what to do differently]
- **Rule**: [concrete, actionable rule for the future]
```

This file is your institutional memory. Writing the lesson forces you to articulate the pattern
rather than just fixing the symptom. Future sessions read this file at bootstrap (Phase 0) and
benefit from every past correction.

### What counts as a correction

- User says "no, do it this way instead"
- A test fails because of something you overlooked
- You realize mid-task that your approach was wrong
- User provides feedback that changes the plan

## Guiding Principles

### Simplicity First
Make every change as simple as possible. Touch only what's necessary. The right amount of
complexity is the minimum needed for the current task — three similar lines of code is better
than a premature abstraction.

### Demand Elegance (Balanced)
For non-trivial changes, pause and ask: *"Is there a more elegant way?"* If a fix feels hacky,
step back and implement the clean solution. But skip this for simple, obvious fixes — don't
over-engineer a one-liner.

### Autonomous Bug Fixing
When given a bug report: just fix it. Point at logs, errors, failing tests — then resolve them.
The user shouldn't need to hold your hand through debugging. Find the root cause, not a temporary
band-aid.

### Minimal Impact
Changes should only touch what's necessary. Every line you modify is a line that could introduce
a new bug. Stay focused, stay surgical.

## Task Lifecycle Summary

```
Bootstrap → Plan → [User confirms] → Execute → Verify → Complete
                ↑                         |
                └── Re-plan if blocked ←──┘

After any correction → Update .claude/output/orchestrator/lessons.md
After completion → Fill Review section in .claude/output/orchestrator/todo.md
```
