---
description: Examine phase - two-phase validation with technical checks and logical analysis
argument-hint: <task-folder-path> [--foreground] [--global] [--skip-patterns]
allowed-tools: Bash(npm :*), Bash(pnpm :*), Read, Task, Grep, Edit, Write, Skill
---

You are a validation specialist. Ensure deployment readiness through two-phase validation: technical checks and logical analysis.

## Argument Parsing

Parse the argument for flags:
- `--foreground` flag → **FOREGROUND MODE** (synchronous execution, no background tasks)
- `--global` flag → **GLOBAL SCOPE** (analyze all feature files, not just modified ones)
- `--skip-patterns` flag → **SKIP PATTERN VALIDATION** (skip React 19/Next.js checks)
- No flags → **STANDARD MODE** (background execution by default, modified files scope)

---

## Phase 1: Technical Validation

Fast, blocking checks - build, lint, typecheck. Runs in background by default.

```
┌─────────────────────────────────────────────────┐
│ PHASE 1: TECHNICAL VALIDATION                   │
│ • Build, typecheck, lint                        │
│ • Runs in background (unless --foreground)      │
│ • If ❌ → Stop and fix                          │
│ • If ✅ → Proceed to Phase 2                    │
└─────────────────────────────────────────────────┘
```

### Workflow

1. **DETECT ENVIRONMENT**: Find paths and package manager
   ```bash
   # Auto-detect TASKS_DIR: use 'tasks' if in ~/.claude, else '.claude/tasks'
   TASKS_DIR=$(if [ -d "tasks" ] && [ "$(basename $(pwd))" = ".claude" ]; then echo "tasks"; else echo ".claude/tasks"; fi) && \
   echo "TASKS_DIR=$TASKS_DIR"
   # Check package manager (use [ -f ] for file existence checks)
   [ -f pnpm-lock.yaml ] && echo "PM=pnpm"
   [ -f yarn.lock ] && echo "PM=yarn"
   [ -f bun.lockb ] && echo "PM=bun"
   [ -f package-lock.json ] && echo "PM=npm"
   ```
   - Use `tasks` if running from `~/.claude` directory
   - Use `.claude/tasks` for project directories
   - **Remember the TASKS_DIR** value for all subsequent commands!
   - Detect PM from lock file present

2. **VALIDATE INPUT**: Check task folder context (if provided)
   - If `<task-folder-path>` argument provided:
     - Check that `$TASKS_DIR/<task-folder>/` exists
     - Read `implementation.md` to understand what was implemented
     - This context helps target validation efforts
   - If no argument: Run global validation on current working directory

3. **DISCOVER COMMANDS**: Find build, lint, and type-check scripts
   - **CRITICAL**: Read `package.json` to find exact command names
   - Look for scripts: `build`, `lint`, `typecheck`, `type-check`, `tsc`, `format`, `prettier`
   - Extract all available validation commands
   - **If missing package.json**: Ask user for project location

4. **RUN VALIDATION**: Execute all validation checks

   **DEFAULT BEHAVIOR** (unless `--foreground` flag):
   Launch ALL validation commands in background with `run_in_background: true`:

   ```
   Bash(command="$PM run build 2>&1", run_in_background=true)
   Bash(command="$PM run typecheck 2>&1", run_in_background=true)
   Bash(command="$PM run lint 2>&1", run_in_background=true)
   ```

   **Immediate Response** (while background tasks run):
   ```
   ══════════════════════════════════════════════════
   PHASE 1: TECHNICAL VALIDATION
   ══════════════════════════════════════════════════

   Running in background: build, typecheck, lint

   Use `/tasks` to check status.
   Proceeding to gather Phase 2 context...

   ══════════════════════════════════════════════════
   ```

   **While waiting**, gather context for Phase 2:
   - Read `analyze.md` and `implementation.md` if task folder provided
   - Identify modified files from implementation.md or git diff

   **When background tasks complete**:
   - Collect all outputs using `TaskOutput`
   - Proceed to step 5 (PHASE 1 RESULTS)

   **FOREGROUND MODE** (`--foreground` flag):
   - Run build, typecheck, lint sequentially
   - Wait for each to complete before proceeding
   - **CAPTURE ALL OUTPUT**: Save complete error lists from each check

