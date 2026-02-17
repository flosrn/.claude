# Audit APEX Workflow - Complete Analysis

<context>
You are auditing the APEX workflow skill located at `skills/workflow-apex/`. This is a multi-step progressive-loading workflow system for Claude Code that orchestrates software implementation through phases: Analyze, Plan, Execute, eXamine.

The skill has 34 files organized as:
- `SKILL.md` (entry point, frontmatter, parameters, flow definition)
- `steps/` (17 step files - the main workflow logic interpreted by the LLM)
- `scripts/` (5 bash scripts - deterministic operations)
- `templates/` (11 template files + README - output file initialization)

**Architecture:** Steps are markdown files loaded one at a time by the LLM. Each step contains execution instructions, decision trees, and session boundary logic. Scripts handle deterministic state mutations (progress updates, state snapshots). Templates initialize output files with `{{variable}}` placeholders.
</context>

<objective>
Read EVERY file in `skills/workflow-apex/` and produce a comprehensive audit covering correctness, consistency, and completeness. Do NOT fix anything - only identify and report issues.
</objective>

<instructions>
## Phase 1: Read ALL Files

Read every file systematically. Use parallel reads where possible.

**Batch 1 - Entry point + Scripts:**
- `SKILL.md`
- `scripts/generate-task-id.sh`
- `scripts/setup-templates.sh`
- `scripts/update-progress.sh`
- `scripts/update-state-snapshot.sh`
- `scripts/session-boundary.sh`

**Batch 2 - Init steps:**
- `steps/step-00-init.md`
- `steps/step-00b-branch.md`
- `steps/step-00b-worktree.md`
- `steps/step-00b-interactive.md`
- `steps/step-00b-economy.md`

**Batch 3 - Core workflow steps:**
- `steps/step-01-analyze.md`
- `steps/step-01b-team-analyze.md`
- `steps/step-02-plan.md`
- `steps/step-03-execute.md`
- `steps/step-03b-team-execute.md`

**Batch 4 - Validation + Review steps:**
- `steps/step-04-validate.md`
- `steps/step-05-examine.md`
- `steps/step-05b-team-examine.md`
- `steps/step-06-resolve.md`

**Batch 5 - Test + Finish steps:**
- `steps/step-07-tests.md`
- `steps/step-08-run-tests.md`
- `steps/step-09-finish.md`

**Batch 6 - Templates:**
- `templates/00-context.md`
- `templates/README.md`
- All `templates/01-*.md` through `templates/09-*.md`

## Phase 2: Audit Checklist

For EACH category below, check every file and report findings.

### 2.1 Flow Integrity (CRITICAL)

Trace every possible execution path through the workflow:

```
Standard:    00 → 01 → 02 → 03 → 04 → [complete]
With tests:  00 → 01 → 02 → 03 → 04 → 07 → 08 → [complete]
With review: 00 → 01 → 02 → 03 → 04 → 05 → 06 → [complete]
Full:        00 → 01 → 02 → 03 → 04 → 07 → 08 → 05 → 06 → [complete]
With PR:     ... → 09 → [complete]
Team mode:   Uses 01b, 03b, 05b instead of 01, 03, 05
```

For each path, verify:
- [ ] Decision tree in each step correctly routes to the next step
- [ ] No circular flows (step A sends to B which sends back to A)
- [ ] `next_step` frontmatter matches actual decision tree logic
- [ ] Session boundary logic is consistent (auto_mode vs non-auto)
- [ ] "Workflow complete" paths are reachable and correct

### 2.2 State Management (CRITICAL)

Check all state variable handling:

- [ ] **Variable declarations**: All variables listed in SKILL.md `<state_variables>` are actually used
- [ ] **Resume restore**: `step-00-init.md` restore list includes ALL flags from Configuration table in `00-context.md` template
- [ ] **Variable propagation**: Each step's `<available_state>` table matches what's actually available from prior steps
- [ ] **State Snapshot updates**: `update-state-snapshot.sh` is called exactly ONCE per step (via `session-boundary.sh`), not duplicated
- [ ] **Progress table**: `update-progress.sh` marks steps in/complete in the right order (no premature marking of future steps)

### 2.3 Script Correctness (HIGH)

For each bash script:
- [ ] **Arguments match callers**: Count args in script vs what steps pass
- [ ] **Error handling**: `set -e`, input validation, edge cases
- [ ] **Awk/sed patterns**: Regex patterns match actual 00-context.md structure
- [ ] **File paths**: All paths constructed correctly (`$APEX_DIR`, `$CONTEXT_FILE`)
- [ ] **Idempotency**: Safe to run multiple times without corruption

### 2.4 Template Consistency (MEDIUM)

- [ ] **Variable coverage**: All `{{variables}}` in templates are replaced by `setup-templates.sh`
- [ ] **setup-templates.sh params**: Script positional args match step-00-init's call
- [ ] **Conditional creation**: Templates only created when corresponding flag is enabled
- [ ] **No orphan files**: Every template is referenced by a step or script
- [ ] **README accuracy**: `templates/README.md` documents all variables and scripts correctly

