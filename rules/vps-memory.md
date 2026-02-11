## VPS Memory Access (OpenClaw)

Flo's long-term memory lives on the VPS at `~/.openclaw/workspace/`.

**NEVER edit MEMORY.md** — it's curated by OpenClaw. Always create new files in `memory/`.

### Search memories
```bash
ssh vps 'cd /root/openclaw && docker compose exec openclaw-gateway node dist/index.js memory search "QUERY"'
```

### Save a new memory
Create a file in `memory/` with tag "via Claude Code local":
```bash
ssh vps 'cat > /root/.openclaw/workspace/memory/YYYY-MM-DD-topic.md << '\''EOF'\''
# Session: YYYY-MM-DD (via Claude Code local)
## Topic
Content here

**Tags:** relevant, tags, here
EOF'
```
Then reindex:
```bash
ssh vps 'cd /root/openclaw && docker compose exec openclaw-gateway node dist/index.js memory index'
```

### Key paths on VPS
- MEMORY.md (curated, READ-ONLY): `/root/.openclaw/workspace/MEMORY.md`
- Session memories (CREATE HERE): `/root/.openclaw/workspace/memory/`
- SQLite index: `/root/.openclaw/memory/main.sqlite`
