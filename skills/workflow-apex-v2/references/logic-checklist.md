# Logic Review Checklist

## Edge Cases & Boundaries

- [ ] Empty inputs handled (null, undefined, [], '')
- [ ] Large inputs bounded (prevent memory exhaustion)
- [ ] Negative numbers handled (if applicable)
- [ ] Zero division prevented
- [ ] Off-by-one errors in loops/indices
- [ ] Floating point precision (use integers for currency)
- [ ] Unicode/emoji handling in strings
- [ ] Timezone handling correct (UTC-aware)

## Error Handling

- [ ] All thrown errors caught appropriately
- [ ] Error messages user-friendly (not stack traces)
- [ ] Fallback behavior for third-party service failures
- [ ] Timeout handling (no infinite waits)
- [ ] Retry logic with exponential backoff (if needed)
- [ ] Error logging includes context

## State & Mutability

- [ ] Immutable updates (no accidental mutations)
- [ ] Shared state properly protected (locks, atomicity)
- [ ] No race conditions (concurrent access)
- [ ] State transitions valid (no invalid states reachable)
- [ ] Initialization order correct
- [ ] Cleanup on error (connections, files, timers)

## Async & Concurrency

- [ ] Promises/async await used correctly
- [ ] No unhandled promise rejections
- [ ] Callback hell avoided (use async/await)
- [ ] Race conditions in async code prevented
- [ ] Proper error propagation through chains
- [ ] Request timeouts set

## Data Validation

- [ ] Input types validated (string, number, array)
- [ ] Input ranges validated (min/max, enums)
- [ ] Required fields present
- [ ] No type coercion surprises (`== ` vs `===`)
- [ ] Array iteration safe (no undefined elements)

## Conditional Logic

- [ ] All branches tested
- [ ] No unreachable code
- [ ] Boolean logic correct (De Morgan's laws)
- [ ] Null/undefined checks before access
- [ ] Optional chaining used (`?.`)
- [ ] Nullish coalescing correct (`??`)

## Loops & Iteration

- [ ] Loop bounds correct
- [ ] No infinite loops
- [ ] Break/continue used correctly
- [ ] Iterator exhaustion handled
- [ ] forEach/map not used for async operations
- [ ] Array mutation during iteration prevented

## Database & Persistence

- [ ] Transactions used for multi-step operations
- [ ] Rollback on error
- [ ] No duplicate key errors
- [ ] Foreign key constraints respected
- [ ] Cascading deletes handled
- [ ] N+1 query problems avoided (batch/join)

## API & Integration

- [ ] Request/response validation
- [ ] Timeout handling
- [ ] Retry logic for transient failures
- [ ] Rate limit handling
- [ ] Graceful degradation if service unavailable
- [ ] Pagination limits set

## Business Logic

- [ ] Calculations correct (rounding, precision)
- [ ] Discount/tax logic audited
- [ ] Date math correct (DST, leap years)
- [ ] Status transitions valid
- [ ] Idempotency where needed (no duplicate orders)
- [ ] Money operations use proper type (Decimal, not float)

## Typical Problem Patterns

```javascript
// ❌ Race condition
let count = 0;
async function increment() { count++; } // Not atomic

// ✅ Fixed
const count = new AtomicInteger(0);
count.incrementAndGet();

// ❌ Off-by-one
for (let i = 0; i <= array.length; i++) // i can equal length
const item = array[i]; // undefined at last iteration

// ✅ Fixed
for (let i = 0; i < array.length; i++)

// ❌ Floating point
0.1 + 0.2 === 0.3 // false

// ✅ Fixed (for money, use cents as integer)
const cents = 10 + 20; // cents, not dollars
```
