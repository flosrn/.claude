---
name: docs-lookup
description: Fetch up-to-date documentation for any library, framework, or package using Context7 MCP. ALWAYS use when user asks about library features, API usage, implementation patterns, "how to do X with Y library", documentation searches, or needs current docs instead of potentially outdated knowledge. Triggers on "documentation", "docs", "how to use", "API", "examples", "library", "framework", "package", "latest", "current version".
---

# Documentation Lookup (Context7 MCP)

This skill ensures Claude fetches **current, accurate documentation** for any library instead of relying on potentially outdated training data.

## CRITICAL RULE

**When user asks about library/framework usage, ALWAYS use Context7 MCP first** to get up-to-date documentation before implementing.

## Available MCP Tools

| Tool | Purpose |
|------|---------|
| `mcp__plugin_next-react-optimizer_context7__resolve-library-id` | Find Context7 library ID for a package |
| `mcp__plugin_next-react-optimizer_context7__get-library-docs` | Fetch documentation for a library |

## When to Use (Automatic Triggers)

Use Context7 MCP when user asks:
- "How do I use X library?"
- "What's the API for Y?"
- "Show me documentation for Z"
- "How to implement A with B framework"
- "What are the options for X?"
- "Latest features in Y"
- Questions about library-specific patterns

## Workflow

### Step 1: Resolve Library ID
```
mcp__plugin_next-react-optimizer_context7__resolve-library-id(
  libraryName="react-query"
)
```

### Step 2: Fetch Documentation
```
mcp__plugin_next-react-optimizer_context7__get-library-docs(
  context7CompatibleLibraryID="/tanstack/query",
  topic="useQuery hooks",
  mode="code"  // or "info" for conceptual guides
)
```

## Mode Selection

| Mode | Use When |
|------|----------|
| `code` | API references, code examples, implementation patterns |
| `info` | Conceptual guides, architecture, decision rationale |

## Common Libraries

| Library | Likely ID Pattern |
|---------|------------------|
| React | `/facebook/react` |
| Next.js | `/vercel/next.js` |
| TanStack Query | `/tanstack/query` |
| Tailwind CSS | `/tailwindlabs/tailwindcss` |
| Drizzle ORM | `/drizzle-team/drizzle-orm` |

## Why Context7 > Knowledge Cutoff

- Training data may be outdated (cutoff: Jan 2025)
- Library APIs change frequently
- New features not in training
- Deprecations and breaking changes
- Accurate code examples

## Example Usage

User asks: "How do I use useSuspenseQuery in TanStack Query?"

```
# 1. Resolve
mcp__plugin_next-react-optimizer_context7__resolve-library-id(libraryName="tanstack query")

# 2. Fetch docs
mcp__plugin_next-react-optimizer_context7__get-library-docs(
  context7CompatibleLibraryID="/tanstack/query",
  topic="useSuspenseQuery",
  mode="code"
)
```
