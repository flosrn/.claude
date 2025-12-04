---
name: supabase-drizzle
description: Supabase + Drizzle ORM migration workflow for Gapila. Use when creating database schemas, running migrations, generating types, syncing Drizzle, or fixing usersInAuth/users TypeScript errors. Automatically activates for database-related tasks.
---

# Supabase + Drizzle Migration Workflow

This skill provides knowledge for database migrations in projects using Supabase with Drizzle ORM.

## When This Skill Activates

- Creating new tables, enums, or database entities
- Modifying existing database schemas
- Running `supabase migrations` or `db diff`
- Syncing Drizzle schemas after migrations
- Fixing TypeScript errors related to `usersInAuth` or `users`
- Questions about RLS policies, security definer functions
- Post-migration type generation

## Quick Reference

### New Entity Workflow

1. Create schema file: `apps/web/supabase/schemas/XX-name.sql`
2. Create migration: `pnpm --filter web supabase migrations new name`
3. Copy schema to migration: `cp schema.sql migrations/$(ls -t migrations/ | head -n1)`
4. Apply: `pnpm --filter web supabase migrations up`
5. Sync Drizzle: See [drizzle-fixes.md](references/drizzle-fixes.md)

### Modify Entity Workflow

1. Edit existing schema file in `apps/web/supabase/schemas/`
2. Generate diff: `pnpm --filter web supabase db diff --local --debug -f name`
3. Apply: `pnpm --filter web supabase migrations up`
4. Sync Drizzle: See [drizzle-fixes.md](references/drizzle-fixes.md)

## Critical Post-Migration Steps

After ANY migration, Drizzle files MUST be regenerated and fixed:

1. `pnpm supabase:web:typegen` - Generate Supabase types
2. `pnpm drizzle:pull` - Pull Drizzle schemas (regenerates files!)
3. `pnpm format:fix` - Format generated files
4. **Fix imports** - See [drizzle-fixes.md](references/drizzle-fixes.md)

The `drizzle:pull` command **completely regenerates** `schema.ts` and `relations.ts`, removing custom imports. These MUST be restored manually.

## Delegate Heavy Work

For full migration execution with automatic fixes, delegate to the `@db-migrate` agent. This keeps bash outputs and logs isolated from your main conversation.

Example: "Use the @db-migrate agent to create a new participants table"

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
