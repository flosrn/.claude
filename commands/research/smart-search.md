# Smart Search Command

## Usage
```
/smart-search [query]
```

## Description
Intelligent research command that uses Brave Search MCP with rate limiting and failure handling.

## Implementation
Performs research using best practices:
- Rate-limited Brave Search queries (1/second)
- Failure fallback to internal knowledge  
- Maximum 3 MCP calls per query
- Site-specific search patterns for coding questions

## Examples
```bash
# Coding question - searches Reddit + StackOverflow
/smart-search "React useEffect dependency array best practices"

# Current events - uses Brave Search with date
/smart-search "TypeScript 5.3 new features"

# Technical troubleshooting
/smart-search "Claude Code MCP server connection issues"
```

## Command Logic
1. Detect query type (coding, current events, troubleshooting)
2. Use appropriate search pattern:
   - Coding: `site:reddit.com OR site:stackoverflow.com [query]`
   - News: Add current date to query
   - General: Standard Brave Search
3. Handle failures gracefully
4. Respect rate limits (1 query/second)