---
name: betterstack-logs
description: Query Better Stack production logs for debugging Vercel/Next.js errors using the bslog CLI. ALWAYS use this skill FIRST when debugging production issues, checking error logs, or investigating crashes — before Vercel MCP, Vercel dashboard, or any other log tool. Triggers on "logs", "production error", "vercel error", "betterstack", "bslog", "check logs", "debug prod", "erreur prod", "voir les logs", "chercher dans les logs", "what's crashing", "why is it broken", "500 error", "TypeError", "crash", "page plante", "ça marche pas en prod", "check the errors", "runtime error", "stack trace", "les logs disent quoi". This gives full untruncated error messages with stack traces — unlike Vercel logs which truncate.
---

# Better Stack Logs — Production Debugging

## Why this exists

Vercel runtime logs truncate error messages and their MCP API is unreliable for SSR errors (they return HTTP 200 even when error boundaries catch crashes). Better Stack receives ALL Vercel logs via log drain with **full messages, stack traces, and deployment context** — nothing is truncated.

## Prerequisites

- `bslog` CLI installed globally (`@steipete/bslog`)
- Environment variables configured: `BETTERSTACK_API_TOKEN`, `BETTERSTACK_QUERY_USERNAME`, `BETTERSTACK_QUERY_PASSWORD`
- Default source: `gapila` (Vercel integration)

## Quick reference

### Most common commands

```bash
# Recent errors (start here for any production issue)
bslog errors --since 24h -n 20

# Search for a specific error pattern
bslog search "TypeError" --since 7d -n 10

# Search for errors on a specific path
bslog search "/api/billing" --since 24h -n 10

# Live tail (real-time monitoring)
bslog tail

# Errors from last hour only
bslog errors --since 1h -n 50
```

### Advanced queries

```bash
# Raw ClickHouse SQL for complex filtering
bslog sql "SELECT dt, message FROM remote(t378272_gapila_2_logs) WHERE message LIKE '%Cannot read properties%' ORDER BY dt DESC LIMIT 20"

# Search with JSON output for programmatic processing
bslog errors --since 24h -n 10 --format json

# Warnings (not just errors)
bslog warnings --since 24h -n 20

# Trace a specific request across all logs
bslog trace <requestId>
```

## Debugging workflow

When investigating a production error:

1. **Start with `bslog errors --since 24h`** to see all recent errors
2. **Look at the error message + stack trace** — Better Stack shows the full untruncated message
3. **Note the `vercel.path`** in the output to identify which route is affected
4. **Note the `vercel.branch` and `vercel.deployment_id`** to know which deployment caused it
5. **Use `bslog search "<key phrase>"` to find related occurrences** and understand frequency
6. **Grep the codebase** for the property/method name in the error to find the crash site

## Output format

Each log entry includes:
- **Timestamp** and **level** (ERROR, WARN, etc.)
- **Full error message** with stack trace (no truncation)
- **Vercel metadata**: branch, deployment_id, environment (production/preview), path, host, request_id, client_ip, user_agent, region

## Time range syntax

- `1h`, `2h`, `6h` — hours
- `1d`, `7d`, `30d` — days
- `1w` — week
- ISO timestamps: `2026-03-15T00:00:00`

## On the VPS

`bslog` is also installed on the VPS with credentials in `~/.bashrc` and in the OpenClaw Docker container environment. Agents on the VPS can use the same commands.
