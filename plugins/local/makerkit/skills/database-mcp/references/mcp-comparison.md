# MCP Database Server Comparison

## Feature Matrix

| Feature | MCP Makerkit | MCP Postgres | MCP Supabase (HTTP) |
|---------|--------------|--------------|---------------------|
| Schema exploration | ✅ Rich | ❌ None | ⚠️ Basic |
| SQL SELECT | ❌ No | ✅ Yes | ✅ Yes |
| SQL INSERT/UPDATE/DELETE | ❌ No | ✅ Yes (if enabled) | ❌ Read-only |
| Function documentation | ✅ With purpose | ❌ None | ❌ None |
| Source file mapping | ✅ Yes | ❌ No | ❌ No |
| Topic categorization | ✅ Yes | ❌ No | ❌ No |
| Enum introspection | ✅ Yes | ⚠️ Manual query | ⚠️ Manual query |
| Production safe | ✅ Yes | ⚠️ Depends | ✅ Yes |
| Local development | ✅ Yes | ✅ Yes | ❌ Cloud only |
| Project logs | ❌ No | ❌ No | ✅ Yes |
| Branching | ❌ No | ❌ No | ✅ Yes |

## When to Use Each

### MCP Makerkit (`makerkit-gapila` / `makerkit-las`)

**Best for:**
- Understanding database structure before writing code
- Finding which schema file defines a table
- Learning what functions are available and their purposes
- Getting enum values without writing SQL
- Exploring relationships between tables

**Tools available:**
```
get_schema_files          - List schema SQL files
get_schema_content        - Read schema file content
get_schemas_by_topic      - Filter by topic
get_database_tables       - List all tables
get_table_info            - Table details (columns, FK, indexes)
get_database_summary      - Full DB overview
get_database_functions    - All functions
get_function_details      - Specific function info
search_database_functions - Search functions
get_all_enums             - All enum types
get_enum_info             - Specific enum
```

### MCP Postgres (`supabase-*-dev`)

**Best for:**
- Running actual SQL queries
- Testing data operations
- Debugging query results
- Inserting test data
- Verifying RLS policies work

**Connection string pattern:**
```
postgresql://postgres:postgres@127.0.0.1:{PORT}/postgres
```

**Ports:**
- gapila: 54332
- lasdelaroute: 54322

### MCP Supabase HTTP (`supabase-*-prod`)

**Best for:**
- Monitoring production
- Viewing logs
- Read-only production queries
- Managing branches (if using Supabase branching)

**Never use for:**
- Write operations
- Testing with fake data
- Development work

## Workflow Examples

### "I need to understand the accounts system"

1. `makerkit-gapila` → `get_schemas_by_topic("accounts")`
2. `makerkit-gapila` → `get_schema_content("03-accounts.sql")`
3. `makerkit-gapila` → `get_table_info("public", "accounts")`
4. `makerkit-gapila` → `search_database_functions("account")`

### "I need to query subscription data"

1. `makerkit-gapila` → `get_table_info("public", "subscriptions")` (understand structure)
2. `supabase-gapila-dev` → `SELECT * FROM subscriptions WHERE status = 'active' LIMIT 10`

### "I need to add a new permission check"

1. `makerkit-gapila` → `search_database_functions("permission")`
2. `makerkit-gapila` → `get_function_details("has_permission")`
3. Understand the pattern, then implement similar

### "I need to debug why RLS is blocking"

1. `makerkit-gapila` → `get_schemas_by_topic("permissions")`
2. `makerkit-gapila` → `get_schema_content("06-roles-permissions.sql")`
3. `supabase-gapila-dev` → Test query as specific user
