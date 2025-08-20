# Memory Search Command

## Usage

```bash
/memory:search "your search query"
/ms "quick search"  # Short alias
```

## Description

Explicitly trigger a CORE Memory search to find relevant information from previous conversations, project context, and stored knowledge.

## Examples

```bash
# Search for previous discussions about a topic
/memory:search "React hooks implementation patterns"

# Find solutions to similar problems
/memory:search "database connection issues TypeScript"

# Look for project-specific context
/memory:search "authentication setup this project"

# Quick search with alias
/ms "previous git workflow"
```

## When to Use

- When you need context from previous conversations
- Looking for solutions you've implemented before
- Searching for project-specific patterns or configurations
- Before asking questions that might have been covered previously

## Implementation

This command triggers the memory-search agent with your specific query, providing targeted results instead of automatic broad searches.

## Related Commands

- `/memory:status` - Check memory search configuration
- `/memory:enable` - Enable automatic memory search  
- `/memory:disable` - Disable automatic memory search