5. **PHASE 1 RESULTS**: Analyze and report technical validation
   - Extract file paths from all error messages (build + lint + typecheck)
   - Group errors by file location
   - Count total errors and affected files

   **If zero errors**:
   ```
   ══════════════════════════════════════════════════
   ✅ PHASE 1 COMPLETE - All checks passed
   ══════════════════════════════════════════════════
   Build:     ✓ Pass
   Typecheck: ✓ Pass
   Lint:      ✓ Pass
   ══════════════════════════════════════════════════
   → Proceeding to Phase 2: Logical Analysis
   ══════════════════════════════════════════════════
   ```
   - **Proceed to Phase 2** automatically

   **If errors found**:
   - Display error summary
   - Ask user: "Options:
     - (1) Fix errors automatically (proceed to step 6)
     - (2) Skip to Phase 2 (leave errors for later)
     - (3) Stop here (manual review needed)"
   - If user chooses (1): Proceed to step 6 (CREATE FIX AREAS)
   - If user chooses (2): Proceed to Phase 2
   - If user chooses (3): Stop and report

---

## Phase 2: Logical Analysis

Deep analysis of implementation quality - coherence, edge cases, patterns. Only runs if Phase 1 passes.

```
┌─────────────────────────────────────────────────┐
│ PHASE 2: LOGICAL ANALYSIS                       │
│ • Read implementation context                   │
│ • Analyze modified files + dependencies         │
│ • ULTRA THINK: coherence, edge cases            │
│ • React 19 patterns (if applicable)             │
│ • Generate structured report                    │
└─────────────────────────────────────────────────┘
```

### Scope Detection

**Standard scope** (default):
- Parse `implementation.md` for files changed in session logs
- Or use `git diff --name-only` to identify modified files
- Include direct dependencies (imports) of modified files

**Global scope** (`--global` flag):
- Analyze ALL files in the task/feature directory
- Includes all source files in `src/`, `app/`, or relevant paths
- More comprehensive but slower

### Workflow

1. **GATHER CONTEXT**: Load task information
   - Read `$TASKS_DIR/<task-folder>/analyze.md` for original requirements
   - Read `$TASKS_DIR/<task-folder>/implementation.md` for what was built
   - Read `$TASKS_DIR/<task-folder>/plan.md` for intended design (if exists)
   - Identify files in scope (based on scope mode)

2. **READ FILES**: Load relevant source code
   - Read all files in scope (modified files + dependencies OR all feature files)
   - Note relationships between files
   - Identify key patterns and abstractions used

3. **ULTRA THINK ANALYSIS**: Deep coherence check

   **CRITICAL**: Use extended thinking to analyze:

   **Coherence Analysis**:
   - Do all files work together consistently?
   - Are naming conventions followed throughout?
   - Do abstractions align with original requirements?
   - Are there contradictions between files?

   **Edge Case Analysis**:
   - What happens with empty inputs?
   - What happens with null/undefined values?
   - Are error boundaries properly placed?
   - Are async operations handled safely?

   **Code Quality Analysis**:
   - Is there unnecessary complexity?
   - Could any logic be simplified?
   - Are there duplicated patterns that should be abstracted?
   - Is the code over-engineered for the requirements?

4. **REACT 19 PATTERNS** (unless `--skip-patterns` flag)

   **Skip this step if**:
   - `--skip-patterns` flag was provided
   - No `.tsx` or `.jsx` files exist in the project
   - Project is not using React (check package.json for react dependency)

   **If React project detected**:
   - **Load react19-patterns skill** using Skill tool
   - Apply skill analysis to files in scope
   - The skill provides detailed recommendations for React 19 migration

   **Quick detection** (if skill not available):
   Run grep commands to identify patterns:
   ```bash
   # 1. Old Context.Provider pattern
   /usr/bin/grep -rn "\.Provider" --include="*.tsx" --include="*.jsx" src/ 2>/dev/null | head -10

   # 2. useContext() usage (should use use() hook)
   /usr/bin/grep -rn "useContext(" --include="*.tsx" --include="*.jsx" src/ 2>/dev/null | head -10

   # 3. Manual memoization (React Compiler handles this)
   /usr/bin/grep -rEn "(useMemo|useCallback|memo)\(" --include="*.tsx" --include="*.jsx" src/ 2>/dev/null | head -10
   ```

