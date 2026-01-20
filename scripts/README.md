# Claude Code Scripts

This directory contains hooks and utilities that extend Claude Code's functionality.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Claude Code Session                                │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
         ┌──────────────────────────┼──────────────────────────┐
         │                          │                          │
         ▼                          ▼                          ▼
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│  SessionStart   │      │ UserPromptSubmit│      │      Stop       │
│                 │      │                 │      │                 │
│ hook-git-       │      │ hook-skill-     │      │ hook-completion-│
│ context.ts      │      │ suggester.ts    │      │ handler.ts      │
│                 │      │                 │      │                 │
│ Injects git     │      │ Suggests skills │      │ Plays sounds,   │
│ context         │      │ based on prompt │      │ triggers APEX   │
└─────────────────┘      └─────────────────┘      └─────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │      Tool Execution Flow      │
                    └───────────────────────────────┘
                                    │
              ┌─────────────────────┴─────────────────────┐
              │                                           │
              ▼                                           ▼
    ┌─────────────────┐                         ┌─────────────────┐
    │   Bash Command  │                         │  Edit / Write   │
    └─────────────────┘                         └─────────────────┘
              │                                           │
              ▼                                           │
    ┌─────────────────┐                                   │
    │  PreToolUse     │                                   │
    │  ─────────────  │                                   │
    │  command-       │                                   │
    │  validator/     │                                   │
    │                 │                                   │
    │  Security gate  │                                   │
    │  Can BLOCK      │                                   │
    │  dangerous      │                                   │
    │  commands       │                                   │
    └─────────────────┘                                   │
              │                                           │
              │ ✅ Allowed                                │
              │ ❌ Blocked                                │
              ▼                                           ▼
    ┌─────────────────┐                         ┌─────────────────┐
    │    Command      │                         │     File        │
    │    Executes     │                         │    Modified     │
    └─────────────────┘                         └─────────────────┘
                                                          │
                                                          ▼
                                                ┌─────────────────┐
                                                │  PostToolUse    │
                                                │  ─────────────  │
                                                │  hook-ts-       │
                                                │  quality-gate   │
                                                │                 │
                                                │  1. Prettier    │
                                                │  2. ESLint fix  │
                                                │  3. ESLint check│
                                                │  4. TypeScript  │
                                                │                 │
                                                │  + apex/hook-   │
                                                │  clipboard.ts   │
                                                └─────────────────┘
```

## Directory Structure

```
~/.claude/scripts/
├── README.md
├── package.json
├── tsconfig.json
│
├── apex/                         # APEX workflow automation
│   ├── hook-clipboard.ts         # Copies next APEX command to clipboard
│   └── yolo-continue.ts          # Terminal spawning for auto-continue
│
├── command-validator/            # Security validation package
│   ├── src/cli.ts                # Hook entry point
│   └── src/lib/validator.ts      # Core validation logic
│
├── statusline/                   # Status display package
│   └── src/index.ts              # Real-time status bar
│
├── hook-completion-handler.ts    # Stop hook - sounds & APEX YOLO
├── hook-git-context.ts           # SessionStart hook - git info
├── hook-skill-suggester.ts       # UserPromptSubmit hook - tool routing
└── hook-ts-quality-gate.ts       # PostToolUse hook - code quality
```

## Hooks

### Naming Convention

All hooks follow **purpose-based naming**: the name describes what the hook does, not which event it listens to.

### Session Lifecycle

| Hook | Event | Purpose |
|------|-------|---------|
| `hook-git-context.ts` | SessionStart | Injects git context (branch, status, last commit) at conversation start |
| `hook-completion-handler.ts` | Stop | Plays completion sounds, handles APEX YOLO workflow continuation |

### User Interaction

| Hook | Event | Purpose |
|------|-------|---------|
| `hook-skill-suggester.ts` | UserPromptSubmit | Analyzes user prompts and suggests specialized skills/tools based on keywords (bilingual EN/FR) |

### Tool Validation

| Hook | Event | Matcher | Purpose |
|------|-------|---------|---------|
| `command-validator/` | PreToolUse | `Bash` | **Security gate** - Blocks dangerous commands (`rm -rf /`, `sudo`, fork bombs, etc.) |
| `hook-ts-quality-gate.ts` | PostToolUse | `Edit\|Write\|MultiEdit` | **Quality gate** - Runs Prettier, ESLint, and TypeScript on modified .ts/.tsx files |
| `apex/hook-clipboard.ts` | PostToolUse | `Edit\|Write\|MultiEdit` | Copies next APEX command to clipboard for workflow automation |

## Packages

### `apex/`

APEX workflow automation scripts.

| Script | Purpose |
|--------|---------|
| `hook-clipboard.ts` | Detects APEX file patterns and copies next command to clipboard |
| `yolo-continue.ts` | Spawns new terminal to continue APEX workflow (called by `hook-completion-handler.ts`) |

### `command-validator/`

Security validation for Bash commands before execution.

- **Entry**: `src/cli.ts`
- **Core logic**: `src/lib/validator.ts`
- **Tests**: 82+ test cases in `__tests__/`
- **Blocks**: `rm -rf /`, `dd`, `sudo`, `passwd`, `chmod 777`, `nmap`, fork bombs
- **Allows**: `ls`, `git`, `npm`, `cat`, `cp`, `mv`, `mkdir`

### `statusline/`

Real-time status display in the Claude Code terminal.

- **Entry**: `src/index.ts`
- **Displays**: Git branch, session cost, context tokens, API rate limits
- **Config**: `statusline.config.json`

## Configuration

All hooks are configured in `~/.claude/settings.json` under the `hooks` key:

```json
{
  "hooks": {
    "UserPromptSubmit": ["hook-skill-suggester.ts"],
    "SessionStart": ["hook-git-context.ts"],
    "PreToolUse": ["command-validator/src/cli.ts"],
    "PostToolUse": ["hook-ts-quality-gate.ts", "apex/hook-clipboard.ts"],
    "Stop": ["hook-completion-handler.ts"]
  },
  "statusLine": {
    "command": "bun ~/.claude/scripts/statusline/src/index.ts"
  }
}
```

## Development

```bash
# Install dependencies
pnpm install

# Run TypeScript files
bun <script>.ts

# Debug hooks (enable verbose logging)
CLAUDE_HOOK_DEBUG=1 bun <hook>.ts
```
