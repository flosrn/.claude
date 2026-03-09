#!/bin/bash
# APEX Session Boundary Script
# Consolidates session boundary logic:
# 1. Auto-commits tracked changes (if branch_mode + commit_flag)
# 2. Marks current step complete (update-progress.sh)
# 3. Updates state snapshot (update-state-snapshot.sh)
# 4. Displays session boundary box with resume command
#
# Usage: session-boundary.sh <task_id> <step_num> <step_name> <summary> \
#          <next_step_num> <next_step_desc> <step_context_line> \
#          [gotcha] [branch_mode] [commit_flag]

set -e

TASK_ID="${1:?Usage: session-boundary.sh <task_id> <step_num> <step_name> <summary> <next_step_num> <next_step_desc> <step_context_line> [gotcha] [branch_mode] [commit_flag]}"
STEP_NUM="${2:?}"
STEP_NAME="${3:?}"
SUMMARY="${4:?}"
NEXT_STEP_NUM="${5:?}"
NEXT_STEP_DESC="${6:?}"
STEP_CONTEXT_LINE="${7:?}"
GOTCHA="${8:-}"
BRANCH_MODE="${9:-false}"
COMMIT_FLAG="${10:-}"

# Resolve script directory (handles symlinks)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Step 1a: Auto-commit code changes if branch_mode + commit_flag
if [[ "$BRANCH_MODE" == "true" && "$COMMIT_FLAG" == "commit" ]]; then
    if git diff --cached --quiet 2>/dev/null && git diff --quiet 2>/dev/null; then
        echo "ℹ️  No changes to commit"
    else
        git add -A 2>/dev/null || true
        git commit -m "apex(${TASK_ID}): step ${STEP_NUM} - ${STEP_NAME}" --no-verify 2>/dev/null || true
        echo "✓ Committed: apex(${TASK_ID}): step ${STEP_NUM} - ${STEP_NAME}"
    fi
fi

# Step 1b: Push code changes (apex output .md files are NOT committed — local only)
# Only push if step 1a committed something (branch_mode + commit_flag)
if [[ "$BRANCH_MODE" == "true" && "$COMMIT_FLAG" == "commit" ]]; then
    git push 2>/dev/null || git push --set-upstream origin "$(git branch --show-current)" 2>/dev/null || true
fi

# Step 2: Mark step complete
bash "${SCRIPT_DIR}/update-progress.sh" "${TASK_ID}" "${STEP_NUM}" "${STEP_NAME}" "complete"

# Step 3: Update state snapshot
# next_step uses just the step identifier (e.g. "03-execute"), not the description
if [[ -n "$GOTCHA" ]]; then
    bash "${SCRIPT_DIR}/update-state-snapshot.sh" "${TASK_ID}" "${NEXT_STEP_NUM}" "${STEP_CONTEXT_LINE}" "${GOTCHA}"
else
    bash "${SCRIPT_DIR}/update-state-snapshot.sh" "${TASK_ID}" "${NEXT_STEP_NUM}" "${STEP_CONTEXT_LINE}"
fi

# Step 4: Display session boundary
echo ""
echo "═══════════════════════════════════════"
echo "  STEP ${STEP_NUM} COMPLETE: ${STEP_NAME}"
echo "═══════════════════════════════════════"
echo "  ${SUMMARY}"
echo "  Resume: /apex -r ${TASK_ID}"
echo "  Next: Step ${NEXT_STEP_NUM} - ${NEXT_STEP_DESC}"
echo "═══════════════════════════════════════"
echo ""

exit 0
