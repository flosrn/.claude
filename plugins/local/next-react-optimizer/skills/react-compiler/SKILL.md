---
name: react-compiler
description: This skill should be used when the user asks about "React Compiler", "automatic memoization", "remove useMemo", "remove useCallback", "memo optimization", "React 19 compiler", "babel-plugin-react-compiler", "CannotPreserveMemoization", or discusses reducing re-renders automatically. Provides React 19 Compiler guidance.
---

# React 19 Compiler (React Compiler v1.0)

React Compiler is a build-time tool that automatically optimizes React components through memoization. Released as stable in October 2025, it eliminates the need for manual `useMemo`, `useCallback`, and `memo` in most cases.

## Core Concept

React Compiler analyzes components at build time and automatically:
- Skips unnecessary re-renders
- Memoizes expensive calculations
- Stabilizes function references

Write idiomatic React without manual optimization:

```typescript
// Before: Manual memoization
function ProductList({ products, onSelect }: Props) {
  const sortedProducts = useMemo(
    () => products.sort((a, b) => a.price - b.price),
    [products]
  )

  const handleClick = useCallback(
    (id: string) => onSelect(id),
    [onSelect]
  )

  return (
    <ul>
      {sortedProducts.map(p => (
        <ProductItem key={p.id} product={p} onClick={handleClick} />
      ))}
    </ul>
  )
}

// After: Let Compiler handle it
function ProductList({ products, onSelect }: Props) {
  const sortedProducts = products.sort((a, b) => a.price - b.price)

  const handleClick = (id: string) => onSelect(id)

  return (
    <ul>
      {sortedProducts.map(p => (
        <ProductItem key={p.id} product={p} onClick={handleClick} />
      ))}
    </ul>
  )
}
```

## Enabling React Compiler

### Next.js 16+

```typescript
// next.config.ts
const config: NextConfig = {
  experimental: {
    reactCompiler: true,
  },
}
```

### Babel Plugin (Manual Setup)

```bash
npm install babel-plugin-react-compiler
```

```javascript
// babel.config.js
module.exports = {
  plugins: [
    ['babel-plugin-react-compiler', {
      // Optional configuration
    }],
  ],
}
```

### Expo SDK 54+

Enabled by default in new Expo projects.

### Vite

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    react({
      babel: {
        plugins: ['babel-plugin-react-compiler'],
      },
    }),
  ],
})
```

## What Gets Optimized

### Automatic Memoization

```typescript
function Dashboard({ data }) {
  // Compiler memoizes this computation
  const processed = data.map(item => ({
    ...item,
    label: formatLabel(item.name),
  }))

  // Compiler stabilizes this callback
  const handleRefresh = () => {
    fetchData()
  }

  // Compiler memoizes this JSX
  return (
    <div>
      <Button onClick={handleRefresh}>Refresh</Button>
      <DataGrid items={processed} />
    </div>
  )
}
```

### Conditional Memoization

Compiler can memoize conditionally - something impossible with manual hooks:

```typescript
function ConditionalComponent({ showDetails, data }) {
  // Compiler only computes when needed
  if (showDetails) {
    const details = computeExpensiveDetails(data)
    return <Details data={details} />
  }

  return <Summary data={data} />
}
```

## When to Keep Manual Memoization

### Rule: Don't Remove Existing Memoization

The compiler respects existing `useMemo`/`useCallback`. Removing them can change output:

```typescript
// KEEP existing memoization - removing may change behavior
const memoizedValue = useMemo(() => expensiveComputation(a, b), [a, b])
```

### Keep Manual Memoization When

1. **Referential equality is critical** (e.g., effect dependencies)
2. **Custom comparison logic needed** (complex objects)
3. **Third-party library expects stable references**
4. **Performance-critical hot paths** with measured need

### Safe to Remove

1. **Simple inline calculations**
2. **Event handlers passed to native elements**
3. **Values only used in render output**

## CannotPreserveMemoization Errors

When the compiler cannot optimize existing manual memoization:

```typescript
// This will show CannotPreserveMemoization error
function Problem({ items }) {
  const x = []
  useHook()
  x.push(items) // Mutation after hook

  // Compiler can't preserve this memoization
  return useCallback(() => [x], [x])
}
```

### Common Causes

1. **Dependency mismatch** - Inferred deps don't match manual deps
2. **Mutation after hooks** - Array/object mutation between hooks
3. **Aliased variables** - Using aliased values in dependency arrays
4. **Conditional memoization** - Memoization inside conditions

### Fixing CannotPreserveMemoization

```typescript
// BEFORE: Error - aliased dependency
function useHook(x) {
  const aliasedX = x
  return useCallback(() => [aliasedX], [x]) // Mismatch!
}

// AFTER: Fixed - use same reference
function useHook(x) {
  return useCallback(() => [x], [x])
}
```

## Performance Results

Real-world improvements:
- **Meta Quest Store**: 12% faster initial loads, 2.5x faster interactions
- **General applications**: 25-40% fewer re-renders without code changes
- **Memory**: Neutral - optimizations don't increase memory usage

## Best Practices

### Do

```typescript
// Write idiomatic React
function Component({ data }) {
  const processed = data.filter(item => item.active)
  const handleClick = () => console.log('clicked')

  return <List items={processed} onClick={handleClick} />
}
```

### Don't

```typescript
// Don't prematurely optimize
function Component({ data }) {
  // Unnecessary - compiler handles this
  const processed = useMemo(() => data.filter(item => item.active), [data])
  const handleClick = useCallback(() => console.log('clicked'), [])

  return <List items={processed} onClick={handleClick} />
}
```

### Migration Strategy

1. **Enable compiler** in `next.config.ts` or Babel
2. **Keep existing memoization** initially
3. **Monitor performance** with React DevTools
4. **Gradually remove manual memoization** where safe
5. **Test thoroughly** - behavior should be identical

## Compatibility

- **React versions**: 17, 18, 19
- **Frameworks**: Next.js, Expo, Vite, custom Babel setups
- **TypeScript**: Full support
- **Server Components**: Not applicable (no client-side rendering)

## Debugging

### React DevTools

Shows which components are re-rendering and why.

### Compiler Logs

Enable verbose logging:

```javascript
// babel.config.js
plugins: [
  ['babel-plugin-react-compiler', {
    logger: {
      logEvent: (filename, event) => {
        console.log(`[Compiler] ${filename}:`, event)
      },
    },
  }],
]
```

## Fetching Latest Documentation

For up-to-date React Compiler docs, use Context7 MCP:

```
mcp__context7__resolve-library-id: React
mcp__context7__get-library-docs: /facebook/react/v19_1_1, topic: "compiler"
```

## Reference Files

For detailed patterns:
- **`references/migration-guide.md`** - Step-by-step migration from manual memoization
- **`references/error-patterns.md`** - Common errors and solutions
