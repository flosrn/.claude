---
name: lsp-navigation
description: Code navigation using cclsp LSP tools. Use for finding definitions, references, renaming symbols, or checking TypeScript diagnostics.
---

# LSP Navigation (cclsp)

Use cclsp MCP tools for semantic code navigation.

## Tools

| Tool | Use Case |
|------|----------|
| `mcp__cclsp__find_definition` | Find where a symbol is defined |
| `mcp__cclsp__find_references` | Find all usages of a symbol |
| `mcp__cclsp__rename_symbol` | Rename symbol across codebase |
| `mcp__cclsp__get_diagnostics` | Get TypeScript errors for a file |

## Examples

```
mcp__cclsp__find_definition(file_path="src/api.ts", symbol_name="fetchUser")
mcp__cclsp__find_references(file_path="src/api.ts", symbol_name="fetchUser")
mcp__cclsp__rename_symbol(file_path="src/api.ts", symbol_name="fetchUser", new_name="getUser")
mcp__cclsp__get_diagnostics(file_path="src/app/page.tsx")
```
