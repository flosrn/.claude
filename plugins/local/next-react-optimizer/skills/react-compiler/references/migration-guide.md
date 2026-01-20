# React Compiler Migration Guide

## Step-by-Step Migration

### Phase 1: Enable Compiler

Enable React Compiler without removing any existing memoization:

```typescript
// next.config.ts
const config: NextConfig = {
  experimental: {
    reactCompiler: true,
  },
}
```

### Phase 2: Validate Behavior

Run tests and manually verify behavior is unchanged:

```bash
# Run existing tests
npm test

# Build and check for compiler warnings
npm run build 2>&1 | grep -i "compiler"
```

### Phase 3: Audit Existing Memoization

Find all manual memoization in the codebase:

```bash
# Find useMemo usage
grep -rn "useMemo" src/ --include="*.tsx" --include="*.ts"

# Find useCallback usage
grep -rn "useCallback" src/ --include="*.tsx" --include="*.ts"

# Find memo() usage
grep -rn "memo(" src/ --include="*.tsx" --include="*.ts"
```

### Phase 4: Categorize Each Instance

For each found instance, categorize:

| Category | Action | Example |
|----------|--------|---------|
| **Simple computation** | Safe to remove | `useMemo(() => items.filter(...), [items])` |
| **Event handler** | Safe to remove | `useCallback(() => onClick(id), [onClick, id])` |
| **Effect dependency** | Keep | `useMemo` whose value is in `useEffect` deps |
| **Referential equality** | Keep | Passed to `memo()` component checking equality |
| **Third-party lib** | Test first | Values passed to external libraries |

### Phase 5: Gradual Removal

Remove memoization in small batches, testing after each:

```typescript
// BEFORE
function ProductList({ products, onSelect }) {
  const sorted = useMemo(
    () => [...products].sort((a, b) => a.name.localeCompare(b.name)),
    [products]
  )

  const handleClick = useCallback(
    (id) => onSelect(id),
    [onSelect]
  )

  return (
    <ul>
      {sorted.map(p => (
        <ProductItem
          key={p.id}
          product={p}
          onClick={() => handleClick(p.id)}
        />
      ))}
    </ul>
  )
}
```

```typescript
// AFTER (if safe)
function ProductList({ products, onSelect }) {
  const sorted = [...products].sort((a, b) => a.name.localeCompare(b.name))

  return (
    <ul>
      {sorted.map(p => (
        <ProductItem
          key={p.id}
          product={p}
          onClick={() => onSelect(p.id)}
        />
      ))}
    </ul>
  )
}
```

## Removal Decision Tree

### useMemo Removal

```
Is the memoized value used in a useEffect dependency array?
  YES → KEEP the useMemo
  NO  ↓

Is the memoized value passed to a child wrapped in React.memo()?
  YES → Does the child use shallow comparison?
        YES → KEEP (or test carefully)
        NO  → Safe to REMOVE
  NO  ↓

Is the value passed to a third-party library expecting stable reference?
  YES → KEEP (or test carefully)
  NO  → Safe to REMOVE
```

### useCallback Removal

```
Is the callback used in a useEffect dependency array?
  YES → KEEP the useCallback
  NO  ↓

Is the callback passed to a child wrapped in React.memo()?
  YES → Consider KEEPING for now
  NO  ↓

Is the callback passed to native DOM elements only?
  YES → Safe to REMOVE
  NO  → Test first, then REMOVE if safe
```

### memo() Removal

Generally keep `memo()` wrappers - they help the compiler understand intent.

## Safe Removal Patterns

### Pattern 1: Simple Computations

```typescript
// SAFE TO REMOVE
const filtered = useMemo(() => items.filter(i => i.active), [items])
// Becomes
const filtered = items.filter(i => i.active)
```

### Pattern 2: Inline Event Handlers

```typescript
// SAFE TO REMOVE
const handleClick = useCallback(() => {
  setCount(c => c + 1)
}, [])
// Becomes
const handleClick = () => {
  setCount(c => c + 1)
}
```

### Pattern 3: Object/Array Creation

```typescript
// SAFE TO REMOVE
const style = useMemo(() => ({ color: 'red', fontSize: 16 }), [])
// Becomes
const style = { color: 'red', fontSize: 16 }
```

## Keep Memoization Patterns

### Pattern 1: Effect Dependencies

```typescript
// KEEP - value used in effect dependency
const options = useMemo(() => ({
  endpoint: `/api/${id}`,
  headers: { auth: token },
}), [id, token])

useEffect(() => {
  fetchData(options)
}, [options]) // ← options must be stable
```

### Pattern 2: Custom Equality Checks

```typescript
// KEEP - child uses custom comparison
const MemoizedChild = memo(Child, (prev, next) => {
  return prev.data.id === next.data.id
})

function Parent({ rawData }) {
  // KEEP - referential equality matters for custom comparison
  const data = useMemo(() => processData(rawData), [rawData])
  return <MemoizedChild data={data} />
}
```

### Pattern 3: Expensive Computations with Side Effects

```typescript
// KEEP - logging/tracking side effects
const result = useMemo(() => {
  console.log('Computing expensive result')
  return expensiveComputation(input)
}, [input])
```

## Testing Checklist

After removing memoization:

- [ ] All unit tests pass
- [ ] Component renders correctly
- [ ] No unexpected re-renders (check React DevTools)
- [ ] Performance is same or better
- [ ] No visual regressions
- [ ] Effects run at expected times
- [ ] Third-party integrations work

## Rollback Strategy

If issues arise:

1. **Identify problematic removal** using git diff
2. **Restore specific memoization** that caused issues
3. **Document why it's needed** in a comment
4. **Add to "keep" list** for future reference

```typescript
// KEEP: Required for Chart.js referential equality
const chartData = useMemo(() => ({
  labels: data.map(d => d.label),
  datasets: [{ data: data.map(d => d.value) }],
}), [data])
```

## Performance Monitoring

### Before Migration

Record baseline metrics:

```typescript
// Add to main component
useEffect(() => {
  const start = performance.now()
  return () => {
    console.log('Render time:', performance.now() - start)
  }
})
```

### After Migration

Compare metrics and verify:
- Render count is same or lower
- Time-to-interactive unchanged
- Memory usage stable
