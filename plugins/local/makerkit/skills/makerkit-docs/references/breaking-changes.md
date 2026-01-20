# Makerkit Breaking Changes

## Version 2.20.x → 2.21.x

### Next.js 16 Upgrade
- Async params/searchParams in pages and layouts
- Cache components mode available
- React 19 required

### Changes Required
```typescript
// Before
export default function Page({ params }: { params: { id: string } }) {
  return <div>{params.id}</div>;
}

// After
export default async function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  return <div>{id}</div>;
}
```

## Version 2.19.x → 2.20.x

### Tailwind CSS 4
- New configuration format
- CSS-first configuration
- Some class names changed

### ESLint 9
- Flat config format required
- `eslint.config.mjs` instead of `.eslintrc`

## Version 2.18.x → 2.19.x

### Drizzle ORM Updates
- Schema regeneration may require import fixes
- Relations file structure changed

### Supabase CLI Updates
- New migration commands
- `--local --debug` flags recommended for db diff

## Common Migration Issues

### TypeScript Errors After Update
1. Check `database.types.ts` is regenerated
2. Verify Drizzle imports are fixed (see supabase-drizzle skill)
3. Run `pnpm typecheck` to identify issues

### Dependency Conflicts
1. Use `pnpm syncpack:fix` to align versions
2. Check peer dependency warnings
3. May need to update React/Next.js versions together

### Build Failures
1. Clear caches: `pnpm clean`
2. Reinstall: `rm -rf node_modules && pnpm i`
3. Check for deprecated APIs in changelog
