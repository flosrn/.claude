#!/bin/bash
# APEX State Snapshot Update Script
# Updates the State Snapshot section in 00-context.md:
# - Sets next_step
# - Appends Step Context summary
# - Records Gotchas
#
# Usage: update-state-snapshot.sh <task_id> <next_step> <step_context_line> [gotcha]

set -e

TASK_ID="${1:?Usage: update-state-snapshot.sh <task_id> <next_step> <step_context_line> [gotcha]}"
NEXT_STEP="${2:?}"
STEP_CONTEXT_LINE="${3:?}"
GOTCHA="${4:-}"

# Find project root
PROJECT_ROOT=$(pwd)
CONTEXT_FILE="${PROJECT_ROOT}/.claude/output/apex/${TASK_ID}/00-context.md"

if [[ ! -f "$CONTEXT_FILE" ]]; then
    echo "Error: Context file not found: $CONTEXT_FILE"
    exit 1
fi

TEMP_FILE=$(mktemp)

# Update next_step value
sed "s/^\*\*next_step:\*\* .*/\*\*next_step:\*\* ${NEXT_STEP}/" "$CONTEXT_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$CONTEXT_FILE"

TEMP_FILE=$(mktemp)

# Append step context line (before ### Gotchas if it exists, otherwise at end of ### Step Context)
if grep -q "### Gotchas" "$CONTEXT_FILE"; then
    awk -v line="- ${STEP_CONTEXT_LINE}" '
    /^### Gotchas/ { print line; print ""; }
    { print }
    ' "$CONTEXT_FILE" > "$TEMP_FILE"
else
    # Append after last line of Step Context section (before next ## heading or EOF)
    awk -v line="- ${STEP_CONTEXT_LINE}" '
    BEGIN { in_step_context = 0; appended = 0 }
    /^### Step Context/ { in_step_context = 1; print; next }
    in_step_context && /^##/ && !appended { print line; print ""; appended = 1; in_step_context = 0 }
    { print }
    END { if (in_step_context && !appended) print line }
    ' "$CONTEXT_FILE" > "$TEMP_FILE"
fi
mv "$TEMP_FILE" "$CONTEXT_FILE"

# Add gotcha if provided
if [[ -n "$GOTCHA" ]]; then
    TEMP_FILE=$(mktemp)
    if grep -q "### Gotchas" "$CONTEXT_FILE"; then
        awk -v gotcha="- ⚠️ ${GOTCHA}" '
        /^### Gotchas/ { print; getline; print; print gotcha; next }
        { print }
        ' "$CONTEXT_FILE" > "$TEMP_FILE"
    else
        # Add Gotchas section at end of State Snapshot
        echo "" >> "$CONTEXT_FILE"
        echo "### Gotchas" >> "$CONTEXT_FILE"
        echo "- ⚠️ ${GOTCHA}" >> "$CONTEXT_FILE"
        cp "$CONTEXT_FILE" "$TEMP_FILE"
    fi
    mv "$TEMP_FILE" "$CONTEXT_FILE"
fi

echo "✓ State snapshot updated: next_step=${NEXT_STEP}"
exit 0
