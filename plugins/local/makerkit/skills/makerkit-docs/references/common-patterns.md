# Common Makerkit Patterns

## File Organization

### Route Structure
```
apps/web/app/home/[account]/
├── page.tsx                    # Team dashboard
├── members/
│   ├── page.tsx               # Members listing
│   └── _lib/server/           # Server-side utilities
│       └── members-page.loader.ts
├── feature/
│   ├── page.tsx              # Feature listing
│   ├── [id]/                 # Individual item
│   │   └── page.tsx
│   ├── _components/          # Feature-specific components
│   └── _lib/
│       ├── server/           # Server-side logic
│       │   ├── feature-page.loader.ts
│       │   └── feature-server-actions.ts
│       └── schemas/          # Zod validation
│           └── feature.schema.ts
```

### Naming Conventions
- Pages: `page.tsx`
- Loaders: `{feature}-page.loader.ts`
- Actions: `{feature}-server-actions.ts`
- Schemas: `{feature}.schema.ts`
- Components: `kebab-case.tsx`

## Data Fetching

### Loader Pattern
```typescript
// _lib/server/feature-page.loader.ts
import 'server-only';

export async function loadFeaturePageData(
  client: SupabaseClient<Database>,
  accountSlug: string,
) {
  return Promise.all([
    loadItems(client, accountSlug),
    loadMetadata(client, accountSlug),
  ]);
}
```

### Page Component
```typescript
// page.tsx
export default async function FeaturePage({ params }: Props) {
  const client = getSupabaseServerClient();
  const slug = (await params).account;

  const [items, metadata] = await loadFeaturePageData(client, slug);

  return <FeatureList items={items} metadata={metadata} />;
}

export default withI18n(FeaturePage);
```

## Mutations

### Server Action Pattern
```typescript
// _lib/server/feature-server-actions.ts
'use server';

import { enhanceAction } from '@kit/next/actions';
import { redirect } from 'next/navigation';

export const createFeature = enhanceAction(
  async (data, { user }) => {
    const client = getSupabaseServerClient();
    const service = createFeatureService();

    const result = await service.create({
      ...data,
      accountId: data.accountId,
    });

    if (result.error) throw result.error;

    redirect(`/home/${data.accountSlug}/feature/${result.data.id}`);
  },
  {
    schema: CreateFeatureSchema,
    auth: true,
  }
);
```

## Forms

### React Hook Form + Server Action
```typescript
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useTransition } from 'react';

export function CreateFeatureForm() {
  const [isPending, startTransition] = useTransition();

  const form = useForm({
    resolver: zodResolver(CreateFeatureSchema),
    defaultValues: { name: '' },
  });

  const onSubmit = (data: CreateFeatureInput) => {
    startTransition(async () => {
      try {
        await createFeature(data);
      } catch (error) {
        if (!isRedirectError(error)) {
          toast.error('Failed to create');
        }
      }
    });
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        {/* form fields */}
      </form>
    </Form>
  );
}
```

## Security

### Helper Functions (DO NOT RECREATE)
```sql
public.has_role_on_account(account_id, role?)
public.has_permission(user_id, account_id, permission)
public.is_account_owner(account_id)
public.has_active_subscription(account_id)
public.is_team_member(account_id, user_id)
public.is_super_admin()
```

### RLS Policy Template
```sql
-- Read: owner or team member
create policy "read" on public.table for select
  to authenticated using (
    account_id = (select auth.uid())
    or public.has_role_on_account(account_id)
  );

-- Write: permission-based
create policy "write" on public.table for insert
  to authenticated with check (
    public.has_permission(auth.uid(), account_id, 'feature.manage'::app_permissions)
  );
```
