---
name: phase-04-review
description: Adversarial code review and resolution - find issues then fix them
prev_phase: ./phase-03-implement.md
next_phase: conditional (05-test | 06-ship | complete)
---

# Phase 04: Review

Conduct adversarial code review and resolve Real findings in a single phase.

**Role:** Skeptical reviewer then resolver

---

## Part A: Examine

1. **Mark phase in progress**
   - Update progress table in `{output_dir}/00-context.md`
   - Set phase 04 status to "In Progress"

2. **Gather implemented changes**
   - Read `{output_dir}/03-implement.md` → list of modified files
   - Run `git diff main..HEAD --stat` to confirm current state (preferred over `git status` — works correctly in worktrees)
   - **If worktree_mode:** DO NOT spawn Agent/Explore subagents for file reading — they resolve paths to main repo, not the worktree (claude-code bug #29083). Instead, read files directly with the Read tool using absolute worktree paths.
   - Prepare file list for review team

3. **Conduct adversarial review**

   **If team_mode:**
   - Use Agent Teams with 3-4 specialized reviewers
     - TeamCreate with team_name = `apex-{task_id}-review`
     - Spawn reviewers (read-only, no implementation):
       - Security reviewer: `model: "sonnet"`, reads `{skill_dir}/references/security-checklist.md`
       - Logic reviewer: `model: "sonnet"`, reads `{skill_dir}/references/logic-checklist.md`
       - Quality reviewer: `model: "sonnet"`, reads `{skill_dir}/references/quality-checklist.md`
       - [Optional] Next.js reviewer: IF package.json contains `next` → reads `{skill_dir}/references/nextjs-checklist.md`
     - Cross-challenge phase: have reviewers share findings, validate/challenge each other
     - Deduplicate findings before presenting
     - Shutdown teammates: `SendMessage` with `type: "shutdown_request"`
     - TeamDelete after all shut down

   **Else (solo mode):**
   - Spawn 3 parallel Explore agents (read-only, no git writes):
     - Security: "Review {output_dir}/03-implement.md and modified files. Check security patterns using {skill_dir}/references/security-checklist.md"
     - Logic: "Review {output_dir}/03-implement.md and modified files. Check business logic patterns using {skill_dir}/references/logic-checklist.md"
     - Quality: "Review {output_dir}/03-implement.md and modified files. Check code quality patterns using {skill_dir}/references/quality-checklist.md"
     - [Optional] Next.js: IF detected → "Review Next.js usage in modified files using {skill_dir}/references/nextjs-checklist.md"
   - Wait for all agents to complete
   - Aggregate findings into single list

4. **Classify findings**
   - For each finding:
     - **Severity:** CRITICAL (breaks feature), HIGH (significant flaw), MEDIUM (improvement), LOW (minor)
     - **Validity:** Real (valid issue), Noise (false positive), Uncertain (needs verification)
   - Discard all LOW severity findings automatically
   - Present findings table with [Severity | Category | Description | File:Line | Validity]

### Severity Filtering

- CRITICAL/HIGH findings with validity "Real": auto-fix (Part B)
- MEDIUM findings with validity "Real": auto-fix
- LOW findings: log but do NOT fix (documented for reference only)
- All Noise findings: discard silently
- Uncertain findings: log with "needs manual review" note

5. **Get human checkpoint** (if not auto_mode)
   - Show findings table
   - Use `AskUserQuestion` tool with question: "Proceed with auto-fixes for all Real findings?" and options: `["Yes — fix all Real findings", "Select which to fix", "Skip fixes — keep as-is"]`
   - If user selects → use `AskUserQuestion` (free text) to ask which findings to fix
   - If user rejects → update severity/validity → proceed only for approved

---

## Part B: Resolve (integrated, same phase)

6. **Auto-fix Real findings**
   - Order by severity (CRITICAL first)
   - For each Real finding (skip Noise/Uncertain):
     - Read affected file
     - Understand issue
     - Apply focused fix
     - Verify: `{PM} run typecheck && {PM} run lint` (or stack equivalent)
     - Commit: `git add -u && git commit -m "apex({task_id}): review fix - {brief description}" || true`

7. **Post-resolution validation**
   - Run full validation suite (using detected package manager from phase 03):
     ```bash
     {PM} run typecheck && {PM} run lint
     ```
     For non-Node.js projects, use the stack-equivalent commands (see phase-03 toolchain table).
   - If failures: read error → fix root cause → re-run
   - Continue until clean

8. **Document resolution**
   - Save to `{output_dir}/04-review.md`:
     - Findings table (all classified)
     - Fixed items (with commit hashes)
     - Unresolved items (Noise/Uncertain with notes)
     - Final validation status (pass/fail)

9. **Mark phase complete**
   - Update `{output_dir}/00-context.md` phase table
   - Set phase 04 status to "Complete"

---

## Routing

10. **Determine next phase**
    ```
    IF test_mode: → phase-05-test
    ELSE IF pr_mode: → phase-06-ship
    ELSE: → complete
    ```

11. **Commit phase completion**
    ```bash
    IF branch_mode:
      git add -u && git commit -m "apex({task_id}): review fixes" || true
    ```

12. **Check pause mode**
    - IF pause_mode: Run `scripts/session-boundary.sh` and STOP
    - ELSE: Proceed to next phase immediately

---

## Recovery (Resume)

If resuming from phase 04 crash:
- Read `{output_dir}/00-context.md` to restore flags and context
- Check `{output_dir}/04-review.md` for incomplete fixes
- Resume fixing remaining Real findings
- Rerun validation suite before routing
