---
name: analyze
description: Analyze Next.js/React code for optimization opportunities (caching, components, bundle size)
allowed-tools: Bash, Read, Glob, Grep
argument-hint: [file-path|directory]
---

# Optimization Analysis Command

Analyze code for Next.js 16 and React 19 optimization opportunities.

## Analysis Areas

1. **Cache Components** - Missing `use cache`, old caching patterns
2. **React Compiler** - Manual memoization that can be removed
3. **Server/Client Components** - Incorrect `use client` placement
4. **Code Splitting** - Barrel file issues, missing dynamic imports
5. **Data Fetching** - Sequential waterfalls, missing Suspense

## Execution

### Step 1: Determine Scope

If argument provided, analyze that path. Otherwise, analyze `app/` and `src/` directories.

```bash
# Check what directories exist
ls -la app/ src/ 2>/dev/null || ls -la
```

### Step 2: Check Project Configuration

```bash
# Check Next.js version
cat package.json | grep '"next"'

# Check if Cache Components enabled
grep -l "cacheComponents" next.config.* 2>/dev/null || echo "cacheComponents not configured"

# Check if React Compiler enabled
grep -l "reactCompiler" next.config.* 2>/dev/null || echo "reactCompiler not configured"
```

### Step 3: Find Old Caching Patterns

Search for deprecated caching patterns:

```bash
# Old fetchCache pattern
grep -rn "fetchCache" app/ src/ --include="*.tsx" --include="*.ts" 2>/dev/null

# Old dynamic export
grep -rn "export const dynamic.*=.*'force" app/ src/ --include="*.tsx" --include="*.ts" 2>/dev/null

# Old revalidate export
grep -rn "export const revalidate" app/ src/ --include="*.tsx" --include="*.ts" 2>/dev/null
```

### Step 4: Find Manual Memoization

Search for potential React Compiler optimizations:

```bash
# useMemo usage
grep -rn "useMemo" app/ src/ components/ --include="*.tsx" --include="*.ts" 2>/dev/null | wc -l

# useCallback usage
grep -rn "useCallback" app/ src/ components/ --include="*.tsx" --include="*.ts" 2>/dev/null | wc -l

# memo() usage
grep -rn "memo(" app/ src/ components/ --include="*.tsx" --include="*.ts" 2>/dev/null | wc -l
```

### Step 5: Analyze Client Component Usage

```bash
# Count use client directives
grep -rn "^'use client'" app/ src/ components/ --include="*.tsx" 2>/dev/null | wc -l

# Find large client components (check file sizes)
find app/ src/ components/ -name "*.tsx" -exec grep -l "'use client'" {} \; 2>/dev/null | head -10
```

### Step 6: Check Barrel Files

```bash
# Find barrel files
find . -name "index.ts" -o -name "index.tsx" 2>/dev/null | grep -v node_modules | head -20

# Check for re-exports
grep -l "export \* from\|export {" */index.ts 2>/dev/null | head -10
```

### Step 7: Check Bundle Configuration

```bash
# Check for optimizePackageImports
grep -A10 "optimizePackageImports" next.config.* 2>/dev/null || echo "No optimizePackageImports configured"
```

### Step 8: Generate Report

Create a summary report in this format:

```
## Optimization Analysis Report

**Project**: [name from package.json]
**Next.js Version**: [version]
**Date**: YYYY-MM-DD

### Configuration Status

| Feature | Status | Action |
|---------|--------|--------|
| cacheComponents | Enabled/Disabled | Enable for Next.js 16 caching |
| reactCompiler | Enabled/Disabled | Enable for auto-memoization |
| optimizePackageImports | Configured/Missing | Add common packages |

### Old Caching Patterns Found

| File | Line | Pattern | Replacement |
|------|------|---------|-------------|
| app/page.tsx | 5 | fetchCache | Use 'use cache' directive |
| ... | ... | ... | ... |

### Manual Memoization Stats

- useMemo: X instances
- useCallback: Y instances
- memo(): Z instances

**Recommendation**: With React Compiler enabled, review these for potential removal.

### Client Component Analysis

- Total 'use client' files: N
- Potential optimization: [list files that could be Server Components]

### Bundle Optimization

- Barrel files found: N
- Missing from optimizePackageImports: [list packages]

### Priority Actions

1. [Highest impact action]
2. [Second priority]
3. [Third priority]
```

## Context7 Integration

For detailed documentation on any finding, fetch from Context7:

```
mcp__context7__get-library-docs: /vercel/next.js/v16.0.3, topic: "[relevant topic]"
```

## Notes

- Read files to understand context before making recommendations
- Prioritize high-impact changes (large files, frequently used components)
- Consider backward compatibility when suggesting migrations
