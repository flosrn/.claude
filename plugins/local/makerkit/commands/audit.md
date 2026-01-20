---
name: audit
description: Audit dependencies, custom packages, and added libraries compared to upstream Makerkit
allowed-tools: Bash, Read, Glob, Grep
---

# Dependency Audit Command

Audit the project's dependencies and track customizations compared to upstream Makerkit.

## Audit Categories

1. **Custom Packages** - Packages you've added that don't exist in upstream
2. **Modified Packages** - Upstream packages you've customized
3. **Added Libraries** - npm dependencies not in upstream Makerkit
4. **Version Mismatches** - Syncpack discrepancies across monorepo

## Usage

```
/makerkit:audit
```

## Execution

### Step 1: Detect Project

```bash
pwd
PROJECT_NAME=$(cat package.json | grep '"name"' | head -1 | sed 's/.*: "\(.*\)".*/\1/')
echo "Project: $PROJECT_NAME"
```

### Step 2: Check Upstream Remote

```bash
git remote -v | grep upstream
```

### Step 3: List Custom Packages

```bash
echo "=== Custom Packages (not in upstream) ==="
# List all packages
ls -d packages/*/ 2>/dev/null || echo "No packages dir"
ls -d packages/features/*/ 2>/dev/null || echo "No features dir"
```

Compare against upstream:
```bash
# Fetch upstream package list
git ls-tree -r --name-only upstream/main | grep "^packages/" | cut -d'/' -f1-2 | sort -u
```

### Step 4: Check Added Libraries

Compare root package.json dependencies:
```bash
echo "=== Root Dependencies ==="
cat package.json | jq '.dependencies, .devDependencies'
```

```bash
echo "=== Upstream Root Dependencies ==="
git show upstream/main:package.json | jq '.dependencies, .devDependencies'
```

### Step 5: Syncpack Analysis

```bash
echo "=== Version Mismatches ==="
pnpm syncpack:list 2>&1
```

### Step 6: Generate Report

Produce a report in this format:

```
## Dependency Audit Report

**Project**: [name]
**Date**: YYYY-MM-DD
**Upstream**: makerkit/next-supabase-turbo

---

### Custom Packages (not in upstream)

| Package | Description |
|---------|-------------|
| packages/features/games | Gapila-specific game logic |
| packages/mcp-server | Custom MCP server |

### Modified Packages (customized from upstream)

| Package | Changes |
|---------|---------|
| apps/web/app/home | Custom dashboard |

### Added Libraries (not in upstream)

| Library | Version | Location | Purpose |
|---------|---------|----------|---------|
| drizzle-orm | X.X.X | packages/supabase | ORM |
| @tanstack/react-query | X.X.X | apps/web | Data fetching |

### Removed Libraries (in upstream but not here)

| Library | Upstream Version | Reason |
|---------|-----------------|--------|
| example-lib | X.X.X | Not needed |

### Version Mismatches (syncpack)

| Package | Versions Found | Recommended |
|---------|---------------|-------------|
| typescript | 5.0.0, 5.1.0 | 5.1.0 |

---

### Recommendations

1. Run `pnpm syncpack:fix` to align versions
2. Document custom packages in CUSTOM_PACKAGES.md
3. Consider upstreaming reusable features
```

## Settings Integration

If `.claude/makerkit.local.md` exists, read it for known custom packages:

```bash
cat .claude/makerkit.local.md 2>/dev/null
```

This file should list:
- Known custom packages
- Known modified packages
- Intentionally added libraries
