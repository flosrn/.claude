---
name: step-01b-team-analyze
description: Agent Team parallel research - explore codebase across multiple research domains simultaneously
prev_step: ./step-00-init.md
next_step: ./step-02-plan.md
load_condition: team_mode = true
---

# Step 1b: Team Analyze (Parallel Research)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER explore the codebase yourself - delegate to researchers
- 🛑 NEVER plan or design solutions - that's step 2
- 🛑 NEVER decide HOW to implement anything
- ✅ ALWAYS use TeamCreate, TaskCreate, and Task tools
- ✅ ALWAYS launch all independent researchers in parallel
- ✅ ALWAYS synthesize findings into step-01 format
- 📋 YOU ARE A RESEARCH COORDINATOR, not a researcher
- 💬 FOCUS on orchestrating researchers, not exploring code
- 🚫 FORBIDDEN to use Edit, Write tools directly (teammates are read-only too)

## EXECUTION PROTOCOLS:

- 🎯 Analyze task complexity before choosing research domains
- 💾 Monitor task completion via TaskList
- 🔄 Cross-pollinate key findings between researchers
- 🚫 FORBIDDEN to have researchers modify any files

## CONTEXT BOUNDARIES:

- Variables from step-00-init are available
- team_mode = true (validated in step-00)
- auto_mode may be true or false (team_mode no longer requires auto_mode)
- This step replaces step-01-analyze.md entirely
- No implementation decisions have been made yet
- Codebase state is unknown - must be discovered by researchers

## CONTEXT RESTORATION (resume mode):

<critical>
If this step was loaded via `/apex -r {task_id}` resume:

