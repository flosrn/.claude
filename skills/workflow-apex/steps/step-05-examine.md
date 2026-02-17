---
name: step-05-examine
description: Adversarial code review - security, logic, and quality analysis
prev_step: ./step-04-validate.md OR ./step-08-run-tests.md
next_step: conditional (06-resolve | 07-tests | 09-finish | complete)
---

# Step 5: Examine (Adversarial Review)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER skip security review
- 🛑 NEVER dismiss findings without justification
- 🛑 NEVER auto-approve without thorough review
- ✅ ALWAYS check OWASP top 10 vulnerabilities
- ✅ ALWAYS classify findings by severity and validity
- ✅ ALWAYS present findings table to user
- 📋 YOU ARE A SKEPTICAL REVIEWER, not a defender
- 💬 FOCUS on "What could go wrong?"
- 🚫 FORBIDDEN to approve without thorough analysis

## EXECUTION PROTOCOLS:

- 🎯 Launch parallel review agents (unless economy_mode)
- 💾 Document all findings with severity
- 📖 Create todos for each finding
- 🚫 FORBIDDEN to skip security analysis

## CONTEXT BOUNDARIES:

- Implementation is complete and validated
- All tests pass
- Now looking for issues that tests miss
- Adversarial mindset - assume bugs exist

## CONTEXT RESTORATION (resume mode):

<critical>
If this step was loaded via `/apex -r {task_id}` resume:

1. Read `{output_dir}/00-context.md` → restore flags, task info, acceptance criteria
2. Read `{output_dir}/03-execute.md` → restore execution log (files modified)
3. Check if `{output_dir}/05-examine.md` already has findings (not just the template header)
4. If findings exist (review was completed before) → skip to step-06-resolve.md
5. If 05-examine progress is "⏳ In Progress" (review crashed mid-execution):
   → Re-run the review from scratch (previous partial findings may be incomplete)
6. If 05-examine progress is "⏸ Pending" (arriving here for the first time):
   → Proceed normally with review below
</critical>

## TEAM MODE BRANCHING:

<critical>
IF {team_mode} = true:
  → Do NOT execute this file.
  → Load `./step-05b-team-examine.md` instead.
  → That file handles parallel adversarial review via Agent Teams.
</critical>

## YOUR TASK:

Conduct an adversarial code review to identify security vulnerabilities, logic flaws, and quality issues.

---

<available_state>
From previous steps:

| Variable | Description |
|----------|-------------|
| `{task_description}` | What was implemented |
| `{task_id}` | Kebab-case identifier |
| `{auto_mode}` | Auto-fix Real findings |
| `{save_mode}` | Save outputs to files |
| `{economy_mode}` | No subagents, direct review |
| `{test_mode}` | Include test steps |
| `{pr_mode}` | Create pull request |
| `{output_dir}` | Path to output (if save_mode) |
| Files modified | From step-03 |
</available_state>

---

## EXECUTION SEQUENCE:

### 1. Initialize Save Output (if save_mode)

**If `{save_mode}` = true:**

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "05" "examine" "in_progress"
```

Append findings to `{output_dir}/05-examine.md` as you work.

### 2. Gather Changes

```bash
git diff --name-only HEAD~1
git status --porcelain
```

Group files: source, tests, config, other.

### 3. Conduct Review

**If `{economy_mode}` = true:**
→ Self-review with checklist:

```markdown
## Security Checklist
- [ ] No SQL injection (parameterized queries)
- [ ] No XSS (output encoding)
- [ ] No secrets in code
- [ ] Input validation present
- [ ] Auth checks on protected routes

## Logic Checklist
- [ ] Error handling for all failure modes
- [ ] Edge cases handled
- [ ] Null/undefined checks
- [ ] Race conditions considered

## Quality Checklist
- [ ] Follows existing patterns
- [ ] No code duplication
- [ ] Clear naming
```

**If `{economy_mode}` = false:**
→ Launch parallel review agents

**CRITICAL: Launch ALL in a SINGLE message using Task tool with `Explore` agent (read-only, fast):**

**Agent 1** (`Explore` — focus: security)
```
Focus: security
Files: {list of modified source files}
Context: {task_description}

Review these files for security vulnerabilities using this checklist:

## A01: Broken Access Control
- Authorization checks on EVERY request (not just UI)
- Server-side enforcement (never trust client)
- IDOR protection: Users can't access others' data by changing IDs
- No privilege escalation paths (horizontal or vertical)
- Default deny policy (explicit allow required)

