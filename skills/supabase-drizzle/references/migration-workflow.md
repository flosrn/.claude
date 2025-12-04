# Complete Migration Workflow

## Overview

Database changes in this project require a specific workflow because:

1. **Schemas** (`supabase/schemas/`) are the source of truth but don't auto-apply
2. **Migrations** (`supabase/migrations/`) are the actual SQL that modifies the database
3. **Drizzle** regenerates files that need manual fixes

## Workflow A: Creating New Entities

Use this when adding new tables, enums, functions, or other new database objects.

### Step 1: Determine Next Schema Number

```bash
ls apps/web/supabase/schemas/
```

Pick the next number (e.g., if last is `25-feature.sql`, use `26-`).

### Step 2: Create Schema File

```bash
touch apps/web/supabase/schemas/26-my-feature.sql
```

Write your SQL with proper security:

```sql
-- Create table
create table if not exists public.my_table (
  id uuid unique not null default extensions.uuid_generate_v4(),
  account_id uuid references public.accounts(id) on delete cascade not null,
  name varchar(255) not null,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  primary key (id)
);

-- Enable RLS (CRITICAL)
alter table "public"."my_table" enable row level security;

-- Revoke default permissions
revoke all on public.my_table from authenticated, service_role;

-- Grant specific permissions
grant select, insert, update, delete on table public.my_table to authenticated;

-- RLS policies
create policy "my_table_read" on public.my_table for select
  to authenticated using (
    account_id = (select auth.uid()) or
    public.has_role_on_account(account_id)
  );

-- Add triggers for timestamps
create trigger set_my_table_timestamp
  before insert or update on public.my_table
  for each row execute function public.trigger_set_timestamps();
```

### Step 3: Create Migration

```bash
pnpm --filter web supabase migrations new my-feature
```

### Step 4: Copy Schema to Migration

```bash
cp apps/web/supabase/schemas/26-my-feature.sql \
   apps/web/supabase/migrations/$(ls -t apps/web/supabase/migrations/ | head -n1)
```

### Step 5: Apply Migration

```bash
pnpm --filter web supabase migrations up
```

### Step 6: Sync Types and Drizzle

```bash
pnpm supabase:web:typegen
pnpm drizzle:pull
pnpm format:fix
```

### Step 7: Fix Drizzle Imports

See [drizzle-fixes.md](drizzle-fixes.md) for required manual fixes.

### Step 8: Verify

```bash
pnpm typecheck
pnpm lint
```

## Workflow B: Modifying Existing Entities

Use this when altering existing tables, adding columns, modifying functions, etc.

### Step 1: Edit Schema File

Modify the existing schema file in `apps/web/supabase/schemas/`.

### Step 2: Generate Diff Migration

```bash
# CRITICAL: Always use --local --debug flags
pnpm --filter web supabase db diff --local --debug -f update-my-feature
```

**Why these flags?**
- `--local`: Compares against local running database
- `--debug`: Works around TLS connection bug in Supabase CLI

### Step 3: Review Generated Migration

Check the generated file in `apps/web/supabase/migrations/` to ensure it matches your intent.

### Step 4: Apply and Sync

```bash
pnpm --filter web supabase migrations up
pnpm supabase:web:typegen
pnpm drizzle:pull
pnpm format:fix
```

### Step 5: Fix Drizzle and Verify

See [drizzle-fixes.md](drizzle-fixes.md), then run `pnpm typecheck`.

## Alternative: Full Reset

For development, sometimes a full reset is cleaner:

```bash
# WARNING: Deletes all local data!
pnpm supabase:web:reset
pnpm supabase:web:typegen
pnpm drizzle:pull
pnpm format:fix
# Fix Drizzle imports...
pnpm typecheck
```

## Troubleshooting

### Migration won't apply

Check if there are pending migrations:
```bash
pnpm --filter web supabase migrations list
```

### Diff shows unexpected changes

Your local database may be out of sync. Try:
```bash
pnpm supabase:web:reset
```

### TypeScript errors after drizzle:pull

You forgot to fix Drizzle imports. See [drizzle-fixes.md](drizzle-fixes.md).
