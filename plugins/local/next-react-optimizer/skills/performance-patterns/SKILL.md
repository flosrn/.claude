---
name: performance-patterns
description: This skill should be used when the user asks about "Server Components", "RSC", "Suspense boundaries", "streaming", "PPR", "Partial Prerendering", "lazy loading", "React performance", "reduce bundle size", "optimize rendering", "client components", "use client", or discusses improving React/Next.js application performance.
---

# Performance Patterns for Next.js 16 & React 19

## Server Components (RSC)

Server Components render on the server, sending only HTML to the client. They reduce bundle size and improve initial load.

### When to Use Server Components

| Scenario | Component Type |
|----------|----------------|
| Data fetching | Server |
| Database access | Server |
| Static content | Server |
| Sensitive operations | Server |
| Interactive UI | Client |
| Browser APIs | Client |
| Event handlers | Client |
| Hooks (useState, useEffect) | Client |

### Default: Server Components

In Next.js App Router, components are Server Components by default:

```typescript
// app/products/page.tsx - Server Component (default)
async function ProductsPage() {
  const products = await db.query('SELECT * FROM products')

  return (
    <main>
      <h1>Products</h1>
      <ProductList products={products} />
    </main>
  )
}
```

### Client Components

Add `'use client'` directive for interactive components:

```typescript
// components/add-to-cart-button.tsx
'use client'

import { useState } from 'react'

export function AddToCartButton({ productId }: { productId: string }) {
  const [loading, setLoading] = useState(false)

  const handleClick = async () => {
    setLoading(true)
    await addToCart(productId)
    setLoading(false)
  }

  return (
    <button onClick={handleClick} disabled={loading}>
      {loading ? 'Adding...' : 'Add to Cart'}
    </button>
  )
}
```

### Composition Pattern

Pass Server Components as children to Client Components:

```typescript
// Server Component
async function ProductPage() {
  const product = await fetchProduct()

  return (
    <ClientWrapper>
      {/* Server Component passed as child */}
      <ProductDetails product={product} />
    </ClientWrapper>
  )
}

// Client Component
'use client'
function ClientWrapper({ children }: { children: React.ReactNode }) {
  const [expanded, setExpanded] = useState(false)

  return (
    <div>
      <button onClick={() => setExpanded(!expanded)}>Toggle</button>
      {expanded && children}
    </div>
  )
}
```

## Suspense Boundaries

Suspense enables streaming by showing fallback UI while content loads.

### Basic Suspense

```typescript
import { Suspense } from 'react'

export default function Page() {
  return (
    <main>
      <h1>Dashboard</h1>

      <Suspense fallback={<StatsSkeleton />}>
        <Stats /> {/* Async component */}
      </Suspense>

      <Suspense fallback={<ChartSkeleton />}>
        <RevenueChart /> {/* Another async component */}
      </Suspense>
    </main>
  )
}
```

### Streaming with Suspense

Each Suspense boundary streams independently:

```typescript
export default async function Page() {
  return (
    <main>
      {/* Renders immediately */}
      <Header />

      {/* Streams when ready */}
      <Suspense fallback={<ProductsSkeleton />}>
        <ProductGrid />
      </Suspense>

      {/* Streams independently */}
      <Suspense fallback={<ReviewsSkeleton />}>
        <Reviews />
      </Suspense>

      {/* Renders immediately */}
      <Footer />
    </main>
  )
}
```

### Nested Suspense

Fine-grained loading states:

```typescript
<Suspense fallback={<DashboardSkeleton />}>
  <Dashboard>
    <Suspense fallback={<RecentActivitySkeleton />}>
      <RecentActivity />
    </Suspense>
    <Suspense fallback={<NotificationsSkeleton />}>
      <Notifications />
    </Suspense>
  </Dashboard>
</Suspense>
```

## Partial Prerendering (PPR)

PPR combines static and dynamic rendering in a single route.

### Enable PPR

```typescript
// next.config.ts
const config: NextConfig = {
  experimental: {
    ppr: true,
  },
}
```

### PPR Pattern

```typescript
// Static shell + dynamic content
export default async function Page() {
  return (
    <main>
      {/* Static - prerendered */}
      <StaticHeader />
      <StaticNavigation />

      {/* Dynamic - streamed at request time */}
      <Suspense fallback={<UserSkeleton />}>
        <DynamicUserSection />
      </Suspense>

      {/* Static - prerendered */}
      <StaticFooter />
    </main>
  )
}
```

