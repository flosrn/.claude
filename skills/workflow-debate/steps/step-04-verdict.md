---
name: step-04-verdict
description: Synthesize debate into structured verdict, cleanup team
---

# Step 4: Verdict

**Role: MODERATOR** - Synthesize all debate evidence into a structured verdict

---

<available_state>
From previous steps:

- `{topic}` - The idea/plan evaluated
- `{rounds}` - Number of debate rounds completed
- `{councillor_count}` - Number of councillors
- `{councillors}` - List of active councillor roles
- `{save_mode}` - Save transcript
- `{economy_mode}` - Economy or standard mode
- `{team_name}` - Team name (standard mode only)
- `{output_dir}` - Output directory (if save_mode)
- `{opening_statements}` - All opening positions
- `{debate_log}` - Full debate exchange log
- `{position_evolution}` - How positions changed across rounds
</available_state>

---

<mandatory_rules>
## MANDATORY EXECUTION RULES (READ FIRST)

- Collect final verdicts from ALL councillors before synthesizing
- Verdict must be one of: PROCEED / PROCEED WITH CONDITIONS / RECONSIDER / DO NOT PROCEED
- Confidence must be one of: HIGH / MEDIUM / LOW
- Present the strongest counter-argument STEELMANNED (strongest form, not weakest)
- Include ALL required verdict sections (no shortcuts)
- Cleanup is MANDATORY: shutdown all councillors + TeamDelete
- The verdict reflects the DEBATE, not the moderator's opinion
</mandatory_rules>

---

<execution_sequence>

<collect_final_votes>
### 4.1 Collect Final Verdicts

Request final positions from each councillor.

**Standard mode (Agent Teams):**

For each councillor:
```
SendMessage:
  type: "message"
  recipient: "{councillor_name}"
  content: |
    ## Final Verdict Request

    The debate on "{topic}" is concluding after {rounds} rounds.

    Provide your final contribution:

    1. **Final Position:** Your position after all debate rounds
    2. **Key Argument:** Your single strongest point
    3. **Concession:** The strongest point from a councillor you disagreed with
       (steelman it — present it in its strongest form)
    4. **Remaining Concern:** What still worries you, even after the debate
    5. **Vote:** PROCEED / PROCEED WITH CONDITIONS / RECONSIDER / DO NOT PROCEED
    6. **Conditions** (if "PROCEED WITH CONDITIONS"): What must be true for you to support

    Be honest. If the debate changed your mind, say so clearly.
  summary: "Final verdict request"
```

Wait for all councillors to respond.

**Economy mode (sequential):**

For each councillor, use a Task call:
```
Task:
  description: "{role} final verdict"
  subagent_type: "Plan"
  model: "sonnet"
  prompt: |
    You are the {ROLE} on a council that just debated: {topic}

    Here is the full debate context:
    {opening_statements summary}
    {debate_log summary — key challenges and responses}

    Your position evolved as follows:
    {position_evolution for this role}

    Provide your final verdict:
    1. Final Position
    2. Key Argument (your single strongest point)
    3. Concession (strongest point from someone you disagreed with, steelmanned)
    4. Remaining Concern
    5. Vote: PROCEED / PROCEED WITH CONDITIONS / RECONSIDER / DO NOT PROCEED
    6. Conditions (if applicable)
```

Collect all results.
</collect_final_votes>

<synthesize_verdict>
### 4.2 Synthesize Verdict

Analyze all final votes and the debate record to produce the structured verdict.

**4.2.1 Determine Overall Verdict**

```
Count votes:
  PROCEED: {count}
  PROCEED WITH CONDITIONS: {count}
  RECONSIDER: {count}
  DO NOT PROCEED: {count}

Determine verdict:
  IF majority PROCEED or PROCEED WITH CONDITIONS: → PROCEED WITH CONDITIONS
  IF majority RECONSIDER or DO NOT PROCEED: → RECONSIDER
  IF unanimous PROCEED: → PROCEED
  IF unanimous DO NOT PROCEED: → DO NOT PROCEED
  IF split (no majority): → RECONSIDER (with note about divided council)
```

**4.2.2 Determine Confidence**

```
HIGH: Supermajority (>75%) agree + positions stable in final rounds
MEDIUM: Majority agrees but significant dissent OR positions still shifting
LOW: No clear majority OR positions shifted significantly in final round
```

**4.2.3 Identify Consensus Points**

Points where 3+ councillors converge (or `ceil(councillor_count * 0.6)+`):
```
For each substantive point discussed:
  Count how many councillors ultimately agreed
  IF >= 60% of councillors agree:
    → Add to Consensus Points with supporting councillors listed
```

**4.2.4 Identify Dissensus Points**

Points where councillors remained divided after all rounds:
```
For each point with persistent disagreement:
  List who holds which position and their core reasoning
  Note: this is HEALTHY — persistent disagreement often signals genuine complexity
```

**4.2.5 Build Risk Assessment**

```
| Risk | Severity | Probability | Raised By | Addressed? |
|------|----------|-------------|-----------|------------|
| {risk 1} | Critical/High/Medium/Low | High/Medium/Low | {role} | Yes/Partially/No |
| {risk 2} | ... | ... | ... | ... |
```

Severity x Probability matrix:
```
             | Low Prob | Med Prob | High Prob |
Critical Sev | Monitor  | Mitigate | Blocker   |
High Sev     | Accept   | Mitigate | Mitigate  |
Medium Sev   | Accept   | Monitor  | Mitigate  |
Low Sev      | Accept   | Accept   | Monitor   |
```

