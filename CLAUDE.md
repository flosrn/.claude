# Global Claude Code Instructions

Project-specific CLAUDE.md files take precedence over these global rules.

## Core Principles

- Use `tree -L 2` before exploring unfamiliar directories
- Never commit secrets or `.env` files
- Reference file paths with line numbers: `src/file.ts:42`

## Research before guessing

<investigate_before_answering>
When you encounter an unfamiliar error, unknown API, unclear documentation, a question you're not 100% confident about, or you've tried the same approach twice without success — stop and search the web before continuing.

Use WebSearch, the `websearch` agent, or MCP tools (mcp__omnisearch__web_search, mcp__exa__web_search_exa) to find current information. Use WebFetch to read official documentation. Use the `explore-docs` agent or context7 MCP for library-specific questions.

Do not speculate or guess when a 30-second web search would give you the real answer. The cost of searching is low; the cost of hallucinating or looping is high.
</investigate_before_answering>