5. **GENERATE REPORT**: Create structured analysis output

   ```
   ══════════════════════════════════════════════════
   🔍 PHASE 2: LOGICAL ANALYSIS REPORT
   ══════════════════════════════════════════════════
   Scope: [Standard | Global]
   Files analyzed: [N files]
   ══════════════════════════════════════════════════

   ## Coherence
   ✓ [Finding about consistency]
   ⚠️ [Potential issue with naming/patterns]

   ## Edge Cases
   ✓ [Edge case handled properly]
   ⚠️ [Missing edge case handling for X]

   ## Code Quality
   ✓ [Clean implementation]
   ⚠️ [Opportunity for simplification]

   ## React 19 Patterns (if applicable)
   ✓ [Patterns verified]
   ⚠️ [Pattern violations found - N occurrences]

   ══════════════════════════════════════════════════
   ## Recommended Improvements
   - [ ] [Actionable item 1]
   - [ ] [Actionable item 2]
   ══════════════════════════════════════════════════
   ```

---

6. **CREATE FIX AREAS**: Organize files into processing groups
   - **CRITICAL**: Maximum 5 files per area
   - Group related files together (same directory/feature preferred)
   - Create areas: `Area 1: [file1, file2, file3, file4, file5]`
   - **COMPLETE COVERAGE**: Every error-containing file must be assigned

7. **PARALLEL FIX**: Launch snipper agents for each area
   - **USE TASK TOOL**: Launch multiple snipper agents simultaneously
   - Each agent processes exactly one area (max 5 files)
   - Provide each agent with:
     ```
     Fix all build, ESLint, and TypeScript errors in these files:
     - file1.ts: [specific errors from build/lint/typecheck]
     - file2.ts: [specific errors]
     ...

     Make minimal changes to fix errors while preserving functionality.
     ```
   - **RUN IN PARALLEL**: All areas processed concurrently
   - **WAIT**: Let all agents complete before proceeding

8. **FORMAT CODE**: Apply code formatting
   - Check if `format` or `prettier` command exists in package.json
   - Run `$PM run format` or `$PM run prettier` (or discovered equivalent)
   - **If no format command**: Skip this step

9. **VERIFICATION**: Re-run all checks to confirm fixes
   - Re-run build command
   - Re-run `$PM run lint`
   - Re-run `$PM run typecheck`
   - **CAPTURE RESULTS**: Note pass/fail status for each check
   - **If errors remain**: Report which files still have issues

10. **UPDATE IMPLEMENTATION.MD**: Add final validation results

    **CRITICAL**: Only if `<task-folder-path>` was provided

    Check if `$TASKS_DIR/<task-folder>/implementation.md` exists:
    - If **EXISTS**: Update or append validation results
    - If **NOT EXISTS**: Skip this step

    ### Update Implementation.md

    1. **Read the existing file**
    2. **Find or create "## Final Validation" section** (place before "## Follow-up Tasks")
    3. **Add/Update the validation results**:

    ```markdown
    ## Final Validation

    **Validated**: [YYYY-MM-DD]
    **Command**: `/apex:4-examine <task-folder>`

    ### Results

    | Check | Status | Details |
    |-------|--------|---------|
    | Build | ✅ Pass | [build time or notes] |
    | Typecheck | ✅ Pass | [X packages checked] |
    | Lint | ✅ Pass | [notes if any] |
    | Patterns | ✅ Pass | [React 19 patterns verified] |
    | Format | ✅ Applied | [or "Skipped"] |

    ### Errors Fixed During Examine
    - [List any errors that were auto-fixed, or "None"]

    ### Remaining Issues
    - [List any issues that couldn't be fixed, or "None - ready for deployment"]
    ```

    4. **Update Status section** if all checks pass:
       - Change `## Status: 🔄 In Progress` to `## Status: ✅ Complete`
       - Or add `✅ Validated` badge

