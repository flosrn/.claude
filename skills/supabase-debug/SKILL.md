---
name: supabase-debug
description: "Debug Supabase production database — run read-only SQL queries, check slow queries, table stats, cache hit rates, index usage, and query Supabase service logs (postgres, auth, API). ALWAYS use this skill when the user asks about production data, database performance, slow queries, or wants to look up stats. Triggers on: \"slow query\", \"table stats\", \"db stats\", \"cache hit\", \"requête lente\", \"stats base\", \"combien de\", \"données prod\", \"production data\", \"db debug\", \"psql\", \"inspect db\", \"vacuum\", \"bloat\", \"dead tuples\", \"index usage\", \"long running\", \"connexions actives\", \"supabase logs\", \"auth logs\", \"postgres logs\", \"combien de participants\", \"combien de campagnes\", \"nombre de gagnants\", \"stats joueurs\", \"données clients\". Even if the user just asks a data question like \"how many users signed up this week\", use this skill to query the answer."
---

# Supabase Debug — Production Database & Logs

Three tools for three different needs. Pick the right one for the job.

## Tool 1: psql — Arbitrary SQL queries

For data lookups, counts, joins, and any custom query. The connection goes through Supavisor (connection pooler) so it's safe to use from scripts and agents.

```bash
psql "$SUPABASE_DATABASE_URL" -c "<SQL query>"
```

Useful flags:
- `-t -A` — no headers, no alignment (clean output for scripts)
- `-c "SELECT json_agg(t) FROM (...) t;"` — JSON output
- `-f /path/to/file.sql` — run a SQL file

### Examples

```bash
# Count published campaigns
psql "$SUPABASE_DATABASE_URL" -c "SELECT count(*) FROM games WHERE status = 'published';"

# Recent participants with game name
psql "$SUPABASE_DATABASE_URL" -c "
  SELECT p.email, p.created_at, g.name AS game
  FROM participants p
  JOIN games g ON g.id = p.game_id
  ORDER BY p.created_at DESC LIMIT 10;"

# Participants per campaign
psql "$SUPABASE_DATABASE_URL" -c "
  SELECT g.name, count(p.id) AS participants
  FROM games g LEFT JOIN participants p ON p.game_id = g.id
  GROUP BY g.id ORDER BY participants DESC;"

# Account subscription status
psql "$SUPABASE_DATABASE_URL" -c "
  SELECT a.name, a.slug, s.status, pp.plan_slug
  FROM accounts a
  LEFT JOIN subscriptions s ON s.account_id = a.id
  LEFT JOIN subscription_items si ON si.subscription_id = s.id AND si.type = 'flat'
  LEFT JOIN product_plans pp ON pp.variant_id = si.variant_id
  ORDER BY a.created_at DESC LIMIT 20;"
```

## Tool 2: supabase inspect db — Packaged diagnostics

Pre-built diagnostic commands for performance analysis. Requires `pg_stat_statements` for most commands.

```bash
supabase inspect db <command> --db-url "$SUPABASE_DATABASE_URL"
```

### Available commands

| Command | What it shows | When to use |
|---------|--------------|-------------|
| `outliers` | Slowest queries by total execution time | "why is the app slow?" |
| `calls` | Most frequently called queries | "what queries run most?" |
| `cache-hit` | Buffer cache hit rate (should be >99%) | "is the DB using enough memory?" |
| `long-running-queries` | Queries running >5 min right now | "is something stuck?" |
| `blocking` | Queries blocking others | "why are queries queuing?" |
| `locks` | Active exclusive locks | "is there a deadlock?" |
| `bloat` | Table/index bloat estimates | "is the DB wasting space?" |
| `vacuum-stats` | Last vacuum per table | "are dead tuples piling up?" |
| `table-stats` | Table sizes + row counts | "how big are the tables?" |
| `index-usage` | Index scan % per table | "are my indexes being used?" |
| `unused-indexes` | Indexes with zero scans | "what indexes can I drop?" |
| `seq-scans` | Tables with many sequential scans | "what tables need indexes?" |
| `role-connections` | Active connections by role | "am I hitting connection limits?" |

## Tool 3: Management API — Supabase service logs

Query logs from Postgres, Auth, API gateway, Edge Functions, and Realtime. Uses BigQuery SQL syntax (not PostgreSQL).

```bash
curl -s "https://api.supabase.com/v1/projects/${SUPABASE_PROJECT_REF}/analytics/endpoints/logs.all" \
  -H "Authorization: Bearer ${SUPABASE_ACCESS_TOKEN}" \
  -G \
  --data-urlencode "iso_timestamp_start=$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-1H +%Y-%m-%dT%H:%M:%SZ)" \
  --data-urlencode "sql=<BigQuery SQL>"
```

### Log tables

| Table | Content |
|-------|---------|
| `postgres_logs` | Postgres queries, errors, connections |
| `edge_logs` | REST API requests (all HTTP traffic) |
| `auth_logs` | Sign-ins, sign-ups, auth errors |
| `realtime_logs` | Realtime subscriptions |
| `function_logs` | Edge Functions invocations |

### Example queries (BigQuery SQL)

```sql
-- Postgres errors last hour
SELECT event_message, metadata
FROM postgres_logs
WHERE event_message ILIKE '%error%'
ORDER BY timestamp DESC LIMIT 20

-- Auth failures last 24h
SELECT event_message, timestamp
FROM auth_logs
WHERE event_message ILIKE '%invalid%' OR event_message ILIKE '%fail%'
ORDER BY timestamp DESC LIMIT 20

-- Slowest API requests
SELECT
  r.method, r.path, r.status_code,
  timestamp
FROM edge_logs
CROSS JOIN UNNEST(metadata) AS m
CROSS JOIN UNNEST(m.request) AS r
WHERE r.status_code >= 500
ORDER BY timestamp DESC LIMIT 20
```

Note: BigQuery SQL uses `UNNEST()` to access nested metadata fields, and `regexp_contains()` instead of `~` for regex.

## Business term mapping

When the user asks in business terms, translate to the correct table:

| Business term | Database table |
|---|---|
| campagne | `games` |
| participant / joueur | `participants` |
| gagnant | `winners` |
| prix / lot | `prizes` |
| template / modèle | `game_templates` |
| abonnement | `subscriptions` |
| compte / client | `accounts` |
| participation | `participations` |

## Safety

This skill is strictly read-only. The database password connects via Supavisor in session mode, which does allow writes — but the skill must never perform them.

- Only use SELECT, EXPLAIN, SHOW, and the `inspect db` commands
- Never run INSERT, UPDATE, DELETE, DROP, ALTER, or TRUNCATE
- When answering business questions (Antoine), translate numbers into insights, don't dump raw SQL
- When answering tech questions (Flo), raw results are fine