## A02: Security Misconfiguration
- No default credentials
- Debug mode disabled in production
- Error messages don't expose internals

## A04: Cryptographic Failures
- Password hashing: bcrypt/Argon2/scrypt (NOT MD5/SHA1)
- No hardcoded encryption keys

## A05: Injection
- SQL: Parameterized queries ONLY (no string concatenation)
- Command: No eval(), exec(), system() with user input
- XSS: Output encoding context-appropriate
- Template: No user input in template names

## Input Validation
- Server-side validation on ALL inputs
- Allowlist approach (whitelist known-good)
- Validate: type, length, format, range
- File uploads: extension + MIME + content inspection
- Regex reviewed for ReDoS vulnerabilities

## Authentication & Sessions
- Session tokens: ≥128 bits entropy, HttpOnly+Secure+SameSite
- Error messages: Generic ("Invalid credentials"), no user enumeration
- Lockout: Exponential delay after failed attempts

## CSRF Protection
- Tokens in state-changing requests (POST, PUT, DELETE)
- SameSite=Lax minimum on cookies

## Search Patterns (run these)
- Hardcoded secrets: password.*=.*['"], api[_-]?key.*=
- Dangerous functions: eval(, exec(, system(, shell_exec(
- SQL injection risk: query(*['"].*+, execute(*f['"]

## Findings Format
For each finding: [BLOCKING/CRITICAL/SUGGESTION] What + Why + How
Example: "[BLOCKING] SQL injection at auth.ts:34. Query uses string concatenation with user input, allowing query modification. Fix: Use parameterized query."
Do NOT speculate — only report findings you can point to in the code.
```

**Agent 2** (`Explore` — focus: logic)
```
Focus: logic
Files: {list of modified source files}
Context: {task_description}

Review these files for logic errors using this checklist:

## Edge Cases
- Null/undefined inputs at every function entry
- Empty arrays/strings/objects
- Boundary values (0, -1, MAX_INT, empty string)
- Single element vs multiple element collections
- Unicode/special characters in string inputs

## Error Handling
- Every async operation has error handling (try/catch, .catch)
- Errors propagated correctly (not swallowed silently)
- Resource cleanup in error paths (connections, file handles, timers)
- Retry logic has backoff and max attempts
- Meaningful error messages (not generic "something went wrong")

## Race Conditions
- Shared state accessed by multiple async paths
- Check-then-act patterns (TOCTOU vulnerabilities)
- Missing locks/mutexes on critical sections
- Event ordering assumptions that may not hold
- Concurrent modification of collections

## Logic Verification
- Boolean expressions correct (De Morgan's law violations)
- Off-by-one errors in loops, slices, and array indexing
- Unreachable code paths / dead code
- Switch/case missing break or default
- Comparison operators (=== vs ==, < vs <=)
- Integer overflow / floating point precision

## State Management
- State transitions are valid (no impossible states)
- Initialization before use
- Cleanup/reset when component unmounts or scope ends
- No stale closures or references
- Promises/async properly awaited (no fire-and-forget)

## Findings Format
For each finding: [BLOCKING/CRITICAL/SUGGESTION] What + Why + How
Severity: CRITICAL (data loss/crash) > HIGH (will cause bugs) > MEDIUM (should fix) > LOW (minor)
Do NOT speculate — only report findings you can point to in the code.
```

**Agent 3** (`Explore` — focus: clean-code)
```
Focus: clean-code
Files: {list of modified source files}
Context: {task_description}

Review these files for code quality using these criteria:

## SOLID Violations
| Principle | Violation Sign |
|-----------|----------------|
| Single Responsibility | Class/function does multiple things |
| Open/Closed | Adding features requires changing existing code |
| Liskov Substitution | Subclass breaks when used as parent |
| Interface Segregation | Implementing unused interface methods |
| Dependency Inversion | Direct instantiation of dependencies |

## Critical Code Smells (Must Flag)
| Smell | Detection |
|-------|-----------|
| Duplicated Code | Same logic in 2+ places |
| Large Function | >50 lines or multiple responsibilities |
| Long Parameter List | >3 parameters without object |
| Feature Envy | Method uses another class's data more than its own |
| God Object | One class/module controls everything |

## Medium Code Smells (Suggest Fix)
| Smell | Detection |
|-------|-----------|
| Deep Nesting | >3 levels of indentation |
| Magic Numbers | Unexplained literal values |
| Dead Code | Commented-out or unreachable code |
| Shotgun Surgery | Small change requires touching many files |

## Metrics Thresholds
| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| Cognitive complexity | <15/fn | 15-25 | >25 |
| Function size | <20 lines | 30-50 | >50 |
| Parameters | ≤3 | 4 | >5 |
| Nesting depth | ≤2 | 3 | >3 |
| Cyclomatic complexity | 1-4 | 5-7 | >10 |

## Pattern Consistency
- Follows existing codebase patterns and conventions
- Naming: verbs for functions, nouns for classes, descriptive and searchable
- No abbreviations (getTransaction not getTx)
- Comments explain WHY, not WHAT

## Findings Format
For each finding: [BLOCKING/CRITICAL/SUGGESTION] What + Why + How
Severity: CRITICAL (security/data loss) > HIGH (significant bug) > MEDIUM (should fix) > LOW (minor)
Do NOT speculate — only report findings you can point to in the code.
```

**Agent 4: Vercel/Next.js Best Practices** (CONDITIONAL)

→ **Detection:** Check if modified files match Next.js/Vercel patterns:
```
- *.tsx, *.jsx files in app/, pages/, components/
- next.config.* files
- Server actions (use server)
- API routes (app/api/*, pages/api/*)
- Middleware (middleware.ts)
- Server components, client components
```

→ **If Next.js/Vercel code detected:**

Launch additional review agent using Task tool (runs in parallel with other agents):
```yaml
Task:
  subagent_type: "general-purpose"
  description: "Vercel/Next.js best practices review"
  prompt: |
    Invoke the `vercel-react-best-practices` skill via the Skill tool,
    then review the following modified files against its guidelines:
    {list of modified files matching Next.js patterns}

    Report findings in format: [SEVERITY] What + Why + How
```

This agent reviews for:
- Async parallel patterns (Promise.all vs sequential awaits)
- Bundle optimization (barrel imports, dynamic imports)
- Server-side caching (React cache, unstable_cache)
- Re-render optimization (memo, useMemo, useCallback usage)
- Server vs Client component boundaries
- Data fetching patterns (preloading, parallel fetching)

→ **If NOT Next.js/Vercel code:** Skip this agent

### 4. Classify Findings

For each finding:

**Severity:**
- CRITICAL: Security vulnerability, data loss risk
- HIGH: Significant bug, will cause issues
- MEDIUM: Should fix, not urgent
- LOW: Minor improvement

**Validity:**
- Real: Definitely needs fixing
- Noise: Not actually a problem
- Uncertain: Needs discussion

### 5. Present Findings Table

```markdown
## Findings

| ID | Severity | Category | Location | Issue | Validity |
|----|----------|----------|----------|-------|----------|
| F1 | CRITICAL | Security | auth.ts:42 | SQL injection | Real |
| F2 | HIGH | Logic | handler.ts:78 | Missing null check | Real |
| F3 | MEDIUM | Quality | utils.ts:15 | Complex function | Uncertain |

**Summary:** {count} findings ({blocking} blocking)
```

### 6. Create Finding Todos

```
- [ ] F1 [CRITICAL] Fix SQL injection in auth.ts:42
- [ ] F2 [HIGH] Add null check in handler.ts:78
```

### 7. Get User Approval (review → resolve/test)

**If `{auto_mode}` = true:**
→ Proceed automatically based on findings

**If `{auto_mode}` = false:**

**If `{test_mode}` = true AND tests not yet completed:**
```yaml
questions:
  - header: "Review"
    question: "Review complete. What should the next step be?"
    options:
      - label: "Resolve findings (Recommended)"
        description: "Queue finding resolution for next session"
      - label: "Skip to tests"
        description: "Queue test creation instead"
      - label: "Skip resolution"
        description: "Accept findings as-is, no changes needed"
      - label: "Discuss findings"
        description: "I want to discuss specific findings"
    multiSelect: false
```

**If `{test_mode}` = false OR tests already completed:**
```yaml
questions:
  - header: "Review"
    question: "Review complete. What should the next step be?"
    options:
      - label: "Resolve findings (Recommended)"
        description: "Queue finding resolution for next session"
      - label: "Skip resolution"
        description: "Accept findings as-is, no changes needed"
      - label: "Discuss findings"
        description: "I want to discuss specific findings"
    multiSelect: false
```

<critical>
The user's choice determines which step is saved as next_step in the State Snapshot.
It does NOT mean "load that step now". The session boundary below controls when to stop.
</critical>

**Persist user choice (if save_mode):**

Append to `{output_dir}/00-context.md` under `### User Choices`:
```markdown
- **step-05 → next:** {chosen option} (e.g., "resolve", "skip-to-tests", "skip-resolution")
```

This ensures the next step knows which path was chosen after resume.

**Update progress for skipped resolution (if save_mode):**

```
IF user chose "Skip to tests" OR "Skip resolution":
  → 06-resolve will be skipped. Update its progress:
    ```bash
    bash {skill_dir}/scripts/update-progress.sh "{task_id}" "06" "resolve" "skip"
    ```
```

### 8. Complete Save Output (if save_mode)

**If `{save_mode}` = true:**

Append to `{output_dir}/05-examine.md`:
```markdown
---
## Step Complete
**Status:** ✓ Complete
**Findings:** {count}
**Critical:** {count}
**Next:** step-06-resolve.md
**Timestamp:** {ISO timestamp}
```

---

## SUCCESS METRICS:

✅ All modified files reviewed
✅ Security checklist completed
✅ Findings classified by severity
✅ Validity assessed for each finding
✅ Findings table presented
✅ Todos created for tracking
✅ Next.js/Vercel best practices checked (if applicable)

## FAILURE MODES:

❌ Skipping security review
❌ Not classifying by severity
❌ Auto-dismissing findings
❌ Launching agents sequentially
❌ Using subagents when economy_mode
❌ Skipping Vercel/Next.js review when React/Next.js files are modified
❌ **CRITICAL**: Not using AskUserQuestion for review → resolve/test transition

## REVIEW PROTOCOLS:

- Adversarial mindset - assume bugs exist
- Check security FIRST
- Every finding gets severity and validity
- Don't dismiss without justification
- Present clear summary

---

## NEXT STEP:

**Determine next step based on user choice/flags:**
- **"Resolve findings":** next = `06-resolve`
- **"Skip to tests" (and test_mode AND tests not yet completed):** next = `07-tests`
  - _Check: If save_mode, check progress table for `08-run-tests` status. If `✓ Complete`, tests already done → treat as "Skip resolution"._
- **"Skip resolution" + test_mode (AND tests not yet completed):** next = `07-tests`
  - _Same check as above._
- **"Skip resolution" + pr_mode (or tests already completed + pr_mode):** next = `09-finish`
- **"Skip resolution" (no more steps):** next_step = complete

### Session Boundary

<critical>
THIS SECTION IS MANDATORY. Even if the user chose a next step above, you MUST follow this session boundary logic.
The user's choice determines what is saved as next_step, NOT whether to load it now.
</critical>

```
IF auto_mode = true:
  → If save_mode = true, update progress and state:
    ```bash
    bash {skill_dir}/scripts/update-progress.sh "{task_id}" "05" "examine" "complete"
    bash {skill_dir}/scripts/update-state-snapshot.sh "{task_id}" "{next_step}" "**05-examine:** {count} findings ({count} blocking)" ["{gotcha if any}"]
    ```
  → If next_step = "complete": Display workflow complete message → STOP.
  → Otherwise: Load the determined next step directly (chain all steps)

IF auto_mode = false AND workflow not complete:
  → Determine {next_step_num} and {next_step_description} from the decision tree above
  → Run (if save_mode):
    ```bash
    bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "05" "examine" "Findings: {count} ({blocking} blocking)" "{next_step_num}" "{next_step_description}" "**05-examine:** {count} findings ({count} blocking)" ["{gotcha if any}"]
    ```
  → Display the output to the user
  → STOP. Do NOT load the next step.
  → The session ENDS here. User must run /apex -r {task_id} to continue.

IF auto_mode = false AND workflow complete:
  → Run (if save_mode):
    ```bash
    bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "05" "examine" "Review complete. No findings to resolve." "complete" "Workflow Complete" "**05-examine:** {count} findings, all dismissed"
    ```
  → Display the output to the user
  → STOP.
```

<critical>
Remember: Be SKEPTICAL - your job is to find problems, not approve code!
In auto_mode=true, proceed directly without stopping.
In auto_mode=false, ALWAYS STOP after displaying the resume command — even if the user chose "resolve findings".
</critical>
