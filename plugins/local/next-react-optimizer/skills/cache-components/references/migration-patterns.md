# Cache Components Migration Patterns

## Complete Migration Guide

### From Next.js 14/15 to Next.js 16 Cache Components

#### Step 1: Enable Cache Components

```typescript
// next.config.ts
const config: NextConfig = {
  experimental: {
    cacheComponents: true,
  },
}
```

#### Step 2: Remove Old Caching Exports

Search for and remove these deprecated patterns:

```bash
# Find old patterns
grep -r "fetchCache" app/
grep -r "export const dynamic" app/
grep -r "export const revalidate" app/
```

#### Step 3: Add use cache Directives

Replace old patterns with explicit caching:

| Old Pattern | New Pattern |
|-------------|-------------|
| `export const fetchCache = 'force-cache'` | `'use cache'` at file/function level |
| `export const dynamic = 'force-static'` | `'use cache'` at file level |
| `export const revalidate = N` | `cacheLife({ revalidate: N })` |
| `export const dynamic = 'force-dynamic'` | Remove (default behavior) |
| `fetch(..., { cache: 'force-cache' })` | Wrap in `'use cache'` function |
| `fetch(..., { next: { revalidate: N } })` | `cacheLife({ revalidate: N })` |

## Pattern-by-Pattern Migration

### Static Page Migration

```typescript
// BEFORE: Next.js 14/15
export const dynamic = 'force-static'

export default async function StaticPage() {
  const data = await fetch('https://api.example.com/static-data')
  return <div>{JSON.stringify(data)}</div>
}
```

```typescript
// AFTER: Next.js 16
'use cache'

export default async function StaticPage() {
  const data = await fetch('https://api.example.com/static-data')
  return <div>{JSON.stringify(data)}</div>
}
```

### ISR (Incremental Static Regeneration) Migration

```typescript
// BEFORE: Next.js 14/15
export const revalidate = 3600 // Revalidate every hour

export default async function ISRPage() {
  const posts = await fetch('https://api.example.com/posts')
  return <PostList posts={posts} />
}
```

```typescript
// AFTER: Next.js 16
import { cacheLife } from 'next/cache'

export default async function ISRPage() {
  'use cache'
  cacheLife({ revalidate: 3600 })
  const posts = await fetch('https://api.example.com/posts')
  return <PostList posts={posts} />
}
```

### On-Demand Revalidation Migration

```typescript
// BEFORE: Next.js 14/15 (API route)
import { revalidateTag, revalidatePath } from 'next/cache'

export async function POST() {
  revalidateTag('posts')
  revalidatePath('/blog')
  return Response.json({ revalidated: true })
}
```

```typescript
// AFTER: Next.js 16 (Server Action)
'use server'
import { updateTag } from 'next/cache'

export async function revalidatePosts() {
  updateTag('posts')
  // Note: revalidatePath still works for path-based invalidation
}
```

### Fetch with Cache Migration

```typescript
// BEFORE: Next.js 14/15
async function getData() {
  const res = await fetch('https://api.example.com/data', {
    cache: 'force-cache',
    next: { revalidate: 300, tags: ['data'] }
  })
  return res.json()
}
```

```typescript
// AFTER: Next.js 16
import { cacheLife, cacheTag } from 'next/cache'

async function getData() {
  'use cache'
  cacheTag('data')
  cacheLife({ revalidate: 300 })
  const res = await fetch('https://api.example.com/data')
  return res.json()
}
```

### generateStaticParams Migration

```typescript
// BEFORE: Next.js 14/15 - implicit static generation
export async function generateStaticParams() {
  const posts = await fetch('https://api.example.com/posts')
  return posts.map(post => ({ slug: post.slug }))
}

export default async function PostPage({ params }) {
  const post = await fetch(`https://api.example.com/posts/${params.slug}`)
  return <Article post={post} />
}
```

```typescript
// AFTER: Next.js 16 - explicit caching
import { cacheTag, cacheLife } from 'next/cache'

