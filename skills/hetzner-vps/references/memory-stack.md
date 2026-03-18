# Memory Stack — QMD + lossless-claw

Three layers give all agents persistent, searchable memory.

```
┌──────────────────────────────────────────────────────┐
│  Layer 3 — Search : QMD v2.0.1 (by Tobias Lütke)    │
│  BM25 + Jina v3 vectors (local GGUF) + LLM reranking│
│  873 files indexed across 7 collections              │
│  Auto-reindex every 5 min                            │
├──────────────────────────────────────────────────────┤
│  Layer 2 — Context : lossless-claw v0.3.0            │
│  DAG-based summarization (replaces sliding-window)   │
│  32 messages verbatim, unlimited depth               │
│  SQLite: ~/.openclaw/lcm.db                          │
├──────────────────────────────────────────────────────┤
│  Layer 1 — Storage : Markdown files                  │
│  MEMORY.md + memory/YYYY-MM-DD.md per agent          │
│  Git-versioned, human-readable source of truth       │
└──────────────────────────────────────────────────────┘
```

## QMD — Hybrid Memory Search

QMD (Query Markdown Documents) is an on-device search engine by Tobias Lütke (Shopify). It replaces OpenClaw's basic `memory_search` with a 3-stage pipeline:

1. **BM25** — exact keyword matching (TF-IDF)
2. **Vector search** — Jina v3 embeddings via local GGUF model (embeddinggemma-300M), no API calls
3. **LLM reranking** — local reranker (Qwen3-Reranker-0.6B) scores relevance

All models run locally on CPU (16 cores). No data leaves the VPS.

### Installation

```bash
# Inside container (as root for global npm)
docker exec openclaw-gateway npm install -g @tobilu/qmd

# Verify
docker exec -u node openclaw-gateway qmd --version
```

### Configuration (openclaw.json)

```json
{
  "memory": {
    "backend": "qmd",
    "qmd": {
      "command": "/usr/local/bin/qmd",
      "includeDefaultMemory": true,
      "update": { "interval": "5m", "debounceMs": 15000 },
      "limits": { "maxResults": 6, "timeoutMs": 30000 }
    }
  }
}
```

### Collections Indexed

| Collection | Path | Files |
|------------|------|------:|
| clawd-memory | `~/.openclaw/workspace/memory` | 178 |
| gapibot-memory | `~/.openclaw/workspace-gapibot/memory` | 62 |
| shipmate-memory | `~/.openclaw/workspace-shipmate/memory` | 58 |
| clawd-workspace | `~/.openclaw/workspace` | 239 |
| gapibot-workspace | `~/.openclaw/workspace-gapibot` | 94 |
| shipmate-workspace | `~/.openclaw/workspace-shipmate` | 80 |
| shared-skills | `/home/node/shared-skills` | 162 |

### Common Operations

```bash
# Check index status
docker exec -u node openclaw-gateway qmd status

# Manual search
docker exec -u node openclaw-gateway qmd search "migration hetzner"

# Rebuild embeddings (CPU, ~10-15 min for 560 hashes)
docker exec -u node openclaw-gateway qmd embed

# Add a new collection
docker exec -u node openclaw-gateway qmd collection add /path/to/dir --name my-collection
```

### Data Locations

- Index: `/home/node/.cache/qmd/index.sqlite` (16 MB)
- Models: `/home/node/.cache/qmd/models/` (~630 MB total: embedding 300M + reranker 330M)
- Config: managed by OpenClaw via `memory.qmd` in openclaw.json

**Performance:** ~537ms per hybrid search on CPU (BM25 alone: <1ms). GPU would bring this to ~100ms but CX53 has no GPU.

---

## lossless-claw — Context Engine

Plugin that replaces OpenClaw's sliding-window compaction with DAG-based summarization. Every message is persisted; nothing is lost during long sessions.

### Installation

```bash
docker exec -u node openclaw-gateway /home/node/bin/openclaw plugins install @martian-engineering/lossless-claw
```

### Configuration (openclaw.json)

```json
{
  "plugins": {
    "slots": { "contextEngine": "lossless-claw" },
    "entries": {
      "lossless-claw": {
        "enabled": true,
        "config": {
          "freshTailCount": 32,
          "contextThreshold": 0.75,
          "incrementalMaxDepth": -1
        }
      }
    }
  },
  "session": {
    "reset": { "mode": "idle", "idleMinutes": 10080 }
  }
}
```

Key settings:
- `freshTailCount: 32` — last 32 messages stay verbatim
- `contextThreshold: 0.75` — compaction triggers at 75% of context window
- `incrementalMaxDepth: -1` — unlimited DAG depth
- `session.reset.idleMinutes: 10080` — sessions last up to 7 days

### Agent Tools Provided

- `lcm_grep` — full-text/semantic search across entire conversation history
- `lcm_describe` — describe a DAG node
- `lcm_expand` — unfold a summary to recover original messages

**Data:** SQLite at `~/.openclaw/lcm.db`

**Known issue:** `runtime.modelAuth` warning at startup — cosmetic, uses legacy auth-profiles fallback.

---

## nativeSkills: false

OpenClaw's `commands.nativeSkills` is set to `false` to prevent automatic Telegram command registration. Instead, `telegram-sync` (in shared-skills) handles it via `sync-vps.sh` post-sync hooks. See `references/shared-skills.md` for details.
