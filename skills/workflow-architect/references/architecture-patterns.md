# Architecture Patterns Reference

## Choosing the Right Structure

### Feature-Based (Recommended for most projects)

Group code by feature/domain, not by type. Each feature is self-contained.

```
src/
  features/
    auth/
      components/
        LoginForm.tsx
        SignupForm.tsx
      hooks/
        useAuth.ts
        useSession.ts
      api/
        auth.api.ts
      types.ts
      index.ts          # Public API only
    dashboard/
      components/
        DashboardPage.tsx
        StatsCard.tsx
      hooks/
        useDashboardData.ts
      api/
        dashboard.api.ts
      types.ts
  shared/               # Truly shared utilities
    components/
      Button.tsx
      Modal.tsx
    hooks/
      useDebounce.ts
    utils/
      formatDate.ts
    types/
      common.ts
```

**When to use:** Most React/Next.js applications. Scales well with team size.

**Key principle:** If you need to modify a feature, you only touch files in that feature's directory.

---

### Layer-Based

Group code by technical layer. Simpler but creates feature scatter.

```
src/
  components/
    auth/
    dashboard/
  hooks/
    useAuth.ts
    useDashboard.ts
  services/
    authService.ts
    dashboardService.ts
  types/
    auth.ts
    dashboard.ts
```

**When to use:** Small projects (< 20 files), or when features heavily share components.

**Avoid when:** You have > 5 features or > 3 developers.

---

### Hybrid (Feature + Shared Layer)

Combine feature-based for domain code with a shared layer for cross-cutting concerns.

```
src/
  features/
    auth/             # Feature-scoped
    billing/
    dashboard/
  shared/
    components/       # Reusable UI
    hooks/            # Generic hooks
    lib/              # Third-party wrappers
    types/            # Shared types
  app/                # App shell, routing, providers
```

**When to use:** Medium-to-large projects. Best balance of organization and pragmatism.

---

## Module Boundary Rules

### 1. Public API Principle

Each feature exposes a clear public API. Internal files are implementation details.

```typescript
// features/auth/index.ts (PUBLIC API)
export { LoginForm } from './components/LoginForm'
export { useAuth } from './hooks/useAuth'
export type { User, Session } from './types'

// NEVER import internal paths from outside:
// BAD: import { validateToken } from '@/features/auth/utils/token'
// GOOD: import { useAuth } from '@/features/auth'
```

### 2. Dependency Direction

Dependencies flow ONE direction: features depend on shared, never the reverse.

```
features/auth → shared/components    (OK)
features/auth → features/billing     (BAD - use events/shared types)
shared/components → features/auth    (BAD - circular)
```

### 3. Colocation Principle

Keep related code close together. Test files live next to source files.

```
features/auth/
  hooks/
    useAuth.ts
    useAuth.test.ts       # Colocated test
  components/
    LoginForm.tsx
    LoginForm.test.tsx    # Colocated test
```

---

## Restructuring Strategies

### Strategy A: Gradual Feature Extraction (Strangler Fig)

For large codebases. Extract one feature at a time without disrupting everything.

1. Create the new feature directory
2. Move files one by one with `git mv`
3. Update imports after each move
4. Verify build passes after each move
5. Repeat for next feature

**Pros:** Low risk, incremental, reviewable.
**Cons:** Slower, temporary inconsistency.

### Strategy B: Full Restructure

For smaller codebases or when the existing structure is unsalvageable.

1. Design the complete target structure
2. Create all new directories
3. Move all files at once
4. Update all imports in one pass
5. Verify build

**Pros:** Clean result, no transition period.
**Cons:** Large diff, harder to review, higher risk.

### Strategy C: Module Splitting

For extracting a module from a god file/module.

1. Identify distinct responsibilities in the god module
2. Create new files for each responsibility
3. Move code to new files, function by function
4. Update the original to re-export (temporary)
5. Update external imports to point to new locations
6. Remove the re-exports from original
7. Delete original if empty

---

## Common Restructuring Patterns

### Pattern: Extract Hook from Component

```
BEFORE:
  components/UserProfile.tsx (300 lines, state + API + UI)

AFTER:
  components/UserProfile.tsx (80 lines, UI only)
  hooks/useUserProfile.ts (120 lines, state + API)
```

### Pattern: Colocate Scattered Feature

```
BEFORE:
  components/auth/LoginForm.tsx
  hooks/useAuth.ts
  services/authService.ts
  types/auth.ts

AFTER:
  features/auth/
    LoginForm.tsx
    useAuth.ts
    auth.api.ts
    types.ts
```

### Pattern: Split Barrel File

```
BEFORE:
  components/index.ts  (re-exports 40 components)

AFTER:
  Direct imports everywhere:
  import { Button } from '@/components/Button'
  (delete index.ts)
```

### Pattern: Extract Shared Module

```
BEFORE:
  features/auth/utils.ts     (has formatDate)
  features/billing/utils.ts  (has formatDate copy)

AFTER:
  shared/utils/formatDate.ts (single source)
  features/auth/utils.ts     (imports from shared)
  features/billing/utils.ts  (imports from shared)
```

---

## Frontend Component Patterns

Patterns specific to Next.js App Router and component-level architecture.

### Pattern: Component Section Organization