### 2.5 Agent Type Validity (HIGH)

Check every `subagent_type` reference across all step files:

Valid built-in types: `Explore`, `general-purpose`, `Bash`, `Plan`, `Snipper`, `websearch`, `intelligent-search`

- [ ] No references to non-existent agent types (e.g., "code-reviewer")
- [ ] Agent type matches the task (read-only tasks use `Explore`, write tasks use `general-purpose`)
- [ ] Custom agents referenced (like `explore-docs`) actually exist or are properly documented

### 2.6 Cross-File References (MEDIUM)

- [ ] **Step loading**: `next_step` in frontmatter matches what decision trees actually load
- [ ] **Script paths**: `{skill_dir}/scripts/X.sh` references match actual filenames
- [ ] **Template references**: Steps reference correct output filenames
- [ ] **Context restoration blocks**: Each step reads the right prior step files on resume

### 2.7 Flag Interactions (MEDIUM)

Test all flag combinations for conflicts:

| Combination | Expected Behavior |
|-------------|-------------------|
| `-w -e` | team_mode wins, economy disabled with warning |
| `-pr` | Implies `-b` (branch_mode) |
| `-wt` | Implies `-b` (branch_mode) |
| `-wt -pr` | Both work together |
| `auto_mode=false` | Auto-enables save_mode |
| `-w` without `-a` | Should work (team_mode no longer requires auto_mode) |

### 2.8 Session Boundary Consistency (HIGH)

For EACH step's NEXT STEP section:
- [ ] `session-boundary.sh` call has correct arg count (8 args: task_id, step_num, step_name, summary, next_step_num, next_step_desc, step_context_line, [gotcha])
- [ ] auto_mode=true path loads next step directly
- [ ] auto_mode=false path calls session-boundary.sh then STOPs
- [ ] "Workflow complete" path uses "complete" as next_step_num
- [ ] No step calls both `update-state-snapshot.sh` directly AND `session-boundary.sh` (which calls it internally)

### 2.9 Economy Mode Overrides (LOW)

- [ ] `step-00b-economy.md` overrides are consistent with what steps actually do
- [ ] Economy mode correctly prevents subagent spawning in all steps
- [ ] References to agent types are accurate

### 2.10 Documentation Accuracy (LOW)

- [ ] `SKILL.md` workflow order matches actual step decision trees
- [ ] `SKILL.md` flag descriptions match `step-00-init.md` parsing
- [ ] `SKILL.md` backtick formatting (no 4-backtick blocks)
- [ ] `templates/README.md` documents all template variables
- [ ] Comments in scripts match actual behavior

## Phase 3: Report Findings

Present findings in this exact format:

```markdown
# APEX Workflow Audit Report

## Summary
- Files analyzed: {count}/34
- Issues found: {count} ({critical} critical, {high} high, {medium} medium, {low} low)

## Issues

### CRITICAL

| # | Files | Issue | Details |
|---|-------|-------|---------|
| 1 | file.md:NN | Brief title | Full description with line references |

### HIGH

| # | Files | Issue | Details |
|---|-------|-------|---------|
| 1 | file.md:NN | Brief title | Full description with line references |

### MEDIUM

| # | Files | Issue | Details |
|---|-------|-------|---------|

### LOW

| # | Files | Issue | Details |
|---|-------|-------|---------|

## Flow Verification

### Path: Standard (00→01→02→03→04)
- Step 00 → 01: [OK/ISSUE]
- Step 01 → 02: [OK/ISSUE]
- ...

### Path: Full (00→01→02→03→04→07→08→05→06→09)
- ...

## Checklist Summary

| Category | Status | Issues |
|----------|--------|--------|
| Flow Integrity | [PASS/FAIL] | {count} |
| State Management | [PASS/FAIL] | {count} |
| Script Correctness | [PASS/FAIL] | {count} |
| Template Consistency | [PASS/FAIL] | {count} |
| Agent Type Validity | [PASS/FAIL] | {count} |
| Cross-File References | [PASS/FAIL] | {count} |
| Flag Interactions | [PASS/FAIL] | {count} |
| Session Boundary | [PASS/FAIL] | {count} |
| Economy Mode | [PASS/FAIL] | {count} |
| Documentation | [PASS/FAIL] | {count} |
```
</instructions>

<constraints>
- Read EVERY file - do NOT skip any. Use parallel reads to maximize speed.
- Report ONLY real issues with specific file:line references.
- Do NOT report style preferences or subjective opinions.
- Do NOT suggest fixes - this is an audit, not a fix session.
- Do NOT modify any files.
- Distinguish between bugs (will break at runtime) and inconsistencies (confusing but won't break).
- If a finding requires understanding cross-file interaction, explain the full chain.
- Use the `Task` tool with `Explore` agents if needed for parallel file reading, but you may also read files directly since there are only 34.
</constraints>

<success_criteria>
- All 34 files read and analyzed
- Every audit category checked
- Every execution path traced
- All findings have specific file:line references
- Clear severity classification (CRITICAL = will break, HIGH = significant bug, MEDIUM = should fix, LOW = minor)
- Report follows the exact format specified above
</success_criteria>
