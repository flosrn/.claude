# Advanced Dynamic Import Patterns

## next/dynamic Options

### Full API

```typescript
import dynamic from 'next/dynamic'

const Component = dynamic(
  () => import('./component'),
  {
    loading: () => <Skeleton />,  // Fallback while loading
    ssr: true,                     // Enable/disable SSR (default: true)
  }
)
```

## Pattern: Conditional Loading

### Based on User Role

```typescript
import dynamic from 'next/dynamic'

const AdminPanel = dynamic(() => import('./admin-panel'))
const UserPanel = dynamic(() => import('./user-panel'))

function Dashboard({ user }) {
  const Panel = user.role === 'admin' ? AdminPanel : UserPanel
  return <Panel />
}
```

### Based on Feature Flag

```typescript
const NewFeature = dynamic(() => import('./new-feature'))
const LegacyFeature = dynamic(() => import('./legacy-feature'))

function Feature({ flags }) {
  const Component = flags.newFeature ? NewFeature : LegacyFeature
  return <Component />
}
```

## Pattern: Intersection Observer Loading

Load component when it enters viewport:

```typescript
'use client'

import dynamic from 'next/dynamic'
import { useInView } from 'react-intersection-observer'

const HeavyComponent = dynamic(() => import('./heavy-component'), {
  loading: () => <HeavySkeleton />,
})

function LazySection() {
  const { ref, inView } = useInView({
    triggerOnce: true,
    threshold: 0.1,
  })

  return (
    <div ref={ref}>
      {inView ? <HeavyComponent /> : <HeavySkeleton />}
    </div>
  )
}
```

## Pattern: Named Exports

When module has named exports:

```typescript
// heavy-module.ts
export function HeavyChart() { ... }
export function HeavyTable() { ... }
```

```typescript
// Import specific named export
const HeavyChart = dynamic(
  () => import('./heavy-module').then(mod => mod.HeavyChart)
)

const HeavyTable = dynamic(
  () => import('./heavy-module').then(mod => mod.HeavyTable)
)
```

## Pattern: With Custom Loading

### Skeleton Matching Component

```typescript
const DataGrid = dynamic(() => import('./data-grid'), {
  loading: () => (
    <div className="animate-pulse">
      <div className="h-10 bg-gray-200 mb-2" /> {/* Header */}
      {[...Array(5)].map((_, i) => (
        <div key={i} className="h-8 bg-gray-100 mb-1" />
      ))}
    </div>
  ),
})
```

### Progress Indicator

```typescript
'use client'

import { useState, useEffect } from 'react'

function LoadingWithProgress() {
  const [progress, setProgress] = useState(0)

  useEffect(() => {
    const interval = setInterval(() => {
      setProgress(p => Math.min(p + 10, 90))
    }, 100)
    return () => clearInterval(interval)
  }, [])

  return (
    <div>
      <progress value={progress} max={100} />
      <span>{progress}% Loading...</span>
    </div>
  )
}

const HeavyComponent = dynamic(() => import('./heavy'), {
  loading: LoadingWithProgress,
})
```

## Pattern: Prefetching

### On Hover Prefetch

```typescript
'use client'

import dynamic from 'next/dynamic'
import { useState } from 'react'

// Define dynamic import
const Modal = dynamic(() => import('./modal'))

// Get the import function for prefetching
const prefetchModal = () => import('./modal')

function Button() {
  const [showModal, setShowModal] = useState(false)

  return (
    <>
      <button
        onMouseEnter={prefetchModal}  // Start loading on hover
        onClick={() => setShowModal(true)}
      >
        Open Modal
      </button>
      {showModal && <Modal onClose={() => setShowModal(false)} />}
    </>
  )
}
```

### On Route Change Prefetch

```typescript
'use client'

import { useRouter } from 'next/navigation'
import { useEffect } from 'react'

// Prefetch heavy components when navigating to their routes
function usePrefetch() {
  const router = useRouter()

  useEffect(() => {
    // When on products page, prefetch product detail components
    router.prefetch('/products/[id]')

    // Prefetch heavy component modules
    import('./product-detail-view')
    import('./product-reviews')
  }, [router])
}
```

## Pattern: Error Handling

```typescript
'use client'

import dynamic from 'next/dynamic'
import { ErrorBoundary } from 'react-error-boundary'

const RiskyComponent = dynamic(() => import('./risky'), {
  loading: () => <Skeleton />,
})

function ErrorFallback({ error, resetErrorBoundary }) {
  return (
    <div role="alert">
      <p>Failed to load component:</p>
      <pre>{error.message}</pre>
      <button onClick={resetErrorBoundary}>Retry</button>
    </div>
  )
}

function SafeRiskyComponent() {
  return (
    <ErrorBoundary FallbackComponent={ErrorFallback}>
      <RiskyComponent />
    </ErrorBoundary>
  )
}
```

## Pattern: SSR Disabled for Browser APIs

```typescript
// Map requires browser APIs
const MapComponent = dynamic(() => import('./map'), {
  ssr: false,
  loading: () => <MapPlaceholder />,
})

// Canvas/WebGL component
const ThreeScene = dynamic(() => import('./three-scene'), {
  ssr: false,
})

// Window/Document dependent
const WindowSizeDisplay = dynamic(() => import('./window-size'), {
  ssr: false,
})
```

## Pattern: Chunking Strategy

### Vendor Chunk

```typescript
// next.config.ts
const config: NextConfig = {
  webpack: (config) => {
    config.optimization.splitChunks = {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          chunks: 'all',
        },
        charts: {
          test: /[\\/]node_modules[\\/](chart\.js|recharts)[\\/]/,
          name: 'charts',
          chunks: 'all',
          priority: 10,
        },
      },
    }
    return config
  },
}
```

## Pattern: Module Federation (Advanced)

Share components across microfrontends:

```typescript
// next.config.ts
const { NextFederationPlugin } = require('@module-federation/nextjs-mf')

const config: NextConfig = {
  webpack: (config, { isServer }) => {
    config.plugins.push(
      new NextFederationPlugin({
        name: 'app1',
        filename: 'static/chunks/remoteEntry.js',
        exposes: {
          './Button': './components/Button',
        },
        shared: {
          react: { singleton: true },
          'react-dom': { singleton: true },
        },
      })
    )
    return config
  },
}
```

## Testing Dynamic Imports

```typescript
// __tests__/dynamic-component.test.tsx
import { render, waitFor } from '@testing-library/react'

// Mock the dynamic import
jest.mock('next/dynamic', () => ({
  __esModule: true,
  default: (loader) => {
    const Component = require('./heavy-component').default
    return Component
  },
}))

test('loads component', async () => {
  const { getByText } = render(<PageWithDynamicComponent />)

  await waitFor(() => {
    expect(getByText('Heavy Component Content')).toBeInTheDocument()
  })
})
```

## Performance Monitoring

```typescript
'use client'

import dynamic from 'next/dynamic'
import { Suspense, useEffect } from 'react'

// Track load time
function withLoadTracking<P extends object>(
  importFn: () => Promise<{ default: React.ComponentType<P> }>,
  name: string
) {
  return dynamic(() => {
    const start = performance.now()
    return importFn().then((mod) => {
      const duration = performance.now() - start
      console.log(`[Dynamic] ${name} loaded in ${duration.toFixed(2)}ms`)
      // Send to analytics
      // analytics.track('component_load', { name, duration })
      return mod
    })
  })
}

const HeavyChart = withLoadTracking(
  () => import('./heavy-chart'),
  'HeavyChart'
)
```
