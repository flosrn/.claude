# Enable Memory Search Command

## Usage

```bash
/memory:enable
```

## Description

Enable automatic CORE Memory search on:
- Session start (when you begin a new Claude Code session)  
- User prompt submit (before Claude responds to each query)

## Effect

Sets `CLAUDE_MEMORY_SEARCH_AUTO=true` in settings.json, restoring the original behavior where Claude automatically searches memory for context.

## When to Use

- When you want comprehensive automatic context retrieval
- For complex projects where previous context is frequently relevant
- When working on ongoing tasks that benefit from historical knowledge

## Trade-offs

**Pros:**
- Automatic context without manual effort
- Comprehensive background knowledge
- Consistent context across sessions

**Cons:**
- Increased latency on every interaction
- Potential information overload
- Higher computational overhead

## Implementation

Executes: `bash $HOME/.claude/scripts/memory-search-manager.sh enable`

## Related Commands

- `/memory:disable` - Disable automatic memory search
- `/memory:status` - Check current configuration
- `/memory:search "query"` - Manual memory search