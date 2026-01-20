---
name: code-splitting
description: This skill should be used when the user asks about "code splitting", "dynamic imports", "next/dynamic", "lazy loading", "barrel files", "optimizePackageImports", "modularizeImports", "bundle size", "tree shaking", "reduce bundle", "import optimization", or discusses JavaScript bundle optimization strategies.
---

# Code Splitting & Bundle Optimization

## Core Concept

Code splitting reduces initial bundle size by loading code only when needed. Next.js automatically splits by route, but additional optimization improves performance.

## Dynamic Imports with next/dynamic

Load components only when needed:

```typescript
import dynamic from 'next/dynamic'

// Basic dynamic import
const HeavyChart = dynamic(() => import('@/components/heavy-chart'))

// With loading state
const HeavyChart = dynamic(() => import('@/components/heavy-chart'), {
  loading: () => <ChartSkeleton />,
})

// Disable SSR for browser-only components
const MapComponent = dynamic(() => import('@/components/map'), {
  ssr: false,
  loading: () => <MapPlaceholder />,
})
```

## When to Use Dynamic Imports

| Use Dynamic Import | Don't Use Dynamic Import |
|--------------------|--------------------------|
| Heavy third-party libs (charts, editors) | Small UI components |
| Conditionally rendered modals | Above-the-fold content |
| Device-specific components | Critical path components |
| Authentication-gated features | Components under 10KB |
| Locale-specific layouts | Frequently used components |

## Barrel File Problem

Barrel files (`index.ts` re-exporting) can bloat bundles:

```typescript
// components/index.ts (BARREL FILE)
export { Button } from './button'
export { Modal } from './modal'
export { Chart } from './chart'  // 200KB
export { Editor } from './editor'  // 500KB

// Using barrel file imports EVERYTHING
import { Button } from '@/components'  // Imports Chart + Editor too!
```

### Solution 1: Direct Imports

```typescript
// GOOD: Import directly
import { Button } from '@/components/button'
import { Modal } from '@/components/modal'

// BAD: Import from barrel
import { Button, Modal } from '@/components'
```

### Solution 2: optimizePackageImports

Next.js 13.5+ auto-optimizes configured packages:

```typescript
// next.config.ts
const config: NextConfig = {
  experimental: {
    optimizePackageImports: [
      'lucide-react',
      '@radix-ui/react-icons',
      '@phosphor-icons/react',
      '@mantine/core',
      '@heroicons/react',
      'date-fns',
      'lodash',
    ],
  },
}
```

With this config, barrel imports are automatically optimized:

```typescript
// This now only imports what's used
import { Search, Menu, X } from 'lucide-react'
```

### Solution 3: modularizeImports (Legacy)

For packages not supported by optimizePackageImports:

```typescript
// next.config.ts
const config: NextConfig = {
  modularizeImports: {
    'my-large-library': {
      transform: 'my-large-library/dist/{{member}}',
    },
  },
}
```

## Tree Shaking Configuration

### Ensure ESM Output

```json
// package.json
{
  "type": "module",
  "sideEffects": false
}
```

### tsconfig for Tree Shaking

```json
{
  "compilerOptions": {
    "module": "ESNext",
    "moduleResolution": "bundler"
  }
}
```

## Bundle Analysis

### Enable Bundle Analyzer

```bash
npm install @next/bundle-analyzer
```

```typescript
// next.config.ts
import bundleAnalyzer from '@next/bundle-analyzer'

const withBundleAnalyzer = bundleAnalyzer({
  enabled: process.env.ANALYZE === 'true',
})

export default withBundleAnalyzer(config)
```

```bash
# Run analysis
ANALYZE=true npm run build
```

### Key Metrics to Watch

- **First Load JS**: Should be under 100KB for fast pages
- **Largest chunks**: Identify candidates for splitting
- **Duplicate modules**: Should be deduplicated
- **Unused exports**: Should be tree-shaken

## Common Optimization Patterns

### Pattern 1: Modal/Dialog Lazy Loading

```typescript
import dynamic from 'next/dynamic'
import { useState } from 'react'

const SettingsModal = dynamic(() => import('./settings-modal'))

function Header() {
  const [showSettings, setShowSettings] = useState(false)

  return (
    <>
      <button onClick={() => setShowSettings(true)}>Settings</button>
      {showSettings && (
        <SettingsModal onClose={() => setShowSettings(false)} />
      )}
    </>
  )
}
```

### Pattern 2: Feature-Based Splitting

```typescript
// Only load admin features for admins
const AdminDashboard = dynamic(() => import('./admin-dashboard'), {
  loading: () => <AdminSkeleton />,
})

function Dashboard({ user }) {
  if (user.role === 'admin') {
    return <AdminDashboard />
  }
  return <UserDashboard />
}
```

### Pattern 3: Below-Fold Content

```typescript
import dynamic from 'next/dynamic'

// Lazy load content that requires scroll to see
const Reviews = dynamic(() => import('./reviews'))
const RelatedProducts = dynamic(() => import('./related-products'))

function ProductPage({ product }) {
  return (
    <main>
      {/* Critical above-fold content - no dynamic */}
      <ProductHero product={product} />
      <ProductDetails product={product} />
      <AddToCartForm productId={product.id} />

      {/* Below fold - lazy loaded */}
      <Reviews productId={product.id} />
      <RelatedProducts categoryId={product.categoryId} />
    </main>
  )
}
```

### Pattern 4: Device-Specific Components

```typescript
import dynamic from 'next/dynamic'

const DesktopNav = dynamic(() => import('./desktop-nav'), {
  ssr: false,
})
const MobileNav = dynamic(() => import('./mobile-nav'), {
  ssr: false,
})

function Navigation() {
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    setIsMobile(window.innerWidth < 768)
  }, [])

  return isMobile ? <MobileNav /> : <DesktopNav />
}
```

## Third-Party Library Optimization

### Check Library Size

Use [bundlephobia.com](https://bundlephobia.com) before adding dependencies.

### Use Lightweight Alternatives

| Heavy Library | Lightweight Alternative |
|---------------|------------------------|
| moment.js (300KB) | date-fns (tree-shakeable) |
| lodash (70KB) | lodash-es or individual imports |
| Chart.js (200KB) | lightweight-charts |

### Import Only What's Needed

```typescript
// BAD: Imports entire library
import _ from 'lodash'
_.debounce(fn, 300)

// GOOD: Import specific function
import debounce from 'lodash/debounce'
debounce(fn, 300)
```

## Verification Checklist

After optimization:

- [ ] First Load JS reduced
- [ ] No barrel file full imports
- [ ] Heavy libs dynamically imported
- [ ] Tree shaking working (sideEffects: false)
- [ ] Bundle analyzer shows improvement
- [ ] Performance unchanged or improved

## Fetching Latest Documentation

For up-to-date patterns, use Context7 MCP:

```
mcp__context7__get-library-docs: /vercel/next.js/v16.0.3, topic: "dynamic import"
mcp__context7__get-library-docs: /vercel/next.js/v16.0.3, topic: "optimizePackageImports"
```

## Reference Files

- **`references/barrel-files.md`** - Barrel file issues and solutions
- **`references/dynamic-import-patterns.md`** - Advanced dynamic import patterns
