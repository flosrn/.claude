---
name: step-00-init
description: Initialize APEX workflow - parse flags, detect continuation, setup state
next_step: ./step-01-analyze.md
---

# Step 0: Initialization

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER skip flag parsing
- 🛑 ONLY check for existing workflow if resume_task is set
- ✅ ALWAYS parse ALL flags before any other action
- ✅ ONLY check for resume if {resume_task} is set
- 📋 YOU ARE AN INITIALIZER, not an executor
- 💬 FOCUS on setup only - don't look ahead to implementation
- 🚫 FORBIDDEN to load step-01 until init is complete

## EXECUTION PROTOCOLS:

- 🎯 Parse flags first, then check resume, then setup
- 💾 Create output structure if save_mode enabled
- 📖 Initialize all state variables before proceeding
- 🚫 FORBIDDEN to start analysis (that's step-01's job)
- ✅ ALWAYS show COMPACT summary (one table) and proceed immediately
- 🚫 FORBIDDEN to show verbose parsing logs or explanations

## CONTEXT BOUNDARIES:

- This is the FIRST step - no previous context exists
- User input contains flags and task description
- Output folder may or may not exist
- Don't assume anything about the codebase yet

## YOUR TASK:

Initialize the APEX workflow by parsing flags, detecting continuation state, and setting up the execution environment.

---

<defaults>
## Default Configuration

**Edit these values to change default behavior. Flags always override defaults.**

```yaml
# ===========================================
# APEX DEFAULT SETTINGS
# ===========================================

auto_mode: false # -a: Skip confirmations, use recommended options
examine_mode: false # -x: Auto-proceed to adversarial review
save_mode: false # -s: Save outputs to .claude/output/apex/
test_mode: false # -t: Include test creation and runner steps
economy_mode: false # -e: No subagents, save tokens (for limited plans)
team_mode: false # -w: Use Agent Teams for parallel execution (incompatible with -e)
branch_mode: false # -b: Verify not on main, create branch if needed
pr_mode: false # -pr: Create pull request at end (enables -b)
interactive_mode: false # -i: Configure flags interactively

# Presets:
# Budget-friendly:  economy_mode: true
# Full quality:     examine_mode: true, save_mode: true, test_mode: true
# Autonomous:       auto_mode: true, examine_mode: true, save_mode: true, test_mode: true
```

**Flag Reference:** See `SKILL.md` for complete flag documentation and examples.

</defaults>

---

## EXECUTION SEQUENCE:

### 1. Parse Flags and Input

**Step 1a: Load defaults from config above**

```
{auto_mode}    = <default>
{examine_mode} = <default>
{save_mode}    = <default>
{test_mode}    = <default>
{economy_mode} = <default>
{team_mode}    = <default>
{branch_mode}  = <default>
{pr_mode}      = <default>
{interactive_mode} = <default>
```

**Step 1b: Parse user input and override defaults:**

```
Enable flags (lowercase - turn ON):
  -a or --auto     → {auto_mode} = true
  -x or --examine  → {examine_mode} = true
  -s or --save     → {save_mode} = true
  -t or --test     → {test_mode} = true
  -e or --economy  → {economy_mode} = true
  -w or --team     → {team_mode} = true

Disable flags (UPPERCASE - turn OFF):
  -A or --no-auto         → {auto_mode} = false
  -X or --no-examine      → {examine_mode} = false
  -S or --no-save         → {save_mode} = false
  -T or --no-test         → {test_mode} = false
  -E or --no-economy      → {economy_mode} = false
  -W or --no-team         → {team_mode} = false
  -B or --no-branch       → {branch_mode} = false
  -PR or --no-pull-request → {pr_mode} = false
  -I or --no-interactive  → {interactive_mode} = false

Branch/PR flags:
  -b or --branch        → {branch_mode} = true
  -pr or --pull-request → {pr_mode} = true, {branch_mode} = true

Interactive:
  -i or --interactive   → {interactive_mode} = true

Other:
  -r or --resume   → {resume_task} = <next argument>
  Remainder        → {task_description}
```

