# Quick Memory Search (ms)

## Usage

```bash
/ms "your search query"
```

## Description

Quick alias for `/memory:search`. Trigger a targeted CORE Memory search with minimal typing.

## Examples

```bash
/ms "React patterns"
/ms "git workflow issues" 
/ms "database setup previous project"
/ms "typescript configuration"
```

## Implementation

Executes: `bash $HOME/.claude/scripts/memory-search-manager.sh search "$1"`

This generates the prompt: 
```
🔍 MANUAL MEMORY SEARCH: Use memory-search to search for: [your query]
```

## Related Commands

- `/memory:search "query"` - Full memory search command
- `/memory:status` - Check memory search configuration
- `/memory:enable` - Enable automatic memory search
- `/memory:disable` - Disable automatic memory search