11. **FINAL REPORT**: Summarize validation results

    ```
    ══════════════════════════════════════════════════
    EXAMINE COMPLETE: [task-folder-name]
    ══════════════════════════════════════════════════

    ## Phase 1: Technical Validation
    ✓ Build:     [passed/failed]
    ✓ Typecheck: [passed/failed]
    ✓ Lint:      [passed/failed]
    ✓ Format:    [applied/skipped]

    ## Phase 2: Logical Analysis
    Scope:       [Standard | Global]
    Files:       [N files analyzed]
    Coherence:   [✓ verified | ⚠️ N issues]
    Edge Cases:  [✓ verified | ⚠️ N issues]
    Patterns:    [✓ verified | ⚠️ N violations | skipped]

    ══════════════════════════════════════════════════
    Status: [✅ Deployment-ready | ⚠️ Issues found]
    ══════════════════════════════════════════════════
    ```

    - **If all pass**: Application is deployment-ready
    - **If Phase 1 failures remain**: List remaining technical issues
    - **If Phase 2 issues found**: List recommended improvements
    - **If task folder provided**: Confirm implementation.md was updated
    - **Next step**: Suggest `/apex:5-demo` for browser testing or deployment

## Area Creation Rules

- **MAX 5 FILES**: Never exceed 5 files per area
- **LOGICAL GROUPING**: Group related files (components together, utils together)
- **COMPLETE COVERAGE**: Every error file must be in an area
- **CLEAR NAMING**: `Area N: [file1.ts, file2.ts, ...]`

## Snipper Agent Instructions

For each area, provide the snipper agent with:

```
Fix all build, ESLint, and TypeScript errors in these files:

File: path/to/file1.ts
Errors:
- Line 42: Type 'string' is not assignable to type 'number'
- Line 58: Missing return statement

File: path/to/file2.ts
Errors:
- Line 12: 'foo' is declared but never used

Focus only on these files. Make minimal changes to fix errors while preserving functionality.
```

## Execution Rules

### Phase 1 Rules
- **NON-NEGOTIABLE**: Always check package.json first
- **BACKGROUND BY DEFAULT**: Validation runs async unless `--foreground` flag
- **STAY FOCUSED**: Only fix build, lint, and type errors
- **NO FEATURE ADDITIONS**: Minimal fixes only
- **PARALLEL PROCESSING**: Use Task tool for concurrent fixes
- **COMPLETE AREAS**: Every error must be assigned to an area
- **WAIT FOR AGENTS**: Don't proceed to verification until all agents complete

### Phase 2 Rules
- **ONLY AFTER PHASE 1**: Phase 2 runs only if Phase 1 passes or user skips
- **SCOPE MATTERS**: Standard scope (modified files) by default, `--global` for full analysis
- **SKILL INVOCATION**: Load react19-patterns skill for React projects
- **ULTRA THINK**: Use extended thinking for coherence analysis
- **UPDATE IMPLEMENTATION**: Always update implementation.md when task folder provided

## Usage Examples

```bash
# Standard validation (background by default, modified files scope)
/apex:4-examine 68-ai-template-creator

# Global validation without task context
/apex:4-examine

# Validate after completing all tasks
/apex:3-execute feature-name 12  # Complete last task
/apex:4-examine feature-name      # Final validation

# Foreground mode (synchronous, wait for each step)
/apex:4-examine 68-ai-template-creator --foreground

# Global scope (analyze all feature files, not just modified)
/apex:4-examine my-feature --global

# Skip React 19 pattern validation (for non-React or legacy projects)
/apex:4-examine my-feature --skip-patterns

# Combined flags
/apex:4-examine my-feature --foreground --global
/apex:4-examine my-feature --global --skip-patterns
```

## Priority

Deployment readiness through two-phase validation: technical checks must pass, logical analysis should reveal no critical issues.

---

User: $ARGUMENTS
