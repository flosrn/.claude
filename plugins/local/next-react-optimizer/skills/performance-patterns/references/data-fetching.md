# Data Fetching Strategies

## Fetching Location Comparison

| Location | When to Use | Pros | Cons |
|----------|-------------|------|------|
| Server Component | Most cases | No client bundle, secure | No interactivity |
| Route Handler | API endpoints | Full control, cacheable | Extra hop |
| Server Action | Mutations | Progressive enhancement | POST only |
| Client (SWR/RQ) | Real-time data | Reactive, offline | Bundle size |

## Server Component Fetching

### Direct Database Access

```typescript
// app/products/page.tsx
import { db } from '@/lib/db'

async function ProductsPage() {
  const products = await db.query('SELECT * FROM products WHERE active = true')

  return <ProductList products={products} />
}
```

### API Fetching

```typescript
async function ProductsPage() {
  const res = await fetch('https://api.example.com/products', {
    // Next.js extends fetch with caching options
    next: { revalidate: 3600 } // Revalidate every hour
  })

  if (!res.ok) throw new Error('Failed to fetch')

  const products = await res.json()
  return <ProductList products={products} />
}
```

## Parallel Data Fetching

### Promise.all Pattern

```typescript
async function DashboardPage() {
  // All fetches start simultaneously
  const [user, stats, notifications, recentOrders] = await Promise.all([
    fetchUser(),
    fetchStats(),
    fetchNotifications(),
    fetchRecentOrders(),
  ])

  return (
    <Dashboard
      user={user}
      stats={stats}
      notifications={notifications}
      orders={recentOrders}
    />
  )
}
```

### Component-Level Parallel

```typescript
// Each component fetches independently and streams when ready
export default function DashboardPage() {
  return (
    <div>
      <Suspense fallback={<UserSkeleton />}>
        <UserWidget /> {/* fetchUser() inside */}
      </Suspense>

      <Suspense fallback={<StatsSkeleton />}>
        <StatsWidget /> {/* fetchStats() inside */}
      </Suspense>

      <Suspense fallback={<NotificationsSkeleton />}>
        <NotificationsWidget /> {/* fetchNotifications() inside */}
      </Suspense>
    </div>
  )
}
```

## Sequential Data Fetching

When data depends on previous results:

```typescript
async function OrderDetailsPage({
  params
}: {
  params: Promise<{ orderId: string }>
}) {
  const { orderId } = await params

  // Sequential - customer depends on order
  const order = await fetchOrder(orderId)
  const customer = await fetchCustomer(order.customerId)
  const orderHistory = await fetchCustomerOrders(customer.id)

  return (
    <OrderDetails
      order={order}
      customer={customer}
      history={orderHistory}
    />
  )
}
```

### Optimize with Partial Parallelization

```typescript
async function OrderDetailsPage({ params }: Props) {
  const { orderId } = await params

  // First fetch is required
  const order = await fetchOrder(orderId)

  // These can be parallel since they only need order data
  const [customer, relatedProducts] = await Promise.all([
    fetchCustomer(order.customerId),
    fetchRelatedProducts(order.productIds),
  ])

  // This needs customer
  const orderHistory = await fetchCustomerOrders(customer.id)

  return <OrderDetails order={order} customer={customer} history={orderHistory} />
}
```

## Preloading Data

### Link Prefetching

```typescript
// Next.js automatically prefetches linked routes
<Link href="/products">Products</Link>

// Disable prefetch for heavy pages
<Link href="/heavy-page" prefetch={false}>Heavy Page</Link>
```

### Manual Preloading

```typescript
'use client'

import { preload } from 'react'

function ProductCard({ productId }: { productId: string }) {
  const handleMouseEnter = () => {
    // Preload product details before click
    preload(`/api/products/${productId}`, { as: 'fetch' })
  }

  return (
    <Link
      href={`/products/${productId}`}
      onMouseEnter={handleMouseEnter}
    >
      View Product
    </Link>
  )
}
```

## Caching Strategies

### Static Data

```typescript
// Cached at build time
async function getStaticData() {
  const res = await fetch('https://api.example.com/static', {
    cache: 'force-cache' // Default in Next.js
  })
  return res.json()
}
```

### Revalidated Data

```typescript
// Revalidate every hour
async function getRevalidatedData() {
  const res = await fetch('https://api.example.com/data', {
    next: { revalidate: 3600 }
  })
  return res.json()
}
```

### Dynamic Data

```typescript
// Never cache
async function getDynamicData() {
  const res = await fetch('https://api.example.com/realtime', {
    cache: 'no-store'
  })
  return res.json()
}
```

### With Cache Components (Next.js 16)

```typescript
import { cacheLife, cacheTag } from 'next/cache'

async function getProducts() {
  'use cache'
  cacheTag('products')
  cacheLife({ revalidate: 3600 })

  const products = await db.query('SELECT * FROM products')
  return products
}
```

## Error Handling

### Try-Catch Pattern

```typescript
async function ProductsPage() {
  try {
    const products = await fetchProducts()
    return <ProductList products={products} />
  } catch (error) {
    // Log error server-side
    console.error('Failed to fetch products:', error)
    // Return fallback UI
    return <ProductsError />
  }
}
```

### Error Boundary Integration

```typescript
// error.tsx - catches errors in segment
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  )
}
```

## Real-time Data with Server Actions

```typescript
// Server Action for mutations
'use server'

import { revalidatePath } from 'next/cache'

export async function updateProduct(formData: FormData) {
  const id = formData.get('id')
  const name = formData.get('name')

  await db.update('products', id, { name })

  // Revalidate affected pages
  revalidatePath('/products')
  revalidatePath(`/products/${id}`)
}
```

## Client-Side Fetching (When Needed)

Use for truly real-time data or interactive features:

```typescript
'use client'

import useSWR from 'swr'

const fetcher = (url: string) => fetch(url).then(r => r.json())

function LiveStockPrice({ symbol }: { symbol: string }) {
  const { data, error, isLoading } = useSWR(
    `/api/stocks/${symbol}`,
    fetcher,
    { refreshInterval: 1000 } // Poll every second
  )

  if (isLoading) return <Skeleton />
  if (error) return <Error />

  return <Price value={data.price} />
}
```
