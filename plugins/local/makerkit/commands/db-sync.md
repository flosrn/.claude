---
name: db-sync
description: Run Supabase + Drizzle database sync workflow (typegen, drizzle pull, fix imports)
allowed-tools: Bash, Read, Edit, Task
argument-hint: [--reset]
---

# Database Sync Command

Synchronize database types and Drizzle schemas for Makerkit projects.

## Workflow

1. **Generate Supabase Types**
   - `pnpm supabase:web:typegen`

2. **Pull Drizzle Schemas**
   - `pnpm drizzle:pull`

3. **Format Generated Files**
   - `pnpm format:fix`

4. **Fix Drizzle Imports**
   - Add eslint-disable
   - Fix usersInAuth imports

5. **Verify**
   - `pnpm typecheck`

## Usage

Basic sync:
```
/makerkit:db-sync
```

Full reset (WARNING: deletes local data):
```
/makerkit:db-sync --reset
```

## Arguments

- `--reset`: Reset database before syncing (deletes all local data)

## Execution

Delegate to the `db-migrate` agent with appropriate context:

If `--reset` is specified:
```
Use the db-migrate agent to perform a full database reset and Drizzle sync
```

Otherwise:
```
Use the db-migrate agent to sync Supabase types and Drizzle schemas (no reset, just regenerate types)
```

For just syncing (no migration), the simplified workflow is:

```bash
# Generate types
pnpm supabase:web:typegen

# Pull Drizzle
pnpm drizzle:pull

# Format
pnpm format:fix
```

Then fix Drizzle imports as documented in the supabase-drizzle skill.

## Expected Output

```
## Database Sync Complete

**Project**: [gapila/lasdelaroute]
**Reset**: [Yes/No]

### Status
- [x] Supabase types generated
- [x] Drizzle schemas pulled
- [x] Imports fixed
- [x] TypeScript compiles

### Files Updated
- apps/web/database.types.ts
- packages/supabase/src/drizzle/schema.ts
- packages/supabase/src/drizzle/relations.ts
```
