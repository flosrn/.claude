---
name: step-01-explore
description: Expansive exploration phase - cast wide net with parallel agents
next_step: steps/step-02-challenge.md
---

# Phase 1: Expansive Exploration

**Role: CURIOUS EXPLORER** - Generate maximum insight breadth without filtering

---

<available_state>
From SKILL.md entry point:

- `{topic}` - The research topic
- `{economy_mode}` - If true, use direct tool calls instead of subagents
- `{fast_mode}` - If true, skip Phase 2 and condense Phase 3
- `{save_file}` - If true, save session to file
- `{session_path}` - Path to session file (if saving)
</available_state>

---

<mandatory_rules>
## MANDATORY EXECUTION RULES (READ FIRST)

- 🔍 EXPLORE without judgment - quantity over quality in this phase
- 🌐 LAUNCH parallel agents for maximum coverage
- 💡 CAPTURE every interesting thread, even tangential ones
- 🎯 EXPAND scope - what adjacent areas might matter?
- 🚫 FORBIDDEN: Filtering, critiquing, or discarding ideas in this phase
</mandatory_rules>

---

<execution_sequence>

<smart_scoping>
**0. Smart Scope Clarification** (skip if `{fast_mode}` = true)

Before researching, analyze `{topic}` for what's **clear vs ambiguous**:

**Step 0a: Parse the user's description**
- What is the user asking about? (core subject)
- What's their intent? (build something, evaluate options, learn, investigate a problem)
- What constraints are mentioned or implied?
- What's left ambiguous or could be interpreted multiple ways?

**Step 0b: Decide whether to ask**

```
IF the topic is clear and specific (e.g., "best practices for API rate limiting in Express.js"):
  → Skip to section 1. No questions needed.

IF there are genuine ambiguities that would change the research direction:
  → Ask 1 targeted AskUserQuestion (see below)
  → Do NOT ask generic context questions — only ask about things that are truly unclear
```

**Step 0c: Ask targeted question (only if ambiguity detected)**

The question must be DERIVED from the topic, not a generic template. Examples:

```yaml
# Example: topic = "authentication for my app"
# Ambiguity: many auth approaches, don't know the stack
questions:
  - header: "Auth scope"
    question: "Authentication covers a lot of ground. What's most important to research?"
    options:
      - label: "Auth provider comparison"
        description: "Clerk vs Auth.js vs Supabase Auth vs custom"
      - label: "Auth architecture patterns"
        description: "JWT vs sessions, middleware design, token refresh"
      - label: "Full auth implementation"
        description: "End-to-end: signup, login, protected routes, roles"
    multiSelect: false

# Example: topic = "improve performance of my Next.js app"
# Ambiguity: performance could mean many things
questions:
  - header: "Perf focus"
    question: "Performance optimization has many angles. Where's the pain?"
    options:
      - label: "Initial page load (Core Web Vitals)"
        description: "LCP, FID, CLS — what users see first"
      - label: "Runtime performance"
        description: "Slow interactions, heavy re-renders, memory leaks"
      - label: "Build & deploy speed"
        description: "Slow builds, large bundles, cold starts"
      - label: "Database / API latency"
        description: "Slow queries, N+1 problems, caching strategy"
    multiSelect: true
```

**Rules for this question:**
- ONLY ask if the answer would materially change what you research
- Prefer multiple-choice options derived from the topic
- 1 question maximum — don't interrogate the user
- If in doubt, skip and research broadly
</smart_scoping>

<parse_topic>
**1. Parse and Expand Topic Scope**

Analyze the topic (refined by user answer if Phase 0 asked a question) to identify:
- **Core question**: What exactly are we researching?
- **Adjacent areas**: What related topics might inform this?
- **Key terms**: What should we search for?
- **Stakeholders**: Who cares about this topic and why?

**Scope Expansion:**
"For `{topic}`, I'm also considering:
- [Related area 1] - because it might affect...
- [Related area 2] - to understand alternatives...
- [Related area 3] - to see historical context..."
</parse_topic>

<parallel_agents>
**2. Execute Research**

<economy_mode_research>
**If `{economy_mode}` = true:** Use direct tool calls in main thread

**Web Search** (use WebSearch tool directly)
- Search: `{topic} best practices 2024 2025`
- Search: `{topic} comparison alternatives`
- Search: `{topic} real-world examples case studies`

**Documentation** (use mcp__context7__resolve-library-id + mcp__context7__query-docs if technical)
- Find relevant library documentation for tools mentioned in topic

**Codebase** (use Grep/Glob directly if applicable)
- `Grep` for patterns related to topic in codebase
- `Glob` for relevant file types
</economy_mode_research>