**Step 1c: Auto-enable save_mode for step-by-step mode:**

```
IF {auto_mode} = false AND {save_mode} = false:
    {save_mode} = true
    (Required for resume between sessions)
```

**Step 1d: Team mode validation:**

```
IF {team_mode} = true AND {economy_mode} = true:
    → WARNING: "Team mode (-w) is incompatible with economy mode (-e). Disabling economy mode."
    → {economy_mode} = false
```

**Step 1e: Detect reference files in input:**

```
Scan {task_description} for file path tokens:

1. A token is a file path if:
   - It contains at least one '/' character
   - AND ends with a known extension (.md, .txt, .json, .yaml, .yml)

2. For each detected file path token:
   - Verify the file exists (relative to project root)
   - If exists: set {reference_files} = that path, remove token from {task_description}
   - If doesn't exist: leave in {task_description} (might be intentional text)

3. If {task_description} is now empty (user only passed a file path):
   → Read the file's first heading (# Title) to derive a description
   → OR extract from filename: "ai-wheel-personalization-2026-02-17-analysis.md"
     → strip date and extension → "ai wheel personalization"
   → Set {task_description} = derived description

4. If no file paths detected: {reference_files} = "" (empty, normal mode)

Examples:
  Input: ".claude/output/brainstorm/auth-analysis.md"
  → {reference_files} = ".claude/output/brainstorm/auth-analysis.md"
  → {task_description} = (derived from file)

  Input: "add auth middleware .claude/output/brainstorm/auth.md"
  → {reference_files} = ".claude/output/brainstorm/auth.md"
  → {task_description} = "add auth middleware"

  Input: "add auth middleware"
  → {reference_files} = ""
  → {task_description} = "add auth middleware"
```

**Step 1f: Generate feature_name and task_id:**

```
{feature_name} = kebab-case-description (without number prefix)

Example: "add user authentication" → "add-user-authentication"
```

**Generate `{task_id}` NOW** (needed before branch setup):

```bash
bash {skill_dir}/scripts/generate-task-id.sh "{feature_name}"
```

→ Capture output as `{task_id}` (e.g., `01-add-user-authentication`)

<critical>
`{task_id}` MUST be generated here, before section 4 (branch setup needs it).
</critical>

### 2. Check Resume Mode

<critical>
ONLY execute this section if {resume_task} is set!
If {resume_task} is NOT set, skip directly to step 3.
</critical>

**If `{resume_task}` is set:**

**Step 2a: Find matching task folder:**

```bash
ls .claude/output/apex/ | grep "{resume_task}"
```

- **Exact match** (e.g., `01-add-auth`): use it
- **Single partial match** (e.g., `-r 01` matches `01-add-auth`): use it
- **Multiple matches**: list them and ask user to specify
- **No match**: list available tasks, ask user to provide correct ID

**Step 2b: Restore state from `00-context.md`:**

1. Read `{output_dir}/00-context.md`
2. Restore ALL flags from Configuration table: `{auto_mode}`, `{examine_mode}`, `{save_mode}`, `{test_mode}`, `{economy_mode}`, `{team_mode}`, `{branch_mode}`, `{pr_mode}`, `{interactive_mode}`
3. Restore task info: `{task_id}`, `{task_description}`, `{feature_name}`, `{branch_name}`
4. Restore `{reference_files}` from Reference Documents section (if any file paths listed)
5. Restore acceptance criteria from State Snapshot section

**Step 2c: Apply flag overrides from current command:**

Any flags passed with the resume command override the stored values.
Example: `/apex -a -r 01` resumes task 01 with `{auto_mode} = true` even if it was stored as `false`.

**Step 2c-post: Re-run validations after flag overrides:**

```
After restoring flags from 00-context.md and applying any CLI flag overrides:
→ Re-run Step 1c (save_mode auto-enable) and Step 1d (team mode checks) validations
  to ensure restored+overridden flags are consistent.
```

**Step 2d: Re-evaluate Skip/Pending after flag overrides:**

