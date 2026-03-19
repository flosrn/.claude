#!/bin/bash
# APEX Worktree Environment Setup
# Configures a git worktree for development:
# - Copies .env files from main repo
# - Symlinks heavy dirs (but NOT node_modules for pnpm monorepos)
# - Installs dependencies via detected package manager
# - Generates deterministic port allocation
# - Detects monorepo and provides filtered dev command
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
# 1. Detect package manager and monorepo type
# ============================================
echo ""
echo "--- Detecting project type ---"

PM=""
IS_MONOREPO=false
MONOREPO_TYPE=""

if [[ -f "${WORKTREE_PATH}/pnpm-workspace.yaml" ]]; then
    PM="pnpm"
    IS_MONOREPO=true
    MONOREPO_TYPE="pnpm"
    echo "  Detected: pnpm monorepo (pnpm-workspace.yaml)"
elif [[ -f "${WORKTREE_PATH}/bun.lockb" ]] || [[ -f "${WORKTREE_PATH}/bun.lock" ]]; then
    PM="bun"
elif [[ -f "${WORKTREE_PATH}/pnpm-lock.yaml" ]]; then
    PM="pnpm"
elif [[ -f "${WORKTREE_PATH}/yarn.lock" ]]; then
    PM="yarn"
elif [[ -f "${WORKTREE_PATH}/package.json" ]]; then
    PM="npm"
fi

if [[ -f "${WORKTREE_PATH}/turbo.json" ]]; then
    IS_MONOREPO=true
    echo "  Detected: Turborepo monorepo (turbo.json)"
fi

if [[ -n "$PM" ]]; then
    echo "  Package manager: ${PM}"
fi

# ============================================
# 2. Copy .env files
# ============================================
echo ""
echo "--- Copying .env files ---"

for pattern in ".env" ".env.local" ".env.*.local" ".env.development" ".env.test"; do
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

