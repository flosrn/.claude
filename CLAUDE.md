# Global Claude Code Instructions

These instructions apply to ALL projects. Project-specific instructions in local CLAUDE.md files take precedence.

## Shell Aliases

This system has shell aliases that override standard commands. Use absolute paths to avoid compatibility issues:

| Command | Aliased To | Problem | Use Instead |
|---------|------------|---------|-------------|
| `ls` | `eza` | `-t` flag works differently | `/bin/ls` |
| `grep` | `rg` | `-E` flag is incompatible | `/usr/bin/grep` |
| `find` | `fd` | Syntax completely different | `/usr/bin/find` |
| `cat` | `bat` | Usually works, but may differ | Use `Read` tool instead |

**Examples:**
```bash
# ❌ WRONG - will fail
ls -1t folder/
grep -E "^[0-9]+" file.txt
find . -name "*.ts"

# ✅ CORRECT - always works
/bin/ls -1t folder/
/usr/bin/grep -E "^[0-9]+" file.txt
/usr/bin/find . -name "*.ts"
```

When generating bash commands with `ls`, `grep`, or `find`, use the absolute path (`/bin/ls`, `/usr/bin/grep`, `/usr/bin/find`).

## LSP Tools (cclsp)

Use cclsp MCP tools for finding symbol definitions and references. LSP provides semantic code understanding rather than text matching:

| Operation | Use This | NOT This |
|-----------|----------|----------|
| Find where function/class is defined | `mcp__cclsp__find_definition` | ❌ Grep/Glob |
| Find all usages of a symbol | `mcp__cclsp__find_references` | ❌ Grep with symbol name |
| Rename function/variable/type | `mcp__cclsp__rename_symbol` | ❌ Manual find/replace |
| Check TypeScript errors | `mcp__cclsp__get_diagnostics` | ❌ Running tsc manually |

### Trigger Patterns

Use cclsp when the task involves:
- "Where is X defined?" → `find_definition`
- "Where is X used?" / "Find usages of X" → `find_references`
- "Rename X to Y" / "Refactor X" → `rename_symbol`
- "Check for errors" / "TypeScript issues" → `get_diagnostics`
- Understanding a function's callers → `find_references`
- Navigating to implementation → `find_definition`

### Why cclsp > Grep

| Grep Problems | cclsp Solution |
|---------------|----------------|
| Matches text in comments/strings | Understands actual code symbols |
| False positives (similar names) | Semantic accuracy |
| Can't rename safely | Atomic cross-file refactoring |
| No type awareness | Full TypeScript understanding |

### Workflow

```
BEFORE using Grep to find a symbol → STOP → Use mcp__cclsp__find_definition or mcp__cclsp__find_references instead
BEFORE doing find/replace refactoring → STOP → Use mcp__cclsp__rename_symbol instead
```

### Example Usage

```typescript
// User: "Where is the handleSubmit function defined?"
// ❌ WRONG: Grep(pattern="handleSubmit", ...)
// ✅ RIGHT: mcp__cclsp__find_definition(file_path="src/...", symbol_name="handleSubmit")

// User: "Rename getUserById to fetchUserById"
// ❌ WRONG: Multiple Edit calls with find/replace
// ✅ RIGHT: mcp__cclsp__rename_symbol(file_path="src/...", symbol_name="getUserById", new_name="fetchUserById")
```

## Codebase Exploration

### Directory Structure Analysis

**ALWAYS use `tree` command** to understand directory structure before:
- Analyzing architecture or project organization
- Making decisions about where to place new files
- Understanding the scope of a feature or module
- Answering questions about codebase structure

```bash
# Overview of project structure
tree -L 2

# Detailed view of specific directory
tree -L 3 <path>

# Show only directories
tree -d -L 3

# Include hidden files (for config exploration)
tree -a -L 2

# Filter by pattern
tree -P "*.ts" --prune -L 3
```

### Exploration Workflow

1. **First**: Run `tree -L 2` to get high-level overview
2. **Then**: Use `tree -L 3 <specific-dir>` for areas of interest
3. **Finally**: Use Read/Grep for specific file contents

## TypeScript Strict Typing