```
IF a flag was changed from false → true on resume:
    Update Progress table entries for affected steps:
    - {examine_mode} true → 05-examine, 06-resolve: ⏭ Skip → ⏸ Pending
    - {test_mode} true → 07-tests, 08-run-tests: ⏭ Skip → ⏸ Pending
    - {pr_mode} true → 09-finish: ⏭ Skip → ⏸ Pending

IF a flag was changed from true → false on resume:
    Update Progress table entries for affected steps:
    - {examine_mode} false → 05-examine, 06-resolve: ⏸ Pending → ⏭ Skip
    - {test_mode} false → 07-tests, 08-run-tests: ⏸ Pending → ⏭ Skip
    - {pr_mode} false → 09-finish: ⏸ Pending → ⏭ Skip
```

**Step 2d-post2: Create missing template files for newly-enabled flags:**

```
IF {save_mode} = true AND any flag was changed from false → true on resume:
    Check if corresponding output files exist in {output_dir}:
    - IF {examine_mode} newly enabled → check 05-examine.md, 06-resolve.md
    - IF {test_mode} newly enabled → check 07-tests.md, 08-run-tests.md
    - IF {pr_mode} newly enabled → check 09-finish.md

    For any MISSING file, create it by rendering from template:
    ```bash
    # Example for missing 07-tests.md:
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    sed -e "s|{{task_id}}|{task_id}|g" \
        -e "s|{{task_description}}|{task_description}|g" \
        -e "s|{{timestamp}}|$TIMESTAMP|g" \
        "{skill_dir}/templates/{NN-step}.md" > "{output_dir}/{NN-step}.md"
    ```
```

**Step 2e: Run branch sub-step if newly enabled on resume:**

```
IF {branch_mode} = true AND {branch_name} is empty (not restored from 00-context.md):
    → Branch mode was newly enabled on this resume
    → Must run the sub-step to set {branch_name}
    → Load steps/step-00b-branch.md (inline, not as separate step)
    → Verifies/creates branch, sets {branch_name}
    → Update 00-context.md Configuration table with new {branch_name}
```

**Step 2f: Determine resume target step:**

1. Read `next_step` from State Snapshot section
2. **If `next_step` is `complete`:** Check the Progress table for any `⏸ Pending` rows (flag overrides in step 2d may have added new steps). If Pending rows exist, override `next_step` to the first Pending step number (e.g., `05-examine`). Otherwise, workflow is already finished — inform user: "✓ Workflow {task_id} is already complete. Nothing to resume." → STOP.
3. **If `next_step` points to a `✓ Complete` step:** The State Snapshot is stale (auto_mode session crashed after completing the step but before updating the snapshot). Fall back to the Progress table: find the first row that is NOT `✓ Complete` and NOT `⏭ Skip`.
4. **Fallback** (if `next_step` missing): parse Progress table for first row that is NOT `✓ Complete` and NOT `⏭ Skip`
5. **Handle "⏳ In Progress"**: this means a step crashed mid-execution → restart that step

**Step 2g: Show resume summary and load target step:**

```
✓ APEX RESUMED: {task_description}

| Variable | Value |
|----------|-------|
| `{task_id}` | {task_id} |
| Resuming at | step-{next_step} |
| `{auto_mode}` | true/false |
| `{save_mode}` | true/false |
| Flags overridden | {list any changed flags, or "none"} |

→ Loading step-{next_step}...
```

**Then load the target step directly. Do NOT continue with fresh init steps 3-5.**

**If {resume_task} is NOT set:** → Skip directly to step 3

### 3. Pre-flight Checks

**Run these lightweight checks before proceeding:**

```bash
# Check task description is not empty
if [[ -z "{task_description}" ]]; then
  echo "Error: No task description provided"
  exit 1
fi

# Warn about uncommitted changes (don't block)
if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
  echo "⚠ Warning: Uncommitted changes detected"
fi

# Check not on detached HEAD
if ! git symbolic-ref HEAD &>/dev/null; then
  echo "⚠ Warning: Detached HEAD state"
fi
```

**These are warnings, not blockers** — APEX will proceed regardless. The user can decide whether to address them.

