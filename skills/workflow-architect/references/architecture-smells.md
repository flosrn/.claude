# Architecture Smells Catalog

## Detection Guide

Use this reference to identify architectural problems in the codebase. Each smell includes what to look for and how to detect it programmatically.

---

## 1. God Module

**What:** A file or module that is excessively large and handles too many responsibilities.

**Detection thresholds:**
- File > 500 lines of code
- Component > 300 lines
- Module exports > 15 symbols
- More than 3 distinct responsibilities

**How to detect:**
```bash
# Find large files
find src/ -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -rn | head -20

# Find files with many exports
grep -c "^export " src/**/*.ts | sort -t: -k2 -rn | head -20
```

**Resolution:** Split into focused modules using Single Responsibility Principle.

---

## 2. Circular Dependencies

**What:** Two or more modules import each other, creating a cycle.

**Detection:**
```bash
# TypeScript projects
npx madge --circular --extensions ts,tsx src/

# If madge not available, manual check
grep -r "from '\.\." src/ | awk -F: '{print $1}' | sort | uniq -c | sort -rn
```

**Why it matters:** Circular deps cause unpredictable load order, make testing impossible in isolation, and create tight coupling.

**Resolution:** Extract shared code into a third module, use dependency inversion, or restructure module boundaries.

---

## 3. Feature Scatter

**What:** Code for a single feature is spread across many unrelated directories.

**Detection:**
```
Symptom: To understand "auth", you need to read:
  src/components/LoginForm.tsx
  src/hooks/useAuth.ts
  src/utils/auth.ts
  src/types/auth.ts
  src/api/auth.ts
  src/store/authStore.ts
  src/middleware/auth.ts
```

**Resolution:** Colocate related code. Move feature code into a single directory: `src/features/auth/`.

---

## 4. Unstable Dependencies

**What:** A stable, core module depends on a frequently-changing module.

**Detection:**
```bash
# Find most-changed files (last 3 months)
git log --since="3 months ago" --name-only --pretty=format: | sort | uniq -c | sort -rn | head -20

# Cross-reference with imports from stable modules
```

**Why it matters:** Changes in unstable modules ripple into stable ones, causing unexpected breakage.

**Resolution:** Invert the dependency. Stable modules define interfaces; unstable modules implement them.

---

## 5. Barrel File Bloat

**What:** Index files (`index.ts`) that re-export everything, defeating tree-shaking and creating implicit coupling.

**Detection:**
```bash
# Find large barrel files
find src/ -name "index.ts" -exec wc -l {} + | sort -rn | head -10

# Check if barrel re-exports everything
grep -c "export \*" src/**/index.ts
```

**Why it matters:** Barrel files create hidden dependencies, slow builds, and prevent proper code splitting.

**Resolution:** Remove barrel files. Use direct imports: `import { X } from './module/X'` instead of `import { X } from './module'`.

---

## 6. Hub Module (Dense Dependencies)

**What:** A module that is imported by a large percentage of the codebase, creating a single point of failure.

**Detection:**
```bash
# Find most-imported files
grep -rh "from '" src/ | sed "s/.*from '//;s/'.*//" | sort | uniq -c | sort -rn | head -20
```

**Thresholds:**
- Imported by > 30% of files = hub module
- Imported by > 50% of files = critical hub

**Resolution:** Split the hub into focused sub-modules. Only import what you need.

---

## 7. Deep Nesting

**What:** Directory structure nested more than 4 levels deep, making navigation difficult.

**Detection:**
```bash
# Find deeply nested files
find src/ -mindepth 5 -type f | head -20

# Count average nesting depth
find src/ -type f -name "*.ts" | awk -F/ '{print NF-1}' | sort -rn | head -5
```

**Resolution:** Flatten structure. Use feature-based organization instead of type-based nesting.

---

## 8. Orphan Files

**What:** Files that are not imported anywhere in the codebase (dead code).

**Detection:**
```bash
# Find files not imported by anything
for f in $(find src/ -name "*.ts" -o -name "*.tsx" | grep -v "index\|test\|spec\|__"); do
  basename=$(basename "$f" | sed 's/\.[^.]*$//')
  if ! grep -rq "$basename" src/ --include="*.ts" --include="*.tsx" -l | grep -vq "$f"; then
    echo "ORPHAN: $f"
  fi
done
```

**Resolution:** Delete orphan files. They add maintenance burden without value.

---

## 9. Misplaced Code

**What:** Code that lives in the wrong directory for its purpose.

**Detection patterns:**
- React components in `utils/` or `lib/`
- Business logic in `components/`
- API calls directly in components (not in hooks/services)
- Type definitions scattered across the codebase
- Configuration in source code directories

**Resolution:** Move code to its correct location based on architecture patterns.

---

## 10. Logical Coupling (Hidden Dependencies)

**What:** Files that always change together in Git history but have no visible import relationship. This is often more dangerous than visible coupling because it's invisible to static analysis.

**Detection:**
```bash
# Find files that frequently change together (last 3 months)
git log --since="3 months ago" --name-only --pretty=format:"---" -- src/ | \
  awk '/^---$/{if(NR>1) for(i in files) for(j in files) if(i<j) print i, j; delete files; next} /^./{files[$0]++}' | \
  sort | uniq -c | sort -rn | head -20
```

**Why it matters:** Logical coupling indicates hidden dependencies that static analysis and TypeScript can't catch. When file A always changes with file B, they're conceptually coupled even without imports.

