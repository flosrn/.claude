---
name: makerkit-docs
description: This skill provides Makerkit documentation and best practices. Use when the user asks about Makerkit architecture, patterns, configuration, authentication, billing, teams, accounts, or any Next.js Supabase Turbo boilerplate questions. Triggers on "makerkit", "how to in makerkit", "makerkit best practice", "upgrade makerkit", "makerkit migration".
---

# Makerkit Documentation & Best Practices

This skill provides access to Makerkit documentation for the Next.js Supabase Turbo boilerplate.

## Documentation Access

Use Context7 MCP to fetch latest Makerkit documentation:

```
resolve-library-id: makerkit
get-library-docs: /docs/next-supabase-turbo
```

The Context7 library ID for Makerkit is available at:
- URL: https://context7.com/websites/makerkit_dev-docs-next-supabase-turbo
- Contains: 232,016 tokens of indexed documentation
- Code snippets: 1,548 examples

## Project-Specific MCP

Both projects have their own Makerkit MCP servers configured:
- **gapila**: `makerkit-gapila` MCP
- **lasdelaroute**: `makerkit-las` MCP

These provide project-aware access to:
- Database schemas and tables
- Component listings
- PRD management
- Code quality commands

## Key Documentation Topics

### Architecture
- Monorepo structure with Turborepo
- App Router patterns (Next.js 16)
- Feature packages organization
- Multi-tenant architecture (personal + team accounts)

### Authentication & Authorization
- Supabase Auth integration
- RLS (Row Level Security) policies
- Permission system (`app_permissions` enum)
- Team roles and membership

### Data Fetching
- Server Components with loaders (reading)
- Server Actions with `enhanceAction` (mutations)
- `enhanceRouteHandler` for API routes

### Billing & Subscriptions
- Stripe/Lemon Squeezy integration
- Subscription plans configuration
- Billing portal setup

### Database
- Supabase for core Makerkit tables
- Drizzle ORM for custom business logic
- Migration workflow (see supabase-drizzle skill)

## Reference Files

- [upgrade-checklist.md](references/upgrade-checklist.md) - Steps for upgrading Makerkit
- [common-patterns.md](references/common-patterns.md) - Frequently used patterns
- [breaking-changes.md](references/breaking-changes.md) - Known breaking changes between versions

## Quick Patterns

### Server Component with Loader
```typescript
async function Page({ params }: Props) {
  const client = getSupabaseServerClient();
  const data = await loadPageData(client, (await params).slug);
  return <Component data={data} />;
}
```

### Server Action with Schema
```typescript
'use server';
import { enhanceAction } from '@kit/next/actions';

export const createItem = enhanceAction(
  async (data) => {
    // mutation logic
    return { success: true };
  },
  { schema: CreateItemSchema }
);
```

### RLS Policy Pattern
```sql
create policy "read_policy" on public.my_table for select
  to authenticated using (
    account_id = (select auth.uid())
    or public.has_role_on_account(account_id)
  );
```
