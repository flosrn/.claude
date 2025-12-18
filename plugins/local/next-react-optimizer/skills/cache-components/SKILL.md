---
name: cache-components
description: This skill should be used when the user asks about "use cache", "cache components", "cacheLife", "cacheTag", "Next.js caching", "opt-in caching", "use cache remote", "use cache private", "cache invalidation", or mentions migrating from fetchCache, force-static, or revalidate patterns. Provides Next.js 16 Cache Components guidance.
---

# Next.js 16 Cache Components

Cache Components provide explicit, opt-in caching in Next.js 16. Unlike previous implicit caching, all dynamic code executes at request time by default unless explicitly cached with `"use cache"`.

## Core Concept

Add `"use cache"` directive to mark routes, components, or functions as cacheable:

```typescript
// File-level: cache entire file's exports
'use cache'

export default async function Page() {
  const data = await fetch('/api/data')
  return <div>{data}</div>
}
```

```typescript
// Component-level: cache specific component
export async function ProductList() {
  'use cache'
  const products = await db.query('SELECT * FROM products')
  return <ul>{products.map(p => <li key={p.id}>{p.name}</li>)}</ul>
}
```

```typescript
// Function-level: cache utility function
export async function getProducts() {
  'use cache'
  return await db.query('SELECT * FROM products')
}
```

## Enable Cache Components

In `next.config.ts`:

```typescript
const config: NextConfig = {
  experimental: {
    cacheComponents: true, // Required for 'use cache'
  },
}
```

## Cache Profiles

### Default (`use cache`)

Standard in-memory cache, checked at request time:

```typescript
async function getData() {
  'use cache'
  return await fetch('/api/data')
}
```

### Remote (`use cache: remote`)

Distributed cache across servers, requires network roundtrip:

```typescript
async function getAnalytics() {
  'use cache: remote'
  cacheLife({ expire: 300 }) // 5 minutes
  return await fetchAnalyticsData()
}
```

### Private (`use cache: private`)

For compliance requirements or when runtime data cannot be refactored:

```typescript
async function getUserData() {
  'use cache: private'
  // Handles cases where runtime APIs must be accessed
  return await fetchUserSpecificData()
}
```

## Cache Duration with cacheLife

Control how long cached data remains valid:

```typescript
import { cacheLife } from 'next/cache'

async function getProducts() {
  'use cache'
  cacheLife({
    stale: 60,      // Serve stale for 60s while revalidating
    revalidate: 300, // Revalidate after 5 minutes
    expire: 3600,   // Hard expire after 1 hour
  })
  return await db.query('SELECT * FROM products')
}
```

Shorthand profiles:

```typescript
cacheLife('minutes')  // Short-lived cache
cacheLife('hours')    // Medium-lived cache
cacheLife('days')     // Long-lived cache
cacheLife('max')      // Maximum cache duration
```

## Cache Invalidation with cacheTag

Tag cached data for targeted invalidation:

```typescript
import { cacheTag } from 'next/cache'

async function getProducts() {
  'use cache'
  cacheTag('products')
  return await db.query('SELECT * FROM products')
}

async function getProduct(id: string) {
  'use cache'
  cacheTag('products', `product-${id}`)
  return await db.query('SELECT * FROM products WHERE id = $1', [id])
}
```

Invalidate with Server Action:

```typescript
'use server'
import { updateTag } from 'next/cache'

export async function updateProduct(id: string, data: ProductData) {
  await db.update('products', id, data)
  updateTag('products')           // Invalidate all products
  updateTag(`product-${id}`)      // Invalidate specific product
}
```

## Migration from Old Patterns

### fetchCache → use cache

```typescript
// Before (Next.js 14/15)
export const fetchCache = 'force-cache'

export default async function Page() {
  const data = await fetch('https://api.example.com/data')
  return <div>{data}</div>
}

// After (Next.js 16)
export default async function Page() {
  'use cache'
  const data = await fetch('https://api.example.com/data')
  return <div>{data}</div>
}
```

### force-static → use cache

```typescript
// Before
export const dynamic = 'force-static'

// After
'use cache'
```

### revalidate → cacheLife

```typescript
// Before
export const revalidate = 3600

// After
import { cacheLife } from 'next/cache'

export default async function Page() {
  'use cache'
  cacheLife({ revalidate: 3600 })
  // ...
}
```

## Critical Rules

### No Runtime APIs Inside Cache

Cached scopes cannot use `cookies()`, `headers()`, or `searchParams`:

```typescript
// WRONG - will error
export default async function Page() {
  'use cache'
  const session = await cookies() // Error!
  return <div>...</div>
}

// CORRECT - read outside, pass as argument
export default async function Page() {
  const session = await cookies()
  return <CachedContent sessionId={session.get('id')} />
}

async function CachedContent({ sessionId }: { sessionId: string }) {
  'use cache'
  // sessionId becomes part of cache key
  return <div>...</div>
}
```

### Suspense for Uncached Dynamic Components

Components without `use cache` that access dynamic data must be wrapped in Suspense:

```typescript
import { Suspense } from 'react'

export default async function Page() {
  'use cache'
  return (
    <main>
      <CachedHeader />
      <Suspense fallback={<Loading />}>
        <DynamicContent /> {/* No 'use cache', uses runtime APIs */}
      </Suspense>
    </main>
  )
}
```

## Partial Pre-Rendering (PPR)

Cache Components complete the PPR story. Pre-render static shell, stream dynamic parts:

```typescript
// page.tsx
'use cache'

export default async function Page() {
  return (
    <main>
      <Header />  {/* Cached in static shell */}
      <Suspense fallback={<ProductsSkeleton />}>
        <DynamicProducts /> {/* Streamed at request time */}
      </Suspense>
    </main>
  )
}
```

## Fetching Latest Documentation

For the most up-to-date Cache Components documentation, use Context7 MCP:

```
mcp__context7__resolve-library-id: Next.js
mcp__context7__get-library-docs: /vercel/next.js/v16.0.3, topic: "use cache"
```

## Reference Files

For detailed patterns and migration guides:
- **`references/migration-patterns.md`** - Complete migration examples
- **`references/cache-strategies.md`** - Advanced caching strategies
