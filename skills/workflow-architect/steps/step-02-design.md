---
name: step-02-design
description: Design the restructuring plan based on audit findings
prev_step: steps/step-01-audit.md
next_step: steps/step-03-handoff.md
---

# Step 2: DESIGN (Restructuring Plan)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER start restructuring - that's step 3
- 🛑 NEVER write or modify code in this step
- ✅ ALWAYS specify exact source → destination for every file move
- ✅ ALWAYS specify import update patterns
- ✅ ALWAYS order operations by dependency (shared types first)
- 📋 YOU ARE A DESIGNER, not an implementer
- 🚫 FORBIDDEN to use Edit, Write, or Bash tools

## CONTEXT BOUNDARIES:

- Audit findings from step-01 are available (smells, dependency map, metrics)
- No restructuring has started
- User has NOT approved any changes yet

## YOUR TASK:

Design a complete, step-by-step restructuring plan that addresses the detected architectural smells.

---

## EXECUTION SEQUENCE:

### 1. Load Architecture Patterns Reference

```
Read: {skill_dir}/references/architecture-patterns.md
```

Use this to choose the right target structure.

### 2. Choose Target Architecture

Based on the audit findings, select the appropriate pattern:

| Codebase Size | Team Size | Pattern |
|---------------|-----------|---------|
| < 20 files | 1-2 devs | Layer-based |
| 20-100 files | 2-5 devs | Hybrid (feature + shared) |
| > 100 files | 5+ devs | Feature-based |

**If `{auto_mode}` = false AND multiple patterns could work:**

```yaml
questions:
  - header: "Architecture"
    question: "Which target architecture should we use?"
    options:
      - label: "Feature-based (Recommended)"
        description: "Group by feature/domain: src/features/auth/, src/features/dashboard/"
      - label: "Hybrid"
        description: "Features + shared layer: src/features/ + src/shared/"
      - label: "Keep current, fix smells only"
        description: "Don't reorganize, just fix circular deps and split god modules"
    multiSelect: false
```

### 2b. Frontend Component Patterns (if scope is frontend)

If `{scope}` includes frontend components, landing page sections, or API routes, apply these additional patterns from the reference:

