---
name: migrate-caching
description: Migrate from old Next.js caching patterns to Next.js 16 Cache Components
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
argument-hint: [--dry-run]
---

# Cache Components Migration Command

Migrate from legacy Next.js caching patterns to Next.js 16 Cache Components.

## What Gets Migrated

| Old Pattern | New Pattern |
|-------------|-------------|
| `export const fetchCache = 'force-cache'` | `'use cache'` |
| `export const dynamic = 'force-static'` | `'use cache'` |
| `export const revalidate = N` | `cacheLife({ revalidate: N })` |
| `fetch(..., { cache: 'force-cache' })` | `'use cache'` on function |
| `fetch(..., { next: { revalidate: N } })` | `cacheLife({ revalidate: N })` |

## Execution

### Step 1: Check Prerequisites

```bash
# Verify Next.js 16+
cat package.json | grep '"next"'

# Check if cacheComponents enabled
grep "cacheComponents" next.config.* 2>/dev/null
```

If cacheComponents not enabled, prompt user to enable it first:

```typescript
// next.config.ts - Required configuration
const config: NextConfig = {
  experimental: {
    cacheComponents: true,
  },
}
```

### Step 2: Find All Old Patterns

```bash
# fetchCache patterns
grep -rn "export const fetchCache" app/ --include="*.tsx" --include="*.ts"

# force-static patterns
grep -rn "export const dynamic.*=.*'force-static'" app/ --include="*.tsx" --include="*.ts"

# revalidate exports
grep -rn "export const revalidate" app/ --include="*.tsx" --include="*.ts"

# fetch with cache options
grep -rn "fetch.*cache.*force-cache\|fetch.*next.*revalidate" app/ --include="*.tsx" --include="*.ts"
```

### Step 3: Dry Run Mode

If `--dry-run` argument provided, show what would change without modifying files:

```
## Migration Preview (Dry Run)

### Files to be modified:

1. **app/products/page.tsx**
   - Remove: `export const fetchCache = 'force-cache'`
   - Add: `'use cache'` at top of default export

2. **app/api/data/route.ts**
   - Remove: `export const revalidate = 3600`
   - Add: `import { cacheLife } from 'next/cache'`
   - Add: `cacheLife({ revalidate: 3600 })` in function

Total: N files would be modified
```

### Step 4: Execute Migration (if not dry-run)

For each file with old patterns:

#### Pattern A: fetchCache Migration

Read the file, then use Edit tool:

```typescript
// BEFORE
export const fetchCache = 'force-cache'

export default async function Page() {
  const data = await fetch('/api/data')
  return <div>{data}</div>
}
```

```typescript
// AFTER
export default async function Page() {
  'use cache'
  const data = await fetch('/api/data')
  return <div>{data}</div>
}
```

#### Pattern B: force-static Migration

```typescript
// BEFORE
export const dynamic = 'force-static'

export default async function Page() {
  // ...
}
```

```typescript
// AFTER
export default async function Page() {
  'use cache'
  // ...
}
```

#### Pattern C: revalidate Migration

```typescript
// BEFORE
export const revalidate = 3600

export default async function Page() {
  // ...
}
```

```typescript
// AFTER
import { cacheLife } from 'next/cache'

export default async function Page() {
  'use cache'
  cacheLife({ revalidate: 3600 })
  // ...
}
```

#### Pattern D: fetch Options Migration

```typescript
// BEFORE
async function getData() {
  const res = await fetch('/api/data', {
    cache: 'force-cache',
    next: { revalidate: 300, tags: ['data'] }
  })
  return res.json()
}
```

```typescript
// AFTER
import { cacheLife, cacheTag } from 'next/cache'

async function getData() {
  'use cache'
  cacheTag('data')
  cacheLife({ revalidate: 300 })
  const res = await fetch('/api/data')
  return res.json()
}
```

### Step 5: Handle Runtime API Issues

After migration, check for runtime API usage inside cached scopes:

```bash
# Find cookies/headers usage
grep -rn "cookies()\|headers()" app/ --include="*.tsx" --include="*.ts"
```

If found in files with `'use cache'`, warn user:

```
## Warning: Runtime APIs in Cached Scope

The following files have runtime APIs that won't work inside 'use cache':

- app/dashboard/page.tsx:15 - cookies()
- app/profile/page.tsx:8 - headers()

These need manual refactoring to:
1. Read runtime data OUTSIDE the cached function
2. Pass as props to cached component
```

### Step 6: Verify Migration

```bash
# Check for remaining old patterns
grep -rn "fetchCache\|force-static\|export const revalidate" app/ --include="*.tsx" --include="*.ts"

# Run typecheck
pnpm typecheck 2>&1 | head -50
```

### Step 7: Generate Report

```
## Cache Components Migration Complete

**Files Modified**: N
**Patterns Migrated**: M

### Changes Made

| File | Change |
|------|--------|
| app/page.tsx | fetchCache → 'use cache' |
| app/products/page.tsx | revalidate → cacheLife |
| ... | ... |

### Manual Review Required

| File | Issue |
|------|-------|
| app/dashboard/page.tsx | cookies() inside cached scope |

### Next Steps

1. Review files with runtime API warnings
2. Run `pnpm build` to verify
3. Test caching behavior in development
4. Consider adding cacheTag for invalidation
```

## Safety Notes

- Always backup files before migration (or ensure git is clean)
- Test thoroughly after migration - caching behavior fundamentally changes
- Some patterns may need manual intervention
- Use `--dry-run` first to preview changes
