---
name: diff
description: Show differences between current project and upstream Makerkit repository
allowed-tools: Bash, Read
argument-hint: [path]
---

# Upstream Diff Command

Show differences between your project and the upstream Makerkit repository.

## Usage

Show all differences:
```
/makerkit:diff
```

Show differences in specific path:
```
/makerkit:diff apps/web
```

## Execution

### Step 1: Verify Upstream Remote

```bash
git remote -v | grep upstream
```

If not configured:
```bash
echo "Upstream not configured. Run:"
echo "git remote add upstream https://github.com/makerkit/next-supabase-turbo.git"
echo "git fetch upstream"
```

### Step 2: Fetch Latest Upstream

```bash
git fetch upstream
```

### Step 3: Show Commit Difference

```bash
echo "=== Commits Behind Upstream ==="
git log --oneline HEAD..upstream/main | head -20

echo ""
echo "=== Commits Ahead of Upstream ==="
git log --oneline upstream/main..HEAD | head -20
```

### Step 4: Show File Differences

If a path argument is provided, diff that path:
```bash
git diff upstream/main -- <path>
```

Otherwise, show summary:
```bash
echo "=== Files Changed from Upstream ==="
git diff --stat upstream/main | tail -30
```

### Step 5: Categorize Changes

```bash
echo "=== Modified Files ==="
git diff --name-status upstream/main | grep "^M" | head -20

echo ""
echo "=== Added Files (local only) ==="
git diff --name-status upstream/main | grep "^A" | head -20

echo ""
echo "=== Deleted Files (removed from upstream) ==="
git diff --name-status upstream/main | grep "^D" | head -20
```

## Output Format

```
## Upstream Diff Report

**Project**: [name]
**Upstream**: upstream/main
**Date**: YYYY-MM-DD

### Summary
- **Behind upstream**: X commits
- **Ahead of upstream**: Y commits
- **Files changed**: Z

### Commits Behind Upstream
Recent upstream commits not yet merged:
- `abc1234` feat: new feature
- `def5678` fix: bug fix
...

### Commits Ahead (Local Only)
Your commits not in upstream:
- `111aaaa` feat: custom feature
- `222bbbb` fix: local fix
...

### File Changes

| Status | Count |
|--------|-------|
| Modified | X |
| Added | Y |
| Deleted | Z |

### Key Differences

**Modified Packages:**
- apps/web/package.json
- packages/ui/package.json

**Custom Code:**
- apps/web/app/custom/
- packages/features/games/

### Recommendation

[Based on the diff, suggest whether an update is needed]
- If behind by significant commits: "Consider running /makerkit:update"
- If mostly custom code: "Changes are primarily local customizations"
```
