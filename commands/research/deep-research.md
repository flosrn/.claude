# Deep Research Command

## Usage
```
/deep-research [query]
```

## Description
Comprehensive research using multiple MCP sources with intelligent orchestration.

## Implementation
Multi-step research process:
1. **Initial Search**: Brave Search for overview
2. **Reddit Deep Dive**: Extract relevant discussions
3. **Technical Analysis**: Check GitHub/docs if coding-related
4. **Synthesis**: Combine findings with analysis

## MCP Servers Used
- `brave-search`: Primary web search
- `reddit`: Community discussions
- `context7`: Documentation lookup (if available)
- `playwright`: Content extraction for key pages

## Failure Handling
- Maximum 10 MCP calls total
- Skip failed services, continue with available
- 1-second intervals between Brave searches
- Fallback to internal knowledge if all fail

## Examples
```bash
# Technology research
/deep-research "Next.js App Router vs Pages Router performance comparison"

# Tool evaluation
/deep-research "Prisma vs Drizzle ORM 2024 comparison"

# Architecture decisions  
/deep-research "microservices vs monolith for startup"
```