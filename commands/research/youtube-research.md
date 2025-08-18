# YouTube Research Command

## Usage
```
/youtube-research [query]
```

## Description
Simplified YouTube research workflow that avoids over-engineering.

## Implementation
Streamlined approach (avoiding complex chains):
1. **Search**: Brave Search `site:youtube.com [query]`
2. **Extract**: Video IDs from results
3. **Transcript**: Use YouTube transcript MCP if available
4. **Fallback**: Use Playwright only if transcript fails

## MCP Servers Used
- `brave-search`: YouTube video discovery
- `youtube-transcript`: Direct transcript extraction
- `playwright`: Fallback for content extraction

## Failure Handling
- Skip Playwright chain if transcript works
- Maximum 5 MCP calls total
- Continue without video content if all fail

## Examples
```bash
# Tutorial search
/youtube-research "Claude Code MCP setup tutorial"

# Technology explanation
/youtube-research "React Server Components explained"

# Conference talks
/youtube-research "Next.js Conf 2024 highlights"
```

## Avoids Over-engineering
- No complex keyword extraction chains
- No multiple research rounds
- Direct transcript access when possible