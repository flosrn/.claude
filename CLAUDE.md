# Global Claude Code Instructions

Project-specific CLAUDE.md files take precedence over these global rules.

## Tool Router (MANDATORY)

When `<tool-router>` appears in context, you MUST:
1. **Invoke the specified Skill/command/agent FIRST** - do not skip
2. **Do NOT manually replicate** what the tool does
3. These suggestions exist because you forget specialized tools

This is non-negotiable. The tool-router identifies the RIGHT tool.

## Shell Aliases (CRITICAL)

Use absolute paths - shell aliases break standard flags:

| Command | Use Instead |
|---------|-------------|
| `ls` | `/bin/ls` |
| `grep` | `/usr/bin/grep` |
| `find` | `/usr/bin/find` |

## Code Quality

Before committing JS/TS projects: `pnpm typecheck && pnpm lint:fix && pnpm format:fix`

## Git

Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`

## Core Principles

- Use `tree -L 2` before exploring unfamiliar directories
- Never commit secrets or `.env` files
- Reference file paths with line numbers: `src/file.ts:42`
- Use TodoWrite for multi-step tasks (one in_progress at a time)
