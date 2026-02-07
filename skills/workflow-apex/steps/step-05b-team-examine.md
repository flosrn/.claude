---
name: step-05b-team-examine
description: Agent Team parallel adversarial review - multiple reviewers examine code simultaneously and challenge each other
prev_step: steps/step-04-validate.md
next_step: steps/step-06-resolve.md
load_condition: team_mode = true AND examine_mode = true
---

# Step 5b: Team Examine (Parallel Adversarial Review)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER review code yourself - delegate to reviewers
- 🛑 NEVER skip the cross-challenge phase
- 🛑 NEVER present findings without deduplication
- 🛑 NEVER allow reviewers to fix code (read-only)
- ✅ ALWAYS use TeamCreate, TaskCreate, and Task tools
- ✅ ALWAYS launch all reviewers in parallel
- ✅ ALWAYS run cross-challenge after initial findings
- ✅ ALWAYS deduplicate before presenting findings table
- 📋 YOU ARE A REVIEW COORDINATOR, not a reviewer
- 💬 FOCUS on orchestrating reviewers and synthesizing findings
- 🚫 FORBIDDEN to use Edit, Write tools directly (reviewers are read-only)

## EXECUTION PROTOCOLS:

- 🎯 Detect review domains before spawning (3 fixed + 1 conditional)
- 💾 Monitor task completion via TaskList
- 📖 Share findings across reviewers for cross-challenge
- 🚫 FORBIDDEN to skip cross-challenge (it's the whole point of team review)

## CONTEXT BOUNDARIES:

- Implementation is complete and validated
- All tests pass
- Now looking for issues that tests miss
- Adversarial mindset - assume bugs exist
- team_mode = true (validated in step-00)
- auto_mode may be true or false (team_mode no longer requires auto_mode)
- This step replaces step-05-examine.md entirely

## CONTEXT RESTORATION (resume mode):

<critical>
If this step was loaded via `/apex -r {task_id}` resume:

1. Read `{output_dir}/00-context.md` → restore flags, task info, acceptance criteria
2. Read `{output_dir}/03-execute.md` → restore execution log (files modified)
3. **Note:** Team mode cannot resume mid-review (teammates don't survive sessions)
4. Check if `{output_dir}/05-examine.md` already has findings
5. If findings exist, skip to step-06-resolve.md:
   → Load step-06-resolve.md directly
6. If no findings yet, fall back to solo review:
   → Set {team_mode} = false (disable for this session only)
   → Load step-05-examine.md (which will now execute solo since team_mode is false)
</critical>

## YOUR TASK:

Orchestrate parallel adversarial review by spawning Agent Team reviewers, one per review domain.

---

<available_state>
From previous steps:

| Variable | Description |
|----------|-------------|
| `{task_description}` | What was implemented |
| `{task_id}` | Kebab-case identifier |
| `{auto_mode}` | true or false (team_mode no longer requires auto_mode) |
| `{save_mode}` | Save outputs to files |
| `{output_dir}` | Path to output (if save_mode) |
| Files modified | From step-03 |
</available_state>

---

## EXECUTION SEQUENCE:

### Phase 1: GATHER CHANGES

#### 1.1 Initialize Save Output (if save_mode)

**If `{save_mode}` = true:**

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "05" "examine" "in_progress"
```

Append logs to `{output_dir}/05-examine.md` as you work.

#### 1.2 Collect Modified Files

```bash
git diff --name-only HEAD~1
git status --porcelain
```

Group files into categories:
- **source**: Application code (*.ts, *.tsx, *.js, *.jsx, *.py, etc.)
- **tests**: Test files (*.test.*, *.spec.*, __tests__/*)
- **config**: Configuration files (*.config.*, *.json, *.yaml, etc.)

#### 1.3 Detect Next.js/React Files

```
Check if modified files match Next.js/Vercel patterns:
- *.tsx, *.jsx files in app/, pages/, components/
- next.config.* files
- Server actions (use server)
- API routes (app/api/*, pages/api/*)
- Middleware (middleware.ts)
- Server components, client components

SET {nextjs_detected} = true/false
```

### Phase 2: SETUP TEAM

#### 2.1 Create Team

```
TeamCreate:
  team_name: "apex-review-{task_id}"
  description: "APEX parallel adversarial review for {task_description}"
```

#### 2.2 Create Review Tasks

Create one task per review domain:

**Task: Security Review**
```
TaskCreate:
  subject: "Security review: OWASP Top 10 analysis"
  description: |
    ## Domain: security

    ## Files to review:
    {list of modified source files}

    ## Context:
    {task_description}

    ## Focus areas:
    - OWASP Top 10 vulnerabilities
    - SQL/NoSQL injection
    - XSS (cross-site scripting)
    - Authentication and authorization flaws
    - Secrets or credentials in code
    - Input validation gaps
    - Insecure deserialization
    - Security misconfigurations

    ## Rules:
    - Read each file carefully
    - Report findings with file:line references
    - Classify severity: CRITICAL / HIGH / MEDIUM / LOW
    - DO NOT suggest fixes - only identify problems
  activeForm: "Reviewing security"
```

**Task: Logic Review**
```
TaskCreate:
  subject: "Logic review: edge cases and error handling"
  description: |
    ## Domain: logic

    ## Files to review:
    {list of modified source files}

    ## Context:
    {task_description}

    ## Focus areas:
    - Edge cases not handled
    - Null/undefined checks missing
    - Race conditions
    - Error handling gaps
    - Off-by-one errors
    - Incorrect boolean logic
    - Unreachable code paths
    - State management issues

    ## Rules:
    - Read each file carefully
    - Report findings with file:line references
    - Classify severity: CRITICAL / HIGH / MEDIUM / LOW
    - DO NOT suggest fixes - only identify problems
  activeForm: "Reviewing logic"
```

**Task: Quality Review**
```
TaskCreate:
  subject: "Quality review: SOLID and clean code analysis"
  description: |
    ## Domain: quality

    ## Files to review:
    {list of modified source files}

    ## Context:
    {task_description}

    ## Focus areas:
    - SOLID principle violations
    - Excessive complexity (cyclomatic, cognitive)
    - Code duplication
    - Poor naming conventions
    - Missing or misleading abstractions
    - Tight coupling
    - God objects or functions
    - Pattern inconsistency with existing codebase

    ## Rules:
    - Read each file carefully
    - Report findings with file:line references
    - Classify severity: CRITICAL / HIGH / MEDIUM / LOW
    - DO NOT suggest fixes - only identify problems
  activeForm: "Reviewing quality"
```

**Task: Vercel/Next.js Review (CONDITIONAL)**

→ **Only create if `{nextjs_detected}` = true:**

```
TaskCreate:
  subject: "Vercel/Next.js review: framework best practices"
  description: |
    ## Domain: vercel

    ## Files to review:
    {list of modified source files}

    ## Context:
    {task_description}

    ## Focus areas:
    - Server vs Client component boundaries ('use client' / 'use server')
    - Bundle optimization (barrel imports, dynamic imports)
    - Data fetching patterns (parallel vs sequential awaits)
    - Server-side caching (React cache, unstable_cache)
    - Re-render optimization (memo, useMemo, useCallback)
    - Preloading and parallel fetching patterns
    - Middleware usage patterns
    - API route best practices

    ## Rules:
    - Read each file carefully
    - Report findings with file:line references
    - Classify severity: CRITICAL / HIGH / MEDIUM / LOW
    - DO NOT suggest fixes - only identify problems
  activeForm: "Reviewing Vercel/Next.js patterns"
```

**No task dependencies needed** — all reviews are independent initially.

### Phase 3: SPAWN REVIEWERS

#### 3.1 Spawn One Reviewer Per Domain

Launch ALL reviewers in a SINGLE message block (parallel spawn):

**Security Reviewer:**
```
Task:
  description: "Security adversarial review"
  subagent_type: "code-reviewer"
  team_name: "apex-review-{task_id}"
  name: "security-reviewer"
  prompt: |
    You are an adversarial security reviewer in an APEX workflow team.
    Your job is to find security vulnerabilities - NOT fix them.

    ## Your Task
    Check TaskList for the security review task, claim it with TaskUpdate
    (set owner to "security-reviewer"), then review all listed files.

    ## Critical Rules
    1. Read the task description for your file list and focus areas
    2. Read EVERY file before reporting findings
    3. Find problems only - DO NOT suggest fixes
    4. Report each finding with: severity, file:line, description
    5. Focus on OWASP Top 10, injection, auth, secrets, input validation
    6. Mark your task as completed when done
    7. Send a message to the team lead with your findings in this format:

    ## Findings
    | Severity | Location | Issue |
    |----------|----------|-------|
    | CRITICAL | file.ts:42 | Description |
```

**Logic Reviewer:**
```
Task:
  description: "Logic adversarial review"
  subagent_type: "code-reviewer"
  team_name: "apex-review-{task_id}"
  name: "logic-reviewer"
  prompt: |
    You are an adversarial logic reviewer in an APEX workflow team.
    Your job is to find logic flaws and edge cases - NOT fix them.

    ## Your Task
    Check TaskList for the logic review task, claim it with TaskUpdate
    (set owner to "logic-reviewer"), then review all listed files.

    ## Critical Rules
    1. Read the task description for your file list and focus areas
    2. Read EVERY file before reporting findings
    3. Find problems only - DO NOT suggest fixes
    4. Report each finding with: severity, file:line, description
    5. Focus on edge cases, null checks, race conditions, error handling
    6. Mark your task as completed when done
    7. Send a message to the team lead with your findings in this format:

    ## Findings
    | Severity | Location | Issue |
    |----------|----------|-------|
    | HIGH | file.ts:78 | Description |
```

**Quality Reviewer:**
```
Task:
  description: "Quality adversarial review"
  subagent_type: "code-reviewer"
  team_name: "apex-review-{task_id}"
  name: "quality-reviewer"
  prompt: |
    You are an adversarial quality reviewer in an APEX workflow team.
    Your job is to find code quality issues - NOT fix them.

    ## Your Task
    Check TaskList for the quality review task, claim it with TaskUpdate
    (set owner to "quality-reviewer"), then review all listed files.

    ## Critical Rules
    1. Read the task description for your file list and focus areas
    2. Read EVERY file before reporting findings
    3. Find problems only - DO NOT suggest fixes
    4. Report each finding with: severity, file:line, description
    5. Focus on SOLID violations, complexity, duplication, naming
    6. Mark your task as completed when done
    7. Send a message to the team lead with your findings in this format:

    ## Findings
    | Severity | Location | Issue |
    |----------|----------|-------|
    | MEDIUM | file.ts:15 | Description |
```

**Vercel Reviewer (CONDITIONAL — only if `{nextjs_detected}` = true):**
```
Task:
  description: "Vercel/Next.js adversarial review"
  subagent_type: "code-reviewer"
  team_name: "apex-review-{task_id}"
  name: "vercel-reviewer"
  prompt: |
    You are an adversarial Vercel/Next.js reviewer in an APEX workflow team.
    Your job is to find framework anti-patterns - NOT fix them.

    ## Your Task
    Check TaskList for the Vercel/Next.js review task, claim it with TaskUpdate
    (set owner to "vercel-reviewer"), then review all listed files.

    ## Critical Rules
    1. Read the task description for your file list and focus areas
    2. Read EVERY file before reporting findings
    3. Find problems only - DO NOT suggest fixes
    4. Report each finding with: severity, file:line, description
    5. Focus on server/client boundaries, bundle optimization, data fetching
    6. Mark your task as completed when done
    7. Send a message to the team lead with your findings in this format:

    ## Findings
    | Severity | Location | Issue |
    |----------|----------|-------|
    | HIGH | page.tsx:20 | Description |
```

**Log each spawn (if save_mode):**
```markdown
### Reviewer Spawned: {reviewer_name}
- Domain: {domain}
- Files: {file list}
**Timestamp:** {ISO}
```

### Phase 4: CROSS-CHALLENGE

#### 4.1 Collect Initial Findings

```
WHILE any review tasks are not completed:
  1. Wait for reviewer messages (they arrive automatically)
  2. Collect findings from each reviewer as they complete
  3. Check TaskList periodically for overall progress
```

#### 4.2 Share Findings Across Reviewers

Once ALL initial reviews are complete, extract the top findings (CRITICAL and HIGH severity) and share them across reviewers:

```
For each reviewer:
  SendMessage:
    type: "message"
    recipient: "{reviewer_name}"
    content: |
      ## Cross-Challenge Round

      Other reviewers found these issues. For each one, answer:
      1. Is this actually a problem? (validate or challenge)
      2. Did you miss anything related in YOUR domain?

      ### Findings from other reviewers:
      {top findings from OTHER reviewers, not this one's own}

      Reply with:
      - Validated: [list of finding IDs you agree with]
      - Challenged: [list of finding IDs that are false positives, with reason]
      - New findings: [anything you discovered during cross-review]
    summary: "Cross-challenge: validate other reviewers' findings"
```

#### 4.3 Collect Cross-Challenge Results

```
WHILE any reviewers have not responded to cross-challenge:
  1. Wait for reviewer messages
  2. Collect validations, challenges, and new findings
  3. Note consensus and disagreements
```

**One round of cross-challenge is sufficient.**

### Phase 5: SYNTHESIZE & CLEANUP

#### 5.1 Deduplicate and Merge Findings

```
For all findings across all reviewers:
  1. Merge duplicates (same file:line, same issue)
  2. Keep the most severe classification when duplicated
  3. Note cross-domain findings (found by multiple reviewers)
  4. Incorporate cross-challenge results:
     - Remove findings challenged by 2+ reviewers (likely false positives)
     - Upgrade findings validated across domains
     - Add new findings discovered during cross-challenge
```

#### 5.2 Classify Findings

For each deduplicated finding:

**Severity:**
- CRITICAL: Security vulnerability, data loss risk
- HIGH: Significant bug, will cause issues
- MEDIUM: Should fix, not urgent
- LOW: Minor improvement

**Validity:**
- Real: Confirmed by multiple reviewers or unchallenged
- Noise: Challenged by 2+ reviewers with valid reasons
- Uncertain: Mixed opinions, needs discussion

#### 5.3 Present Findings Table

```markdown
## Findings

| ID | Severity | Category | Location | Issue | Validity | Reviewers |
|----|----------|----------|----------|-------|----------|-----------|
| F1 | CRITICAL | Security | auth.ts:42 | SQL injection | Real | security, logic |
| F2 | HIGH | Logic | handler.ts:78 | Missing null check | Real | logic |
| F3 | MEDIUM | Quality | utils.ts:15 | Complex function | Uncertain | quality |

**Summary:** {count} findings ({blocking} blocking)
**Cross-challenge:** {validated} validated, {challenged} challenged, {new} new findings discovered
```

#### 5.4 Create Finding Todos

```
- [ ] F1 [CRITICAL] Fix SQL injection in auth.ts:42
- [ ] F2 [HIGH] Add null check in handler.ts:78
```

#### 5.5 Shutdown Reviewers

For each reviewer:

```
SendMessage:
  type: "shutdown_request"
  recipient: "{reviewer_name}"
  content: "Review complete, shutting down. Thanks for the thorough review!"
```

Wait for shutdown confirmations.

#### 5.6 Delete Team

```
TeamDelete
```

#### 5.7 Review Summary

```
**Team Adversarial Review Complete**

**Team:** apex-review-{task_id}
**Reviewers:** {count} reviewers ({list of domains})

**Review Results:**
- security-reviewer: {count} findings
- logic-reviewer: {count} findings
- quality-reviewer: {count} findings
- vercel-reviewer: {count} findings (if applicable)

**Cross-Challenge Results:**
- Validated: {count} findings confirmed across domains
- Challenged: {count} false positives removed
- New: {count} additional findings from cross-review

**Final Findings:** {total count} ({critical} critical, {high} high, {medium} medium, {low} low)
```

### 6. Get User Approval (review → resolve/test)

**If `{auto_mode}` = true:**
→ Proceed automatically based on findings

**If `{auto_mode}` = false:**

```yaml
questions:
  - header: "Review"
    question: "Team review complete. How would you like to proceed?"
    options:
      - label: "Resolve findings (Recommended)"
        description: "Address the identified issues"
      - label: "Skip to tests"
        description: "Skip resolution, proceed to test creation"
      - label: "Skip resolution"
        description: "Accept findings, don't make changes"
      - label: "Discuss findings"
        description: "I want to discuss specific findings"
    multiSelect: false
```

<critical>
This is one of the THREE transition points that requires user confirmation:
1. plan → execute
2. validate → review
3. review → resolve/test (THIS ONE)
</critical>

**Persist user choice (if save_mode):**

Append to `{output_dir}/00-context.md` under `### User Choices`:
```markdown
- **step-05 → next:** {chosen option} (e.g., "resolve", "skip-to-tests", "skip-resolution")
```

### 7. Complete Save Output (if save_mode)

**If `{save_mode}` = true:**

Append to `{output_dir}/05-examine.md`:
```markdown
---
## Step Complete
**Status:** ✓ Complete
**Mode:** Team review (Agent Teams)
**Reviewers:** {count}
**Findings:** {count}
**Critical:** {count}
**Cross-challenge:** {validated} validated, {challenged} challenged
**Next:** step-06-resolve.md
**Timestamp:** {ISO timestamp}
```

---

## SUCCESS METRICS:

✅ All modified files reviewed by domain specialists
✅ Cross-challenge phase completed (findings validated across domains)
✅ Findings deduplicated and merged
✅ Findings classified by severity and validity
✅ Findings table presented (matching step-05 format)
✅ Todos created for each finding
✅ All reviewers shutdown cleanly
✅ Team deleted
✅ Progress logged (if save_mode)

## FAILURE MODES:

❌ Reviewing code directly instead of delegating to reviewers
❌ Skipping cross-challenge phase (this is the KEY differentiator)
❌ Presenting duplicate findings from multiple reviewers
❌ Allowing reviewers to suggest/implement fixes
❌ Not shutting down reviewers after completion
❌ Not deleting the team
❌ Launching reviewers sequentially instead of in parallel
❌ Using Edit or Write tools (reviewers are read-only)
❌ **CRITICAL**: Skipping Vercel/Next.js reviewer when React/Next.js files are modified

## COORDINATION PROTOCOLS:

- Delegate, don't review
- All reviewers launch in parallel (no dependencies)
- Cross-challenge is mandatory — it catches false positives and cross-domain issues
- Deduplicate before presenting to avoid noise
- Output must match step-05 format (findings table, todos, severity)
- Always cleanup: shutdown reviewers + delete team

---

## NEXT STEP:

**Determine next step based on user choice/flags:**
- **"Resolve findings":** next = `06-resolve`
- **"Skip to tests" (and test_mode):** next = `07-tests`
- **"Skip resolution" + test_mode:** next = `07-tests`
- **"Skip resolution" + pr_mode:** next = `09-finish`
- **"Skip resolution" (no more steps):** Workflow complete

### Session Boundary

```
IF auto_mode = true:
  → Load the determined next step directly (chain all steps)

IF auto_mode = false AND workflow not complete:
  → Mark step complete in progress table (if save_mode):
    bash {skill_dir}/scripts/update-progress.sh "{task_id}" "05" "examine" "complete"
  → Update State Snapshot in 00-context.md:
    1. Set next_step to the determined next step
    2. Append to Step Context: "- **05-examine:** {count} findings ({count} blocking)"
  → Display:

    ═══════════════════════════════════════
      STEP 05 COMPLETE: Team Examine
    ═══════════════════════════════════════
      Reviewers: {count} ({domains})
      Findings: {count} ({blocking} blocking)
      Cross-challenge: {validated}/{challenged}/{new}
      Resume: /apex -r {task_id}
      Next: Step {NN} - {description}
    ═══════════════════════════════════════

  → STOP. Do NOT load the next step.

IF workflow complete:
  → Show final APEX WORKFLOW COMPLETE summary
  → STOP.
```

<critical>
Remember: You are a COORDINATOR in this step. Your job is to:
1. Gather changes and detect review domains
2. Set up the team and review tasks
3. Spawn reviewers with clear focus areas
4. Run cross-challenge to validate findings
5. Synthesize and deduplicate findings
6. Present results and clean up

You do NOT review code yourself. Reviewers do the work.
Reviewers are READ-ONLY — they find problems, they do NOT fix them.
</critical>