For each frontend smell detected in step-01:
- **Fat Route Handler** (#12) → Apply "Route Handler Slimming" pattern: extract transformations to `_lib/mappers.ts`
- **Inline Types in Routes** (#13) → Move to `_lib/schemas.ts` (Zod) or `_lib/types.ts`
- **Unnecessary Wrapper** (#14) → Apply "Wrapper Collapsing" decision tree
- **Flat Component Section** (#15) → Apply "Component Section Organization" pattern with `lib/` subdirectory

Include these frontend restructuring operations in the move plan alongside structural changes.

### 3. Design Target Structure

Draw the complete target directory tree:

```markdown
## Target Structure

src/
  features/
    auth/
      components/
        LoginForm.tsx          ← from src/components/auth/LoginForm.tsx
        SignupForm.tsx          ← from src/components/auth/SignupForm.tsx
      hooks/
        useAuth.ts             ← from src/hooks/useAuth.ts
        useSession.ts          ← from src/hooks/useSession.ts
      api/
        auth.api.ts            ← from src/services/authService.ts
      types.ts                 ← from src/types/auth.ts
    dashboard/
      ...
  shared/
    components/
      Button.tsx               ← stays (already correct)
      Modal.tsx                ← stays
    hooks/
      useDebounce.ts           ← from src/hooks/useDebounce.ts
    utils/
      formatDate.ts            ← extracted from src/utils/helpers.ts
    types/
      common.ts               ← from src/types/index.ts (split)
```

### 4. Create Move Plan

List every file operation in execution order:

```markdown
## Move Plan

### Phase 1: Create Structure (no risk)
1. `mkdir -p src/features/auth/{components,hooks,api}`
2. `mkdir -p src/features/dashboard/{components,hooks,api}`
3. `mkdir -p src/shared/{components,hooks,utils,types}`

### Phase 2: Move Shared Dependencies First
(These are imported by features, so move first to avoid circular issues)

| # | Operation | Source | Destination |
|---|-----------|--------|-------------|
| 1 | `git mv` | `src/types/common.ts` | `src/shared/types/common.ts` |
| 2 | `git mv` | `src/utils/formatDate.ts` | `src/shared/utils/formatDate.ts` |
| 3 | Update imports | All files importing from old paths | New paths |
| 4 | **VERIFY** | `npx tsc --noEmit` | Must pass |
| 5 | **COMMIT** | `refactor: move shared types and utils` | |

### Phase 3: Move Feature - Auth
| # | Operation | Source | Destination |
|---|-----------|--------|-------------|
| 6 | `git mv` | `src/components/auth/LoginForm.tsx` | `src/features/auth/components/LoginForm.tsx` |
| 7 | `git mv` | `src/hooks/useAuth.ts` | `src/features/auth/hooks/useAuth.ts` |
| 8 | `git mv` | `src/services/authService.ts` | `src/features/auth/api/auth.api.ts` |
| 9 | Update imports | All files importing from old paths | New paths |
| 10 | **VERIFY** | `npx tsc --noEmit` | Must pass |
| 11 | **COMMIT** | `refactor: move auth feature files` | |

### Phase 4: Split God Module
| # | Operation | Details |
|---|-----------|---------|
| 12 | Extract | Move `formatDate`, `formatCurrency` from `helpers.ts` → `shared/utils/format.ts` |
| 13 | Extract | Move `validateEmail`, `validatePhone` from `helpers.ts` → `shared/utils/validate.ts` |
| 14 | Update imports | Point all consumers to new locations |
| 15 | Delete | Remove empty `helpers.ts` (or keep with remaining functions) |
| 16 | **VERIFY** | `npx tsc --noEmit` | Must pass |
| 17 | **COMMIT** | `refactor: split helpers.ts god module` | |

### Phase 5: Fix Circular Dependencies
| # | Operation | Details |
|---|-----------|---------|
| 18 | Extract shared types | Create `shared/types/auth-user.ts` for types shared between auth and user |
| 19 | Update both modules | Point to shared types instead of importing from each other |
| 20 | **VERIFY** | `npx tsc --noEmit` + `npx madge --circular` |
| 21 | **COMMIT** | `refactor: break auth ↔ user circular dependency` | |

### Phase 6: Cleanup
| # | Operation | Details |
|---|-----------|---------|
| 22 | Delete orphans | Remove identified orphan files |
| 23 | Remove empty dirs | Clean up empty directories |
| 24 | Update barrel files | Simplify or remove index.ts re-exports |
| 25 | **FINAL VERIFY** | Full build + tests |
| 26 | **COMMIT** | `refactor: cleanup orphans and empty dirs` | |
```

### 5. Impact Assessment

```markdown
## Impact Assessment

### Files Moving: 15
### Files Splitting: 2
### Files Deleting: 3
### Import Updates: ~45 files
### New Directories: 8
### Commits: 6 (one per phase)

### Risk Assessment
| Phase | Risk | Mitigation |
|-------|------|------------|
| Phase 2 (shared) | Low | Small scope, verify after each move |
| Phase 3 (features) | Medium | Many import updates, TypeScript catches issues |
| Phase 4 (split) | High | Extracting from god module requires careful analysis |
| Phase 5 (circular) | High | May need to redesign module boundaries |
```

### 6. Present Plan for Approval

**If `{dry_run}` = true:**
→ Present the plan and stop. Do not proceed to step-03.

**If `{auto_mode}` = true:**
→ Proceed directly to step-03.

**If `{auto_mode}` = false:**

```yaml
questions:
  - header: "Approve"
    question: "Restructuring plan ready. Proceed with execution?"
    options:
      - label: "Execute full plan (Recommended)"
        description: "Execute all phases with verification after each"
      - label: "Execute critical phases only"
        description: "Only Phase 4 (god module) and Phase 5 (circular deps)"
      - label: "Modify plan"
        description: "I want to adjust the plan before executing"
    multiSelect: false
```

---

## SUCCESS METRICS:

- Every file move has explicit source → destination
- Operations ordered by dependency (shared first, then features)
- Verification step after each phase
- Commit message for each phase
- Impact assessment with risk analysis

## FAILURE MODES:

- Moving files before their dependencies are moved
- Missing import update specifications
- No verification steps between phases
- Not accounting for test files alongside source files

---

## NEXT STEP:

**If `{standalone_mode}` = true:**
→ After plan approved, load `./step-03-restructure.md`

**If `{standalone_mode}` = false (default):**
→ After plan approved, load `./step-03-handoff.md`

<critical>
DESIGN ONLY - don't execute anything!
</critical>
