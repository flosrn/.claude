# Drizzle Post-Migration Fixes

## Why These Fixes Are Required

The `pnpm drizzle:pull` command regenerates `schema.ts` and `relations.ts` **completely** from the database. This removes:

1. ESLint disable directive (generated code has many warnings)
2. Custom `usersInAuth` import (auth schema users table)

Without these fixes, TypeScript compilation **will fail**.

## File Locations

- **Schema**: `packages/supabase/src/drizzle/schema.ts`
- **Relations**: `packages/supabase/src/drizzle/relations.ts`
- **Auth Users**: `packages/supabase/src/drizzle/auth.users.ts` (custom file, never regenerated)

## Fix 1: schema.ts

### Add at TOP of file (line 1)

```typescript
/* eslint-disable */
```

### Add AFTER drizzle imports (before any table definitions)

```typescript
import { usersInAuth as users } from './auth.users';
```

### Complete Example

```typescript
/* eslint-disable */
import { sql } from 'drizzle-orm';
import {
  bigint,
  boolean,
  foreignKey,
  // ... other imports
} from 'drizzle-orm/pg-core';
import { usersInAuth as users } from './auth.users';

// Rest of generated schema...
export const appPermissions = pgEnum('app_permissions', [
  // ...
]);
```

## Fix 2: relations.ts

### Add import for usersInAuth

```typescript
import { usersInAuth } from './auth.users';
```

### Remove usersInAuth from schema import

If the generated file imports `usersInAuth` from `./schema`, remove it:

```typescript
// BEFORE (wrong - will error)
import {
  accounts,
  usersInAuth,  // REMOVE THIS LINE
  // ...
} from './schema';

// AFTER (correct)
import {
  accounts,
  // ...
} from './schema';
import { usersInAuth } from './auth.users';
```

## Automated Script

Run the fix script:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/supabase-drizzle/scripts/fix-drizzle-imports.sh
```

Or specify a custom path:

```bash
./fix-drizzle-imports.sh packages/supabase/src/drizzle
```

## Verification

After fixes, run:

```bash
pnpm typecheck
```

If you see errors about `users` or `usersInAuth`, the imports are missing.

## Common Errors

### Error: Cannot find name 'users'

**Cause**: Missing `import { usersInAuth as users } from './auth.users';` in schema.ts

### Error: Module has no exported member 'usersInAuth'

**Cause**: relations.ts imports `usersInAuth` from `./schema` instead of `./auth.users`
