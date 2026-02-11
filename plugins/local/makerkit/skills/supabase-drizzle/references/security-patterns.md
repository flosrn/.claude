# Database Security Patterns

## Core Principles

1. **Always enable RLS** on new tables
2. **Never use SECURITY DEFINER** without explicit access controls
3. **Use existing helper functions** - don't recreate them
4. **Validate storage paths** with account_id

## RLS Policy Patterns

### Basic Read Policy

```sql
create policy "table_read" on public.my_table for select
  to authenticated using (
    -- Personal account access
    account_id = (select auth.uid())
    or
    -- Team account access
    public.has_role_on_account(account_id)
  );
```

### Permission-Based Write Policy

```sql
create policy "table_write" on public.my_table for insert
  to authenticated with check (
    public.has_permission(auth.uid(), account_id, 'feature.manage'::app_permissions)
  );

create policy "table_update" on public.my_table for update
  to authenticated
  using (
    public.has_permission(auth.uid(), account_id, 'feature.manage'::app_permissions)
  )
  with check (
    public.has_permission(auth.uid(), account_id, 'feature.manage'::app_permissions)
  );

create policy "table_delete" on public.my_table for delete
  to authenticated using (
    public.has_permission(auth.uid(), account_id, 'feature.manage'::app_permissions)
  );
```

## Existing Helper Functions

**DO NOT recreate these - they already exist:**

```sql
-- Account Access Control
public.has_role_on_account(account_id, role?)     -- Check team membership
public.has_permission(user_id, account_id, permission)  -- Check permissions
public.is_account_owner(account_id)               -- Verify ownership
public.has_active_subscription(account_id)        -- Subscription status
public.is_team_member(account_id, user_id)        -- Direct membership check

-- Administrative Functions
public.is_super_admin()                           -- Super admin check
public.is_aal2()                                  -- MFA verification

-- Configuration
public.is_set(field_name)                         -- Feature flag checks
```

## SECURITY DEFINER Functions

### Dangerous Pattern (NEVER DO THIS)

```sql
-- This bypasses all RLS and anyone can call it!
CREATE OR REPLACE FUNCTION public.dangerous_function()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER AS $$
BEGIN
  DELETE FROM sensitive_table;
END;
$$;
GRANT EXECUTE ON FUNCTION public.dangerous_function() TO authenticated;
```

### Safe Pattern

```sql
CREATE OR REPLACE FUNCTION public.safe_function(target_account_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = '' -- Prevent SQL injection
AS $$
BEGIN
  -- MUST validate permissions FIRST
  IF NOT public.is_account_owner(target_account_id) THEN
    RAISE EXCEPTION 'Access denied: insufficient permissions';
  END IF;

  -- Now safe to proceed
  -- Your operation here
END;
$$;
```

## Storage Bucket Policies

```sql
create policy bucket_policy on storage.objects for all using (
  bucket_id = 'my_bucket'
  and (
    kit.get_storage_filename_as_uuid(name) = auth.uid()
    or public.has_role_on_account(kit.get_storage_filename_as_uuid(name))
  )
)
with check (
  bucket_id = 'my_bucket'
  and (
    kit.get_storage_filename_as_uuid(name) = auth.uid()
    or public.has_permission(
      auth.uid(),
      kit.get_storage_filename_as_uuid(name),
      'files.upload'::app_permissions
    )
  )
);
```

## Adding New Permissions

```sql
-- Add to the enum
ALTER TYPE public.app_permissions ADD VALUE 'feature.manage';
COMMIT;
```

## Table Creation Checklist

- [ ] Table created with proper columns and constraints
- [ ] RLS enabled: `alter table enable row level security`
- [ ] Default permissions revoked: `revoke all from authenticated, service_role`
- [ ] Specific permissions granted: `grant select, insert, update, delete to authenticated`
- [ ] RLS policies created for each operation (select, insert, update, delete)
- [ ] Indexes added for foreign keys and common queries
- [ ] Timestamp triggers added if using created_at/updated_at
