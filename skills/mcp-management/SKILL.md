# MCP Management Skill

Expert guidance for configuring and managing MCP (Model Context Protocol) servers in Claude Code.

## When to Use This Skill

Use when:
- Adding, removing, or configuring MCP servers
- Understanding MCP scopes (user, local, project, enterprise)
- Troubleshooting MCP connection issues
- Setting up team-shared MCP configurations
- Configuring enterprise MCP policies

**Trigger phrases:**
- "add mcp server", "configure mcp", "mcp scope"
- "share mcp with team", "project mcp"
- "mcp not working", "mcp authentication"

## MCP Scopes (Critical Concept)

### Scope Hierarchy (Precedence: Local > Project > User)

| Scope | Storage | Visibility | Use Case |
|-------|---------|------------|----------|
| **local** (default) | `~/.claude.json` → `projects.<path>.mcpServers` | Private, current project only | Personal dev servers, sensitive credentials |
| **project** | `<project>/.mcp.json` | Team-shared (version controlled) | Standard project tools, team collaboration |
| **user** | `~/.claude.json` → `mcpServers` | All your projects | Personal utilities across projects |
| **enterprise** | System directories | Organization-wide | IT-managed servers |

### Storage Locations

```
~/.claude.json
├── mcpServers: { ... }              # USER scope
└── projects:
    └── "/path/to/project":
        └── mcpServers: { ... }      # LOCAL scope

<project>/.mcp.json                   # PROJECT scope (git tracked)

/Library/Application Support/ClaudeCode/managed-mcp.json  # ENTERPRISE (macOS)
/etc/claude-code/managed-mcp.json                         # ENTERPRISE (Linux)
```

## Adding MCP Servers

### By Transport Type

```bash
# HTTP (recommended for remote servers)
claude mcp add --transport http <name> <url>
claude mcp add --transport http notion https://mcp.notion.com/mcp

# SSE (deprecated, use HTTP when available)
claude mcp add --transport sse <name> <url>

# Stdio (local servers)
claude mcp add --transport stdio <name> -- <command> [args...]
claude mcp add --transport stdio airtable -- npx -y airtable-mcp-server
```

### With Scope

```bash
# Local scope (default) - private, current project
claude mcp add --transport http stripe https://mcp.stripe.com

# Project scope - shared with team via .mcp.json
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp

# User scope - available in all your projects
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
```

### With Environment Variables

```bash
# Pass env vars for sensitive data
claude mcp add --transport stdio db --env DATABASE_URL=YOUR_URL -- npx -y @bytebase/dbhub
```

### With Authentication Headers

```bash
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

## Managing Servers

```bash
# List all configured servers
claude mcp list

# Get details for a specific server
claude mcp get github

# Remove a server
claude mcp remove github

# Check server status (within Claude Code)
/mcp

# Reset project scope approvals
claude mcp reset-project-choices
```

## Project Scope (.mcp.json)

### File Format

```json
{
  "mcpServers": {
    "server-name": {
      "command": "/path/to/server",
      "args": ["--flag", "value"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

### Environment Variable Expansion

Supported in `.mcp.json`:
- `${VAR}` - Expands to env var value
- `${VAR:-default}` - Uses default if not set

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

### Plugin MCP Servers

Plugins can bundle MCP servers using `${CLAUDE_PLUGIN_ROOT}`:

```json
{
  "mcpServers": {
    "plugin-api": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/api-server",
      "args": ["--port", "8080"]
    }
  }
}
```

## Authentication

### OAuth 2.0 Flow

```bash
# 1. Add server
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp

# 2. Authenticate in Claude Code
> /mcp
# Select "Authenticate" and follow browser flow
```

### Clear Authentication

Use `/mcp` menu → "Clear authentication"

## Enterprise Configuration

### managed-mcp.json (Exclusive Control)

Deploys fixed servers, users cannot add their own:

```json
{
  "mcpServers": {
    "github": { "type": "http", "url": "https://api.githubcopilot.com/mcp/" },
    "company-internal": {
      "type": "stdio",
      "command": "/usr/local/bin/company-mcp-server"
    }
  }
}
```

### Allowlist/Denylist (Policy Control)

In managed settings file:

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverCommand": ["npx", "-y", "approved-package"] },
    { "serverUrl": "https://mcp.company.com/*" }
  ],
  "deniedMcpServers": [
    { "serverName": "dangerous-server" },
    { "serverUrl": "https://*.untrusted.com/*" }
  ]
}
```

## Troubleshooting

### Server Not Starting

```bash
# Test server command manually
npx -y @modelcontextprotocol/server-filesystem /tmp

# Check logs
cat ~/.claude/logs/mcp-*.log

# Verify environment variables
echo $GITHUB_TOKEN
```

### Connection Errors

```bash
# Test network
curl https://api.example.com/mcp

# Check proxy settings
echo $HTTP_PROXY
```

### Output Limits

```bash
# Increase max output tokens for large responses
export MAX_MCP_OUTPUT_TOKENS=50000
claude
```

### Windows Notes

Use `cmd /c` wrapper for npx on native Windows:

```bash
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

## MCP Resources and Prompts

### Reference Resources

```
> Can you analyze @github:issue://123?
> Review @docs:file://api/authentication
```

### Execute MCP Prompts

```
> /mcp__github__list_prs
> /mcp__jira__create_issue "Bug title" high
```

## Quick Reference Commands

| Action | Command |
|--------|---------|
| Add HTTP server | `claude mcp add --transport http <name> <url>` |
| Add stdio server | `claude mcp add --transport stdio <name> -- <cmd>` |
| Add to project scope | `claude mcp add --scope project ...` |
| Add to user scope | `claude mcp add --scope user ...` |
| List servers | `claude mcp list` |
| Check status | `/mcp` |
| Authenticate | `/mcp` → select server |
| Remove server | `claude mcp remove <name>` |
| Import from Desktop | `claude mcp add-from-claude-desktop` |
