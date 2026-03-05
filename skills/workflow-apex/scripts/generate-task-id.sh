#!/bin/bash
# Generate the next available APEX task ID
#
# Usage: generate-task-id.sh "feature-name"
# Output: NN-feature-name (e.g., "01-add-auth-middleware")
#
# Scans .claude/output/apex/ for existing task folders and returns
# the next available number prefixed to the feature name.

set -e

FEATURE_NAME="$1"

if [[ -z "$FEATURE_NAME" ]]; then
    echo "Error: feature name is required" >&2
    echo "Usage: generate-task-id.sh \"feature-name\"" >&2
    exit 1
fi

APEX_DIR="${PWD}/.claude/output/apex"
mkdir -p "$APEX_DIR"

# Find the highest existing number prefix
NEXT_NUM=1
HIGHEST=$(ls -1 "$APEX_DIR" 2>/dev/null | grep -oE '^[0-9]+' | sort -n | tail -1)
if [[ -n "$HIGHEST" ]]; then
    # Force base-10 interpretation (leading zeros would be treated as octal)
    NEXT_NUM=$((10#$HIGHEST + 1))
fi

TASK_NUM=$(printf "%02d" "$NEXT_NUM")
echo "${TASK_NUM}-${FEATURE_NAME}"
