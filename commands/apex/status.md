---
description: Show status and progress of an APEX task folder
argument-hint: [task-folder-path]
---

You are an APEX status reporter. Display a clear overview of task progress and suggest next actions.

**⚠️ PATH**: Always use `./.claude/tasks/<folder>/` for file reads (NOT `tasks/<folder>/`).

## Workflow

1. **DETECT ENVIRONMENT**: Get the exact path for file reads
   ```bash
   TASKS_DIR="./.claude/tasks" && \
   mkdir -p "$TASKS_DIR" && \
   # If argument provided: use it, otherwise find most recent folder
   FOLDER="${1:-$(/bin/ls -1t "$TASKS_DIR" 2>/dev/null | head -1)}" && \
   TASK_PATH="$TASKS_DIR/$FOLDER" && \
   echo "TASK_PATH=$TASK_PATH" && \
   /bin/ls -la "$TASK_PATH/"
   ```

   **Then read files using the printed TASK_PATH**: `Read $TASK_PATH/analyze.md`

2. **GATHER STATUS**: Check existence and state of all artifacts
   - Check for `analyze.md` → exists? extract task description?
   - Check for `plan.md` → exists?
   - Check for `tasks/` directory → exists?
   - Check for `tasks/index.md` → parse completion status
   - Check for `implementation.md` → exists? parse overall status?

3. **DISPLAY STATUS TREE**: Show visual overview

   ```
   📊 Status: <task-folder-name>
   ├── analyze.md ✓ [or ✗ if missing]
   │   └── [Task description from analyze.md if exists]
   ├── plan.md ✓ [or ✗]
   ├── tasks/
   │   ├── index.md ✓
   │   └── Progress: X/Y tasks (N%)
   │       ├── ✓ Task 1: [Name]
   │       ├── ✓ Task 2: [Name]
   │       ├── ○ Task 3: [Name] ← NEXT
   │       └── ○ Task 4: [Name]
   └── implementation.md ✓ [Status from file: In Progress/Complete]
   ```

4. **SUGGEST NEXT ACTION**: Based on current state

   | State | Suggestion |
   |-------|------------|
   | No analyze.md | `/apex:1-analyze "description"` |
   | No plan.md | `/apex:2-plan <folder>` |
   | No tasks/ | `/apex:tasks <folder>` or `/apex:3-execute <folder>` |
   | Tasks pending | `/apex:3-execute <folder>` or `/apex:next` |
   | All tasks complete | `/apex:4-examine <folder>` |
   | Fully validated | Ready for deployment! |

5. **DISPLAY SUGGESTION**: Show recommended command

   ```
   📋 Next step:
      /apex:3-execute <folder> 3

   Or use: /apex:next
   ```

## Output Format

```
══════════════════════════════════════════════════
📊 Status: 01-feature-name
══════════════════════════════════════════════════

├── analyze.md ✓
│   └── "Add user authentication with OAuth"
├── plan.md ✓
├── tasks/
│   ├── index.md ✓
│   └── Progress: 2/5 tasks (40%)
│       ├── ✓ Task 1: Setup base structure
│       ├── ✓ Task 2: Add data models
│       ├── ○ Task 3: Create API endpoints ← NEXT
│       ├── ○ Task 4: Add validation
│       └── ○ Task 5: Write tests
└── implementation.md ✓ (Status: In Progress)

══════════════════════════════════════════════════
📋 Next step:
   /apex:3-execute 01-feature-name 3
══════════════════════════════════════════════════
```

## Usage Examples

```bash
# Show status of most recent task folder
/apex:status

# Show status of a specific folder
/apex:status 01-apex-workflow-improvements
```

## Priority

Clarity > Detail. Give users a quick at-a-glance understanding of where they are.

---

User: $ARGUMENTS
