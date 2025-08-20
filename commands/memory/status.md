# Memory Status Command

## Usage

```bash
/memory:status
```

## Description

Check the current configuration of CORE Memory search automation.

## Output

Shows whether automatic memory search is:
- **ENABLED**: Memory search runs automatically on session start and user prompts
- **DISABLED**: Memory search only runs when explicitly requested via commands

## Implementation

Executes: `bash $HOME/.claude/scripts/memory-search-manager.sh status`

## Related Commands

- `/memory:search "query"` - Manual memory search
- `/memory:enable` - Enable automatic memory search  
- `/memory:disable` - Disable automatic memory search