---
name: database-mcp
description: Guide for using database MCP servers effectively in Makerkit projects. Use when querying databases, analyzing schemas, exploring tables, running SQL, or working with Supabase data. Triggers on "query database", "SQL", "MCP database", "analyze table", "database schema", "supabase query", "postgres", "execute SQL", "database tools".
---

# Database MCP Usage Guide

This skill teaches how to effectively use the available database MCP servers for Makerkit projects (gapila and lasdelaroute).

## Project Configuration

| Project | Next.js | Supabase API | Supabase DB | Studio |
|---------|---------|--------------|-------------|--------|
| **gapila** | 3001 | 54331 | 54332 | 54333 |
| **lasdelaroute** | 3000 | 54321 | 54322 | 54323 |

## MCP Decision Matrix

Use this table to choose the right MCP for your task:

| Task | MCP to Use | Why |
|------|-----------|-----|
| Explore schema structure | `makerkit-*` | Knows project schema files, topics, source mapping |
| List tables/functions | `makerkit-*` | Returns structured info with file sources |
| Understand a function's purpose | `makerkit-*` | Has purpose extraction and descriptions |
| Run SELECT queries | `supabase-*-dev` (Postgres) | Direct SQL execution |
| Run INSERT/UPDATE/DELETE | `supabase-*-dev` (Postgres) | Write access enabled |
| Query production data | `supabase-*-prod` (HTTP) | Read-only, safe for prod |
| Debug RLS policies | `supabase-*-dev` (Postgres) | Can test as different roles |
| Get enum values | `makerkit-*` | `get_all_enums` tool |
| Analyze table relationships | `makerkit-*` | FK info with source file context |

## Available MCP Servers

### Gapila Project

| Server | Type | Purpose | Port/URL |
|--------|------|---------|----------|
| `makerkit-gapila` | stdio | Schema exploration, functions, PRDs | Local |
| `supabase-gapila-dev` | Postgres | SQL queries (read/write) | 54332 |
| `supabase-gapila-prod` | HTTP | Production monitoring | mcp.supabase.com |

### Lasdelaroute Project

| Server | Type | Purpose | Port/URL |
|--------|------|---------|----------|
| `makerkit-las` | stdio | Schema exploration, functions, PRDs | Local |
| `supabase-las-prod` | HTTP | Production monitoring | mcp.supabase.com |

## MCP Makerkit Tools

The custom `makerkit-*` MCP provides these database tools:

### Schema Exploration
- `get_schema_files` - List all schema SQL files with topics
- `get_schema_content` - Read raw SQL of a schema file
- `get_schemas_by_topic` - Find schemas by topic (auth, billing, accounts, etc.)

### Table Analysis
- `get_database_tables` - List all project tables
- `get_table_info` - Detailed table schema (columns, FK, indexes)
- `get_database_summary` - Overview of entire database

### Function Discovery
- `get_database_functions` - All functions with purposes
- `get_function_details` - Detailed function info
- `search_database_functions` - Search by name/purpose

### Type Information
- `get_all_enums` - All enum types and values
- `get_enum_info` - Specific enum details

## MCP Postgres Tools

The `supabase-*-dev` Postgres MCP provides:

- `query` - Execute SELECT queries
- `execute` - Execute INSERT/UPDATE/DELETE (if write enabled)

## Usage Examples

### Explore Schema Structure
```
Use makerkit-gapila MCP:
- get_schema_files to list all schemas
- get_schemas_by_topic("billing") for billing-related schemas
- get_table_info("public", "subscriptions") for table details
```

### Run a Query
```
Use supabase-gapila-dev MCP:
- query: SELECT * FROM accounts LIMIT 5
```

### Understand a Function
```
Use makerkit-gapila MCP:
- get_function_details("has_permission")
- Returns: purpose, parameters, security level, source file
```

## Best Practices

1. **Start with makerkit MCP** for understanding schema before writing queries
2. **Use Postgres MCP** only for actual SQL execution
3. **Never use prod MCP** for write operations
4. **Check ports** - gapila uses 543xx, lasdelaroute uses 5432x
5. **Prefer functions over raw SQL** when they exist (better RLS handling)

## Common Mistakes to Avoid

- Using port 54322 for gapila (wrong - that's lasdelaroute)
- Using port 3000 for gapila web app (wrong - it's 3001)
- Querying prod when you meant dev
- Writing raw SQL when a function exists for the operation

## Reference Files

- [mcp-comparison.md](references/mcp-comparison.md) - Detailed MCP feature comparison
- [project-config.md](references/project-config.md) - Full project configurations
