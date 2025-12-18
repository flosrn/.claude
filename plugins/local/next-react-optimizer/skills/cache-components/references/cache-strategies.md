# Advanced Cache Strategies

## Cache Strategy Selection

### When to Use Each Profile

| Profile | Use Case | Latency | Consistency |
|---------|----------|---------|-------------|
| `'use cache'` | Most static content | Fast (in-memory) | High |
| `'use cache: remote'` | Shared across servers | Medium (network) | Medium |
| `'use cache: private'` | User-specific cached data | Variable | Low |

## Granular Caching Patterns

### Page-Level vs Component-Level

```typescript
// Page-level: Entire page cached as unit
'use cache'

export default async function ProductsPage() {
  const products = await fetchProducts()
  const categories = await fetchCategories()
  return (
    <main>
      <CategoryNav categories={categories} />
      <ProductGrid products={products} />
    </main>
  )
}
```

```typescript
// Component-level: Independent cache entries
export default async function ProductsPage() {
  return (
    <main>
      <CachedCategoryNav />
      <CachedProductGrid />
    </main>
  )
}

async function CachedCategoryNav() {
  'use cache'
  cacheLife('days') // Categories change rarely
  const categories = await fetchCategories()
  return <CategoryNav categories={categories} />
}

async function CachedProductGrid() {
  'use cache'
  cacheLife('hours') // Products update more often
  cacheTag('products')
  const products = await fetchProducts()
  return <ProductGrid products={products} />
}
```

### Function-Level Caching

Cache expensive computations or database queries:

```typescript
// Cache database queries
async function getProductWithRelations(id: string) {
  'use cache'
  cacheTag(`product-${id}`)

  const product = await db.query(`
    SELECT p.*, c.name as category_name
    FROM products p
    JOIN categories c ON p.category_id = c.id
    WHERE p.id = $1
  `, [id])

  return product
}

// Cache expensive computations
async function computeRecommendations(userId: string) {
  'use cache'
  cacheTag(`recommendations-${userId}`)
  cacheLife('hours')

  // Expensive ML-based recommendations
  const userHistory = await fetchUserHistory(userId)
  const recommendations = await mlModel.predict(userHistory)
  return recommendations
}
```

## Cache Key Management

### Props as Cache Keys

Serialized props become part of the cache key:

```typescript
// Different props = different cache entries
async function ProductCard({ productId }: { productId: string }) {
  'use cache'
  // Cache key includes productId
  const product = await fetchProduct(productId)
  return <Card>{product.name}</Card>
}

// Usage: Each productId has its own cache entry
<ProductCard productId="1" />  // Cache entry 1
<ProductCard productId="2" />  // Cache entry 2
```

### Controlling Cache Scope

```typescript
// Narrow scope: Cache per user
async function UserDashboard({ userId }: { userId: string }) {
  'use cache'
  cacheTag(`dashboard-${userId}`)
  // Each user has separate cache
  const data = await fetchDashboardData(userId)
  return <Dashboard data={data} />
}

// Wide scope: Shared cache
async function GlobalStats() {
  'use cache'
  cacheTag('global-stats')
  // Single cache entry shared by all users
  const stats = await fetchGlobalStats()
  return <Stats data={stats} />
}
```

## Cache Invalidation Strategies

### Tag-Based Invalidation

```typescript
// Hierarchical tagging
async function getCategory(slug: string) {
  'use cache'
  cacheTag('categories', `category-${slug}`)
  return await db.query('SELECT * FROM categories WHERE slug = $1', [slug])
}

// Invalidation options
async function updateCategory(slug: string, data: CategoryData) {
  await db.update('categories', slug, data)

  // Option 1: Invalidate specific category
  updateTag(`category-${slug}`)

  // Option 2: Invalidate all categories
  updateTag('categories')
}
```

### Time-Based Strategies

```typescript
// Short-lived: Frequently changing data
async function getLiveScores() {
  'use cache'
  cacheLife({
    stale: 5,       // Serve stale for 5s
    revalidate: 10, // Revalidate every 10s
    expire: 60,     // Hard expire after 1 min
  })
  return await fetchLiveScores()
}

// Long-lived: Rarely changing data
async function getSiteConfig() {
  'use cache'
  cacheLife({
    stale: 3600,      // Serve stale for 1 hour
    revalidate: 86400, // Revalidate daily
    expire: 604800,   // Expire after 1 week
  })
  return await fetchSiteConfig()
}
```

## Distributed Caching

### Remote Cache for Multi-Server

```typescript
async function getSharedAnalytics() {
  'use cache: remote'
  cacheLife({ expire: 300 })

  // Cached in distributed cache (e.g., Redis)
  // Shared across all server instances
  return await computeExpensiveAnalytics()
}
```

### Connection for Dynamic Context

```typescript
import { connection } from 'next/server'

async function MixedPage() {
  // Make context dynamic
  await connection()

  // This runs every request
  const realtimeData = await fetchRealtimeData()

  // This is still cached remotely
  const cachedAnalytics = await getCachedAnalytics()

  return (
    <div>
      <RealtimeWidget data={realtimeData} />
      <AnalyticsChart data={cachedAnalytics} />
    </div>
  )
}

async function getCachedAnalytics() {
  'use cache: remote'
  cacheLife({ expire: 300 })
  return await fetchAnalyticsData()
}
```

## Error Handling in Cached Functions

```typescript
async function getCriticalData() {
  'use cache'
  cacheTag('critical-data')

  try {
    const data = await fetchCriticalData()
    return { success: true, data }
  } catch (error) {
    // Log error but don't cache failures
    console.error('Failed to fetch critical data:', error)
    throw error // Prevents caching the error
  }
}
```

## Cache Warming

Pre-populate cache on deployment or schedule:

```typescript
// API route for cache warming
// app/api/warm-cache/route.ts
import { unstable_noStore } from 'next/cache'

export async function POST() {
  unstable_noStore() // Don't cache this route

  // Warm critical caches
  await Promise.all([
    warmProductCache(),
    warmCategoryCache(),
    warmConfigCache(),
  ])

  return Response.json({ warmed: true })
}

async function warmProductCache() {
  const products = await db.query('SELECT id FROM products LIMIT 100')
  await Promise.all(
    products.map(p => getProduct(p.id)) // Triggers cache population
  )
}
```

## Debugging Cache Behavior

### Development Logging

```typescript
async function getDebuggedData() {
  'use cache'

  if (process.env.NODE_ENV === 'development') {
    console.log('[CACHE] getDebuggedData called at', new Date().toISOString())
  }

  const data = await fetchData()

  if (process.env.NODE_ENV === 'development') {
    console.log('[CACHE] getDebuggedData returning', data.length, 'items')
  }

  return data
}
```

### Cache Headers in Response

Check response headers to verify caching:
- `X-Cache: HIT` - Served from cache
- `X-Cache: MISS` - Fresh data fetched
- `Cache-Control` - Cache directives
