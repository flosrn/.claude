---
name: phase-06-ship
description: Finalize workflow - commit, push, create PR
prev_phase: ./phase-05-test.md
---

# Phase 06: Ship

Finisher role (no code changes).

## Sequence

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
       --body "## Summary\n\n{description}\n\nCloses #XX" \
       ${BASE_BRANCH:+--base "$BASE_BRANCH"}
     ```
   - Capture PR URL from output
6. Save to `{output_dir}/06-ship.md`
7. Mark 06 complete using `update-progress.sh 06`
8. Update state snapshot: `update-state-snapshot.sh complete`
9. Display final summary

## PR Body Template

```markdown
## Summary

[2-3 sentence feature description]

## Changes

- [Change 1]
- [Change 2]
- [Change 3]

## Testing

[How to test, test coverage, or "All tests passing"]

Closes #{issue_number}
```

## Output Format

```markdown
# Phase 06: Ship

## Git Push
✅ Pushed to origin/{branch_name}

## PR Created
- URL: https://github.com/{owner}/{repo}/pull/{pr_number}
- Title: feat({feature}): {description}
- Base: main
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
- [ ] No uncommitted changes
- [ ] State marked complete
