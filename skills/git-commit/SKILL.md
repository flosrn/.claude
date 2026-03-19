---
name: commit
description: Quick commit and push with conventional messages, branch safety, and secret detection
model: haiku
allowed-tools: Bash(git *), AskUserQuestion
---

# Commit & Push

Analyze changes, commit with conventional message, push.

## Workflow

### 0. Find git repo

```bash
git rev-parse --git-dir 2>/dev/null
```

- If in a git repo → continue to step 1
- If NOT in a git repo → scan subdirectories for repos with dirty state:
  ```bash
  for dir in */; do git -C "$dir" status --porcelain=v1 2>/dev/null | grep -q . && echo "$dir"; done
  ```
  - **Exactly one dirty repo** → `cd` into it, continue
  - **Multiple dirty repos** → you MUST call the AskUserQuestion tool (not just print text) to ask the user which repo(s) to commit. Provide each repo name as an option plus "all". Then `cd` into the selected repo and continue. If "all", process each repo sequentially.
  - **No dirty repos** → inform user, **stop**

### 1. Assess state

```bash
git branch --show-current
git status --porcelain=v1
git diff --stat
git diff --cached --stat
git log --oneline -3
```

- Nothing to commit → inform user, **stop**

### 2. Stage files

- Stage files **explicitly by name** — never `git add -A` or `git add .`
- **Skip secret files**: `.env`, `.env.*`, `credentials.*`, `*.key`, `*.pem`, `*.secret`
- If secret files detected, warn user and skip them

### 3. Commit

Generate one concise conventional commit message:

- Format: `type(scope): imperative summary` — under 72 chars
- Types: `feat`, `fix`, `update`, `docs`, `chore`, `refactor`, `test`, `perf`, `revert`
- Imperative mood, lowercase after colon
- Match style of recent commits from `git log`

```bash
git commit -m "$(cat <<'EOF'
type(scope): message here
EOF
)"
```

### 4. Push

```bash
# Set upstream if needed
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || git push -u origin $(git branch --show-current)
# Otherwise
git push
```

## Rules

- SPEED OVER PERFECTION: one good message, commit, done
- NO INTERACTION: never ask questions — EXCEPT when multiple repos have changes (use the AskUserQuestion tool)
- NEVER force push
- NEVER stage secrets
- Report: commit hash, message, push status
