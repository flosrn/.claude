# Restructuring Techniques Reference

## Safe File Operations

### Moving Files with Git History

ALWAYS use `git mv` to preserve file history:

```bash
# Move single file
git mv src/utils/auth.ts src/features/auth/utils.ts

# Move directory
git mv src/components/auth/ src/features/auth/components/

# Rename file
git mv src/api/getUser.ts src/api/fetchUser.ts
```

**NEVER use plain `mv`** - it breaks git history tracking.

### Creating Directories Before Moving

```bash
# Create target directory first
mkdir -p src/features/auth/{components,hooks,api}

# Then move files
git mv src/components/LoginForm.tsx src/features/auth/components/
git mv src/hooks/useAuth.ts src/features/auth/hooks/
```

---

## Import Migration

### Step 1: Identify All Imports to Update

After moving a file, find all files that import from the old path:

```bash
# Find all files importing from old path
grep -rn "from '.*old/path" src/ --include="*.ts" --include="*.tsx"
```

### Step 2: Update Imports

Use the Edit tool to update each import. For path alias projects:

```typescript
// BEFORE (old path)
import { useAuth } from '@/hooks/useAuth'

// AFTER (new path)
import { useAuth } from '@/features/auth/hooks/useAuth'
```

### Step 3: Verify No Broken Imports

```bash
# TypeScript will catch broken imports
npx tsc --noEmit 2>&1 | grep "Cannot find module"

# Or check for specific old path
grep -rn "from '.*old/path" src/ --include="*.ts" --include="*.tsx"
```

---

## Incremental Commit Strategy

### One Commit Per Logical Group

Group related moves into single commits:

```bash
# Commit 1: Create new structure
git add -A && git commit -m "refactor: create auth feature directory structure"

# Commit 2: Move auth files
git mv src/components/LoginForm.tsx src/features/auth/components/
git mv src/hooks/useAuth.ts src/features/auth/hooks/
git add -A && git commit -m "refactor: move auth files to features/auth"

# Commit 3: Update imports
# (after updating all import statements)
git add -A && git commit -m "refactor: update imports for auth restructure"
```

### Checkpoint Before Risky Operations

```bash
# Create checkpoint
git add -A && git commit -m "architect: checkpoint before restructure"

# If something goes wrong:
git reset HEAD~1  # Undo last commit but keep changes
# or
git reset --hard HEAD~1  # Discard everything since checkpoint
```

---

## Path Alias Configuration

### Updating tsconfig.json / next.config

When restructuring, update path aliases to match new structure:

```json
// tsconfig.json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"],
      "@/features/*": ["./src/features/*"],
      "@/shared/*": ["./src/shared/*"]
    }
  }
}
```

### Updating Import Maps

If using import maps or module resolution:

```typescript
// vite.config.ts
resolve: {
  alias: {
    '@': path.resolve(__dirname, './src'),
    '@features': path.resolve(__dirname, './src/features'),
    '@shared': path.resolve(__dirname, './src/shared'),
  }
}
```

---

## Dependency Analysis Techniques

### Quick Dependency Check

```bash
# Count how many files import a specific module
grep -rl "from '.*module-name" src/ --include="*.ts" --include="*.tsx" | wc -l

# See what a file imports
grep "^import\|from '" src/path/to/file.ts

# See what imports a file
grep -rl "from '.*file-name" src/ --include="*.ts" --include="*.tsx"
```

### Circular Dependency Detection

```bash
# If madge is available
npx madge --circular --extensions ts,tsx src/

# Manual detection: check if A imports B AND B imports A
for file in $(find src/ -name "*.ts" -o -name "*.tsx"); do
  imports=$(grep "from '" "$file" | sed "s/.*from '//;s/'.*//")
  for imp in $imports; do
    # Resolve relative import to check reverse
    echo "$file -> $imp"
  done
done | sort
```

### File Size Analysis

```bash
# Find largest files (likely god modules)
find src/ -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -rn | head -20

# Find files with most exports
for f in $(find src/ -name "*.ts" -o -name "*.tsx"); do
  count=$(grep -c "^export " "$f" 2>/dev/null || echo 0)
  if [ "$count" -gt 10 ]; then
    echo "$count $f"
  fi
done | sort -rn
```

---

## Validation Checklist

After restructuring, verify:

```bash
# 1. TypeScript compiles
npx tsc --noEmit

# 2. No broken imports remain
grep -rn "Cannot find module" <(npx tsc --noEmit 2>&1) || echo "All imports OK"

# 3. Linter passes
pnpm lint

# 4. Build succeeds
pnpm build

# 5. Tests pass
pnpm test

# 6. No orphan files created
# (manually review git status)
git status

# 7. Git history preserved for moved files
git log --follow -- src/new/path/file.ts
```

---

## Common Pitfalls

### 1. Moving files without updating imports
**Always** grep for the old path after every move. TypeScript will catch most issues, but dynamic imports and string references won't be caught.

### 2. Breaking re-exports
If other packages or entry points re-export from a moved file, those need updating too. Check `index.ts` files, `package.json` exports, and any build configuration.

### 3. Forgetting test files
When moving source files, move their colocated test files too:
```bash
git mv src/hooks/useAuth.ts src/features/auth/hooks/
git mv src/hooks/useAuth.test.ts src/features/auth/hooks/
```

### 4. CSS/SCSS module references
CSS modules import by relative path. Moving a component without its CSS module breaks styles:
```bash
git mv src/components/Button.tsx src/shared/components/
git mv src/components/Button.module.css src/shared/components/
```

### 5. Not updating lazy imports
Dynamic imports with string paths don't get TypeScript checking:
```typescript
// These need manual updating
const Page = lazy(() => import('./old/path/Page'))
// Update to:
const Page = lazy(() => import('./new/path/Page'))
```
