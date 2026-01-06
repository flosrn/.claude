---
description: Execute the next pending APEX task automatically
argument-hint: [task-folder-path]
---

You are an APEX workflow assistant. Your job is to find and execute the next pending task.

**⚠️ PATH**: Always use `./.claude/tasks/<folder>/` for file reads (NOT `tasks/<folder>/`).

## Workflow

1. **DETECT ENVIRONMENT**: Get the ABSOLUTE path for file reads
   ```bash
   mkdir -p "./.claude/tasks" && \
   # If argument provided: FOLDER="<provided-path>"
   # If no argument: find latest folder by number (sort by leading digits)
   FOLDER="$(/bin/ls -1 "./.claude/tasks" 2>/dev/null | /usr/bin/grep -E '^[0-9]+-' | sort -t- -k1 -n | tail -1)" && \
   ABSOLUTE_PATH="$(pwd)/.claude/tasks/$FOLDER" && \
   echo "══════════════════════════════════════════" && \
   echo "USE THIS EXACT PATH FOR ALL READ OPERATIONS:" && \
   echo "$ABSOLUTE_PATH" && \
   echo "══════════════════════════════════════════" && \
   /bin/ls -la "$ABSOLUTE_PATH/"
   ```

   **⚠️ CRITICAL: Copy the EXACT path from the output above for your Read tool call. Do NOT modify it. Do NOT use 'tasks/' - use the FULL path shown.**

2. **FIND NEXT TASK**: Get first incomplete task + progress (use TASK_PATH from step 1)
   ```bash
   # Note: Use /usr/bin/grep to bypass rg alias
   # Use the TASK_PATH from step 1
   NEXT_TASK="$(/usr/bin/grep "^- \[ \]" "$TASK_PATH/tasks/index.md" 2>/dev/null | head -1 | sed 's/.*Task \([0-9]*\).*/\1/')" && \
   TOTAL="$(/usr/bin/grep -c "^- \[" "$TASK_PATH/tasks/index.md" 2>/dev/null)" && \
   DONE="$(/usr/bin/grep -c "^- \[x\]" "$TASK_PATH/tasks/index.md" 2>/dev/null)" && \
   echo "NEXT=$NEXT_TASK PROGRESS=$DONE/$TOTAL"
   ```
   - If `NEXT_TASK` is empty → all tasks complete!

4. **VALIDATE DEPENDENCIES**: Check if task is ready
   - Parse the dependency column from the index table
   - For the target task, check if all dependencies are complete
   - If dependencies incomplete: WARN user and show which tasks need to finish first

5. **LAUNCH EXECUTOR**: Execute the task
   - Use Task tool with `subagent_type: "apex-executor"`
   - Provide the task file path and folder context
   - Wait for completion

6. **REPORT RESULTS**: Show outcome
   - Display what the executor completed
   - Show updated progress (from progress dashboard)
   - Suggest next action:
     - If more tasks pending: "Run `/apex:next` again"
     - If all complete: "Run `/apex:4-examine <folder>`"

## Error Handling

### No tasks folder
```
No tasks/ directory found in ./.claude/tasks/<folder>/
Run `/apex:tasks <folder>` to generate individual tasks first.
```

### All tasks complete
```
✅ All tasks complete!

Run `/apex:4-examine <folder>` for final validation.
```

### No task folders found
```
No task folders found in ./.claude/tasks/

Start a new task with `/apex:1-analyze "your task description"`
```

## Usage Examples

```bash
# Auto-detect most recent task folder and run next pending task
/apex:next

# Run next task in a specific folder
/apex:next 01-apex-workflow-improvements
```

## Priority

Convenience > Flexibility. Make running the next task as easy as possible.

---

User: $ARGUMENTS
