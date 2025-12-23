# Project Database Configuration

## Gapila

**Project path:** `/Users/flo/Code/nextjs/gapila`
**Project ID:** `gapila-backend`

### Ports

| Service | Port | URL |
|---------|------|-----|
| Next.js | 3001 | http://localhost:3001 |
| Supabase API | 54331 | http://127.0.0.1:54331 |
| Supabase DB | 54332 | postgresql://postgres:postgres@127.0.0.1:54332/postgres |
| Supabase Studio | 54333 | http://127.0.0.1:54333 |
| Inbucket (email) | 54334 | http://127.0.0.1:54334 |

### MCP Servers

```json
{
  "makerkit-gapila": {
    "type": "stdio",
    "command": "node",
    "args": ["/Users/flo/Code/nextjs/gapila/packages/mcp-server/build/index.js"]
  },
  "supabase-gapila-dev": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-postgres",
             "postgresql://postgres:postgres@127.0.0.1:54332/postgres",
             "--write"]
  },
  "supabase-gapila-prod": {
    "type": "http",
    "url": "https://mcp.supabase.com/mcp?project_ref=..."
  }
}
```

### Schema Files Location

```
/Users/flo/Code/nextjs/gapila/apps/web/supabase/schemas/
├── 00-privileges.sql     # Security setup
├── 01-enums.sql          # Enum types
├── 02-config.sql         # Configuration
├── 03-accounts.sql       # Accounts system
├── 04-roles.sql          # Role definitions
├── 05-memberships.sql    # Team memberships
├── 06-roles-permissions.sql
├── 07-invitations.sql
├── 08-billing-customers.sql
├── 09-subscriptions.sql
├── 10-orders.sql
├── 11-notifications.sql
├── 12-one-time-tokens.sql
├── 13-mfa.sql
├── 14-super-admin.sql
├── 15-account-views.sql
├── 16-storage.sql
└── 17-roles-seed.sql
```

---

## Lasdelaroute

**Project path:** `/Users/flo/Code/nextjs/lasdelaroute`
**Project ID:** `lasdelaroute-backend`

### Ports

| Service | Port | URL |
|---------|------|-----|
| Next.js | 3000 | http://localhost:3000 |
| Supabase API | 54321 | http://127.0.0.1:54321 |
| Supabase DB | 54322 | postgresql://postgres:postgres@127.0.0.1:54322/postgres |
| Supabase Studio | 54323 | http://127.0.0.1:54323 |
| Inbucket (email) | 54324 | http://127.0.0.1:54324 |

### MCP Servers

```json
{
  "makerkit-las": {
    "type": "stdio",
    "command": "node",
    "args": ["/Users/flo/Code/nextjs/lasdelaroute/packages/mcp-server/build/index.js"]
  },
  "supabase-las-prod": {
    "type": "http",
    "url": "https://mcp.supabase.com/mcp?project_ref=ebyqlzbnwfeikwwyuxdb"
  }
}
```

---

## Quick Port Reference

```
              | gapila | lasdelaroute |
--------------+--------+--------------+
Next.js       | 3001   | 3000         |
Supabase API  | 54331  | 54321        |
Supabase DB   | 54332  | 54322        |
Studio        | 54333  | 54323        |
Inbucket      | 54334  | 54324        |
```

**Memory trick:**
- Gapila uses `543xx` (x = 31, 32, 33, 34)
- Lasdelaroute uses `5432x` (default Supabase ports)

---

## Detecting Current Project

Use the working directory to determine which project:

```bash
# In hooks or scripts
if [[ "$PWD" == *"gapila"* ]]; then
  DB_PORT=54332
  PROJECT="gapila"
elif [[ "$PWD" == *"lasdelaroute"* ]]; then
  DB_PORT=54322
  PROJECT="lasdelaroute"
fi
```

The makerkit plugin includes detection scripts at:
- `${CLAUDE_PLUGIN_ROOT}/scripts/detect-project.sh`
- `${CLAUDE_PLUGIN_ROOT}/scripts/project-status.sh`
