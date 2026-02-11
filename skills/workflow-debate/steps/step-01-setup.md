---
name: step-01-setup
description: Parse flags, validate configuration, create team, spawn councillors
next_step: steps/step-02-opening.md
---

# Step 1: Council Setup

**Role: MODERATOR** - Configure and convene the council

---

<available_state>
From SKILL.md entry point:

- `{topic}` - The idea/plan to evaluate (flags removed)
- `{rounds}` - Number of debate rounds (default 2)
- `{councillor_count}` - Number of councillors (default 4)
- `{save_mode}` - Save transcript to file
- `{economy_mode}` - Sequential subagents instead of Agent Teams
- `{focus}` - Domain focus for 6th councillor
</available_state>

---

<mandatory_rules>
## MANDATORY EXECUTION RULES (READ FIRST)

- You are the MODERATOR — stay neutral, orchestrate, never advocate
- Parse ALL flags before any other action
- Validate flag combinations before proceeding
- In standard mode: use TeamCreate + Task with team_name for councillors
- In economy mode: use sequential Task calls without team_name
- ALL councillors use `subagent_type: "Plan"` (read-only, deep thinking)
- NEVER spawn councillors sequentially in standard mode — always parallel
- Load councillor role details from `references/roles.md`
</mandatory_rules>

---

<execution_sequence>

<parse_flags>
### 1.1 Parse and Validate Flags

**Parse from user input (already done in SKILL.md entry_point):**

```
{topic}             = user input with flags removed
{rounds}            = -r N (default 2, clamp 1-4)
{councillor_count}  = -c N (default 4, clamp 3-6)
{save_mode}         = -s flag present
{economy_mode}      = -e flag present
{focus}             = -f X value (or none)
```

**Validate combinations:**

```
IF {councillor_count} = 6 AND {focus} is not set:
  → WARN: "Domain Expert requires -f flag. Reducing to 5 councillors."
  → {councillor_count} = 5

IF {councillor_count} < 3:
  → {councillor_count} = 3

IF {councillor_count} > 6:
  → {councillor_count} = 6

IF {rounds} < 1: → {rounds} = 1
IF {rounds} > 4: → {rounds} = 4

IF {economy_mode} = false:
  → Check ~/.claude/settings.json for CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS
  → IF not set: WARN and fallback to economy mode
    → {economy_mode} = true
```
</parse_flags>

<determine_roster>
### 1.2 Determine Councillor Roster

Based on `{councillor_count}`:

```
{councillors} = []

IF {councillor_count} >= 3:
  → Add: visionary, critic, pragmatist

IF {councillor_count} >= 4:
  → Add: innovator

IF {councillor_count} >= 5:
  → Add: ethicist

IF {councillor_count} >= 6:
  → Add: domain-expert (with {focus} specialization)
```

**Display roster:**

```
## Council Configuration

Topic: {topic}
Rounds: {rounds}
Mode: {economy_mode ? "Economy (sequential)" : "Standard (Agent Teams)"}
Save: {save_mode ? "Yes" : "No"}
Focus: {focus || "None"}

### Councillors ({councillor_count}):
| # | Role | Perspective |
|---|------|-------------|
| 1 | Visionary | Potential, opportunities, best-case |
| 2 | Critic | Flaws, risks, failure modes |
| 3 | Pragmatist | Feasibility, constraints, execution |
| 4 | Innovator | Alternatives, creative reframings |
| 5 | Ethicist | Human impact, moral implications |
| 6 | Domain Expert ({focus}) | {focus}-specific expertise |

(Show only rows up to {councillor_count})
```
</determine_roster>

<setup_save>
### 1.3 Setup Save Directory (if save_mode)

**If `{save_mode}` = true:**

```
{topic_slug} = kebab-case of {topic} (truncated to 50 chars)
{date} = YYYY-MM-DD
{output_dir} = .claude/output/council/{topic_slug}-{date}
```

Create output directory:
```bash
mkdir -p {output_dir}
```

Write initial context file:
```markdown
# Council Session: {topic}
**Date:** {date}
**Rounds:** {rounds}
**Councillors:** {councillor_count}
**Mode:** {economy_mode ? "Economy" : "Standard"}
**Focus:** {focus || "None"}

---
```

Save to `{output_dir}/session.md`.
</setup_save>

<spawn_councillors>
### 1.4 Spawn Councillors

Read `references/roles.md` to get detailed prompts for each councillor.

<standard_mode>
#### Standard Mode (Agent Teams)

**1.4.1 Create Team:**
```
TeamCreate:
  team_name: "council-{topic_slug}"
  description: "Council debate: {topic}"
```

