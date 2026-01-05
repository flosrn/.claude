# Next.js 16 & React 19 Optimizer Plugin

Comprehensive optimization patterns for Next.js 16 and React 19 applications. Covers Cache Components, React Compiler, code splitting, and performance best practices.

## Features

### Skills (Auto-activated Knowledge)

Skills activate automatically when you ask about relevant topics:

| Skill | Triggers | Topics Covered |
|-------|----------|----------------|
| **nextjs-migration** | "upgrade Next.js", "migrate to Next 16", "breaking changes" | Complete 15→16 migration guide, proxy.ts, codemods |
| **cache-components** | "use cache", "cacheLife", "cacheTag", "cache invalidation" | Next.js 16 Cache Components, migration from old patterns |
| **react-compiler** | "React Compiler", "automatic memoization", "remove useMemo" | React 19 auto-memoization, CannotPreserveMemoization errors |
| **react19-patterns** | "useContext", "use() hook", "Context.Provider", "ViewTransition" | React 19 new patterns: use() hook, Context shorthand, ViewTransition |
| **performance-patterns** | "Server Components", "Suspense", "streaming", "PPR" | RSC patterns, data fetching, loading states |
| **code-splitting** | "dynamic imports", "barrel files", "bundle size" | next/dynamic, tree shaking, optimizePackageImports |

### Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `/next-react-optimizer:analyze` | Analyze code for optimization opportunities | `/next-react-optimizer:analyze [path]` |
| `/next-react-optimizer:migrate-caching` | Migrate old caching patterns to Cache Components | `/next-react-optimizer:migrate-caching [--dry-run]` |

### Agents

| Agent | Triggers | Purpose |
|-------|----------|---------|
| **optimization-analyzer** | "optimize my app", "analyze performance", editing page.tsx/layout.tsx | Proactive + on-request optimization analysis |

## Context7 Integration

This plugin includes Context7 MCP configuration for fetching live documentation:

- **Next.js**: `/vercel/next.js/v16.0.3` - Latest Next.js 16 docs
- **React**: `/facebook/react/v19_1_1` - Latest React 19 docs

When skills or agents need detailed information, they query Context7 for up-to-date content.

## Installation

The plugin is located at:
```
~/.claude/plugins/local/next-react-optimizer/
```

It auto-loads when Claude Code starts. Restart Claude Code after installation.

## Usage Examples

### Ask Questions (Skills Activate Automatically)

```
"How do I use cache components in Next.js 16?"
→ Loads cache-components skill

"What does the React Compiler do?"
→ Loads react-compiler skill

"How do I fix barrel file imports?"
→ Loads code-splitting skill

"When should I use Server Components vs Client Components?"
→ Loads performance-patterns skill
```

### Run Commands

```bash
# Analyze entire project
/next-react-optimizer:analyze

# Analyze specific file or directory
/next-react-optimizer:analyze app/products/

# Preview caching migration without changes
/next-react-optimizer:migrate-caching --dry-run

# Execute caching migration
/next-react-optimizer:migrate-caching
```

### Trigger Agent

```
"Optimize my Next.js app"
"Analyze my React code for performance issues"
"Review this component for optimization opportunities"
```

The agent also triggers proactively after editing:
- `page.tsx`, `layout.tsx`, `loading.tsx` files
- Components with data fetching
- Files with `use client` directive

## What Gets Analyzed

The **analyze** command checks for:

1. **Old Caching Patterns** - `fetchCache`, `force-static`, `revalidate` exports
2. **Manual Memoization** - `useMemo`, `useCallback`, `memo()` usage
3. **Client Component Usage** - Unnecessary `use client` directives
4. **Barrel File Issues** - Index file re-exports causing bundle bloat
5. **Bundle Configuration** - Missing `optimizePackageImports`

## Migration Support

The **migrate-caching** command handles:

| Old Pattern | Migrated To |
|-------------|-------------|
| `export const fetchCache = 'force-cache'` | `'use cache'` directive |
| `export const dynamic = 'force-static'` | `'use cache'` directive |
| `export const revalidate = N` | `cacheLife({ revalidate: N })` |
| `fetch(..., { cache: 'force-cache' })` | `'use cache'` on function |

## File Structure

```
next-react-optimizer/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── .mcp.json                 # Context7 MCP configuration
├── agents/
│   └── optimization-analyzer.md
├── commands/
│   ├── analyze.md
│   └── migrate-caching.md
├── skills/
│   ├── cache-components/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── code-splitting/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── performance-patterns/
│   │   ├── SKILL.md
│   │   └── references/
│   └── react-compiler/
│       ├── SKILL.md
│       └── references/
└── README.md
```

## Prerequisites

- **Next.js 16+** for Cache Components features
- **React 19** or React Compiler enabled for auto-memoization
- **Claude Code** with plugins enabled

## Resources

- [Next.js 16 Blog Post](https://nextjs.org/blog/next-16)
- [React Compiler Announcement](https://react.dev/blog/2025/10/07/react-compiler-1)
- [Cache Components Docs](https://nextjs.org/docs/app/getting-started/cache-components)
