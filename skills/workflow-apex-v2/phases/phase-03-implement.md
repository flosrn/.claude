---
name: phase-03-implement
description: Execute plan and validate - implement file by file, then typecheck/lint/test
prev_phase: ./phase-02-plan.md
next_phase: conditional (04-review | 05-test | 06-ship | complete)
---

# Phase 03: Implement

Execute approved plan and validate implementation in a single phase.

**Role:** Implementer following an approved plan

---

## Part A: Execute

1. **Mark phase in progress**
   - Update progress table in `{output_dir}/00-context.md`
   - Set phase 03 status to "In Progress"

2. **Git checkpoint**
   ```bash
   git add -u && git commit -m "apex: checkpoint before implement ({task_id})" || true
   ```

3. **Create implementation todos**
   - Read `{output_dir}/02-plan.md`
   - Extract file-by-file changes from "Files to Modify" section
   - Create todo list in memory

4. **Execute implementation**

   **If team_mode:**
   - Use Agent Teams with domain-based partitioning
     - TeamCreate with team_name = `apex-{task_id}-impl`
     - TaskCreate for each domain (backend, frontend, database, etc.)
     - Spawn teammates with `model: "sonnet"` and `mode: "plan"`
     - Coordinate: read submitted plans, approve/challenge findings, handle escalations
     - Verify no file conflicts before execution (check git status together)
     - Shutdown teammates after all tasks complete: `SendMessage` with `type: "shutdown_request"`
     - TeamDelete after all teammates shut down

   **Else (solo mode):**
   - Standard todo-driven implementation
   - For each file in plan:
     - Read existing file
     - Apply changes according to plan
     - Verify syntax (no parsing errors)
     - Commit per-file: `git add -u && git commit -m "apex({task_id}): implement {filename}" || true`

5. **Log progress (save-every-2 rule)**
   - After every 2 file modifications, append progress to `{output_dir}/03-implement.md`
   - Track: files modified, lines changed, issues encountered, workarounds applied
   - Do NOT wait until the end to log — compaction can happen mid-implementation

---

## Part B: Validate (integrated, no session break)

6. **Detect project toolchain**

   ```bash
   # Detect package manager
   if [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then PM="bun"
   elif [ -f "pnpm-lock.yaml" ]; then PM="pnpm"
   elif [ -f "yarn.lock" ]; then PM="yarn"
   elif [ -f "package.json" ]; then PM="npm"
   fi

   # Detect available scripts (Node.js projects)
   if [ -f "package.json" ]; then
     HAS_TYPECHECK=$(node -e "const p=require('./package.json'); process.exit(p.scripts?.typecheck ? 0 : 1)" 2>/dev/null && echo "true" || echo "false")
     HAS_LINT=$(node -e "const p=require('./package.json'); process.exit(p.scripts?.lint ? 0 : 1)" 2>/dev/null && echo "true" || echo "false")
     HAS_TEST=$(node -e "const p=require('./package.json'); process.exit(p.scripts?.test ? 0 : 1)" 2>/dev/null && echo "true" || echo "false")
     HAS_FORMAT=$(node -e "const p=require('./package.json'); process.exit(p.scripts?.format ? 0 : 1)" 2>/dev/null && echo "true" || echo "false")
   fi
   ```

   **Non-Node.js project detection:**
   | Marker | Stack | Typecheck | Lint | Test | Format |
   |--------|-------|-----------|------|------|--------|
   | `pyproject.toml` / `requirements.txt` | Python | `mypy .` | `ruff check .` | `pytest` | `ruff format --check .` |
   | `go.mod` | Go | `go vet ./...` | `golangci-lint run` | `go test ./...` | `gofmt -l .` |
   | `Cargo.toml` | Rust | `cargo check` | `cargo clippy` | `cargo test` | `cargo fmt --check` |
   | `composer.json` | PHP | — | `composer lint` | `composer test` | — |
   | `Makefile` | Generic | — | `make lint` | `make test` | — |

7. **Run validation suite (MUST ALL PASS)**

   **IF worktree_mode = true:** Ensure CWD is the worktree before running validation:
   ```bash
   cd {worktree_path}  # Critical: validation must run from worktree, not main repo
   ```

   **IF monorepo (turbo.json exists):** Use `--filter` for validation:
   ```bash
   pnpm turbo typecheck --filter={main_app}...
   pnpm turbo lint --filter={main_app}...
   pnpm turbo test --filter={main_app}...
   ```

   **ELSE (single app):**
   - Typecheck: `{PM} run typecheck` (or stack equivalent)
   - Lint: `{PM} run lint --fix` (or stack equivalent)
   - Tests: `{PM} run test` (or stack equivalent)
   - Format: `{PM} run format` (if available)

   Fix any failures immediately and re-run until green

### Pre-existing Failures

Before attributing failures to your changes, check if they pre-exist:

```bash
# Stash your changes and run tests on the base state
git stash && {PM} run test 2>&1 | tail -5; git stash pop
```

If tests fail without your changes:
- Log: "Pre-existing failure: {test_name} — not caused by this implementation"
- Exclude these tests from MUST PASS criteria
- Only your new failures must be fixed

### File Conflict Check (team mode)

After all teammates complete:
```bash
# Verify no file was modified by multiple teammates
git diff --name-only | sort | uniq -d
```
If duplicates found: merge manually, re-run validation.

8. **Self-audit against acceptance criteria**
   - Read `{output_dir}/00-context.md` → State Snapshot → Acceptance Criteria
   - For each AC:
     - Is it demonstrably met by the implementation?
     - Can you point to specific code that satisfies it?
   - Document findings in `{output_dir}/03-implement.md`

9. **Code pattern audit** (compact checklist)
   - All new functions follow existing patterns (naming, structure, error handling)
   - No duplicate logic
   - TypeScript strict rules applied (no `any`, no `as any`, proper type guards)
   - No unhandled promises or errors
   - Comments reflect why, not what

10. **Save findings**
    - Append validation results to `{output_dir}/03-implement.md`
    - Include: test pass/fail, lint pass/fail, ACs met (Y/N), audit notes

11. **Mark phase complete**
    - Update `{output_dir}/00-context.md` phase table
    - Set phase 03 status to "Complete"

---

## Routing

12. **Determine next phase**
    ```
    IF examine_mode: → phase-04-review
    ELSE IF test_mode: → phase-05-test
    ELSE IF pr_mode: → phase-06-ship
    ELSE: → complete
    ```

13. **Commit phase completion**
    ```bash
    IF branch_mode:
      git add -u && git commit -m "apex({task_id}): implement" || true
    ```

14. **Check pause mode**
    - IF pause_mode: Run `scripts/session-boundary.sh` and STOP
    - ELSE: Proceed to next phase immediately

---

## Recovery (Resume)

If resuming from phase 03 crash:
- Read `{output_dir}/00-context.md` to restore flags and context
- Check git status and `{output_dir}/03-implement.md` to find last-completed file
- Resume from next file in plan
- Rerun validation suite before proceeding to routing