Set `{team_name}` = "council-{topic_slug}"

**1.4.2 Create Tasks (one per councillor):**

For each councillor in `{councillors}`:
```
TaskCreate:
  subject: "Opening statement: {role}"
  description: |
    ## Role: {role}
    ## Topic: {topic}
    Provide your opening statement from the {role} perspective.
    See the prompt you received for detailed instructions.
  activeForm: "Preparing {role} opening"
```

**1.4.3 Spawn ALL councillors in a SINGLE message (parallel):**

For each role, spawn with this pattern:

```
Task:
  description: "{role} councillor"
  subagent_type: "Plan"
  team_name: "{team_name}"
  name: "{role}"
  model: "sonnet"
  prompt: |
    You are the {ROLE} on a council evaluating this topic:

    ## Topic
    {topic}

    {role-specific prompt from references/roles.md}

    ## Your Task
    1. Check TaskList for your opening statement task
    2. Claim it: TaskUpdate({ taskId: "X", owner: "{role}", status: "in_progress" })
    3. Analyze the topic deeply from your perspective
    4. Send your opening statement to the team lead (moderator):

    SendMessage({
      type: "message",
      recipient: "team-lead",
      content: |
        ## Opening Statement: {ROLE}

        ### Position
        [Your initial position on the topic]

        ### Key Arguments (3-5 points)
        1. [Argument with reasoning]
        2. [Argument with reasoning]
        3. [Argument with reasoning]

        ### Initial Confidence
        [Your confidence level per your role's scale]

        ### Key Question for Other Councillors
        [One question you want another specific councillor to address]
      summary: "{Role} opening statement"
    })

    5. Mark task complete: TaskUpdate({ taskId: "X", status: "completed" })
    6. Wait for further instructions from the moderator.

    ## Critical Rules
    - Stay in character as the {ROLE}
    - Be substantive, not generic — make specific arguments about THIS topic
    - Do NOT read or modify any files
    - Do NOT interact with other councillors yet (opening statements are independent)
```

**CRITICAL: Launch ALL councillors in a SINGLE message for parallel execution.**
All Task calls must be in the same response block.
</standard_mode>

<economy_mode>
#### Economy Mode (Sequential Subagents)

No TeamCreate needed. Spawn councillors sequentially using Task without team_name:

For each role in `{councillors}`:
```
Task:
  description: "{role} opening analysis"
  subagent_type: "Plan"
  model: "sonnet"
  prompt: |
    You are the {ROLE} on a council evaluating this topic:

    ## Topic
    {topic}

    {role-specific prompt from references/roles.md}

    ## Your Task
    Analyze this topic deeply from your perspective and provide:

    ## Opening Statement: {ROLE}

    ### Position
    [Your initial position on the topic]

    ### Key Arguments (3-5 points)
    1. [Argument with reasoning]
    2. [Argument with reasoning]
    3. [Argument with reasoning]

    ### Initial Confidence
    [Your confidence level per your role's scale]

    ### Key Question for Other Councillors
    [One question you want another specific councillor to address]

    ## Rules
    - Stay in character as the {ROLE}
    - Be substantive, not generic
    - Do NOT read or modify any files
```

Collect each result into `{opening_statements}`.

**Note:** In economy mode, the opening statements are collected in step-01 directly.
Skip step-02 and proceed to step-03 with `{opening_statements}` populated.
</economy_mode>

</spawn_councillors>

</execution_sequence>

---

<success_metrics>

- All flags parsed and validated correctly
- Councillor roster determined and displayed
- Save directory created (if save_mode)
- In standard mode: team created, all councillors spawned in parallel
- In economy mode: all opening statements collected sequentially
- No councillors given access to each other's positions yet

</success_metrics>

<failure_modes>

- Spawning councillors sequentially in standard mode (must be parallel)
- Forgetting to check for Agent Teams env var
- Not clamping flag values to valid ranges
- Spawning domain-expert without a focus area
- Using subagent_type other than "Plan" (councillors must be read-only)
- Letting councillors see each other's positions during opening phase

</failure_modes>

---

<next_step_directive>
**CRITICAL:** After all councillors are spawned:

**If `{economy_mode}` = true:**
Opening statements were collected in this step. Skip step-02.

"**Council convened.** Opening statements collected (economy mode).

Loading `step-03-debate.md`..."

→ Load `steps/step-03-debate.md` directly

**If `{economy_mode}` = false:**
Councillors are spawned and working on opening statements in parallel.

"**Council convened.** {councillor_count} councillors are preparing opening statements.

Loading `step-02-opening.md`..."

→ Load `steps/step-02-opening.md`
</next_step_directive>