**Resolution:** Colocate logically coupled files in the same feature directory. If they truly belong together, make the relationship explicit.

---

## 11. Duplicate Modules

**What:** Multiple files that do essentially the same thing with slight variations.

**Detection:**
```bash
# Find similarly named files
find src/ -name "*.ts" | xargs -I {} basename {} | sort | uniq -d

# Find files with similar exports
grep -rh "^export function\|^export const\|^export class" src/ | sort | uniq -cd
```

**Resolution:** Merge into a single, well-designed module with proper configuration/parameters.

---

## 12. Fat Route Handler

**What:** API route file > 150 lines containing data transformation logic mixed with HTTP handling. The route handler does mapping, object construction, and type coercion instead of delegating to a mapper.

**Detection:**
```bash
# Find large route handlers
find src/ app/ -name "route.ts" -exec wc -l {} + | sort -rn | head -10

# Check for inline transformations in routes
grep -n "\.map\|\.reduce\|Object\.assign\|spread" app/**/route.ts
```

**Thresholds:**
- Route file > 150 lines of non-import code
- Route file imports 3+ type definitions AND contains `.map()` or manual object construction
- Route file defines its own interfaces (see Smell #13)

**Resolution:** Extract transformation logic to `_lib/mappers.ts`. Route handler becomes: validate request → call service → map response → return.

---

## 13. Inline Types in Route Handlers

**What:** TypeScript interfaces defined inside route handlers or API files instead of shared type files. Creates type drift when the same data shape is defined independently in both backend and frontend.

**Detection:**
```bash
# Find interfaces defined in route files
grep -n "^interface\|^type\|^export interface\|^export type" app/**/route.ts

# Cross-reference: same field names in multiple interfaces
grep -rh "placeId\|userId\|rating" --include="*.ts" | sort | uniq -c | sort -rn
```

**Signal:** Same field names appearing in interfaces defined in 2+ different files (one in a route handler, one in a component or shared types file).

**Resolution:** Move to `_lib/schemas.ts` (Zod, preferred) or `_lib/types.ts`. Use Zod schemas as single source of truth validated at runtime on both sides.

---

## 14. Unnecessary Wrapper Component

**What:** A component that renders exactly one child with identical or subset props — a pure passthrough that adds no logic, layout, error boundary, or Suspense.

**Detection:**
```bash
# Find tiny component files (likely wrappers)
find src/ app/ -name "*.tsx" -exec awk 'END{if(NR<20) print FILENAME, NR" lines"}' {} \;

# Check for 1:1 component renders
grep -l "return <[A-Z][a-zA-Z]* " app/**/*.tsx | xargs grep -L "Suspense\|ErrorBoundary\|className\|<div\|<section"
```

**Signal:** Component file < 20 lines that imports one component and renders it forwarding all or most props.

**Decision tree before fixing:**
- Does it establish a Server/Client Component boundary (`'use client'` on child)? → Keep, document the boundary
- Does it add Suspense, ErrorBoundary, or layout? → Keep, it provides value
- Neither? → Collapse: have `index.ts` re-export the child directly

**Resolution:** Either collapse (delete wrapper, re-export child from `index.ts`) or justify by adding an error boundary, Suspense boundary, or layout wrapper.

---

## 15. Flat Component Section

**What:** Component section with 8+ files all at the same directory level, mixing types, utilities, constants, and UI components without organizational subdirectories.

**Detection:**
```bash
# Find directories with many flat files
find app/ src/ -type d -exec sh -c 'count=$(ls -1 "$1"/*.ts "$1"/*.tsx 2>/dev/null | wc -l); [ "$count" -gt 7 ] && echo "$1: $count files"' _ {} \;

# Check for inconsistency with sibling sections
ls -d app/**/sections/*/lib app/**/sections/*/_lib 2>/dev/null
```

**Signal:**
- Directory has 8+ `.ts`/`.tsx` files with no subdirectories
- Sibling directories use `lib/` or `_lib/` subdirectories but this one doesn't
- Files named `types.ts`, `utils.ts`, `constants.ts` sitting alongside component files

**Resolution:** Organize following the Component Section Organization pattern:
```
section/
  index.ts                # Entry point (barrel) — re-exports main component
  main-component.tsx      # Main orchestrator — top level, next to index.ts
  components/             # or _components/ under App Router routes
    sub-component-a.tsx
    sub-component-b.tsx
  lib/                    # or _lib/ under App Router routes
    types.ts
    utils.ts
    constants.ts
    mappers.ts
```

---

## Severity Matrix

| Smell | Impact | Detection Difficulty | Fix Complexity |
|-------|--------|---------------------|----------------|
| God Module | High | Easy | Medium |
| Circular Deps | Critical | Easy (with tooling) | High |
| Feature Scatter | Medium | Medium | Medium |
| Unstable Deps | High | Hard | High |
| Barrel Bloat | Medium | Easy | Low |
| Hub Module | High | Easy | High |
| Deep Nesting | Low | Easy | Low |
| Orphan Files | Low | Medium | Low |
| Misplaced Code | Medium | Hard | Low |
| Logical Coupling | High | Hard (needs Git) | Medium |
| Duplicate Modules | Medium | Medium | Medium |
| Fat Route Handler | Medium | Easy | Low |
| Inline Types in Routes | Medium | Easy | Low |
| Unnecessary Wrapper | Low | Easy | Low |
| Flat Component Section | Low | Easy | Low |