<standard_mode_research>
**If `{economy_mode}` = false:** Launch parallel subagents

**CRITICAL: Launch ALL agents in a SINGLE message for parallel execution.**

**Agent 1: Web Search** (`websearch`)
```
Research the current state of: {topic}

Find:
1. Current best practices and popular approaches
2. Recent developments and trends (2024-2025)
3. Key players, thought leaders, and their perspectives
4. Common use cases and applications
5. Any recent controversies or debates

Focus on diverse, authoritative sources.
```

**Agent 2: Documentation Research** (`explore-docs`) - if technical topic
```
Find documentation and technical guidance for: {topic}

Search for:
1. Official documentation from relevant tools/frameworks
2. Best practices guides
3. Code examples and patterns
4. Configuration recommendations
5. Known limitations or gotchas

Focus on practical implementation guidance.
```

**Agent 3: Codebase Exploration** (`explore-codebase`) - if applicable
```
Search the codebase for patterns related to: {topic}

Find:
1. Existing implementations of similar functionality
2. Patterns and conventions already in use
3. Related utilities or helpers
4. Test patterns for similar features
5. Any prior attempts or related code

Return file paths with line numbers.
```
</standard_mode_research>
</parallel_agents>

<interactive_check>
**3. Research Direction Check** (skip if `{fast_mode}`)

After initial research, present the most interesting directions discovered and let the user steer:

```yaml
questions:
  - header: "Directions"
    question: "Initial research on {topic} found several directions. Which should I dig deeper into?"
    options:
      - label: "{discovered_direction_1}"
        description: "{why this direction emerged from research}"
      - label: "{discovered_direction_2}"
        description: "{why this direction emerged from research}"
      - label: "{discovered_direction_3}"
        description: "{why this direction emerged from research}"
      - label: "All look relevant"
        description: "Continue with broad coverage"
    multiSelect: true
```

**Rules:**
- Options MUST come from actual research findings — not generic placeholders
- Use the most divergent/interesting directions found, not obvious ones
- If research found a surprising or controversial angle, include it as an option
- User's selection narrows the focus for Phases 2-3
</interactive_check>

<synthesize>
**4. Synthesize Broad Findings**

Combine all agent findings into comprehensive overview:

```
## Phase 1 Discoveries: {topic}

**Current Landscape:**
- [Finding 1 with source]
- [Finding 2 with source]
- [Finding 3 with source]

**Key Players & Perspectives:**
- [Player/Expert 1]: [Their view]
- [Player/Expert 2]: [Their view]

**Popular Approaches:**
1. [Approach 1] - used by [who], pros/cons
2. [Approach 2] - used by [who], pros/cons
3. [Approach 3] - used by [who], pros/cons

**Interesting Threads:**
- [Tangential but relevant finding]
- [Unexpected connection]
- [Emerging trend]

**Initial Impressions:**
At first glance, it seems like [initial take]. But this needs to be challenged.

**Questions Raised:**
- [Question that emerged from research]
- [Uncertainty that needs investigation]
```

Store in `{phase_1_discoveries}`
</synthesize>

<save_progress>
**5. Save Progress** (if `{save_file}` is true)

Append to `{session_path}`:
```markdown
# Brainstorm Session: {topic}
**Date:** {current_date}

## Phase 1: Expansive Exploration

[Phase 1 discoveries content]

---
```
</save_progress>

</execution_sequence>

---

<success_metrics>

- Multiple parallel agents launched for breadth
- Scope expanded beyond obvious interpretations
- Diverse sources and perspectives gathered
- Tangential but relevant threads captured
- Initial questions and uncertainties noted
- No premature filtering or conclusions
</success_metrics>

<failure_modes>

- Launching agents sequentially instead of parallel
- Only searching for confirming evidence
- Filtering out "irrelevant" findings too early
- Drawing conclusions before Phase 4
- Missing adjacent areas that could inform the topic
</failure_modes>

---

<next_step_directive>
**CRITICAL:** After presenting Phase 1 discoveries:

**If `{fast_mode}` = true:**
"**Phase 1 complete.** Skipping challenge phase (fast mode).

Loading `step-03-synthesize.md`..."

→ Load `steps/step-03-synthesize.md` directly

**If `{fast_mode}` = false:**
"**Phase 1 complete.** We've cast a wide net and gathered diverse perspectives.

**NEXT: Phase 2 - Critical Challenge**

Now I become the DEVIL'S ADVOCATE. Every finding above will be questioned and stress-tested.

Loading `step-02-challenge.md`..."

→ Load `steps/step-02-challenge.md`
</next_step_directive>