### 4. Run Optional Sub-Steps

**Load sub-steps in order (if flags enabled):**

```
IF {interactive_mode} = true:
  → Load steps/step-00b-interactive.md
  → User configures flags interactively
  → Return here with updated flags

IF {branch_mode} = true:
  → Load steps/step-00b-branch.md
  → Verify/create branch
  → Return here with {branch_name} set

IF {economy_mode} = true:
  → Load steps/step-00b-economy.md
  → Apply economy overrides
```

### 5. Create Output Structure (if save_mode)

**If `{save_mode}` = true:**

Run the template setup script to initialize all output files:

```bash
bash {skill_dir}/scripts/setup-templates.sh \
  "{task_id}" \
  "{task_description}" \
  "{auto_mode}" \
  "{examine_mode}" \
  "{save_mode}" \
  "{test_mode}" \
  "{economy_mode}" \
  "{branch_mode}" \
  "{pr_mode}" \
  "{interactive_mode}" \
  "{branch_name}" \
  "{original_input}" \
  "{team_mode}" \
  "{reference_files}"
```

**Note:** Pass the full `{task_id}` (with number prefix, e.g., `01-add-auth`).
The task_id was already generated in step 1f.

This script:

- Uses the provided `{task_id}` (or auto-generates if only feature name given)
- Creates `.claude/output/apex/{task_id}/` directory
- Initializes `00-context.md` with configuration and progress table
- Pre-creates all step files from templates (01-analyze.md, 02-plan.md, etc.)
- Only creates files for enabled steps (examine, tests, PR)
- Outputs the generated `{task_id}` for use in subsequent steps

### 6. Mark Init Complete and Proceed

**If `{save_mode}` = true:**

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "00" "init" "complete"
```

**Always (regardless of auto_mode):**

Show COMPACT initialization summary (one table, then proceed immediately):

```
✓ APEX: {task_description}

| Variable | Value |
|----------|-------|
| `{task_id}` | 01-kebab-name |
| `{auto_mode}` | true/false |
| `{examine_mode}` | true/false |
| `{save_mode}` | true/false |
| `{test_mode}` | true/false |
| `{economy_mode}` | true/false |
| `{team_mode}` | true/false |
| `{branch_mode}` | true/false |
| `{pr_mode}` | true/false |
| `{reference_files}` | path or empty |

→ Analyzing...
```

<critical>
KEEP OUTPUT MINIMAL:
- One line header with task
- One table with ALL variables (use brackets to show they're available)
- One line "→ Analyzing..." then IMMEDIATELY load step-01
- NO verbose explanations, NO parsing logs, NO separators
</critical>

**Then proceed directly to step-01-analyze.md**

---

## SUCCESS METRICS:

✅ All flags correctly parsed (enable AND disable)
✅ Output is COMPACT (one table, no verbose logs)
✅ Variables shown with `{brackets}` notation
✅ Proceeded to step-01 immediately after table
✅ Output folder created with 00-context.md (if save_mode)

## FAILURE MODES:

❌ Verbose output with separators and explanations
❌ Showing parsing steps/logs to user
❌ Not using `{variable}` bracket notation
❌ Not proceeding immediately after summary
❌ **CRITICAL**: Blocking workflow with unnecessary confirmations

## INITIALIZATION PROTOCOLS:

- Parse ALL flags before any other action
- Check resume BEFORE creating new output folder
- Verify branch BEFORE creating output structure (if branch_mode)
- Create output structure BEFORE confirming start
- Load economy overrides BEFORE proceeding to step-01

---

## NEXT STEP:

After showing initialization summary, always proceed directly to `./step-01-analyze.md`

**Note:** Step-00-init and step-01-analyze always run together in the same session. The first session boundary (stop point when `auto_mode=false`) is at the END of step-01-analyze. See step-01 for session boundary details.

<critical>
Remember:
- Step-00 is an INITIALIZER, not a GATEKEEPER
- Output MUST be compact: one table, no verbose logs
- Use `{variable}` notation to show available state
- Proceed immediately to step-01 - never block!
</critical>
