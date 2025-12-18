# Advanced Streaming Patterns

## Streaming Architecture

### How Streaming Works in Next.js

1. Server renders static shell immediately
2. Suspense boundaries mark streaming points
3. Dynamic content streams as it becomes available
4. Client hydrates progressively

```
Request → [Static Shell] → Stream 1 → Stream 2 → ... → Complete
              ↓               ↓          ↓
           Render         Hydrate    Hydrate
```

## Strategic Suspense Placement

### Above-the-Fold Priority

```typescript
export default async function Page() {
  return (
    <>
      {/* NO Suspense - renders immediately */}
      <Header />
      <HeroSection />

      {/* Suspense for below-fold content */}
      <Suspense fallback={<ProductGridSkeleton />}>
        <ProductGrid />
      </Suspense>

      <Suspense fallback={<TestimonialsSkeleton />}>
        <Testimonials />
      </Suspense>
    </>
  )
}
```

### Independent vs Sequential Streaming

```typescript
// INDEPENDENT: Each streams separately
export default function Page() {
  return (
    <div className="grid grid-cols-2">
      <Suspense fallback={<LeftPanelSkeleton />}>
        <LeftPanel /> {/* May load second */}
      </Suspense>
      <Suspense fallback={<RightPanelSkeleton />}>
        <RightPanel /> {/* May load first */}
      </Suspense>
    </div>
  )
}

// SEQUENTIAL: Wait for outer before inner
export default function Page() {
  return (
    <Suspense fallback={<ContainerSkeleton />}>
      <Container>
        <Suspense fallback={<ContentSkeleton />}>
          <Content /> {/* Only loads after Container */}
        </Suspense>
      </Container>
    </Suspense>
  )
}
```

## Waterfall Prevention

### Problem: Sequential Waterfalls

```typescript
// BAD: Creates waterfall
async function Dashboard() {
  const user = await fetchUser()
  const stats = await fetchStats(user.id)  // Waits for user
  const notifications = await fetchNotifications(user.id)  // Waits for stats

  return <DashboardUI user={user} stats={stats} notifications={notifications} />
}
```

### Solution: Parallel with Suspense

```typescript
// GOOD: Parallel loading with independent Suspense
async function Dashboard() {
  return (
    <div>
      <Suspense fallback={<UserSkeleton />}>
        <UserSection />
      </Suspense>
      <Suspense fallback={<StatsSkeleton />}>
        <StatsSection />
      </Suspense>
      <Suspense fallback={<NotificationsSkeleton />}>
        <NotificationsSection />
      </Suspense>
    </div>
  )
}

// Each fetches independently
async function UserSection() {
  const user = await fetchUser()
  return <UserCard user={user} />
}

async function StatsSection() {
  const stats = await fetchStats()
  return <StatsGrid stats={stats} />
}
```

### Solution: Parallel Fetch with Promise.all

```typescript
// GOOD: Single component with parallel fetches
async function Dashboard() {
  const [user, stats, notifications] = await Promise.all([
    fetchUser(),
    fetchStats(),
    fetchNotifications(),
  ])

  return <DashboardUI user={user} stats={stats} notifications={notifications} />
}
```

## Streaming with Error Boundaries

```typescript
import { Suspense } from 'react'
import { ErrorBoundary } from 'react-error-boundary'

export default function Page() {
  return (
    <ErrorBoundary fallback={<GlobalError />}>
      <Header />

      <ErrorBoundary fallback={<ProductsError />}>
        <Suspense fallback={<ProductsSkeleton />}>
          <Products />
        </Suspense>
      </ErrorBoundary>

      <ErrorBoundary fallback={<ReviewsError />}>
        <Suspense fallback={<ReviewsSkeleton />}>
          <Reviews />
        </Suspense>
      </ErrorBoundary>
    </ErrorBoundary>
  )
}
```

## Streaming with Route Groups

### Shared Loading States

```
app/
├── (main)/
│   ├── layout.tsx      # Shared layout
│   ├── loading.tsx     # Shared loading state
│   ├── products/
│   │   └── page.tsx
│   └── categories/
│       └── page.tsx
```

### Route-Specific Loading

```
app/
├── products/
│   ├── loading.tsx     # Products-specific skeleton
│   └── page.tsx
├── orders/
│   ├── loading.tsx     # Orders-specific skeleton
│   └── page.tsx
```

## Out-of-Order Streaming

Components can stream in any order - whichever finishes first renders first:

```typescript
export default function Page() {
  return (
    <>
      {/* Slowest data - renders last */}
      <Suspense fallback={<AnalyticsSkeleton />}>
        <SlowAnalytics />  {/* 3s fetch */}
      </Suspense>

      {/* Medium speed - renders second */}
      <Suspense fallback={<ProductsSkeleton />}>
        <Products />  {/* 1s fetch */}
      </Suspense>

      {/* Fastest - renders first */}
      <Suspense fallback={<HeaderSkeleton />}>
        <DynamicHeader />  {/* 200ms fetch */}
      </Suspense>
    </>
  )
}
```

## Progressive Enhancement with Streaming

```typescript
// Enhance content as more data loads
export default function ProductPage({ productId }: Props) {
  return (
    <div>
      {/* Core content - immediate */}
      <Suspense fallback={<ProductBasicSkeleton />}>
        <ProductBasic id={productId} />
      </Suspense>

      {/* Enhanced content - streams later */}
      <Suspense fallback={<ReviewsSkeleton />}>
        <ProductReviews id={productId} />
      </Suspense>

      {/* Optional content - lowest priority */}
      <Suspense fallback={<SimilarProductsSkeleton />}>
        <SimilarProducts id={productId} />
      </Suspense>
    </div>
  )
}
```

## Streaming Performance Tips

1. **Place Suspense boundaries strategically** - Not too many, not too few
2. **Keep fallbacks lightweight** - Heavy fallbacks defeat the purpose
3. **Prioritize above-fold content** - No Suspense for critical path
4. **Use route-level loading.tsx** - Automatic Suspense for pages
5. **Monitor Time to First Byte (TTFB)** - Streaming should improve this
6. **Test with slow network** - Use Chrome DevTools throttling
