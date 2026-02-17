---
name: step-03-restructure
description: Execute the restructuring plan safely with git mv and import migration
prev_step: steps/step-02-design.md
next_step: steps/step-04-verify.md
---

# Step 3: RESTRUCTURE (Safe Execution)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER deviate from the approved plan
- 🛑 NEVER move a file without reading it first
- 🛑 NEVER skip import updates after a move
- ✅ ALWAYS use `git mv` (never plain `mv`)
- ✅ ALWAYS update imports immediately after each move
- ✅ ALWAYS verify with `npx tsc --noEmit` after each phase
- ✅ ALWAYS commit after each phase
- 📋 YOU ARE AN EXECUTOR following an approved plan
- 🚫 FORBIDDEN to add restructuring not in the plan

## CONTEXT BOUNDARIES:

- Plan from step-02 is approved and must be followed
- Phases are ordered by dependency (shared first, then features)
- Each phase ends with verify + commit
- Don't restructure beyond what's planned

## YOUR TASK:

Execute the approved restructuring plan phase by phase, verifying and committing after each phase.

---

## EXECUTION SEQUENCE:

### 1. Load Restructuring Techniques Reference

```
Read: {skill_dir}/references/restructuring-techniques.md
```

### 2. Git Checkpoint (safety net)

Create a checkpoint before making any changes:

```bash
git add -A && git commit --allow-empty -m "architect: checkpoint before restructure ({task_id})"
```

This enables `git reset HEAD~1` to rollback if restructuring breaks the codebase.

### 3. Create Task Tracking

Create tasks from the plan phases:

```
Plan phase:
### Phase 2: Move Shared Dependencies

Becomes task:
- [ ] Phase 2: Move shared dependencies (types, utils)
- [ ] Phase 3: Move auth feature files
- [ ] Phase 4: Split god module
- [ ] Phase 5: Fix circular dependencies
- [ ] Phase 6: Cleanup orphans
```

### 4. Execute Phase by Phase

For each phase in the plan:

**4.1 Mark Phase In Progress**
- Only ONE phase active at a time

**4.2 Create Directories**
```bash
mkdir -p src/features/auth/{components,hooks,api}
```

**4.3 Move Files with `git mv`**

For each file move in the phase:

1. **Read the file** before moving (understand what it exports)
2. **Move with git mv:**
   ```bash
   git mv src/old/path/file.ts src/new/path/file.ts
   ```
3. **Move colocated files** (tests, CSS modules, stories):
   ```bash
   git mv src/old/path/file.test.ts src/new/path/file.test.ts
   git mv src/old/path/file.module.css src/new/path/file.module.css
   ```

**4.4 Update All Imports**

After moving files in a phase, update every file that imports from old paths:

```bash
# Find all files still importing from old path
grep -rn "from '.*old/path" src/ --include="*.ts" --include="*.tsx"
```

Use Edit tool to update each import:

```typescript
// BEFORE
import { useAuth } from '@/hooks/useAuth'

// AFTER
import { useAuth } from '@/features/auth/hooks/useAuth'
```

**If `{economy_mode}` = false and many imports to update (> 10 files):**
→ Launch parallel Snipper agents to update imports in batches of 3-5 files each.

**4.5 Verify Phase**

```bash
npx tsc --noEmit
```

**If errors:** Fix immediately. Common issues:
- Missed import update → fix the import
- Relative path broken → adjust relative path
- Re-export broken → update barrel file

**4.6 Commit Phase**

```bash
git add -A && git commit -m "refactor: {phase description from plan}"
```

**4.7 Mark Phase Complete**

Log progress:
```markdown
### Phase X: {name}
- Moved: {N} files
- Updated imports: {N} files
- TypeScript: PASS
- Committed: {hash}
```

### 5. Handle God Module Splits

When splitting a god module (special case):

1. **Read the entire file** to understand all exports and their consumers
2. **Group exports by responsibility** (the plan should specify groupings)
3. **Create new files** for each responsibility group
4. **Move code** function by function to new files
5. **Temporarily re-export** from original for backwards compat:
   ```typescript
   // Original file (temporary, remove in cleanup phase)
   export { formatDate, formatCurrency } from './shared/utils/format'
   ```
6. **Update external imports** to point to new locations
7. **Remove re-exports** from original
8. **Delete original** if empty

### 6. Handle Circular Dependency Breaks

When breaking circular dependencies (special case):

1. **Identify the shared types/functions** that both modules need
2. **Create a shared module** in `shared/` for these items
3. **Move shared code** to the new shared module
4. **Update both modules** to import from shared instead of each other
5. **Verify no cycles remain:**
   ```bash
   npx madge --circular --extensions ts,tsx src/
   ```

### 7. Log Progress (if save_mode)

Append to `.claude/output/architect/{task_id}/03-restructure.md`:

```markdown
## Restructure Log

### Phase 1: Create Structure
- Created 8 directories
- Timestamp: {ISO}

### Phase 2: Move Shared Dependencies
- Moved: src/types/common.ts → src/shared/types/common.ts
- Moved: src/utils/format.ts → src/shared/utils/format.ts
- Updated 12 import statements
- TypeScript: PASS
- Commit: abc1234
- Timestamp: {ISO}

### Phase 3: Move Auth Feature
...
```

---

## SUCCESS METRICS:

- All planned file moves executed with `git mv`
- All imports updated after each move
- TypeScript passes after each phase
- One clean commit per phase
- No files moved outside the plan

## FAILURE MODES:

- Using `mv` instead of `git mv` (loses history)
- Moving files without updating imports
- Not verifying between phases
- Committing broken state
- Adding moves not in the approved plan

---

## NEXT STEP:

After all phases complete, load `./step-04-verify.md`

<critical>
ALWAYS verify TypeScript after EVERY phase!
ALWAYS use git mv, NEVER plain mv!
</critical>
