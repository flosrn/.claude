# Tasks: APEX Workflow Improvements

## Overview

Enhance the APEX workflow with 14 improvements including a dedicated executor agent, background execution modes, progress visibility, and new convenience commands.

## Task List

| Task | Name | Dependencies | File(s) |
|------|------|--------------|---------|
| 1 | Create apex-executor Agent | None | `agents/apex-executor.md` |
| 2 | Add Progress Dashboard | None | `commands/apex/3-execute.md` |
| 3 | Add Dry-Run and Quick Validation Flags | None | `commands/apex/3-execute.md` |
| 4 | Enhance Parallel Auto-Detect + Use apex-executor | Task 1 | `commands/apex/3-execute.md` |
| 5 | Add Commit Template | None | `commands/apex/3-execute.md` |
| 6 | Add Background Mode to 1-analyze | None | `commands/apex/1-analyze.md` |
| 7 | Add Quick Summary Template | None | `commands/apex/1-analyze.md` |
| 8 | Add Background Mode to 4-examine | None | `commands/apex/4-examine.md` |
| 9 | Create /apex:next Command | Task 1 | `commands/apex/next.md` |
| 10 | Create /apex:status Command | None | `commands/apex/status.md` |
| 11 | Add System Notification | None | `settings.json` |

- [x] **Task 1**: Create apex-executor Agent - `task-01.md`
- [x] **Task 2**: Add Progress Dashboard - `task-02.md`
- [x] **Task 3**: Add Dry-Run and Quick Validation Flags - `task-03.md`
- [x] **Task 4**: Enhance Parallel Auto-Detect + Use apex-executor - `task-04.md` (depends on Task 1)
- [x] **Task 5**: Add Commit Template - `task-05.md`
- [x] **Task 6**: Add Background Mode to 1-analyze - `task-06.md`
- [x] **Task 7**: Add Quick Summary Template - `task-07.md`
- [x] **Task 8**: Add Background Mode to 4-examine - `task-08.md`
- [x] **Task 9**: Create /apex:next Command - `task-09.md` (depends on Task 1)
- [x] **Task 10**: Create /apex:status Command - `task-10.md`
- [x] **Task 11**: Add System Notification - `task-11.md`

## Execution Strategy

```
Task 1 → [Task 4 ‖ Task 9]
         ↓
[Task 2 ‖ Task 3 ‖ Task 5 ‖ Task 6 ‖ Task 7 ‖ Task 8 ‖ Task 10 ‖ Task 11]
```

**Simplified view:**

```
Task 1 ─┬─→ Task 4
        └─→ Task 9

[Task 2 ‖ Task 3 ‖ Task 5 ‖ Task 6 ‖ Task 7 ‖ Task 8 ‖ Task 10 ‖ Task 11] (all independent)
```

**Parallelization opportunities:**
- **9 tasks can run immediately in parallel**: Tasks 2, 3, 5, 6, 7, 8, 10, 11 have no dependencies
- **2 tasks depend on Task 1**: Tasks 4 and 9 require apex-executor to exist
- **Maximum parallelism**: Start Task 1 + all independent tasks simultaneously

## Recommended Commands

```bash
# Sequential execution (recommended for first run)
/apex:3-execute 01-apex-workflow-improvements 1
/apex:3-execute 01-apex-workflow-improvements 2
/apex:3-execute 01-apex-workflow-improvements 3
# ... continue through 11

# Parallel execution - independent tasks
/apex:3-execute 01-apex-workflow-improvements 2,3,5,6,7,8,10,11

# After Task 1 completes, run dependent tasks
/apex:3-execute 01-apex-workflow-improvements 4,9

# Auto-detect parallel tasks
/apex:3-execute 01-apex-workflow-improvements --parallel
```

## Optimal Execution Order

1. **First wave** (Task 1 required first):
   ```
   /apex:3-execute 01-apex-workflow-improvements 1
   ```

2. **Second wave** (all can be parallel):
   ```
   /apex:3-execute 01-apex-workflow-improvements 2,3,4,5,6,7,8,9,10,11
   ```

**Start with**: Task 1 - it creates the apex-executor agent needed by Tasks 4 and 9.

## File Change Summary

| File | Tasks Modifying |
|------|-----------------|
| `agents/apex-executor.md` | Task 1 (CREATE) |
| `commands/apex/3-execute.md` | Tasks 2, 3, 4, 5 |
| `commands/apex/1-analyze.md` | Tasks 6, 7 |
| `commands/apex/4-examine.md` | Task 8 |
| `commands/apex/next.md` | Task 9 (CREATE) |
| `commands/apex/status.md` | Task 10 (CREATE) |
| `settings.json` | Task 11 |

**Note**: Tasks 2, 3, 4, 5 all modify `3-execute.md` - consider running these sequentially to avoid merge conflicts.
