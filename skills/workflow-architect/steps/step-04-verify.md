---
name: step-04-verify
description: Verify restructuring integrity - build, tests, import validation, before/after comparison
prev_step: steps/step-03-restructure.md
next_step: null
---

# Step 4: VERIFY (Final Validation)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER complete with failing build
- ✅ ALWAYS run full build before marking done
- ✅ ALWAYS verify git history is preserved for moved files
- ✅ ALWAYS provide before/after comparison
- 📋 YOU ARE A VALIDATOR ensuring quality
- 🚫 FORBIDDEN to skip any verification check

## CONTEXT BOUNDARIES:

- All restructuring from step-03 is complete
- Files have been moved, imports updated, commits made
- Need to verify everything works end-to-end

## YOUR TASK:

Run comprehensive verification and produce a before/after report.

---

## EXECUTION SEQUENCE:

### 1. TypeScript Check

```bash
npx tsc --noEmit
```

**If errors:** Fix and re-run until clean.

### 2. Linter Check

```bash
pnpm lint
```

**If errors:** Fix with `pnpm lint --fix`, then manual fixes.

### 3. Build Check

```bash
pnpm build
```

**If build fails:**
1. Read error
2. Fix issue (likely missed import or path alias)
3. Re-run
4. **Loop until passes**

### 4. Test Suite

```bash
pnpm test
```

**If tests fail:** Fix and re-run. Common issues after restructuring:
- Test imports pointing to old paths
- Snapshot tests with old file paths
- Mock paths need updating

### 5. Circular Dependency Check

```bash
# If madge available
npx madge --circular --extensions ts,tsx src/

# If not available, manual verification
grep -rn "from '" src/ --include="*.ts" --include="*.tsx" | \
  awk -F: '{print $1}' | sort | uniq -c | sort -rn | head -10
```

### 6. Verify Git History Preserved

Spot-check that moved files retained their git history:

```bash
# Pick 3 key files that were moved
git log --follow --oneline -5 -- src/new/path/file.ts
```

If history shows commits from before the restructure, `git mv` worked correctly.

### 7. Before/After Comparison

Generate a comprehensive report:

```markdown
## Restructuring Complete

### Before/After Structure
| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Total files | 85 | 82 | -3 (orphans removed) |
| Max file size | 842 lines | 180 lines | -78% |
| Circular deps | 3 | 0 | Fixed |
| God modules | 2 | 0 | Split |
| Avg nesting depth | 5.2 | 3.1 | -40% |
| Orphan files | 4 | 0 | Removed |
| Hub modules (>30%) | 2 | 0 | Split |

### Smells Resolved
| Smell | Status |
|-------|--------|
| God Module (`helpers.ts`) | Split into `format.ts`, `validate.ts`, `string.ts` |
| Circular Dep (auth ↔ user) | Extracted shared types to `shared/types/` |
| Feature Scatter (auth) | Colocated in `features/auth/` |
| Barrel Bloat (components/index.ts) | Removed, using direct imports |
| Orphan files (4) | Deleted |

### Verification Results
| Check | Status |
|-------|--------|
| TypeScript | PASS |
| ESLint | PASS |
| Build | PASS |
| Tests | PASS (42/42) |
| Circular Deps | 0 found |
| Git History | Preserved |

### Commits Created
1. `abc1234` - refactor: create feature directory structure
2. `def5678` - refactor: move shared types and utils
3. `ghi9012` - refactor: move auth feature files
4. `jkl3456` - refactor: split helpers.ts god module
5. `mno7890` - refactor: break auth-user circular dependency
6. `pqr1234` - refactor: cleanup orphans and empty dirs

### New Structure
```
src/
  features/
    auth/         (5 files, self-contained)
    dashboard/    (4 files, self-contained)
    user/         (3 files, self-contained)
  shared/
    components/   (6 reusable UI components)
    hooks/        (3 generic hooks)
    utils/        (4 focused utility modules)
    types/        (2 shared type files)
```
```

**If `{save_mode}` = true:**
→ Write report to `.claude/output/architect/{task_id}/04-verify.md`

### 8. Offer Commit / Squash

**Use AskUserQuestion:**

```yaml
questions:
  - header: "Complete"
    question: "Restructuring verified and passing. How would you like to finalize?"
    options:
      - label: "Keep individual commits (Recommended)"
        description: "Each phase has its own commit for easy review and rollback"
      - label: "Squash into single commit"
        description: "Combine all restructuring into one commit"
      - label: "Done"
        description: "Finish without additional git operations"
    multiSelect: false
```

**If squash:**
```bash
git reset --soft {checkpoint_commit}
git commit -m "refactor: restructure {scope} - fix god modules, circular deps, colocate features"
```

---

## SUCCESS METRICS:

- TypeScript passes
- Linter passes
- Build passes
- Tests pass
- No circular dependencies
- Git history preserved for moved files
- Before/after comparison shows improvement

## FAILURE MODES:

- Completing with failing build
- Skipping circular dependency check
- Not verifying git history preservation
- No before/after comparison

---

## WORKFLOW COMPLETE

<critical>
NEVER complete if build fails!
ALWAYS show before/after metrics!
</critical>
