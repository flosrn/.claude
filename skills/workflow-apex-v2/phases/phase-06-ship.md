---
name: phase-06-ship
description: Finalize workflow - commit, push, create PR, mirror labels, optional CI monitoring
prev_phase: ./phase-05-test.md
---

# Phase 06: Ship

Finisher role (no code changes).

## Sequence

0. **Restore context from `.env.local`**
   ```bash
   source {output_dir}/.env.local
   ```
   This loads `{main_repo_path}`, `{worktree_path}`, `{task_id}`, `{pm}`, `{is_monorepo}`, etc.

1. Mark 06 in_progress using `update-progress.sh 06`
2. Verify git status: `git status --short`
3. Commit remaining changes:
   ```bash
   git add -u && git commit -m "apex({task_id}): final changes" || true
   ```
4. Push to origin:
   ```bash
   git push -u origin {branch_name}
   ```
5. IF pr_mode: Create PR
   - Detect issue number from `{issue_url}` or ask
   - Detect base branch: check `.claude/apex-pr-base` or default `main`
   - Create PR:
     ```bash
     gh pr create \
       --title "feat({feature_name}): {task_description}" \
       --body "$(cat <<'PREOF'
     ## Summary

     [2-3 sentence feature description]

     ## Changes

     - [Change 1]
     - [Change 2]
     - [Change 3]

     ## Testing

     [How to test, test coverage, or "All tests passing"]

     Closes #{issue_number}
     PREOF
     )" \
       ${BASE_BRANCH:+--base "$BASE_BRANCH"}
     ```
   - Capture PR URL and number from output

6. IF pr_mode AND {issue_number} set: **Mirror issue labels to PR**
   ```bash
   LABELS=$(gh issue view {issue_number} --json labels -q '[.labels[].name] | join(",")')
   if [ -n "$LABELS" ]; then
     gh pr edit --add-label "$LABELS"
   fi
   ```

7. IF pr_mode: **Optional CI monitoring**
   - Check if CronCreate tool is available
   - If available, propose: "Monitor CI status? (polls every 5 min, auto-stops on green/red)"
   - If user approves (or auto_mode=true):
     ```
     CronCreate(
       schedule="*/5 * * * *",
       prompt="Check CI for the latest PR: gh pr checks --repo {owner}/{repo}.
         All pass → report success and CronDelete this job.
         Any fail → report failure details and CronDelete this job.
         Still running → do nothing, wait for next poll."
     )
     ```

8. IF worktree_mode: **Worktree cleanup**
   - Return to main repo: `cd {main_repo_path}`
   - Remove worktree:
     ```bash
     git worktree remove .worktrees/{task_id} --force 2>/dev/null || true
     git branch -d {task_id} 2>/dev/null || true
     ```
   - If removal fails (uncommitted changes), warn user instead of force-removing

9. Save to `{output_dir}/06-ship.md`
10. Mark 06 complete using `update-progress.sh 06`
11. Update state snapshot: `update-state-snapshot.sh complete`
12. Display final summary

## Output Format

```markdown
# Phase 06: Ship

## Git Push
Pushed to origin/{branch_name}

## PR Created
- URL: https://github.com/{owner}/{repo}/pull/{pr_number}
- Title: feat({feature}): {description}
- Base: main
- Labels: {mirrored_labels}
- CI Monitoring: {enabled|disabled}
- Status: Open

## Summary
- Branch: {branch_name}
- Commits: {count}
- Files: {count}
```

## Success Criteria

- [ ] All commits on feature branch
- [ ] PR created with title and body
- [ ] PR links to issue (if applicable)
- [ ] Issue labels mirrored to PR (if applicable)
- [ ] No uncommitted changes
- [ ] State marked complete
