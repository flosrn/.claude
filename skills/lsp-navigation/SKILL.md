---
name: lsp-navigation
description: TypeScript/JavaScript code navigation and refactoring using LSP tools (cclsp MCP). ALWAYS use when finding symbol definitions, finding all references/usages, renaming symbols across codebase, or checking TypeScript diagnostics/errors. Triggers on "where is defined", "find usages", "find references", "rename", "refactor", "TypeScript errors", "diagnostics", "go to definition", "who calls", "callers of".
---

# LSP Navigation & Refactoring (cclsp MCP)

This skill ensures Claude uses the **cclsp MCP server** for code navigation instead of grep-based searches.

## CRITICAL RULE

**NEVER use Grep/Glob to find symbol definitions or references.** Always use cclsp MCP tools which understand actual code semantics.

## Available MCP Tools

| Tool | Purpose | Example |
|------|---------|---------|
| `mcp__cclsp__find_definition` | Find where a symbol is defined | Where is `handleSubmit` defined? |
| `mcp__cclsp__find_references` | Find all usages of a symbol | Where is `UserContext` used? |
| `mcp__cclsp__rename_symbol` | Rename symbol across codebase | Rename `getData` to `fetchData` |
| `mcp__cclsp__get_diagnostics` | Get TypeScript errors for file | Check errors in `page.tsx` |

## When to Use (Automatic Triggers)

Use cclsp MCP when user asks:
- "Where is X defined?" -> `find_definition`
- "Where is X used?" / "Find usages of X" -> `find_references`
- "Rename X to Y" / "Refactor X" -> `rename_symbol`
- "Check for errors" / "TypeScript issues" -> `get_diagnostics`
- "Who calls this function?" -> `find_references`
- "Go to definition of X" -> `find_definition`

## Why cclsp > Grep

| Problem with Grep | cclsp Solution |
|-------------------|----------------|
| Matches text in comments/strings | Understands actual code symbols |
| False positives (similar names) | Semantic accuracy |
| Can't rename safely | Atomic cross-file refactoring |
| No type awareness | Full TypeScript understanding |

## Usage Examples

```
# Find definition
mcp__cclsp__find_definition(
  file_path="src/components/Form.tsx",
  symbol_name="handleSubmit"
)

# Find all references
mcp__cclsp__find_references(
  file_path="src/context/UserContext.tsx",
  symbol_name="UserContext",
  include_declaration=true
)

# Rename symbol
mcp__cclsp__rename_symbol(
  file_path="src/utils/api.ts",
  symbol_name="getData",
  new_name="fetchData"
)

# Get diagnostics
mcp__cclsp__get_diagnostics(
  file_path="src/app/page.tsx"
)
```

## Workflow

1. **Before searching for symbols** -> STOP -> Use `find_definition` or `find_references`
2. **Before find/replace refactoring** -> STOP -> Use `rename_symbol`
3. **To check TypeScript errors** -> Use `get_diagnostics`
