---
name: health
description: Run comprehensive health checks on Makerkit project (typecheck, lint, syncpack, dependencies)
allowed-tools: Bash, Read
argument-hint: [--fix]
---

# Makerkit Health Check Command

Run comprehensive health checks on the current Makerkit project.

## Checks Performed

1. **TypeScript Compilation**
   - `pnpm typecheck`

2. **ESLint**
   - `pnpm lint` (or `pnpm lint:fix` with --fix)

3. **Syncpack (Version Alignment)**
   - `pnpm syncpack:list`

4. **Dependency Audit**
   - Check for outdated packages
   - Verify peer dependencies

## Usage

```
/makerkit:health
```

With auto-fix:
```
/makerkit:health --fix
```

## Execution

### Step 1: Detect Project

```bash
pwd
cat package.json | grep '"name"' | head -1
```

### Step 2: TypeScript Check

```bash
echo "=== TypeScript Check ==="
pnpm typecheck 2>&1
TS_EXIT=$?
```

### Step 3: Lint Check

If `--fix` argument provided:
```bash
echo "=== Lint Check (with fix) ==="
pnpm lint:fix 2>&1
```

Otherwise:
```bash
echo "=== Lint Check ==="
pnpm lint 2>&1
```

### Step 4: Syncpack Check

```bash
echo "=== Syncpack (Version Alignment) ==="
pnpm syncpack:list 2>&1
```

If `--fix` and issues found:
```bash
pnpm syncpack:fix
```

### Step 5: Summary

Report results in this format:

```
## Health Check Results

**Project**: [name]
**Date**: YYYY-MM-DD

| Check | Status | Details |
|-------|--------|---------|
| TypeScript | PASS/FAIL | X errors |
| Lint | PASS/FAIL | X warnings, Y errors |
| Syncpack | PASS/FAIL | X mismatches |

### Issues Found
[List any issues that need attention]

### Recommendations
[Suggestions for fixing issues]
```
