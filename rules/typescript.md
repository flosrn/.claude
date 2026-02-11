---
path: "**/*.{ts,tsx}"
description: TypeScript strict typing rules - loaded when editing .ts/.tsx files
---

## TypeScript Strict Rules

**NEVER use:**
- `any` or `as any` - Use proper types or `unknown` with type guards
- `@ts-ignore` / `@ts-expect-error` - Fix the actual type error
- Type assertions without validation (`as SomeType`)

**For external data (API responses, user input, env vars):**
```typescript
// Use Zod schemas
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string(),
  email: z.string().email(),
});

type User = z.infer<typeof UserSchema>;

// Validate at runtime
const user = UserSchema.parse(apiResponse);
```

**Type narrowing patterns:**
```typescript
// Use type guards instead of assertions
function isUser(obj: unknown): obj is User {
  return typeof obj === 'object' && obj !== null && 'id' in obj;
}

// Use discriminated unions
type Result<T> = { success: true; data: T } | { success: false; error: string };
```

**Before committing TypeScript changes:**
```bash
pnpm typecheck && pnpm lint:fix && pnpm format:fix
```