### Forbidden Patterns

**NEVER use these types** - they defeat the purpose of TypeScript:

| Type | Why it's bad | What to do instead |
|------|--------------|---------------------|
| `any` | Disables all type checking | Use proper types or `unknown` with type guards |
| `as any` | Type assertion escape hatch | Fix the underlying type issue |
| `// @ts-ignore` | Silences compiler errors | Fix the type error properly |
| `// @ts-expect-error` | Only acceptable with explanation | Prefer fixing the actual issue |

### Proper Use of Special Types

```typescript
// WRONG - using any
function process(data: any) { return data.value; }

// CORRECT - using unknown with type guard
function process(data: unknown) {
  if (isValidData(data)) {
    return data.value;
  }
  throw new Error('Invalid data');
}

// Type guard function
function isValidData(data: unknown): data is { value: string } {
  return typeof data === 'object' && data !== null && 'value' in data;
}
```

### When `unknown` is Acceptable

Use `unknown` ONLY when:
- Receiving data from external sources (API responses, user input)
- Parsing JSON
- Working with third-party libraries without types
- **Always** narrow with type guards before using

### When `never` is Acceptable

Use `never` ONLY for:
- Exhaustive switch/if checks
- Functions that always throw
- Impossible states in discriminated unions

```typescript
// Correct use of never - exhaustive check
function handleStatus(status: 'pending' | 'done' | 'error'): string {
  switch (status) {
    case 'pending': return 'Waiting...';
    case 'done': return 'Complete!';
    case 'error': return 'Failed';
    default:
      const _exhaustive: never = status;
      throw new Error(`Unhandled status: ${_exhaustive}`);
  }
}
```

### Type Inference Best Practices

- **Let TypeScript infer** when the type is obvious
- **Explicitly type** function parameters and return types
- **Explicitly type** exported functions and public APIs
- **Use const assertions** for literal types: `as const`

```typescript
// Let inference work - no need to annotate
const count = 0;                    // inferred as number
const items = ['a', 'b'];           // inferred as string[]

// Explicitly type function signatures
function calculateTotal(items: CartItem[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Use const for literal types
const CONFIG = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
} as const;
```

### Runtime Validation

For external data, use Zod for runtime validation:

```typescript
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(1),
});

type User = z.infer<typeof UserSchema>;

// Safe parsing with runtime validation
function parseUser(data: unknown): User {
  return UserSchema.parse(data);
}
```

### Strict tsconfig Settings

Ensure these are enabled in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "exactOptionalPropertyTypes": true
  }
}
```

## Code Quality Standards

### Before Committing

Always verify code quality:
```bash
# Type checking (if TypeScript project)
pnpm typecheck || npm run typecheck || yarn typecheck

# Linting
pnpm lint:fix || npm run lint:fix || yarn lint:fix

# Formatting
pnpm format:fix || npm run format:fix || yarn format:fix
```

### Error Handling

- Never swallow errors silently
- Log errors with context
- Provide meaningful error messages to users
- Use typed errors when possible

## Git Workflow

### Commit Messages

Follow conventional commits format:
- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Code refactoring
- `docs:` Documentation only
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

### Before Creating PRs

1. Ensure all tests pass
2. Run linting and formatting
3. Review changed files with `git diff`
4. Write clear PR description with context

## Communication Style

- Be concise and direct
- Explain the "why" not just the "what"
- Reference file paths with line numbers: `src/file.ts:42`
- Use code blocks with language hints for syntax highlighting

## Task Management

- Use TodoWrite for multi-step tasks
- Mark tasks complete immediately after finishing
- Break complex tasks into smaller actionable items
- Keep only ONE task in_progress at a time

## Security Awareness

- Never commit secrets, API keys, or credentials
- Check for `.env` files before committing
- Be cautious with user input (SQL injection, XSS, etc.)
- Validate data at system boundaries

## Performance Considerations

- Avoid premature optimization
- Profile before optimizing
- Consider bundle size for frontend code
- Use lazy loading for heavy components

## Documentation

- Document complex logic inline
- Keep README files up to date
- Prefer self-documenting code over comments
- Only create markdown files when explicitly requested
