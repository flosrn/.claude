# APEX v2 Task: {{task_id}}

**Created:** {{timestamp}}
**Task:** {{task_description}}
**Version:** v2 (single-session)

---

## Configuration

| Flag | Value |
|------|-------|
| Examine (`-x`) | {{examine_mode}} |
| Test (`-t`) | {{test_mode}} |
| Team (`-w`) | {{team_mode}} |
| Branch (`-b`) | {{branch_mode}} |
| PR (`-pr`) | {{pr_mode}} |
| Auto (`-a`) | {{auto_mode}} |
| Pause (`-p`) | {{pause_mode}} |
| Interactive (`-i`) | {{interactive_mode}} |
| Worktree (`-wt`) | {{worktree_mode}} |
| Quick (`-q`) | {{quick_mode}} |
| Branch name | {{branch_name}} |
| Worktree path | {{worktree_path}} |

---

## User Request

```
{{original_input}}
```

## Reference Documents

{{reference_docs}}

---

## Progress

| Phase | Status | Timestamp |
|-------|--------|-----------|
| 00-init | ⏸ Pending | |
| 01-context | {{context_status}} | |
| 02-plan | {{plan_status}} | |
| 03-implement | ⏸ Pending | |
| 04-review | {{examine_status}} | |
| 05-test | {{test_status}} | |
| 06-ship | {{pr_status}} | |

---

## State Snapshot

**feature_name:** {{feature_name}}
**worktree_path:** {{worktree_path}}
**next_step:** 01

### Acceptance Criteria

_Defined during phase-01-context_

### Step Context

_Brief summaries added as phases complete_

### Gotchas

_Surprises, workarounds, and deviations discovered during execution_

### User Choices

_Decisions recorded at interactive transition points_
