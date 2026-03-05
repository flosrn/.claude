#!/bin/bash
# APEX Worktree Environment Setup
# Configures a git worktree created by EnterWorktree for development:
# - Copies .env files from main repo
# - Creates relative symlinks for heavy directories (node_modules, .next/cache, etc.)
# - Generates a deterministic port offset from task_id
#
# Usage: setup-worktree.sh <main_repo_root> <worktree_path> <task_id>
# Idempotent — safe to run multiple times.

set -e

MAIN_REPO_ROOT="$1"
WORKTREE_PATH="$2"
TASK_ID="$3"

if [[ -z "$MAIN_REPO_ROOT" || -z "$WORKTREE_PATH" || -z "$TASK_ID" ]]; then
    echo "Error: Usage: setup-worktree.sh <main_repo_root> <worktree_path> <task_id>"
    exit 1
fi

# Resolve to absolute paths
MAIN_REPO_ROOT=$(cd "$MAIN_REPO_ROOT" && pwd)
WORKTREE_PATH=$(cd "$WORKTREE_PATH" && pwd)

echo "Setting up worktree environment..."
echo "  Main repo: ${MAIN_REPO_ROOT}"
echo "  Worktree:  ${WORKTREE_PATH}"
echo "  Task ID:   ${TASK_ID}"

# ============================================
# 1. Copy .env files
# ============================================
echo ""
echo "--- Copying .env files ---"

for pattern in ".env" ".env.local" ".env.*.local"; do
    # Use find for glob patterns, direct check for simple names
    if [[ "$pattern" == *"*"* ]]; then
        while IFS= read -r -d '' envfile; do
            basename=$(basename "$envfile")
            if [[ ! -f "${WORKTREE_PATH}/${basename}" ]]; then
                cp "$envfile" "${WORKTREE_PATH}/${basename}"
                echo "  Copied: ${basename}"
            else
                echo "  Exists: ${basename} (skipped)"
            fi
        done < <(find "$MAIN_REPO_ROOT" -maxdepth 1 -name "$pattern" -print0 2>/dev/null)
    else
        if [[ -f "${MAIN_REPO_ROOT}/${pattern}" ]]; then
            if [[ ! -f "${WORKTREE_PATH}/${pattern}" ]]; then
                cp "${MAIN_REPO_ROOT}/${pattern}" "${WORKTREE_PATH}/${pattern}"
                echo "  Copied: ${pattern}"
            else
                echo "  Exists: ${pattern} (skipped)"
            fi
        fi
    fi
done

# ============================================
# 2. Create relative symlinks for heavy dirs
# ============================================
echo ""
echo "--- Creating symlinks ---"

# Compute relative path from worktree to main repo
REL_PATH=$(python3 -c "import os; print(os.path.relpath('${MAIN_REPO_ROOT}', '${WORKTREE_PATH}'))")

# Directories to symlink (only if they exist in main repo)
SYMLINK_DIRS=("node_modules" ".next/cache" "vendor" "target" ".venv")

for dir in "${SYMLINK_DIRS[@]}"; do
    src="${MAIN_REPO_ROOT}/${dir}"
    dest="${WORKTREE_PATH}/${dir}"

    if [[ -d "$src" ]]; then
        if [[ -L "$dest" ]]; then
            echo "  Symlink exists: ${dir} (skipped)"
        elif [[ -d "$dest" ]]; then
            echo "  Directory exists: ${dir} (skipped, not overwriting)"
        else
            # Create parent directory if needed (e.g., .next/ for .next/cache)
            mkdir -p "$(dirname "$dest")"
            ln -s "${REL_PATH}/${dir}" "$dest"
            echo "  Linked: ${dir} → ${REL_PATH}/${dir}"
        fi
    fi
done

# ============================================
# 3. Port offset (deterministic from task_id)
# ============================================
echo ""
echo "--- Port offset ---"

# Generate a deterministic offset (100-999) from task_id hash
HASH=$(echo -n "$TASK_ID" | cksum | awk '{print $1}')
PORT_OFFSET=$(( (HASH % 900) + 100 ))

# Write to .env.local (append if exists, create if not)
ENV_LOCAL="${WORKTREE_PATH}/.env.local"
if grep -q "^PORT_OFFSET=" "$ENV_LOCAL" 2>/dev/null; then
    echo "  PORT_OFFSET already set in .env.local (skipped)"
else
    echo "" >> "$ENV_LOCAL"
    echo "# APEX worktree port offset (auto-generated)" >> "$ENV_LOCAL"
    echo "PORT_OFFSET=${PORT_OFFSET}" >> "$ENV_LOCAL"
    echo "  PORT_OFFSET=${PORT_OFFSET} written to .env.local"
fi

# ============================================
# 4. Detect project type
# ============================================
echo ""
echo "--- Project detection ---"

if [[ -f "${WORKTREE_PATH}/package.json" ]]; then
    echo "  Detected: Node.js (package.json)"
elif [[ -f "${WORKTREE_PATH}/Cargo.toml" ]]; then
    echo "  Detected: Rust (Cargo.toml)"
elif [[ -f "${WORKTREE_PATH}/go.mod" ]]; then
    echo "  Detected: Go (go.mod)"
elif [[ -f "${WORKTREE_PATH}/requirements.txt" ]] || [[ -f "${WORKTREE_PATH}/pyproject.toml" ]]; then
    echo "  Detected: Python"
elif [[ -f "${WORKTREE_PATH}/composer.json" ]]; then
    echo "  Detected: PHP (composer.json)"
else
    echo "  No specific project type detected"
fi

echo ""
echo "✓ Worktree environment ready"
exit 0
