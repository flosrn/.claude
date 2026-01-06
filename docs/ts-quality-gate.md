# TypeScript Quality Gate - Complete Documentation

> A PostToolUse hook that automatically validates TypeScript files after Write/Edit operations.

## Overview

The TypeScript Quality Gate is a **PostToolUse hook** that runs after every file write to TypeScript files (`.ts`, `.tsx`). It ensures code quality by running Prettier, ESLint, and TypeScript checks immediately after modifications.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TS QUALITY GATE FLOW                                     │
└─────────────────────────────────────────────────────────────────────────────┘

    Claude writes file              Hook triggers              Feedback injected
    ─────────────────              ─────────────              ─────────────────
┌────────────────────┐         ┌─────────────────────┐     ┌─────────────────────┐
│ Write tool:        │    →    │ 1. Prettier --write │  →  │ 🔴 3 ESLint errors  │
│ src/auth/login.tsx │         │ 2. ESLint --fix     │     │ 🔵 1 TypeScript err │
│                    │         │ 3. ESLint check     │     │ in login.tsx        │
└────────────────────┘         │ 4. TypeScript check │     │                     │
                               └─────────────────────┘     │ Fix NOW the errors  │
                                                           └─────────────────────┘
```

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Auto-format** | Prettier runs first, formatting code automatically |
| **Auto-fix** | ESLint `--fix` resolves simple issues |
| **Immediate feedback** | Errors reported in the same turn |
| **Turbo-aware** | Uses `turbo typecheck` when available (cached, faster) |
| **Monorepo-smart** | Finds nearest `tsconfig.json` for accurate type checking |
| **Minimal output** | Only shows errors for the modified file |

---

## How It Works

### 1. File Detection

```typescript
// Only triggers for TypeScript files
if (!filePath.endsWith(".ts") && !filePath.endsWith(".tsx")) {
  process.exit(0); // Skip non-TS files
}
```

### 2. Project Root Discovery

The hook locates the project root by searching upward for:
1. `pnpm-workspace.yaml` (monorepo root)
2. `package.json` with `workspaces` field
3. Any `package.json` (fallback)

### 3. tsconfig.json Discovery

For accurate type checking, finds the nearest `tsconfig.json`:
- Searches upward from the file location
- Stops at project root
- Falls back to project root tsconfig

### 4. Tool Availability Check

Detects available tools:
```typescript
const hasPrettier = existsSync(join(projectRoot, "node_modules/.bin/prettier"));
const hasEslint = hasEslintBin && hasEslintConfig; // Needs config + binary
const hasTypeScript = hasTscBin && tsconfigDir !== null;
```

**ESLint Config Requirement** (ESLint 9+):
- Requires `eslint.config.js`, `eslint.config.mjs`, or `eslint.config.cjs`
- Legacy `.eslintrc.*` files are NOT supported

### 5. Validation Pipeline

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  1. Prettier    │ →   │  2. ESLint      │ →   │  3. ESLint      │ →   │  4. TypeScript  │
│  --write        │     │  --fix          │     │  (check only)   │     │  --noEmit       │
│  (format)       │     │  (auto-fix)     │     │  (report)       │     │  (type check)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘     └─────────────────┘
```

---

## Turbo Integration

When `turbo.json` exists at project root, the hook uses Turbo for TypeScript checking:

```bash
# Without Turbo
tsc --noEmit -p tsconfig.json

# With Turbo (much faster with caching)
pnpm turbo run typecheck --filter=@kit/web
```

**Benefits**:
- Cached type checks (skip if unchanged)
- Parallel package checking
- Faster feedback in monorepos

---

## Output Format

### Success (No Output)

When all checks pass, the hook outputs nothing and exits silently.

### Errors Found

```
🔴 2 ESLint errors • 🔵 1 TypeScript error in login.tsx
│ src/auth/login.tsx
│   2:15  error  'Response' is defined but never used  @typescript-eslint/no-unused-vars
│   5:8   error  Missing return type                   @typescript-eslint/explicit-function-return-type
│ src/auth/login.tsx(12,5): error TS2322: Type 'string' is not assignable to type 'number'
```

### System Message Injection

The hook injects a `systemMessage` that Claude sees:

```json
{
  "systemMessage": "\n🔴 2 ESLint errors • 🔵 1 TypeScript error in login.tsx\n│ [error details]",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Fix NOW the following errors AND warnings detected in login.tsx:\n\n[full details]"
  }
}
```

