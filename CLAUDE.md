# User Profile

**Name**: Florian  
**Role**: Senior Full-Stack Developer

## Environment

- **OS**: macOS Tahoe 26
- **Editor**: VS Code
- **Terminal**: Ghostty
- **Shell**: zsh
- **Mobile**: iPhone (iOS 26), iPad (iPadOS 26)

## Code Preferences

- TypeScript over JavaScript
- Functional patterns preferred
- Semantic commit messages
- Tests required before commits

## Common Tools

- Package manager: pnpm (preferred), npm (fallback)
- Build: Always run lint + typecheck before production
- Git: Conventional commits format

# Planning guidelines

IMPORTANT: When producing plans or task lists :

- DO NOT include any dates, durations, or hour estimates.
- Focus on deliverables, dependencies, prerequisites, and outputs only.

## MCP Servers

- **Rewatch**: ALWAYS use MCP Rewatch for dev server management when available
  - Prefer `restart_process` over manual server starts
  - Use `get_process_logs` to monitor development output
  - Background process management prevents timeout issues
  - If port conflict detected (e.g. :3000 already in use), kill existing process and restart with Rewatch
- **Playwright**: ALWAYS use Playwright MCP for browser testing when available
  - Take screenshots to analyze UI elements and layout issues
  - Monitor console logs for frontend errors and debugging
  - Test interactions across Chrome, Firefox, WebKit
