# Quality Review Checklist

## SOLID Principles

- [ ] Single Responsibility: One reason to change per class/function
- [ ] Open/Closed: Open for extension, closed for modification
- [ ] Liskov Substitution: Subtypes usable where parent expected
- [ ] Interface Segregation: Small focused interfaces, not fat ones
- [ ] Dependency Inversion: Depend on abstractions, not concretions

## Code Smells

- [ ] Long functions (>50 lines): extract methods
- [ ] Deep nesting (>3 levels): extract or restructure
- [ ] Duplicate code: consolidate to DRY
- [ ] Magic numbers/strings: extract to named constants
- [ ] God class/module: too many responsibilities
- [ ] Shotgun surgery: changes require edits in many places
- [ ] Feature envy: accessing other object's internals
- [ ] Primitive obsession: use objects instead of primitives
- [ ] Long parameter lists: use object or builder
- [ ] Speculative generality: don't build unused abstractions

## Naming

- [ ] Variables named for intent (no `x`, `temp`, `data`)
- [ ] Functions named as verbs (getUser, calculateTotal)
- [ ] Classes named as nouns (User, PaymentProcessor)
- [ ] Boolean variables prefixed (isActive, hasPermission, canDelete)
- [ ] Constants SCREAMING_CASE
- [ ] No misleading names (don't call int `count` if it's really an index)

## Comments

- [ ] Complex logic explained (the "why", not "what")
- [ ] No redundant comments ("i++" followed by "increment i")
- [ ] Comments kept up-to-date with code
- [ ] TODO/FIXME comments actionable
- [ ] Dead code removed (not commented out)

## Type Safety (TypeScript)

- [ ] No `any` type (use `unknown` + type guard)
- [ ] No `as` type assertions without validation
- [ ] Proper error types (Error class, not string)
- [ ] Exhaustive type checks (switch statements)
- [ ] Generics used where polymorphism needed

## Testing Quality

- [ ] Tests have clear arrange-act-assert structure
- [ ] Test names describe behavior (not "test1")
- [ ] No test interdependencies
- [ ] Fast unit tests (<100ms total)
- [ ] Integration tests isolated (no external deps)
- [ ] High coverage of critical paths (>80%)
- [ ] Negative test cases included

## Performance

- [ ] No unnecessary re-renders (React)
- [ ] No memory leaks (cleanup subscriptions)
- [ ] No infinite loops or recursion
- [ ] Expensive operations memoized or lazy-loaded
- [ ] Bundle size reasonable for features
- [ ] API calls batched, not N+1

## Code Metrics

- [ ] Cyclomatic complexity <10 per function
- [ ] Cognitive complexity <15 per function
- [ ] Function length <50 lines (preferably <30)
- [ ] Class methods <15
- [ ] Class responsibilities <3
- [ ] DRY violations consolidated

## Pattern Consistency

- [ ] Same patterns used across codebase
- [ ] Error handling pattern uniform
- [ ] Logging pattern consistent
- [ ] State management approach unified
- [ ] Async handling standardized

## Maintainability

- [ ] Code readability high (reviews easily understood)
- [ ] Dependencies documented
- [ ] Future extension points clear
- [ ] Backward compatibility considered
- [ ] Migration path planned for breaking changes

## Red Flags (Immediate Fixes)

- Production errors not caught by tests
- Disabled linting/type checking
- Hardcoded values that belong in config
- Copy-paste code blocks
- Functions that do multiple things
- No error handling in async chains
- Race conditions in concurrent code
- Missing validation of external input
