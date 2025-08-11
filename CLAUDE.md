# User Profile

**Name**: Florian  
**Role**: Senior Full-Stack Developer

## Environment

- **OS**: macOS 26 (Tahoe)
- **Editor**: VS Code
- **Terminal**: Ghostty
- **Shell**: zsh
- **Mobile**: iPhone (iOS 26), iPad (iPadOS 26), Apple Watch (watchOS 26)

## Code Preferences

- TypeScript over JavaScript
- **NEVER use `any` type - use proper types or `unknown`**
- **ALWAYS import types explicitly (no missing imports)**
- **ALWAYS fix TypeScript errors before proceeding**
- Functional patterns preferred
- Semantic commit messages
- Tests required before commits

## Common Tools

- Package manager: pnpm (preferred), npm (fallback)
- Build: Always run lint + typecheck before production
- Git: Conventional commits format

## Automated Quality Workflow

The following quality checks are **automatically executed** via Claude Code hooks:

### Pre-Edit Validation (`PreToolUse:Edit`)
- TypeScript syntax validation
- Project-wide TypeScript compilation check
- Git repository status check

### Post-Edit Processing (`PostToolUse:Edit|Write`)
- **Automatic linting**: ESLint with `--fix`
- **Automatic formatting**: Prettier
- **TypeScript type checking**: Full compilation validation
- **`any` usage detection**: Blocks any usage of `any` type
- **Import validation**: Ensures all imports are resolved

### Final Quality Gate (`Stop`)
- Comprehensive TypeScript check
- Full project linting validation
- Build validation (if available)
- Final `any` usage scan
- All checks must pass before session completion

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