Organize files within a component section (e.g., a landing page section, a feature panel) with an entry point + categorized subdirectories. This is the dominant best practice for sections with 5+ files (Feature-Sliced Design, Bulletproof React, Clean Architecture).

```
BEFORE (everything flat):
  sections/google-benchmark/
    index.ts
    google-benchmark.tsx
    google-benchmark-section.tsx
    mock-data.ts              # Mixed: interfaces + utility functions
    animated-rating.tsx
    competitor-ranking.tsx
    your-business-card.tsx
    price-level.tsx
    ... (8+ files flat, no organization)

AFTER (entry point + main component at top level, sub-components in subdirectory):
  sections/google-benchmark/
    index.ts                  # Entry point (barrel) — re-exports from ./google-benchmark
    google-benchmark.tsx      # Main orchestrator — TOP LEVEL, next to index.ts
    components/               # Sub-components only (not the main component)
      benchmark-results.tsx   # Layout composition
      benchmark-skeleton.tsx  # Loading state
      competitor-ranking.tsx  # Display component
      contextual-cta.tsx      # Display component
      place-search-bar.tsx    # Interactive input
      your-business-card.tsx  # Display component
      animated-rating.tsx     # Micro component
      price-level.tsx         # Shared atom
      rating-gauge.tsx        # Micro component
    lib/                      # Non-UI code
      types.ts                # Section-internal interfaces
      utils.ts                # Pure utility functions
      mappers.ts              # Data transformation functions
      constants.ts            # Section-specific constants
```

**Why the main component sits next to index.ts (not inside components/):**
- Immediately visible when opening the directory (Josh Comeau, Robin Wieruch, Reddit consensus)
- `index.ts` re-exports from `./google-benchmark` (1 level, clean)
- Clear hierarchy: entry point → orchestrator → sub-components
- `components/` contains only children, never the parent

**When to use `components/` vs `_components/`:**
- `_components/` — inside Next.js App Router route directories (private folder convention, underscore prefix excludes from routing)
- `components/` — inside sections or features that are NOT directly under a route directory (no routing concern, no need for underscore)

**Same logic applies to `lib/` vs `_lib/`:**
- `_lib/` — inside route directories (e.g., `app/api/places/_lib/`)
- `lib/` — inside component sections (e.g., `sections/google-benchmark/lib/`)

**Scaling rules:**
- < 5 files: keep flat (Josh Comeau style), no subdirectories needed
- 5-15 files: entry point + main component + `components/` + `lib/` (this pattern)
- 15+ files: consider adding `hooks/`, `types/` as separate subdirectories alongside `components/` and `lib/`

**Key principle:** `index.ts` is the only export point. External consumers import from the section, never from internal subdirectories.

### Pattern: Route Handler Slimming

Extract data transformation logic from API route handlers into dedicated mapper functions.

```
BEFORE:
  api/places/benchmark/route.ts (300 lines)
    - HTTP handling
    - Google API calls
    - Response mapping (mapDetailsToPlace, mapNearbyToCompetitors)
    - Type definitions (BenchmarkResponse, GoogleBenchmarkDetails)
    - Error handling

AFTER:
  api/places/benchmark/route.ts (80 lines)
    - HTTP handling only: validate → call → map → return
  api/places/_lib/
    mappers.ts                  # mapDetailsToPlace, mapNearbyToCompetitors
    schemas.ts                  # Zod schemas for request/response validation
    client.ts                   # External API HTTP client
```

**Target:** Route handler should be orchestration only — no `.map()`, no object construction, no type coercion. Under 100 lines.

### Pattern: Wrapper Collapsing

Detect and remove unnecessary passthrough components that add no value.

```
BEFORE:
  index.ts → exports GoogleBenchmarkSection
  google-benchmark-section.tsx (11 lines, just renders GoogleBenchmark with same props)
  google-benchmark.tsx (actual logic)

AFTER (collapsed):
  index.ts → exports GoogleBenchmark directly
  google-benchmark.tsx (actual logic)
  (google-benchmark-section.tsx deleted)
```

**Decision tree before collapsing:**
1. Does the wrapper establish a Server/Client Component boundary? → Keep, document why
2. Does it add Suspense, ErrorBoundary, or layout? → Keep, it provides value
3. Does it transform props or add defaults? → Keep, it has logic
4. None of the above? → Collapse: re-export child from `index.ts`, delete wrapper

### Pattern: API Route Infrastructure Colocation

Share infrastructure utilities across sibling API route handlers using a private `_lib/` directory.

```
BEFORE:
  api/places/autocomplete/route.ts  (each has its own cache, rate-limit, API client code)
  api/places/details/route.ts
  api/places/nearby/route.ts
  api/places/benchmark/route.ts

AFTER:
  api/places/
    _lib/
      cache.ts              # In-memory TTL cache (getCached<T>, setCache<T>)
      client.ts             # HTTP client (placesPost<T>, placesGet<T>)
      rate-limit.ts         # IP-based rate limiter (checkRateLimit)
      schemas.ts            # Shared Zod schemas (API contract)
    autocomplete/route.ts   # Thin handler using _lib/
    details/route.ts
    nearby/route.ts
    benchmark/route.ts
```

**Rules:**
- `_lib/` prefix makes the folder private (excluded from Next.js routing)
- Each file has a single concern
- Files export typed generics (`getCached<T>`, `placesPost<T>`)
- No dependencies on route-specific logic — pure infrastructure