**4.2.6 Position Evolution Summary**

For each councillor:
```
{Role}: {opening position} → {final position}
  Key shift: {what changed and why, or "Held firm because..."}
```

**4.2.7 Steelman Counter-Argument**

Present the single strongest argument AGAINST the verdict:
```
The strongest case against "{verdict}" is:

{Steelmanned argument — presented in its most compelling form}

This argument was primarily championed by {role}, and was
{addressed/partially addressed/not fully addressed} during the debate.

Why the council's verdict stands despite this argument:
{reason the counter-argument was outweighed}
```

**4.2.8 Alternative Path**

If the Innovator proposed an alternative approach:
```
The Innovator proposed an alternative: {description}

Council assessment of the alternative:
- Visionary: {view}
- Critic: {view}
- Pragmatist: {view}
```
</synthesize_verdict>

<present_verdict>
### 4.3 Present Verdict

```markdown
═══════════════════════════════════════════════════════════════
                     COUNCIL VERDICT
═══════════════════════════════════════════════════════════════

## Topic
{topic}

## Verdict: {PROCEED / PROCEED WITH CONDITIONS / RECONSIDER / DO NOT PROCEED}
## Confidence: {HIGH / MEDIUM / LOW}

---

### Consensus Points
{Points where 3+ councillors converged}
1. {consensus point} — supported by: {roles}
2. {consensus point} — supported by: {roles}

### Dissensus Points
{Persistent disagreements — these signal genuine complexity}
1. {point of disagreement}
   - {Role A}: {position}
   - {Role B}: {position}

### Risk Assessment
| Risk | Severity | Probability | Raised By | Status |
|------|----------|-------------|-----------|--------|
| {risk} | {sev} | {prob} | {role} | {status} |

### Position Evolution
| Councillor | Opening | Final | Changed? |
|------------|---------|-------|----------|
| {role} | {opening position} | {final position} | {Yes/No: reason} |

### Recommendation
{Verdict rationale — WHY the council reached this conclusion}

**Conditions (if applicable):**
1. {condition that must be met}
2. {condition that must be met}

### Strongest Counter-Argument
{Steelmanned version of the best argument against the verdict}

Why the verdict stands: {reason}

### Open Questions
{Questions the council could not resolve}
1. {open question}
2. {open question}

### Alternative Path
{Innovator's proposed alternative, if any}
Assessment: {brief council view on the alternative}

---

### Council Composition
| Role | Final Vote | Final Confidence |
|------|------------|-----------------|
| {role} | {vote} | {confidence} |

### Debate Statistics
- Rounds: {rounds}
- Councillors: {councillor_count}
- Position changes: {count}
- Challenges made: {total count}
- Peer exchanges: {count} (standard mode only)
- Moderator interventions: {count}

═══════════════════════════════════════════════════════════════
```
</present_verdict>

<save_verdict>
### 4.4 Save Verdict (if save_mode)

**If `{save_mode}` = true:**

Append to `{output_dir}/session.md`:

```markdown
## Phase 4: Verdict

{Full verdict content from 4.3}

---
**Session complete.**
**Timestamp:** {ISO timestamp}
```

Display: "Transcript saved to `{output_dir}/session.md`"
</save_verdict>

<cleanup>
### 4.5 Cleanup (MANDATORY)

<standard_mode_cleanup>
#### Standard Mode (Agent Teams)

**4.5.1 Shutdown each councillor:**

For each councillor in `{councillors}`:
```
SendMessage:
  type: "shutdown_request"
  recipient: "{councillor_name}"
  content: "Council complete. Thank you for your contribution to the debate."
```

Wait for shutdown approvals from all councillors.

**4.5.2 Delete team:**
```
TeamDelete
```

**4.5.3 Confirm cleanup:**
"Council disbanded. All councillors shut down and team deleted."
</standard_mode_cleanup>

<economy_mode_cleanup>
#### Economy Mode

No team cleanup needed (no team was created).
"Council session complete (economy mode)."
</economy_mode_cleanup>

</cleanup>

</execution_sequence>

---

<success_metrics>

- Final verdicts collected from all councillors
- Verdict is one of the 4 defined levels
- Confidence level is one of 3 defined levels
- All required verdict sections present:
  - [ ] Consensus Points
  - [ ] Dissensus Points
  - [ ] Risk Assessment (with severity/probability table)
  - [ ] Position Evolution Summary
  - [ ] Recommendation with rationale
  - [ ] Strongest Counter-Argument (steelmanned)
  - [ ] Open Questions
  - [ ] Alternative Path (if applicable)
- Transcript saved (if save_mode)
- All councillors shutdown (standard mode)
- Team deleted (standard mode)

</success_metrics>

<failure_modes>

- Presenting moderator's own verdict instead of synthesizing the debate
- Strawmanning the counter-argument (presenting a weak version)
- Missing required verdict sections
- Not collecting final votes from all councillors
- Skipping cleanup (orphaned councillors and team)
- Presenting a binary verdict when the debate was nuanced
- Not showing position evolution (the journey matters, not just the destination)
- Using confidence: HIGH when the council was divided

</failure_modes>

---

<completion>
**Council session complete.**

The structured adversarial debate has produced a verdict informed by {councillor_count} distinct perspectives across {rounds} rounds of cross-examination.

**Key differentiators from this session:**
- Independent opening statements (no anchoring bias)
- Structured cross-examination (challenges required, not optional)
- Peer exchange (councillors debated each other directly)
- Position tracking (how views evolved with evidence)
- Steelmanned counter-arguments (strongest form of dissent)
</completion>
