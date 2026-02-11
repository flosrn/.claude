---
name: step-02-opening
description: Collect independent opening statements from all councillors (no cross-contamination)
next_step: steps/step-03-debate.md
---

# Step 2: Opening Statements

**Role: MODERATOR** - Collect independent positions before debate begins

---

<available_state>
From previous steps:

- `{topic}` - The idea/plan to evaluate
- `{rounds}` - Number of debate rounds
- `{councillor_count}` - Number of councillors
- `{councillors}` - List of active councillor roles
- `{save_mode}` - Save transcript
- `{economy_mode}` - Should be false (economy mode skips this step)
- `{team_name}` - Team name for Agent Teams
- `{output_dir}` - Output directory (if save_mode)
</available_state>

---

<mandatory_rules>
## MANDATORY EXECUTION RULES (READ FIRST)

- This step only runs in standard (Agent Teams) mode
- Economy mode collects openings in step-01 and skips here
- DO NOT share any councillor's statement with other councillors during this phase
- Wait for ALL councillors to complete before proceeding
- Independence is critical — cross-contamination biases the debate
- You are the MODERATOR: collect, acknowledge, do not argue or evaluate
</mandatory_rules>

---

<execution_sequence>

<collect_statements>
### 2.1 Wait for Opening Statements

All councillors were spawned in step-01 and are working in parallel.

```
WHILE any opening statement tasks are not completed:
  1. Wait for councillor messages (they arrive automatically)
  2. As each councillor sends their opening statement:
     - Acknowledge receipt (brief)
     - Store in {opening_statements} under their role
     - Note their initial confidence level
  3. Check TaskList periodically for overall progress
```

**Important:** Do NOT respond with substantive feedback. Just acknowledge:
```
SendMessage:
  type: "message"
  recipient: "{councillor_name}"
  content: "Opening statement received. Stand by for the debate phase."
  summary: "Acknowledged {role} opening"
```

</collect_statements>

<quality_check>
### 2.2 Quality Check

Once all opening statements are collected, verify each one has:

- [ ] Clear position stated
- [ ] 3-5 specific arguments (not generic platitudes)
- [ ] Confidence level declared
- [ ] At least one question for another councillor

**If any statement is too vague or generic:**
```
SendMessage:
  type: "message"
  recipient: "{councillor_name}"
  content: |
    Your opening statement needs more specificity.

    Instead of general claims, provide:
    - Concrete arguments about THIS specific topic: {topic}
    - Specific scenarios, examples, or evidence
    - A clear, actionable question for another councillor

    Please revise and resend.
  summary: "Request more specific opening"
```

Wait for the revision before proceeding.
</quality_check>

<present_overview>
### 2.3 Present Opening Overview

Display a summary of all opening positions to the user (NOT to councillors):

```markdown
## Opening Statements Summary

**Topic:** {topic}

### Positions at a Glance

| Councillor | Position | Confidence |
|------------|----------|------------|
| Visionary | {1-line summary} | {level} |
| Critic | {1-line summary} | {level} |
| Pragmatist | {1-line summary} | {level} |
| Innovator | {1-line summary} | {level} |
| Ethicist | {1-line summary} | {level} |
| Domain Expert | {1-line summary} | {level} |

(Show only active councillors)

### Key Tensions Identified
- {Visionary} vs {Critic}: {nature of disagreement}
- {Pragmatist} vs {Innovator}: {nature of disagreement}
- {Other notable tension}

### Cross-Questions Raised
- {Role A} asks {Role B}: "{question}"
- {Role C} asks {Role D}: "{question}"
```

**This overview is for the USER only.** The councillors will receive all statements in the next step.
</present_overview>

<save_openings>
### 2.4 Save Opening Statements (if save_mode)

**If `{save_mode}` = true:**

Append to `{output_dir}/session.md`:

```markdown
## Phase 2: Opening Statements

### {Role 1}: {councillor name}
{full opening statement}

### {Role 2}: {councillor name}
{full opening statement}

[... for each councillor]

### Tensions Identified
{tensions summary}

---
```
</save_openings>

</execution_sequence>

---

<success_metrics>

- All `{councillor_count}` opening statements collected
- Each statement has specific arguments (not generic)
- Each statement includes a confidence level
- No cross-contamination between councillors
- Summary presented to user with tensions identified
- Transcript saved (if save_mode)

</success_metrics>

<failure_modes>

- Sharing one councillor's statement with another before debate
- Accepting vague or generic opening statements
- Responding to councillors with substantive feedback (biasing them)
- Proceeding before all statements are collected
- Not identifying key tensions between positions

</failure_modes>

---

<next_step_directive>
**CRITICAL:** After all opening statements are collected and summarized:

"**Opening statements complete.** {councillor_count} councillors have stated their positions.

**Key tensions:**
- {tension 1}
- {tension 2}

**NEXT: Phase 3 - Debate ({rounds} rounds)**

Now the councillors will see each other's positions and engage in structured cross-examination. Peer exchange begins.

Loading `step-03-debate.md`..."

→ Load `steps/step-03-debate.md`
</next_step_directive>
