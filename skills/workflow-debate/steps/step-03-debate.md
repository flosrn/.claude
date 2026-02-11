---
name: step-03-debate
description: Cross-examination rounds with peer exchange between councillors
next_step: steps/step-04-verdict.md
---

# Step 3: Debate Rounds

**Role: MODERATOR** - Facilitate structured cross-examination and peer exchange

---

<available_state>
From previous steps:

- `{topic}` - The idea/plan to evaluate
- `{rounds}` - Number of debate rounds (1-4)
- `{councillor_count}` - Number of councillors
- `{councillors}` - List of active councillor roles
- `{save_mode}` - Save transcript
- `{economy_mode}` - Economy or standard mode
- `{team_name}` - Team name (standard mode only)
- `{output_dir}` - Output directory (if save_mode)
- `{opening_statements}` - All councillors' opening positions
</available_state>

---

<mandatory_rules>
## MANDATORY EXECUTION RULES (READ FIRST)

- Each round MUST include ALL councillors challenging at least 2 specific points
- **Peer exchange is MANDATORY in standard mode** — councillors message each other directly
- Moderator MUST inject anti-groupthink questions if positions converge too quickly
- Track position evolution across rounds (who changed their mind, and why)
- Never let a councillor evade a direct challenge — enforce engagement
- Each round must produce NEW insights, not repeat previous arguments
- Do NOT cut rounds short — complete all `{rounds}` rounds
- The debate log `{debate_log}` accumulates across all rounds
</mandatory_rules>

---

<execution_sequence>

<debate_loop>
### 3.1 Debate Loop

Execute `{rounds}` rounds of cross-examination:

```
FOR round_num = 1 TO {rounds}:

  ### Round {round_num} of {rounds}

  3.1.1 → Share all positions with each councillor
  3.1.2 → Councillors cross-examine and peer-exchange
  3.1.3 → Collect responses and track position changes
  3.1.4 → Moderator intervention (if needed)
  3.1.5 → Present round summary to user
  3.1.6 → Save round (if save_mode)
```
</debate_loop>

<share_positions>
### 3.1.1 Share Positions

At the start of each round, share ALL current positions with each councillor.

**Standard mode (Agent Teams):**

For each councillor:
```
SendMessage:
  type: "message"
  recipient: "{councillor_name}"
  content: |
    ## Debate Round {round_num} of {rounds}

    Here are all councillors' current positions. Your job:
    1. Challenge at least 2 SPECIFIC points from other councillors
    2. Respond to any challenges directed at you from the previous round
    3. Message other councillors DIRECTLY to probe their arguments (use SendMessage)
    4. Update your position and confidence if warranted

    ### All Current Positions:

    {For each other councillor:}
    #### {Role}: {position summary}
    Key arguments:
    {numbered list of arguments}
    Confidence: {level}

    {If round > 1, include previous round's challenges directed at this councillor:}
    ### Challenges You Must Address:
    {list of challenges from other councillors}

    ### Your Response Format:

    **Challenges I'm Making:**
    1. **To {Role}:** "{specific claim}" is wrong because {reason}. Question: {question}
    2. **To {Role}:** "{specific claim}" needs scrutiny because {reason}. Question: {question}

    **Responses to Challenges Against Me:**
    - On "{point}": {direct response}

    **Position Update:**
    - Previous: {position}
    - Current: {updated or unchanged}
    - Changed because: {reason, or "No change - my arguments hold"}

    **Confidence:** {updated level}
  summary: "Round {round_num} debate instructions"
```

**Economy mode (sequential):**

For each councillor, use a Task call:
```
Task:
  description: "{role} round {round_num} debate"
  subagent_type: "Plan"
  model: "sonnet"
  prompt: |
    You are the {ROLE} on a council evaluating: {topic}

    ## Debate Round {round_num} of {rounds}

    Here are all councillors' current positions:
    {all positions}

    {if round > 1: previous challenges directed at this councillor}

    Your job:
    1. Challenge at least 2 SPECIFIC points from other councillors
    2. Respond to any challenges directed at you
    3. Update your position if warranted

    Respond with the format specified above.
```

Collect each result and update positions.
</share_positions>

<peer_exchange>
### 3.1.2 Peer Exchange (Standard Mode Only)

**This is the KEY DIFFERENTIATOR of the council skill.**

In standard mode, councillors can and SHOULD message each other directly. The instructions given in 3.1.1 encourage this.

**What to expect:**
- Councillors will use SendMessage to challenge each other directly
- These peer exchanges create genuine debate dynamics
- The moderator can observe via idle notifications with peer DM summaries
- Peer exchanges may surface insights that wouldn't emerge in mediated-only debate

**Moderator role during peer exchange:**
- Let it happen — don't over-intervene
- Observe the peer DM summaries in idle notifications
- Only intervene if a councillor is being evasive or the debate stalls
- Note particularly insightful peer exchanges for the debate log

**Allow time for peer exchange to develop before collecting round results.**
Wait for all councillors to send their round responses to the team lead.
</peer_exchange>

<collect_round>
### 3.1.3 Collect Round Results

Once all councillors have responded for the round:

```
FOR each councillor response:
  1. Extract challenges made (who they challenged, on what point)
  2. Extract responses to challenges (how they addressed pushback)
  3. Extract position updates (changed or unchanged, with reason)
  4. Extract confidence level changes
  5. Note any peer exchange insights

Update {debate_log}:
  Round {round_num}:
    {role}:
      challenges_made: [{target, point, question}]
      challenges_received: [{from, point}]
      position: {current position}
      confidence: {current level}
      changed: {yes/no, reason}
      peer_exchanges: [{with, topic, outcome}]
```

Track position evolution in `{position_evolution}`:
```
{role}:
  round_0 (opening): {position} - {confidence}
  round_1: {position} - {confidence} - changed: {reason}
  round_2: {position} - {confidence} - changed: {reason}
```
</collect_round>

<moderator_intervention>
### 3.1.4 Moderator Intervention

**Check after each round for these anti-patterns:**

<groupthink_detection>
**Groupthink Detection:**
If 3+ councillors agree on a major point without rigorous challenge:

```
SendMessage:
  type: "message"
  recipient: "{critic_name}"  (or whichever councillor should disagree)
  content: |
    ## Moderator Challenge

    I notice emerging consensus on: "{the converging point}"

    Before we accept this consensus, steelman the OPPOSING view:
    - What would need to be true for this consensus to be WRONG?
    - What evidence would change your mind?
    - What blind spots might we all share?

    Provide a genuine counter-argument, not a token objection.
  summary: "Anti-groupthink challenge"
```
</groupthink_detection>

<evasion_detection>
**Evasion Detection:**
If a councillor deflects a direct challenge:

```
SendMessage:
  type: "message"
  recipient: "{evasive_councillor}"
  content: |
    ## Moderator: Engagement Required

    {Challenger role} raised this specific challenge:
    "{the specific challenge}"

    Your response did not address it directly. Please respond specifically:
    - Do you agree or disagree with their point?
    - If you disagree, provide a concrete counter-argument
    - If you agree, how does it change your position?

    Vague responses are not acceptable in this council.
  summary: "Enforce engagement on challenge"
```
</evasion_detection>

<stale_debate>
**Stale Debate Detection:**
If a round produces no position changes and no new arguments:

Inject a reframing question:
```
SendMessage:
  type: "broadcast"  (or individual messages)
  content: |
    ## Moderator: Reframing Question

    The debate has stalled. Consider this angle:

    "{provocative question that reframes the topic}"

    Examples:
    - "What if the timeline was 10x shorter/longer?"
    - "What if the budget was unlimited/zero?"
    - "What if the main competitor already did this?"
    - "What would you recommend if you had to live with the consequences personally?"

    Each councillor: how does this reframing change your analysis?
  summary: "Reframing question to break stalemate"
```
</stale_debate>
</moderator_intervention>

<round_summary>
### 3.1.5 Present Round Summary

After each round, display to the user:

```markdown
### Round {round_num} of {rounds} Complete

**Position Changes:**
| Councillor | Before | After | Changed? |
|------------|--------|-------|----------|
| Visionary | {prev} | {current} | {Yes: reason / No} |
| Critic | {prev} | {current} | {Yes: reason / No} |
| Pragmatist | {prev} | {current} | {Yes: reason / No} |
| Innovator | {prev} | {current} | {Yes: reason / No} |

**Key Exchanges:**
- {Role A} → {Role B}: {summary of challenge and response}
- {Role C} → {Role D}: {summary of challenge and response}

**Emerging Consensus:** {points where 3+ councillors agree}
**Persistent Disagreements:** {points still contested}

**Moderator Notes:** {any interventions made and why}
```
</round_summary>

<save_round>
### 3.1.6 Save Round (if save_mode)

**If `{save_mode}` = true:**

Append to `{output_dir}/session.md`:

```markdown
### Round {round_num}

#### Challenges
{challenge details per councillor}

#### Position Updates
{position evolution table}

#### Key Exchanges
{notable peer exchanges}

#### Moderator Interventions
{any interventions}

---
```
</save_round>

</execution_sequence>

---

<success_metrics>

- All `{rounds}` rounds completed (no rounds skipped)
- Each councillor challenged 2+ specific points per round
- Peer exchange occurred between councillors (standard mode)
- Position evolution tracked across all rounds
- Moderator intervened when groupthink, evasion, or stalemate detected
- New insights emerged in each round (not just repetition)
- Debate log accumulated across all rounds

</success_metrics>

<failure_modes>

- Cutting rounds short before all councillors respond
- Not enforcing the 2-challenge minimum per councillor per round
- Skipping moderator intervention when groupthink is detected
- Not tracking position changes across rounds
- Letting councillors repeat arguments without new substance
- Over-intervening and dominating the debate (moderator should facilitate, not lead)
- In standard mode: not encouraging/allowing peer exchange

</failure_modes>

---

<next_step_directive>
**CRITICAL:** After all `{rounds}` rounds are complete:

"**Debate complete.** {rounds} rounds of cross-examination finished.

**Position Evolution:**
{brief summary of who changed their mind and why}

**Key Results:**
- Consensus areas: {count}
- Persistent disagreements: {count}
- Position changes: {count}

**NEXT: Phase 4 - Verdict**

Synthesizing all debate evidence into a structured verdict.

Loading `step-04-verdict.md`..."

→ Load `steps/step-04-verdict.md`
</next_step_directive>
