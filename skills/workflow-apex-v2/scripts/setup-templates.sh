#!/bin/bash
# APEX v2 Template Setup Script
# Creates output directory structure and initializes template files for 6-phase workflow
#
# Usage: setup-templates.sh "task-id-or-feature-name" [other args...]
# Accepts either a full task_id (e.g., "01-add-auth") or a feature name (e.g., "add-auth").
# If only a feature name is given, auto-generates the next available number.

set -e

# Arguments
INPUT_NAME="$1"
TASK_DESCRIPTION="$2"
EXAMINE_MODE="${3:-false}"
TEST_MODE="${4:-false}"
BRANCH_MODE="${5:-false}"
PR_MODE="${6:-false}"
INTERACTIVE_MODE="${7:-false}"
BRANCH_NAME="${8:-}"
ORIGINAL_INPUT="${9:-}"
TEAM_MODE="${10:-false}"
REFERENCE_FILE="${11:-}"
WORKTREE_MODE="${12:-false}"
WORKTREE_PATH_ARG="${13:-}"
AUTO_MODE="${14:-false}"
PAUSE_MODE="${15:-false}"
QUICK_MODE="${16:-false}"

# Validate required arguments
if [[ -z "$INPUT_NAME" ]]; then
    echo "Error: Feature name or task ID is required"
    exit 1
fi

if [[ -z "$TASK_DESCRIPTION" ]]; then
    echo "Error: TASK_DESCRIPTION is required"
    exit 1
fi

# Get current timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Use OUTPUT_BASE if provided (critical for worktree mode), else fall back to pwd
# In worktree mode, pwd is the worktree — but output files must live in the main repo
OUTPUT_BASE="${17:-}"
PROJECT_ROOT="${OUTPUT_BASE:-$(pwd)}"
APEX_OUTPUT_DIR="${PROJECT_ROOT}/.claude/output/apex-v2"

# Create apex output directory if it doesn't exist
mkdir -p "$APEX_OUTPUT_DIR"

# Get script directory for calling sibling scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse input: full task_id (e.g., "01-add-auth") or feature name only (e.g., "add-auth")
if [[ "$INPUT_NAME" =~ ^([0-9]+)-(.+)$ ]]; then
    # Full task_id provided — use as-is
    TASK_ID="$INPUT_NAME"
    FEATURE_NAME="${BASH_REMATCH[2]}"
else
    # Feature name only — delegate to generate-task-id.sh
    FEATURE_NAME="$INPUT_NAME"
    TASK_ID=$("$SCRIPT_DIR/generate-task-id.sh" "$FEATURE_NAME")
fi

OUTPUT_DIR="${APEX_OUTPUT_DIR}/${TASK_ID}"

# Get skill directory
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="${SKILL_DIR}/templates"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Escape special characters for sed replacement strings
# Handles: \ & | (our delimiter)
escape_sed_replacement() {
    printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

# Function to replace template variables
render_template() {
    local template_file="$1"
    local output_file="$2"

    # Determine status strings based on flags
    local examine_status="⏭ Skip"
    [[ "$EXAMINE_MODE" == "true" ]] && examine_status="⏸ Pending"

    local test_status="⏭ Skip"
    [[ "$TEST_MODE" == "true" ]] && test_status="⏸ Pending"

    local pr_status="⏭ Skip"
    [[ "$PR_MODE" == "true" ]] && pr_status="⏸ Pending"

    local context_status="⏸ Pending"
    [[ "$QUICK_MODE" == "true" ]] && context_status="⏭ Skip"

    local plan_status="⏸ Pending"
    [[ "$QUICK_MODE" == "true" ]] && plan_status="⏭ Skip"

    # Escape user-provided values (may contain special chars)
    local safe_task_desc
    safe_task_desc=$(escape_sed_replacement "$TASK_DESCRIPTION")
    local safe_original_input
    safe_original_input=$(escape_sed_replacement "$ORIGINAL_INPUT")
    local safe_branch_name
    safe_branch_name=$(escape_sed_replacement "$BRANCH_NAME")
    local safe_worktree_path
    safe_worktree_path=$(escape_sed_replacement "$WORKTREE_PATH_ARG")

    # Build reference docs content
    local reference_docs_content
    if [[ -n "$REFERENCE_FILE" ]]; then
        reference_docs_content="**MUST READ before planning/execution:** \`${REFERENCE_FILE}\`"
    else
        reference_docs_content="_No reference documents provided._"
    fi
    local safe_reference_docs
    safe_reference_docs=$(escape_sed_replacement "$reference_docs_content")

    # Read template and replace variables
    sed -e "s|{{task_id}}|${TASK_ID}|g" \
        -e "s|{{task_description}}|${safe_task_desc}|g" \
        -e "s|{{timestamp}}|${TIMESTAMP}|g" \
        -e "s|{{examine_mode}}|${EXAMINE_MODE}|g" \
        -e "s|{{test_mode}}|${TEST_MODE}|g" \
        -e "s|{{branch_mode}}|${BRANCH_MODE}|g" \
        -e "s|{{pr_mode}}|${PR_MODE}|g" \
        -e "s|{{interactive_mode}}|${INTERACTIVE_MODE}|g" \
        -e "s|{{team_mode}}|${TEAM_MODE}|g" \
        -e "s|{{branch_name}}|${safe_branch_name}|g" \
        -e "s|{{feature_name}}|${FEATURE_NAME}|g" \
        -e "s|{{original_input}}|${safe_original_input}|g" \
        -e "s|{{examine_status}}|${examine_status}|g" \
        -e "s|{{test_status}}|${test_status}|g" \
        -e "s|{{pr_status}}|${pr_status}|g" \
        -e "s|{{worktree_mode}}|${WORKTREE_MODE}|g" \
        -e "s|{{worktree_path}}|${safe_worktree_path}|g" \
        -e "s|{{reference_docs}}|${safe_reference_docs}|g" \
        -e "s|{{auto_mode}}|${AUTO_MODE}|g" \
        -e "s|{{pause_mode}}|${PAUSE_MODE}|g" \
        -e "s|{{quick_mode}}|${QUICK_MODE}|g" \
        -e "s|{{context_status}}|${context_status}|g" \
        -e "s|{{plan_status}}|${plan_status}|g" \
        "$template_file" > "$output_file"
}

# Initialize 00-context.md
render_template "${TEMPLATE_DIR}/00-context.md" "${OUTPUT_DIR}/00-context.md"

# Initialize core phase files (phases 01-03 always created)
render_template "${TEMPLATE_DIR}/01-context.md" "${OUTPUT_DIR}/01-context.md"
render_template "${TEMPLATE_DIR}/02-plan.md" "${OUTPUT_DIR}/02-plan.md"
render_template "${TEMPLATE_DIR}/03-implement.md" "${OUTPUT_DIR}/03-implement.md"

# Conditional templates
if [[ "$EXAMINE_MODE" == "true" ]]; then
    render_template "${TEMPLATE_DIR}/04-review.md" "${OUTPUT_DIR}/04-review.md"
fi

if [[ "$TEST_MODE" == "true" ]]; then
    render_template "${TEMPLATE_DIR}/05-test.md" "${OUTPUT_DIR}/05-test.md"
fi

if [[ "$PR_MODE" == "true" ]]; then
    render_template "${TEMPLATE_DIR}/06-ship.md" "${OUTPUT_DIR}/06-ship.md"
fi

# Output the generated task_id for capture by caller
echo "TASK_ID=${TASK_ID}"
echo "OUTPUT_DIR=${OUTPUT_DIR}"
echo "✓ APEX v2 templates initialized: ${OUTPUT_DIR}"
exit 0