# Copy app-level .env files in monorepos
if [[ "$IS_MONOREPO" == true ]] && [[ -d "${MAIN_REPO_ROOT}/apps" ]]; then
    for app_dir in "${MAIN_REPO_ROOT}"/apps/*/; do
        app_name=$(basename "$app_dir")
        for envfile in "${app_dir}".env "${app_dir}".env.local "${app_dir}".env.development; do
            if [[ -f "$envfile" ]]; then
                dest="${WORKTREE_PATH}/apps/${app_name}/$(basename "$envfile")"
                if [[ ! -f "$dest" ]]; then
                    mkdir -p "$(dirname "$dest")"
                    cp "$envfile" "$dest"
                    echo "  Copied: apps/${app_name}/$(basename "$envfile")"
                fi
            fi
        done
    done
fi

# ============================================
# 3. Create relative symlinks for heavy dirs
# ============================================
echo ""
echo "--- Creating symlinks ---"

REL_PATH=$(python3 -c "import os; print(os.path.relpath('${MAIN_REPO_ROOT}', '${WORKTREE_PATH}'))")

# node_modules is EXCLUDED for pnpm monorepos — pnpm uses relative symlinks
# internally that break when the workspace root changes. Use pnpm install instead.
if [[ "$PM" == "pnpm" ]]; then
    SYMLINK_DIRS=(".next/cache" "vendor" "target" ".venv")
    echo "  (node_modules excluded — pnpm install will handle it)"
else
    SYMLINK_DIRS=("node_modules" ".next/cache" "vendor" "target" ".venv")
fi

for dir in "${SYMLINK_DIRS[@]}"; do
    src="${MAIN_REPO_ROOT}/${dir}"
    dest="${WORKTREE_PATH}/${dir}"

    if [[ -d "$src" ]]; then
        if [[ -L "$dest" ]]; then
            echo "  Symlink exists: ${dir} (skipped)"
        elif [[ -d "$dest" ]]; then
            echo "  Directory exists: ${dir} (skipped, not overwriting)"
        else
            mkdir -p "$(dirname "$dest")"
            ln -s "${REL_PATH}/${dir}" "$dest"
            echo "  Linked: ${dir} → ${REL_PATH}/${dir}"
        fi
    fi
done

# ============================================
# 4. Install dependencies
# ============================================
echo ""
echo "--- Installing dependencies ---"

if [[ -n "$PM" ]] && [[ -f "${WORKTREE_PATH}/package.json" ]]; then
    if [[ -d "${WORKTREE_PATH}/node_modules" ]] || [[ -L "${WORKTREE_PATH}/node_modules" ]]; then
        echo "  node_modules exists (skipped)"
    else
        echo "  Running ${PM} install --frozen-lockfile..."
        cd "$WORKTREE_PATH"
        case "$PM" in
            pnpm)  pnpm install --frozen-lockfile 2>&1 | tail -5 ;;
            bun)   bun install --frozen-lockfile 2>&1 | tail -5 ;;
            yarn)  yarn install --frozen-lockfile 2>&1 | tail -5 ;;
            npm)   npm ci 2>&1 | tail -5 ;;
        esac
        echo "  ✓ Dependencies installed"
    fi
elif [[ -f "${WORKTREE_PATH}/pyproject.toml" ]]; then
    echo "  Python project — run 'uv sync' or 'pip install -e .' manually"
elif [[ -f "${WORKTREE_PATH}/go.mod" ]]; then
    echo "  Go project — run 'go mod download' if needed"
elif [[ -f "${WORKTREE_PATH}/Cargo.toml" ]]; then
    echo "  Rust project — cargo builds on demand"
else
    echo "  No package manager detected (skipped)"
fi

# ============================================
# 5. Port allocation (deterministic from task_id)
# ============================================
echo ""
echo "--- Port allocation ---"

# Generate deterministic port
HASH=$(echo -n "$TASK_ID" | cksum | awk '{print $1}')
PORT_OFFSET=$(( (HASH % 900) + 100 ))
PORT=$(( 3000 + PORT_OFFSET ))  # Range: 3100-3999

# Check if port is already in use, bump if needed
ATTEMPTS=0
while lsof -iTCP:"$PORT" -sTCP:LISTEN &>/dev/null && [[ $ATTEMPTS -lt 10 ]]; do
    PORT=$(( PORT + 1 ))
    ATTEMPTS=$(( ATTEMPTS + 1 ))
done

# For monorepos: write PORT + NEXT_PUBLIC_SITE_URL to the app's .env.local
# This is where Next.js actually reads env vars from (not root .env.local)
if [[ "$IS_MONOREPO" == true ]] && [[ -d "${WORKTREE_PATH}/apps/web" ]]; then
    APP_ENV_LOCAL="${WORKTREE_PATH}/apps/web/.env.local"

    if grep -q "^PORT=" "$APP_ENV_LOCAL" 2>/dev/null; then
        EXISTING_PORT=$(grep "^PORT=" "$APP_ENV_LOCAL" | head -1 | cut -d= -f2)
        echo "  PORT=${EXISTING_PORT} already set in apps/web/.env.local (skipped)"
        PORT="$EXISTING_PORT"
    else
        # Append port config to apps/web/.env.local
        echo "" >> "$APP_ENV_LOCAL"
        echo "# APEX worktree — auto-generated port (task: ${TASK_ID})" >> "$APP_ENV_LOCAL"
        echo "PORT=${PORT}" >> "$APP_ENV_LOCAL"
        echo "NEXT_PUBLIC_SITE_URL=http://localhost:${PORT}" >> "$APP_ENV_LOCAL"
        echo "  apps/web/.env.local → PORT=${PORT}"
        echo "  apps/web/.env.local → NEXT_PUBLIC_SITE_URL=http://localhost:${PORT}"
    fi

    # Also update NEXT_PUBLIC_SITE_URL if it was already in the file (from copy step)
    if grep -q "^NEXT_PUBLIC_SITE_URL=http://localhost:" "$APP_ENV_LOCAL" 2>/dev/null; then
        sed -i '' "s|^NEXT_PUBLIC_SITE_URL=http://localhost:[0-9]*|NEXT_PUBLIC_SITE_URL=http://localhost:${PORT}|" "$APP_ENV_LOCAL"
    fi
else
    # Non-monorepo: write to root .env.local
    ENV_LOCAL="${WORKTREE_PATH}/.env.local"
    if grep -q "^PORT=" "$ENV_LOCAL" 2>/dev/null; then
        EXISTING_PORT=$(grep "^PORT=" "$ENV_LOCAL" | head -1 | cut -d= -f2)
        echo "  PORT=${EXISTING_PORT} already set in .env.local (skipped)"
        PORT="$EXISTING_PORT"
    else
        echo "" >> "$ENV_LOCAL"
        echo "# APEX worktree port (auto-generated from task: ${TASK_ID})" >> "$ENV_LOCAL"
        echo "PORT=${PORT}" >> "$ENV_LOCAL"
        echo "  PORT=${PORT} → http://localhost:${PORT}"
    fi
fi

# ============================================
# 6. Monorepo dev command
# ============================================
if [[ "$IS_MONOREPO" == true ]]; then
    echo ""
    echo "--- Dev server ---"

    MAIN_APP=""
    if [[ -f "${WORKTREE_PATH}/apps/web/package.json" ]]; then
        MAIN_APP=$(cd "$WORKTREE_PATH" && node -e "console.log(require('./apps/web/package.json').name)" 2>/dev/null || echo "web")
    fi

    if [[ -n "$MAIN_APP" ]]; then
        echo ""
        echo "  To start dev server in this worktree:"
        echo ""
        echo "    PORT=${PORT} pnpm --filter ${MAIN_APP} dev"
        echo ""
        echo "  Or with transitive deps (slower, for full-stack testing):"
        echo ""
        echo "    PORT=${PORT} pnpm turbo dev --filter=${MAIN_APP}..."
        echo ""
        echo "  ⚠ NEVER use bare 'pnpm dev' → launches ALL packages"
    fi
fi

echo ""
echo "✓ Worktree environment ready"
exit 0
