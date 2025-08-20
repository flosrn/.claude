# Disable Memory Search Command

## Usage

```bash
/memory:disable
```

## Description

Disable automatic CORE Memory search, switching to manual-only mode. Memory search will no longer run automatically on:
- Session start
- User prompt submit

## Effect

Sets `CLAUDE_MEMORY_SEARCH_AUTO=false` in settings.json. You can still trigger memory search manually using `/memory:search "query"`.

## When to Use

- For faster response times without automatic context retrieval
- When working on isolated tasks that don't need historical context  
- To reduce computational overhead and session startup time
- For debugging or testing without memory interference

## Benefits

- **Performance**: Faster response times
- **Control**: Explicit control over when memory is accessed
- **Focus**: No automatic context that might be irrelevant
- **Efficiency**: Reduced token usage and processing overhead

## Implementation

Executes: `bash $HOME/.claude/scripts/memory-search-manager.sh disable`

## Note

This is the current default configuration. Memory search remains available via:
- `/memory:search "your query"`
- `/ms "quick search"`

## Related Commands

- `/memory:enable` - Re-enable automatic memory search
- `/memory:status` - Check current configuration  
- `/memory:search "query"` - Manual memory search