1. Read `{output_dir}/00-context.md` → restore flags, task info, acceptance criteria
2. Check if `{output_dir}/01-analyze.md` already has findings (not just the template header)
3. If findings exist (analysis was completed before) → skip to step-02-plan.md directly
4. If 01-analyze progress is "⏳ In Progress" (analysis crashed mid-execution):
   → Team mode cannot resume mid-research (teammates don't survive sessions)
   → Fall back to solo: set {team_mode} = false, load step-01-analyze.md
5. If 01-analyze progress is "⏸ Pending" (arriving here for the first time):
   → Proceed normally with team analysis (teammates are fresh)
</critical>

## YOUR TASK:

Orchestrate parallel research by spawning Agent Team researchers, one per research domain determined by task complexity.

---

<available_state>
From step-00-init:

| Variable | Description |
|----------|-------------|
| `{task_description}` | What to implement |
| `{task_id}` | Kebab-case identifier |
| `{reference_files}` | Path to reference document (e.g., brainstorm output), or empty |
| `{auto_mode}` | true or false (team_mode no longer requires auto_mode) |
| `{save_mode}` | Save outputs to files |
| `{output_dir}` | Path to output (if save_mode) |
| `{economy_mode}` | Always false when team_mode is true |
| Research domains | Determined in Phase 1 based on task complexity |
</available_state>

---

## EXECUTION SEQUENCE:

### Phase 0: READ REFERENCE DOCUMENTS (if any)

<critical>
**If `{reference_files}` is not empty:**

Read the reference file FIRST — it is the primary source of truth for what needs to be built.

1. Read the reference file using the Read tool
2. Extract and note:
   - **Objective:** What specifically needs to be built/changed
   - **Design decisions:** Schemas, approaches, tech choices already decided
   - **Implementation details:** APIs, patterns, architectures described
   - **Constraints:** Performance targets, compatibility requirements
   - **File references:** Any files mentioned in the reference doc
3. Use these findings to:
   - Inform how you split research domains (Phase 1)
   - Include key context in researcher prompts (Phase 3)
   - Guide the Task Requirements section during synthesis (Phase 5)

**If `{reference_files}` is empty:**
→ Skip to Phase 1.
</critical>

### Phase 1: ANALYZE COMPLEXITY

#### 1.1 Initialize Save Output (if save_mode)

**If `{save_mode}` = true:**

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "01" "analyze" "in_progress"
```

Append logs to `{output_dir}/01-analyze.md` as you work.

#### 1.2 Assess Task Scope

Before spawning researchers, THINK about what information you need:

```
Task: {task_description}

1. SCOPE: How many areas of the codebase are affected?
   - Single file/function → Low (2 domains)
   - Multiple related files → Medium (3 domains)
   - Cross-cutting concerns → High (4 domains)

2. LIBRARIES: Which external libraries are involved?
   - None or well-known basics → Skip docs research
   - Unfamiliar library or specific API needed → Need docs-researcher
   - Multiple libraries interacting → Need multiple doc domains

3. PATTERNS: Do I need to understand existing patterns?
   - Simple addition → Lightweight codebase research
   - Must integrate with existing code → Deep codebase research

4. UNCERTAINTY: What am I unsure about?
   - Clear requirements, known approach → Fewer researchers
   - Unclear approach, unfamiliar territory → More researchers
```

#### 1.3 Determine Research Domains (2-4)

Based on complexity, select from these domain types:

| Domain | subagent_type | Use When |
|--------|---------------|----------|
| `codebase-researcher` | `Explore` | Always - find existing patterns, related files, utilities, test patterns |
| `docs-researcher` | `general-purpose` | Unfamiliar library API, need current syntax (uses Context7/WebFetch) |
| `web-researcher` | `general-purpose` | Need best practices, common approaches, gotchas (uses WebSearch) |
| `codebase-researcher-2` | `Explore` | High complexity - split codebase exploration into multiple areas |

**Decision Matrix:**

| Task Type | Domains | Example |
|-----------|---------|---------|
| **Simple fix** | 2 | 1x codebase-researcher + 1x web-researcher |
| **Add feature (familiar stack)** | 2-3 | 1x codebase-researcher + 1x web-researcher |
| **Add feature (unfamiliar library)** | 3 | 1x codebase-researcher + 1x docs-researcher + 1x web-researcher |
| **Complex integration** | 3-4 | 1-2x codebase-researcher + 1x docs-researcher + 1x web-researcher |

### Phase 2: SETUP TEAM

#### 2.1 Create Team

```
TeamCreate:
  team_name: "apex-research-{task_id}"
  description: "APEX parallel research for {task_description}"
```

#### 2.2 Create Tasks

For each research domain, create a task:

```
TaskCreate:
  subject: "Research {domain_name}"
  description: |
    ## Domain: {domain_name}

    ## Research Focus:
    {specific exploration instructions for this domain}

    ## What to Find:
    {specific questions this researcher should answer}

    ## Rules:
    - Report findings with file:line references
    - Do NOT suggest implementations or approaches
    - Do NOT modify any files
    - Focus on WHAT EXISTS, not what SHOULD BE
    - Be thorough but concise
  activeForm: "Researching {domain_name}"
```

No task dependencies needed - all research is independent initially.

### Phase 3: SPAWN RESEARCHERS

#### 3.1 Spawn One Researcher Per Domain

**Launch ALL researchers in ONE message (parallel).**

For **codebase researchers** (read-only, fast):

```
Task:
  description: "Research codebase for {specific_area}"
  subagent_type: "Explore"
  team_name: "apex-research-{task_id}"
  name: "codebase-researcher"
  prompt: |
    You are a researcher in an APEX workflow team. Your job is to explore
    the codebase and report findings about {specific_area}.

    ## Your Task
    Check TaskList for your assigned task, claim it with TaskUpdate (set owner
    to your name), then research what's described in the task.

    ## Research Instructions
    Find existing code related to: {specific_area}

    Report:
    1. Files with paths and line numbers
    2. Patterns used for similar features
    3. Relevant utilities and helpers
    4. Test patterns and test file locations
    5. Configuration files and dependencies

    ## Critical Rules
    1. Read the task description carefully for your research focus
    2. Report findings with specific file:line references
    3. Do NOT suggest implementations - only report what EXISTS
    4. Do NOT modify any files
    5. Mark your task as completed when done
    6. Send a message to the team lead summarizing your findings
```

For **docs researchers** (need WebFetch/Context7):

```
Task:
  description: "Research {library_name} documentation"
  subagent_type: "general-purpose"
  team_name: "apex-research-{task_id}"
  name: "docs-researcher"
  prompt: |
    You are a documentation researcher in an APEX workflow team. Your job is
    to find relevant library documentation for {library_name}.

    ## Your Task
    Check TaskList for your assigned task, claim it with TaskUpdate (set owner
    to your name), then research the documentation.

    ## Research Instructions
    Research {library_name} documentation for: {specific_question}

    Find:
    1. Current API for {specific_feature}
    2. Code examples and usage patterns
    3. Configuration options
    4. Migration notes or version-specific gotchas

    Use Context7 MCP (resolve-library-id then query-docs) for up-to-date docs.
    Fall back to WebFetch for official documentation sites.

    ## Critical Rules
    1. Focus on finding CURRENT, ACCURATE documentation
    2. Include code examples where available
    3. Do NOT suggest implementations - only report documentation findings
    4. Do NOT modify any files
    5. Mark your task as completed when done
    6. Send a message to the team lead summarizing your findings
```

For **web researchers** (need WebSearch):

```
Task:
  description: "Research best practices for {topic}"
  subagent_type: "general-purpose"
  team_name: "apex-research-{task_id}"
  name: "web-researcher"
  prompt: |
    You are a web researcher in an APEX workflow team. Your job is to find
    best practices and common approaches for {topic}.

    ## Your Task
    Check TaskList for your assigned task, claim it with TaskUpdate (set owner
    to your name), then research the topic.

    ## Research Instructions
    Search for: {specific_question_or_approach}

    Find:
    1. Common patterns and best practices
    2. Known pitfalls and gotchas
    3. Performance considerations
    4. Security considerations (if relevant)

    Use WebSearch and WebFetch tools for research.

    ## Critical Rules
    1. Focus on PRACTICAL, ACTIONABLE findings
    2. Cite sources where possible
    3. Do NOT suggest implementations - only report findings
    4. Do NOT modify any files
    5. Mark your task as completed when done
    6. Send a message to the team lead summarizing your findings
```

**Log each spawn (if save_mode):**
```markdown
### Researcher Spawned: {domain_name}
- Domain: {domain_name}
- Type: {subagent_type}
- Focus: {research focus}
**Timestamp:** {ISO}
```

### Phase 4: CROSS-POLLINATE

#### 4.1 Lead Coordination Loop

The lead (you) enters coordination mode:

```
WHILE any research tasks are not completed:
  1. Wait for researcher messages (they arrive automatically)

  2. Handle findings reports:
     - Note key discoveries from each researcher
     - Identify connections between findings

  3. Forward relevant discoveries between researchers:
     - Example: "codebase researcher found Zod validation pattern —
       docs researcher, find Zod schema composition docs"
     - Example: "web researcher found rate limiting best practice —
       codebase researcher, check if rate limiting exists in middleware/"

  4. Handle researcher questions:
     - Answer questions about the task or scope
     - Keep responses focused - don't redirect research

  5. Check TaskList periodically for overall progress
```

#### 4.2 Cross-Pollination Rules

```
- Keep it LIGHT — 1-2 rounds max, don't over-coordinate
- SKIP entirely if findings are straightforward and independent
- Only forward discoveries that could meaningfully improve another researcher's work
- Never ask a researcher to redo their work — only to check additional things
```

#### 4.3 Handle Failures

```
IF a researcher gets stuck or returns poor results:
  1. Read their message carefully
  2. If scope issue: provide clarification via SendMessage
  3. If tool issue: suggest alternative approach
  4. If unrecoverable:
     - Shutdown that researcher
     - Note the gap in findings
     - Fill it yourself during synthesis (Phase 5)
```

### Phase 5: SYNTHESIZE & CLEANUP

#### 5.1 Verify All Tasks Complete

```
TaskList → Verify all research tasks show status: "completed"
```

#### 5.2 Combine Findings

Combine ALL researcher findings into the step-01 structured format.

**Start with Task Requirements (MANDATORY):**

```markdown
## Task Requirements

### Objective
{Clear 2-3 sentence description of what needs to be built/changed.
 If reference doc exists: extract the objective from it.
 If no reference doc: infer from task description + researcher findings.}

### Key Specifications
{If reference doc exists: key decisions, schemas, approaches, performance targets extracted from it.
 If no reference doc: inferred from task description and what researchers discovered.}
- {Specific technical requirement}
- {Schema/interface to implement or modify}
- {Integration points}
- {Performance/quality constraints}

### Reference
{If reference doc: "**Source:** `{reference_files}` — {one-line summary of what it contains}"}
{If no reference doc: "Inferred from task description and codebase analysis"}
```

<critical>
The Task Requirements section is MANDATORY — it must appear FIRST in the 01-analyze.md output, before Codebase Context.
- WITH reference doc: extract concrete specs, schemas, decisions, constraints from the reference
- WITHOUT reference doc: infer what needs to change from the task description + what researchers discovered
- Either way, be SPECIFIC about what needs to be built
</critical>

**Then continue with Codebase Context:**

```markdown
## Codebase Context

### Related Files Found
| File | Lines | Contains |
|------|-------|----------|
| `src/example/file.ts` | 1-150 | Description of what's there |

### Patterns Observed
- **Pattern name**: Description with file:line reference
- **Pattern name**: Description with file:line reference

### Utilities Available
- `src/lib/util.ts` - Description of utility
- `src/lib/helper.ts` - Description of helper

### Similar Implementations
- `src/example/similar.ts:42` - Description (reference for patterns)

### Test Patterns
- Tests in `__tests__/` folders
- Uses {test framework} with {test utilities}

## Documentation Insights

### Libraries Used
- **{library}**: Description of relevant API
- **{library}**: Description of relevant API

## Research Findings

### Common Approaches
- Finding from web research
- Best practice from web research

### Pitfalls to Avoid
- Known gotcha from research
```

#### 5.3 Infer Acceptance Criteria

Based on task and combined research context:

```markdown
## Inferred Acceptance Criteria

Based on "{task_description}" and existing patterns:

- [ ] AC1: [specific measurable outcome]
- [ ] AC2: [specific measurable outcome]
- [ ] AC3: [specific measurable outcome]

_These will be refined in the planning step._
```

**If `{save_mode}` = true:** Update 00-context.md acceptance criteria section (replace `_Defined during step-01-analyze_` with the inferred AC)

#### 5.4 Shutdown Researchers

For each researcher:

```
SendMessage:
  type: "shutdown_request"
  recipient: "{domain_name}"
  content: "Research complete, shutting down. Thank you for your findings!"
```

Wait for shutdown confirmations.

#### 5.5 Delete Team

```
TeamDelete
```

#### 5.6 Research Summary

```
**Team Research Complete**

**Team:** apex-research-{task_id}
**Domains:** {count} research domains, {count} researchers

**Domain Results:**
- {domain_name}: {summary of key findings}
- {domain_name}: {summary of key findings}

**Files identified:** {count}
**Patterns documented:** {count}
**Libraries researched:** {count}

→ Proceeding to planning phase...
```

### 6. Complete Save Output (if save_mode)

**If `{save_mode}` = true:**

Append to `{output_dir}/01-analyze.md`:
```markdown
---
## Step Complete
**Status:** Complete
**Mode:** Team research (Agent Teams)
**Domains:** {count}
**Researchers:** {count}
**Files identified:** {count}
**Next:** step-02-plan.md
**Timestamp:** {ISO timestamp}
```

Note: Progress updates (marking step-01 complete and setting next_step) are handled by `session-boundary.sh` in the NEXT STEP section.

---

## SUCCESS METRICS:

✅ Task complexity analyzed before choosing research domains
✅ Right number of researchers spawned (2-4 based on complexity)
✅ Right type of researchers chosen (Explore vs general-purpose)
✅ All researchers launched in parallel (single message)
✅ Cross-pollination used when findings connect (skipped when unnecessary)
✅ All findings synthesized into step-01 structured format
✅ Acceptance criteria inferred from findings
✅ All researchers shutdown cleanly
✅ Team deleted
✅ NO planning or implementation decisions made
✅ Progress logged (if save_mode)

## FAILURE MODES:

❌ Exploring the codebase directly instead of delegating to researchers
❌ Starting to plan or design (that's step 2!)
❌ Suggesting implementations or approaches
❌ Allowing researchers to modify files
❌ Launching researchers sequentially instead of parallel
❌ Over-coordinating cross-pollination (more than 2 rounds)
❌ Not shutting down researchers after completion
❌ Not deleting the team
❌ Using plan mode for researchers (they're read-only, no approval needed)
❌ **CRITICAL**: Not synthesizing findings into structured step-01 format

## COORDINATION PROTOCOLS:

- Delegate research, don't explore yourself
- Spawn all independent researchers in parallel
- Cross-pollinate only when findings meaningfully connect
- Keep coordination light - researchers are autonomous
- Synthesize all findings into step-01 format
- Always cleanup: shutdown researchers + delete team

---

## NEXT STEP:

### Session Boundary

```
IF auto_mode = true:
  → If save_mode = true, update progress and state:
    ```bash
    bash {skill_dir}/scripts/update-progress.sh "{task_id}" "01" "analyze" "complete"
    bash {skill_dir}/scripts/update-state-snapshot.sh "{task_id}" "02-plan" "**01-analyze:** {one-line summary of key findings}" ["{gotcha if any}"]
    ```
  → Load ./step-02-plan.md directly (chain all steps)

IF auto_mode = false:
  → Run (if save_mode):
    ```bash
    bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "01" "analyze" "Key findings: {count} files, {count} patterns (team research)" "02-plan" "Plan (Strategic Design)" "**01-analyze:** {one-line summary of key findings}"
    ```
  → Display the output to the user
  → STOP. Do NOT load the next step.
  → The session ENDS here. User must run /apex -r {task_id} to continue.
```

<critical>
Remember: You are a RESEARCH COORDINATOR in this step. Your job is to:
1. Analyze task complexity and choose research domains
2. Set up the team and tasks
3. Spawn researchers with clear instructions
4. Cross-pollinate key findings between researchers
5. Synthesize all findings into structured format
6. Clean up

You do NOT explore the codebase yourself. Researchers do the work.
Output MUST match step-01 format: Related Files, Patterns, Utilities, Documentation Insights, Research Findings, Acceptance Criteria.
</critical>
