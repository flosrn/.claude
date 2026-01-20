# React Compiler Error Patterns

## CannotPreserveMemoization

The most common compiler error indicating manual memoization cannot be preserved.

### Error Message Format

```
CannotPreserveMemoization: React Compiler has skipped optimizing this component
because the existing manual memoization could not be preserved. The inferred
dependencies did not match the manually specified dependencies, which could
cause the value to change more or less frequently than expected.
```

### Cause 1: Aliased Dependencies

**Problem**: Using an aliased variable in memoization.

```typescript
// ERROR
function useHook(x) {
  const aliasedX = x
  const aliasedProp = x.y.z

  return useCallback(() => [aliasedX, x.y.z], [x, aliasedProp])
  //                                          ^^^^^^^^^^^^^^^^
  // Dependencies don't match: aliasedX vs x, aliasedProp vs x.y.z
}
```

**Fix**: Use original references.

```typescript
// FIXED
function useHook(x) {
  return useCallback(() => [x, x.y.z], [x])
}
```

### Cause 2: Mutation After Hooks

**Problem**: Mutating a value between hook calls.

```typescript
// ERROR
function useFoo(props) {
  const x = []
  useHook()
  x.push(props) // Mutation after hook

  return useCallback(() => [x], [x])
  // Compiler can't preserve because x was mutated
}
```

**Fix**: Avoid mutations or restructure.

```typescript
// FIXED
function useFoo(props) {
  const x = useMemo(() => [props], [props])

  return useCallback(() => x, [x])
}
```

### Cause 3: Conditional Value Access

**Problem**: Accessing values conditionally inside memoization.

```typescript
// ERROR
function Component({ propA, propB }) {
  return useMemo(() => {
    const x = {}
    if (identity(null) ?? propA.a) {
      mutate(x)
      return { value: propB.x.y }
    }
  }, [propA.a, propB.x.y])
  // Conditional access makes dependency inference difficult
}
```

**Fix**: Simplify or extract conditional logic.

```typescript
// FIXED
function Component({ propA, propB }) {
  const shouldProcess = identity(null) ?? propA.a
  const value = propB.x.y

  return useMemo(() => {
    if (shouldProcess) {
      return { value }
    }
    return undefined
  }, [shouldProcess, value])
}
```

### Cause 4: Mutable Return Values

**Problem**: Returning mutable values from functions.

```typescript
// ERROR
component Component() {
  const getIsEnabled = () => {
    if (data != null) return true
    return {} // Returns mutable object
  }

  // isEnabled may be mutable
  const isEnabled = useMemo(() => getIsEnabled(), [getIsEnabled])
  // Compiler can't guarantee this is safe
}
```

**Fix**: Return consistent types.

```typescript
// FIXED
component Component() {
  const isEnabled = useMemo(() => {
    return data != null
  }, [data])
}
```

## Other Compiler Warnings

### Skipped Optimization

```
React Compiler has skipped optimizing this component because...
```

**Common causes**:
- Complex control flow
- Dynamic property access
- Spread operators in unusual contexts

**Action**: Review component structure, may not need manual fix.

### Potential Memory Leak

```
Potential memory leak detected in component...
```

**Fix**: Ensure proper cleanup in effects.

```typescript
useEffect(() => {
  const subscription = subscribe()
  return () => subscription.unsubscribe() // Required cleanup
}, [])
```

## Debugging Compiler Issues

### Enable Verbose Logging

```javascript
// babel.config.js
module.exports = {
  plugins: [
    ['babel-plugin-react-compiler', {
      compilationMode: 'annotation', // Only compile marked components
      panicThreshold: 'all', // Show all warnings
      logger: {
        logEvent: (filename, event) => {
          if (event.kind === 'CompileError') {
            console.error(`Compile error in ${filename}:`, event)
          }
        },
      },
    }],
  ],
}
```

### Opt-Out Individual Components

If a component causes issues:

```typescript
// @react-compiler-ignore
function ProblematicComponent() {
  // Compiler will skip this component
}
```

### Check Compiled Output

Inspect the compiled JavaScript to understand transformations:

```bash
# Build with source maps
npm run build -- --source-map

# Or check .next/static/chunks for compiled code
```

## Best Practices for Avoiding Errors

### Do

1. **Keep dependencies simple** - Use direct prop/state references
2. **Avoid mutations** - Use immutable patterns
3. **Return consistent types** - Don't mix primitives and objects
4. **Extract complex logic** - Simplify memoized functions

### Don't

1. **Alias dependencies** - Use original references
2. **Mutate after hooks** - Keep mutations before hooks
3. **Use complex conditionals** - Extract to separate variables
4. **Return different types** - Be consistent

## When to Keep Manual Memoization

Even with compiler errors, sometimes manual memoization is correct:

```typescript
// KEEP: Complex equality requirement
const complexData = useMemo(() => {
  return processData(rawData)
}, [rawData]) // Manual control over when this updates

// Document why it's needed
// @react-compiler-skip-memoization
```