export async function generateStaticParams() {
  'use cache'
  cacheLife('days')
  const posts = await fetch('https://api.example.com/posts')
  return posts.map(post => ({ slug: post.slug }))
}

export default async function PostPage({ params }: { params: Promise<{ slug: string }> }) {
  'use cache'
  const { slug } = await params
  cacheTag(`post-${slug}`)
  const post = await fetch(`https://api.example.com/posts/${slug}`)
  return <Article post={post} />
}
```

## Handling Runtime APIs

### cookies() / headers() Pattern

```typescript
// BEFORE: Could sometimes work with caching
export default async function Page() {
  const session = cookies().get('session')
  // ...caching behavior was implicit
}
```

```typescript
// AFTER: Explicit separation
import { cookies } from 'next/headers'

export default async function Page() {
  // Read runtime data OUTSIDE cache scope
  const sessionCookie = await cookies()
  const sessionId = sessionCookie.get('session')?.value

  // Pass to cached component
  return <CachedPageContent sessionId={sessionId} />
}

async function CachedPageContent({ sessionId }: { sessionId?: string }) {
  'use cache'
  // sessionId becomes part of cache key
  // Different sessionId = different cache entry
  const userData = sessionId
    ? await fetchUserData(sessionId)
    : null
  return <div>{/* ... */}</div>
}
```

### searchParams Pattern

```typescript
// BEFORE: searchParams often broke caching
export default async function SearchPage({ searchParams }) {
  const query = searchParams.q
  const results = await search(query)
  return <SearchResults results={results} />
}
```

```typescript
// AFTER: Explicit handling
export default async function SearchPage({
  searchParams
}: {
  searchParams: Promise<{ q?: string }>
}) {
  const { q } = await searchParams
  return <CachedSearchResults query={q || ''} />
}

async function CachedSearchResults({ query }: { query: string }) {
  'use cache'
  cacheTag(`search-${query}`)
  cacheLife('minutes') // Short cache for search results
  const results = await search(query)
  return <SearchResults results={results} />
}
```

## Mixed Static/Dynamic Pages

```typescript
// Page with both cached and dynamic sections
import { Suspense } from 'react'
import { cookies } from 'next/headers'

export default async function DashboardPage() {
  // Read dynamic data at page level
  const session = await cookies()
  const userId = session.get('userId')?.value

  return (
    <main>
      {/* Static cached header */}
      <CachedNavigation />

      {/* Dynamic user-specific content */}
      <Suspense fallback={<DashboardSkeleton />}>
        <DynamicDashboard userId={userId} />
      </Suspense>

      {/* Static cached footer */}
      <CachedFooter />
    </main>
  )
}

async function CachedNavigation() {
  'use cache'
  cacheLife('days')
  const navItems = await fetchNavigation()
  return <nav>{/* ... */}</nav>
}

// No 'use cache' - runs at request time
async function DynamicDashboard({ userId }: { userId?: string }) {
  if (!userId) return <LoginPrompt />
  const dashboardData = await fetchDashboard(userId)
  return <Dashboard data={dashboardData} />
}

async function CachedFooter() {
  'use cache'
  cacheLife('days')
  return <footer>{/* ... */}</footer>
}
```

## Automated Migration Script

For large codebases, consider this migration approach:

```bash
# 1. Find all files with old patterns
grep -rl "export const fetchCache" app/ > migration-files.txt
grep -rl "export const dynamic.*force-static" app/ >> migration-files.txt
grep -rl "export const revalidate" app/ >> migration-files.txt

# 2. Review each file and apply appropriate pattern
# 3. Test thoroughly - caching behavior has fundamentally changed

# 4. Validate no old patterns remain
grep -r "fetchCache\|force-static\|export const revalidate" app/
```

## Testing Migration

After migration, verify caching behavior:

1. **Development**: Check console for cache hits/misses
2. **Build**: `next build` should show correct static/dynamic routes
3. **Production**: Monitor cache headers and response times
4. **Invalidation**: Test that `updateTag()` correctly invalidates cached data