---

## Configuration

### Hook Registration

In `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bun ~/.claude/scripts/hook-ts-quality-gate.ts"
          }
        ]
      }
    ]
  }
}
```

### Timeouts

| Operation | Timeout |
|-----------|---------|
| Prettier | 10 seconds |
| ESLint --fix | 10 seconds |
| ESLint check | 10 seconds |
| TypeScript | 30 seconds |

### Log File

Tool usage is logged to: `~/.claude/tool-usage.log`

```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "session_id": "abc123",
  "tool_use_id": "xyz789",
  "tool_name": "Write",
  "file_path": "/path/to/file.ts",
  "status": "error",
  "errors": ["ESLint errors:\n..."]
}
```

---

## Source Code Analysis

**Location**: `~/.claude/scripts/hook-ts-quality-gate.ts`

### Key Functions

#### `findProjectRoot(filePath: string)`

Searches upward for project root indicators:
1. `pnpm-workspace.yaml` (monorepo)
2. `package.json` with `workspaces`
3. Any `package.json` (fallback)

#### `runCommand(command: string[], cwd?: string, timeoutMs?: number)`

Executes shell commands with:
- Timeout handling (process killed if exceeded)
- stdout/stderr capture
- Success/failure detection

#### `main()`

1. Parse hook input from stdin
2. Extract file path
3. Skip non-TypeScript files
4. Find project root
5. Run validation pipeline
6. Collect and format errors
7. Output hook response (if errors found)

---

## Error Filtering

The hook filters TypeScript errors to show only those in the modified file:

```typescript
// Get relative path for matching
const relativeToTsconfig = filePath.replace(tsconfigDir + "/", "");

// Only show errors for this specific file
if (cleanLine.startsWith(relativeToTsconfig) && cleanLine.includes("error TS")) {
  tsErrors.push(cleanLine);
}
```

**Turbo output handling**: Removes turbo prefix (e.g., `@kit/web:typecheck:`) before matching.

---

## Integration with TypeScript Strict Rules

The hook works alongside the global TypeScript rules in `~/.claude/rules/typescript.md`:

```markdown
## TypeScript Strict Rules

**NEVER use:**
- `any` or `as any` - Use proper types or `unknown` with type guards
- `@ts-ignore` / `@ts-expect-error` - Fix the actual type error
- Type assertions without validation (`as SomeType`)

**For external data (API responses, user input, env vars):**
Use Zod schemas for runtime validation.
```

The quality gate enforces these rules by failing on type errors.

---

## Troubleshooting

### "No project root found"

**Cause**: No `package.json` found in parent directories
**Solution**: Ensure you're in a valid project directory

### ESLint not running

**Cause**: Missing ESLint config file (ESLint 9+ requirement)
**Solution**: Create `eslint.config.js`:
```javascript
export default [
  // Your ESLint config
];
```

### TypeScript timeout

**Cause**: Large project with slow type checking
**Solution**:
- Use Turbo (`turbo.json`) for caching
- Add incremental build in `tsconfig.json`
- Consider `--skipLibCheck`

### Prettier not formatting

**Cause**: Prettier not installed or failing
**Solution**: Check `node_modules/.bin/prettier` exists

---

## Behavior Matrix

| Tool | Installed | Config | Action |
|------|-----------|--------|--------|
| Prettier | ✅ | N/A | Format file |
| Prettier | ❌ | N/A | Skip |
| ESLint | ✅ | ✅ | --fix then check |
| ESLint | ✅ | ❌ | Skip |
| ESLint | ❌ | Any | Skip |
| TypeScript | ✅ | ✅ | Type check |
| TypeScript | ✅ | ❌ | Skip (no tsconfig) |
| TypeScript | ❌ | Any | Skip |

---

## Performance Considerations

1. **First run is slowest**: TypeScript caches type information
2. **Turbo dramatically improves speed**: Cached checks skip unchanged packages
3. **Monorepo overhead**: Finding project root takes time in deep directories
4. **Timeouts are generous**: 30s for TypeScript allows for large projects

---

## Best Practices

1. **Don't ignore errors** - The gate exists to catch issues early
2. **Fix immediately** - Errors compound if left unaddressed
3. **Use Turbo** - Significantly speeds up type checking
4. **Keep ESLint config modern** - Use flat config (`eslint.config.js`)
5. **Trust Prettier** - Let it handle formatting, focus on logic
