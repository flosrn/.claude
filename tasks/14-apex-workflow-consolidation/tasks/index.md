# Tasks: APEX Workflow Consolidation

## Overview

Consolidate 6 improvement axes for the APEX workflow system: TASKS_DIR hardcoding, file rename, port detection, brainstorm enhancement, documentation cross-links, and skill verification (already complete).

## Task List

| Task | Name | Dependencies |
|------|------|--------------|
| 1 | Hardcode TASKS_DIR across all commands | None |
| 2 | Rename 5-demo to 5-browser-test | Task 1 |
| 3 | Add automatic port detection | Task 2 |
| 4 | Enhance brainstorm interview depth | Task 1 |
| 5 | Add documentation cross-links | Task 2 |

- [x] **Task 1**: Hardcode TASKS_DIR - `task-01.md`
- [x] **Task 2**: Rename 5-demo to 5-browser-test - `task-02.md` (depends on Task 1)
- [x] **Task 3**: Add automatic port detection - `task-03.md` (depends on Task 2)
- [x] **Task 4**: Enhance brainstorm interview depth - `task-04.md` (depends on Task 1)
- [x] **Task 5**: Add documentation cross-links - `task-05.md` (depends on Task 2)

## Execution Strategy

```
Task 1 → [Task 2 ‖ Task 4] → [Task 3 ‖ Task 5]
```

**Parallelization opportunities:**
- After Task 1: Tasks 2 and 4 can run simultaneously (different files)
- After Task 2: Tasks 3 and 5 can run simultaneously (3 modifies renamed file, 5 updates docs)

## Recommended Commands

```bash
# Sequential execution (safe, one at a time)
/apex:3-execute 14-apex-workflow-consolidation 1
/apex:3-execute 14-apex-workflow-consolidation 2
/apex:3-execute 14-apex-workflow-consolidation 3
/apex:3-execute 14-apex-workflow-consolidation 4
/apex:3-execute 14-apex-workflow-consolidation 5

# Parallel execution after Task 1
/apex:3-execute 14-apex-workflow-consolidation 2,4

# Parallel execution after Task 2
/apex:3-execute 14-apex-workflow-consolidation 3,5

# Auto-detect parallel tasks
/apex:3-execute 14-apex-workflow-consolidation --parallel
```

**Start with**: Task 1 - it has no dependencies and all other tasks depend on it.

## Git Commit Strategy

Each task should produce one atomic commit:
1. `refactor(apex): hardcode TASKS_DIR across all commands`
2. `refactor(apex): rename 5-demo to 5-browser-test`
3. `feat(apex): add automatic port detection to browser-test`
4. `feat(apex): enhance brainstorm interview depth`
5. `docs(apex): add cross-links between CLAUDE.md and overview.md`

## Verification Skipped

**Axis 4 (Skill Integration)** was verified during analysis - no changes needed:
- `4-examine.md:4` already has `Skill` in `allowed-tools`
- `4-examine.md:202-205` correctly documents skill invocation
- Skill exists at expected path