## Loading States

### loading.tsx Convention

```typescript
// app/products/loading.tsx
export default function Loading() {
  return (
    <div className="animate-pulse">
      <div className="h-8 bg-gray-200 rounded w-1/4 mb-4" />
      <div className="grid grid-cols-3 gap-4">
        {[...Array(6)].map((_, i) => (
          <div key={i} className="h-48 bg-gray-200 rounded" />
        ))}
      </div>
    </div>
  )
}
```

### Instant Loading States

```typescript
// Combine loading.tsx with Suspense
export default function ProductsLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div>
      <ProductFilters />
      <Suspense fallback={<ProductGridSkeleton />}>
        {children}
      </Suspense>
    </div>
  )
}
```

## Lazy Loading Components

### next/dynamic

```typescript
import dynamic from 'next/dynamic'

// Lazy load heavy component
const HeavyChart = dynamic(() => import('@/components/heavy-chart'), {
  loading: () => <ChartSkeleton />,
})

// Disable SSR for browser-only components
const MapWithNoSSR = dynamic(() => import('@/components/map'), {
  ssr: false,
  loading: () => <MapPlaceholder />,
})
```

### React.lazy (Client Components)

```typescript
'use client'

import { lazy, Suspense } from 'react'

const LazyModal = lazy(() => import('./modal'))

function App() {
  const [showModal, setShowModal] = useState(false)

  return (
    <div>
      <button onClick={() => setShowModal(true)}>Open</button>
      {showModal && (
        <Suspense fallback={<ModalSkeleton />}>
          <LazyModal onClose={() => setShowModal(false)} />
        </Suspense>
      )}
    </div>
  )
}
```

## Data Fetching Patterns

### Parallel Data Fetching

```typescript
// GOOD: Parallel fetches
async function Page() {
  const [products, categories, user] = await Promise.all([
    fetchProducts(),
    fetchCategories(),
    fetchUser(),
  ])

  return <Dashboard products={products} categories={categories} user={user} />
}
```

### Sequential When Dependent

```typescript
// When data depends on previous result
async function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const product = await fetchProduct(id)
  const recommendations = await fetchRecommendations(product.categoryId)

  return <ProductPage product={product} recommendations={recommendations} />
}
```

### Preload Pattern

```typescript
import { preload } from 'react'

// Preload data before it's needed
function ProductLink({ id }: { id: string }) {
  return (
    <Link
      href={`/products/${id}`}
      onMouseEnter={() => preload(`/api/products/${id}`, { as: 'fetch' })}
    >
      View Product
    </Link>
  )
}
```

## Image Optimization

```typescript
import Image from 'next/image'

// Optimized image with priority for LCP
<Image
  src="/hero.jpg"
  alt="Hero image"
  width={1200}
  height={600}
  priority // Load immediately for above-fold images
  placeholder="blur"
  blurDataURL={blurData}
/>

// Lazy loaded images
<Image
  src="/product.jpg"
  alt="Product"
  width={400}
  height={400}
  loading="lazy" // Default for below-fold
/>
```

## Best Practices Summary

### Do

1. **Default to Server Components** - Only use Client when needed
2. **Use Suspense boundaries** - Enable streaming and better UX
3. **Parallel fetch data** - Use Promise.all when possible
4. **Lazy load heavy components** - Reduce initial bundle
5. **Optimize images** - Use next/image with priority for LCP
6. **Use PPR** - Combine static shell with dynamic content

### Don't

1. **Don't add 'use client' unnecessarily** - Increases bundle size
2. **Don't nest too many Suspense boundaries** - Creates jank
3. **Don't block on sequential fetches** - Parallelize when possible
4. **Don't load heavy components eagerly** - Use dynamic imports

## Fetching Latest Documentation

For up-to-date patterns, use Context7 MCP:

```
mcp__context7__get-library-docs: /vercel/next.js/v16.0.3, topic: "server components"
mcp__context7__get-library-docs: /vercel/next.js/v16.0.3, topic: "streaming"
```

## Reference Files

- **`references/streaming-patterns.md`** - Advanced streaming techniques
- **`references/data-fetching.md`** - Data fetching strategies
