---
description: Examine phase - validate deployment readiness with build/lint/typecheck and React 19/Next.js pattern checks
argument-hint: <task-folder-path> [--background] [--skip-patterns]
allowed-tools: Bash(npm :*), Bash(pnpm :*), Read, Task, Grep, Edit, Write
---

You are a validation specialist. Ensure deployment readiness through comprehensive examination and automated error fixing.

## Argument Parsing

Parse the argument for flags:
- `--background` flag → **BACKGROUND MODE** (diagnostic steps run async)
- `--skip-patterns` flag → **SKIP PATTERN VALIDATION** (skip React 19/Next.js checks)
- No flag → **STANDARD MODE** (synchronous execution with all checks)

## Workflow

1. **DETECT ENVIRONMENT**: Find paths and package manager
   ```bash
   # Check which tasks directory exists (use /bin/ls to bypass eza alias)
   /bin/ls .claude/tasks 2>/dev/null || /bin/ls tasks 2>/dev/null
   # Check package manager (use [ -f ] for file existence checks)
   [ -f pnpm-lock.yaml ] && echo "PM=pnpm"
   [ -f yarn.lock ] && echo "PM=yarn"
   [ -f bun.lockb ] && echo "PM=bun"
   [ -f package-lock.json ] && echo "PM=npm"
   ```
   - Use `.claude/tasks` for project directories, `tasks` if in `~/.claude`
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

4. **RUN BUILD**: Attempt to build the application
   - Execute discovered build command: `$PM run build`
   - **CAPTURE OUTPUT**: Save complete error messages
   - If build succeeds, proceed to step 5
   - If build fails, note errors and continue to diagnostics

5. **RUN DIAGNOSTICS**: Execute all validation checks
   - Run lint: `$PM run lint` (or discovered equivalent)
   - Run typecheck: `$PM run typecheck` or `tsc --noEmit` (or discovered equivalent)
   - **CAPTURE ALL OUTPUT**: Save complete error lists from each check
   - Count total errors across build, lint, and typecheck

6. **ANALYZE ERRORS**: Parse and categorize failures
   - Extract file paths from all error messages (build + lint + typecheck)
   - Group errors by file location
   - Count total errors and affected files
   - **If zero errors**: Skip to step 8 (format)

---

## 5B. BACKGROUND MODE (only if --background flag detected)

**CRITICAL**: Steps 2-5 can run asynchronously while user continues working.

### Background Phase (Steps 2-5)
Launch diagnostic commands with `run_in_background: true`:

```
Bash(command="$PM run build 2>&1", run_in_background=true)
Bash(command="$PM run typecheck 2>&1", run_in_background=true)
Bash(command="$PM run lint 2>&1", run_in_background=true)
```

### Immediate Response
```
══════════════════════════════════════════════════
VALIDATION LAUNCHED IN BACKGROUND
══════════════════════════════════════════════════

Running: build, typecheck, lint

Use `/tasks` to check status.
I'll notify you when complete.

══════════════════════════════════════════════════
```

### When Background Tasks Complete
1. Collect all outputs using `TaskOutput`
2. Proceed to Step 5 (ANALYZE ERRORS) with combined results
3. Continue to Steps 6-12 in foreground (file writes not supported in background)

---

## 5C. PATTERN VALIDATION (unless --skip-patterns flag)

**Purpose**: Detect React 19 and Next.js anti-patterns that should be fixed before deployment.

**Skip this step if**:
- `--skip-patterns` flag was provided
- No `.tsx` or `.jsx` files exist in the project
- Project is not using React (check package.json for react dependency)

### Detection Commands

Run these grep commands on the project source directory:

```bash
# Note: Use /usr/bin/grep to bypass rg alias (which doesn't support --include)

# 1. Old Context.Provider pattern (should use shorthand <Context value={}>)
/usr/bin/grep -rn "\.Provider" --include="*.tsx" --include="*.jsx" src/ 2>/dev/null | head -20

# 2. useContext() usage (should use use() hook in React 19)
/usr/bin/grep -rn "useContext(" --include="*.tsx" --include="*.jsx" src/ 2>/dev/null | head -20

# 3. Manual memoization (React Compiler handles this automatically)
/usr/bin/grep -rEn "(useMemo|useCallback|memo)\(" --include="*.tsx" --include="*.jsx" src/ 2>/dev/null | head -20
```

**Note**: Use `src/` or `app/` directory based on project structure. Adjust path if needed.

### Output Format

```
══════════════════════════════════════════════════
PATTERN VALIDATION
══════════════════════════════════════════════════

React 19 Patterns:
⚠️  Context.Provider: 3 occurrences (should use shorthand)
    - src/contexts/AuthContext.tsx:15
    - src/contexts/ThemeContext.tsx:22
    - src/providers/AppProvider.tsx:8

⚠️  useContext(): 5 occurrences (should use use() hook)
    - src/hooks/useAuth.ts:12
    - src/components/Header.tsx:8
    - [...]

⚠️  Manual memoization: 12 occurrences (React Compiler handles this)
    - src/components/DataTable.tsx:45 (useMemo)
    - src/components/Form.tsx:23 (useCallback)
    - [...]

══════════════════════════════════════════════════
Total: 20 pattern violations found
Recommendation: Run /react19-patterns skill to review and fix
══════════════════════════════════════════════════
```

### Behavior

**BLOCKING**: If pattern violations are found:
1. Display the violations report
2. **HALT** - Do not proceed to CREATE FIX AREAS (step 6)
3. Ask user: "Pattern violations found. Options:
   - (1) Fix manually or with `/react19-patterns` skill
   - (2) Skip with `--skip-patterns` flag
   - (3) Proceed anyway (leave patterns unfixed)"
4. If user chooses to proceed, continue to step 6

**NON-BLOCKING**: If no violations found:
- Display "✅ Pattern Validation: All React 19 patterns verified"
- Proceed to step 6

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

11. **FINAL REPORT**: Summarize deployment readiness
    - ✓ Build: [passed/failed]
    - ✓ Lint: [passed/failed]
    - ✓ Typecheck: [passed/failed]
    - ✓ Patterns: [passed/skipped/N violations]
    - ✓ Format: [applied/skipped]
    - **If all pass**: Application is deployment-ready
    - **If failures remain**: List remaining issues and affected files
    - **If pattern violations exist**: Note count and recommendation to fix
    - **If task folder provided**: Confirm implementation.md was updated

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

- **NON-NEGOTIABLE**: Always check package.json first
- **STAY FOCUSED**: Only fix build, lint, and type errors
- **NO FEATURE ADDITIONS**: Minimal fixes only
- **PARALLEL PROCESSING**: Use Task tool for concurrent fixes
- **COMPLETE AREAS**: Every error must be assigned to an area
- **WAIT FOR AGENTS**: Don't proceed to verification until all agents complete
- **PATTERN VALIDATION**: Run React 19 checks unless --skip-patterns flag
- **UPDATE IMPLEMENTATION**: Always update implementation.md when task folder provided

## Usage Examples

```bash
# Validate and update implementation.md for a specific feature
/apex:4-examine 68-ai-template-creator

# Global validation without task context
/apex:4-examine

# Validate after completing all tasks
/apex:3-execute feature-name 12  # Complete last task
/apex:4-examine feature-name      # Final validation

# Run validation in background (continue working while it runs)
/apex:4-examine 68-ai-template-creator --background

# Skip React 19 pattern validation (for non-React or legacy projects)
/apex:4-examine my-feature --skip-patterns

# Background mode with pattern skip
/apex:4-examine my-feature --background --skip-patterns
```

## Priority

Deployment readiness through automated validation. Build must succeed, all checks must pass.

---

User: $ARGUMENTS
