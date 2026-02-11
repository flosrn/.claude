---
name: supabase-drizzle
description: This skill provides Supabase + Drizzle ORM migration workflow for Makerkit projects. Use when creating database schemas, running migrations, generating types, syncing Drizzle, fixing usersInAuth/users TypeScript errors, or working with RLS policies. Triggers on "database", "migration", "drizzle", "supabase", "schema", "RLS", "typegen", "db diff".
---

# Supabase + Drizzle Migration Workflow

This skill provides comprehensive knowledge for database migrations in Makerkit projects using Supabase with Drizzle ORM.

## Project Detection

This skill is context-aware. Paths adjust based on detected project:
- **gapila**: `/Users/flo/Code/nextjs/gapila`
- **lasdelaroute**: `/Users/flo/Code/nextjs/lasdelaroute`

## Quick Reference

### New Entity Workflow
1. Create schema file: `apps/web/supabase/schemas/XX-name.sql`
2. Create migration: `pnpm --filter web supabase migrations new name`
3. Copy schema to migration
4. Apply: `pnpm --filter web supabase migrations up`
5. Sync Drizzle: See [drizzle-fixes.md](references/drizzle-fixes.md)

### Modify Entity Workflow
1. Edit existing schema file in `apps/web/supabase/schemas/`
2. Generate diff: `pnpm --filter web supabase db diff --local --debug -f name`
3. Apply: `pnpm --filter web supabase migrations up`
4. Sync Drizzle: See [drizzle-fixes.md](references/drizzle-fixes.md)

## Critical Post-Migration Steps

After ANY migration, Drizzle files MUST be regenerated and fixed:

```bash
pnpm supabase:web:typegen    # Generate Supabase types
pnpm drizzle:pull            # Pull Drizzle schemas (regenerates files!)
pnpm format:fix              # Format generated files
# Then fix imports - see references/drizzle-fixes.md
```

The `drizzle:pull` command **completely regenerates** `schema.ts` and `relations.ts`, removing custom imports. These MUST be restored.

## Automated Fix Script

Use the script at `${CLAUDE_PLUGIN_ROOT}/skills/supabase-drizzle/scripts/fix-drizzle-imports.sh`:

```bash
./fix-drizzle-imports.sh [path-to-packages-supabase]
```

This automatically:
1. Adds `/* eslint-disable */` to schema.ts
2. Adds `usersInAuth` import to schema.ts
3. Fixes `usersInAuth` import in relations.ts

## Delegate Heavy Work

For full migration execution with automatic fixes, delegate to the `db-migrate` agent:

```
Use the db-migrate agent to create a new [entity] table
```

This keeps bash outputs isolated from your main conversation.

## Reference Files

- [drizzle-fixes.md](references/drizzle-fixes.md) - Required post-migration fixes
- [migration-workflow.md](references/migration-workflow.md) - Detailed workflow steps
- [security-patterns.md](references/security-patterns.md) - RLS and security best practices

## Common Commands

```bash
# List migrations
pnpm --filter web supabase migrations list

# Reset database (WARNING: deletes data)
pnpm supabase:web:reset

# Generate types only
pnpm supabase:web:typegen

# Pull Drizzle schemas
pnpm drizzle:pull

# Check diff without creating migration
pnpm --filter web supabase db diff --local --debug
```

## Security Checklist

When creating new tables:
- [ ] RLS enabled: `alter table enable row level security`
- [ ] Default permissions revoked
- [ ] Specific permissions granted
- [ ] RLS policies for each operation (select, insert, update, delete)
- [ ] Use existing helper functions (don't recreate)

See [security-patterns.md](references/security-patterns.md) for details.
