# Claude Code Configuration

> A comprehensive, power-user setup for Claude Code with 57 commands, 22 skills, 14 agents, and intelligent automation hooks.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║     ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗     ██████╗ ██████╗     ║
║    ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝    ██╔════╝██╔════╝     ║
║    ██║     ██║     ███████║██║   ██║██║  ██║█████╗      ██║     ██║          ║
║    ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝      ██║     ██║          ║
║    ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗    ╚██████╗╚██████╗     ║
║     ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═════╝     ║
║                                                                              ║
║                        Power User Configuration                              ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              ~/.claude/                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐      │
│  │   CLAUDE.md │   │   rules/    │   │  settings   │   │   chrome/   │      │
│  │   (global)  │   │ typescript  │   │  .json      │   │  extension  │      │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘   └──────┬──────┘      │
│         │                 │                 │                 │              │
│         └────────────┬────┴─────────────────┴────────────┬────┘              │
│                      │                                   │                   │
│                      ▼                                   ▼                   │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                         CORE ENGINE                                    │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │                    Hook System (scripts/)                        │  │  │
│  │  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌────────┐  │  │  │
│  │  │  │ git-context  │ │skill-suggest │ │ ts-quality   │ │complete│  │  │  │
│  │  │  │  (session)   │ │   (prompt)   │ │   (gate)     │ │handler │  │  │  │
│  │  │  └──────────────┘ └──────────────┘ └──────────────┘ └────────┘  │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                      │                                   │                   │
│         ┌────────────┴────────────────────────────────────┴────────────┐     │
│         │                                                              │     │
│         ▼                                                              ▼     │
│  ┌──────────────────────────────────┐    ┌──────────────────────────────┐   │
│  │         COMMANDS (57)            │    │          SKILLS (22)          │   │
│  │  ┌────────────────────────────┐  │    │  ┌────────────────────────┐  │   │
│  │  │ /apex workflow             │  │    │  │ databases              │  │   │
│  │  │   0-brainstorm → 5-test    │  │    │  │ typescript-strict      │  │   │
│  │  │ /git commands              │  │    │  │ debugging              │  │   │
│  │  │   commit, pr, merge        │  │    │  │ aesthetic              │  │   │
│  │  │ /skills creation           │  │    │  │ ai-multimodal          │  │   │
│  │  │   prompts, agents, hooks   │  │    │  │ frontend-design        │  │   │
│  │  │ /utils                     │  │    │  │ web-frameworks         │  │   │
│  │  │   fix, watch, auto         │  │    │  │ ...and 15 more         │  │   │
│  │  └────────────────────────────┘  │    │  └────────────────────────┘  │   │
│  └──────────────────────────────────┘    └──────────────────────────────┘   │
│         │                                                              │     │
│         └────────────────────────┬─────────────────────────────────────┘     │
│                                  ▼                                           │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                         AGENTS (14)                                    │  │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌─────────┐  │  │
│  │  │  Explore  │ │  Snipper  │ │code-review│ │ websearch │ │ vision  │  │  │
│  │  └───────────┘ └───────────┘ └───────────┘ └───────────┘ └─────────┘  │  │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌─────────┐  │  │
│  │  │db-migrate │ │apex-exec  │ │fix-grammar│ │explore-doc│ │ action  │  │  │
│  │  └───────────┘ └───────────┘ └───────────┘ └───────────┘ └─────────┘  │  │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐              │  │
│  │  │ translate │ │resolve-pkg│ │setup-optim│ │intel-srch │              │  │
│  │  └───────────┘ └───────────┘ └───────────┘ └───────────┘              │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                  │                                           │
│                                  ▼                                           │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      MCP SERVERS                                      │  │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐          │  │
│  │  │ omnisearch │ │  chrome    │ │ playwright │ │   cclsp    │          │  │
│  │  └────────────┘ └────────────┘ └────────────┘ └────────────┘          │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Overview

This is a **power-user Claude Code configuration** that transforms the CLI into a comprehensive development environment. It features:

- **Intelligent Automation**: Hooks that inject context (git status), suggest tools, and enforce quality gates
- **Structured Workflows**: APEX methodology for complex multi-step implementations
- **Domain Expertise**: Specialized skills for databases, TypeScript, debugging, UI design, and more
- **Extensible Architecture**: Plugins, marketplaces, and custom agents

## Statistics

```
┌─────────────────────────────────────────────────────────────────┐
│                       FEATURE COUNT                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Commands    ████████████████████████████████████████  57      │
│   Skills      ██████████████████████                    22      │
│   Agents      ██████████████                            14      │
│   Hooks       ████                                       4      │
│   Rules       █                                          1      │
│   MCP Servers ███████                                    7      │
│                                                                 │
│   TOTAL FEATURES: 105                                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Key Components

### Commands (`commands/`)

```
┌────────────────────────────────────────────────────────────────────────────┐
│ COMMAND CATEGORIES                                                         │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  ┌─ APEX Workflow ──────────────────────────────────────────────────────┐  │
│  │  /0-brainstorm  →  /1-analyze  →  /2-plan  →  /3-execute  →  /4-exam │  │
│  │  /apex           /next          /status     /handoff      /overview  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                            │
│  ┌─ Git Operations ─────────────────────────────────────────────────────┐  │
│  │  /commit         Smart conventional commits                          │  │
│  │  /create-pr      Intelligent PR creation                             │  │
│  │  /merge          Safe branch merging                                 │  │
│  │  /commitizen     Interactive commit wizard                           │  │
│  │  /fix-pr-comments Address PR review feedback                         │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                            │
│  ┌─ Analysis & Debug ───────────────────────────────────────────────────┐  │
│  │  /debug          Systematic 4-phase debugging                        │  │
│  │  /explain        Code explanation with diagrams                      │  │
│  │  /explore        Deep codebase exploration                           │  │
│  │  /review         Code review with findings table                     │  │
│  │  /visualize      Architecture diagrams                               │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                            │
│  ┌─ Meta/Creation ──────────────────────────────────────────────────────┐  │
│  │  /create-prompt       Expert prompt engineering                      │  │
│  │  /create-skills       Build new skills                               │  │
│  │  /create-slash-command Create custom commands                        │  │
│  │  /create-subagent     Build Task tool agents                         │  │
│  │  /create-meta-prompt  Claude-to-Claude pipelines                     │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                            │
│  ┌─ Utilities ──────────────────────────────────────────────────────────┐  │
│  │  /deploy         Build, test, commit, push                           │  │
│  │  /refactor       Multi-file refactoring                              │  │
│  │  /fix-errors     Auto-fix TypeScript errors                          │  │
│  │  /ultrathink     Extended reasoning mode                             │  │
│  │  /quick-search   Lightning-fast search                               │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

### Skills (`skills/`)

```
┌────────────────────────────────────────────────────────────────────────────┐
│ DOMAIN EXPERTISE                                                           │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  ┌─ Code Quality ────────────┐  ┌─ Design & UI ──────────────────────┐    │
│  │  • typescript-strict      │  │  • aesthetic                       │    │
│  │  • debugging              │  │  • frontend-design                 │    │
│  │  • code-review-mastery    │  │  • ui-styling                      │    │
│  │  • lsp-navigation         │  │  • web-frameworks                  │    │
│  └───────────────────────────┘  └────────────────────────────────────┘    │
│                                                                            │
│  ┌─ Infrastructure ──────────┐  ┌─ AI & Automation ──────────────────┐    │
│  │  • databases              │  │  • ai-multimodal                   │    │
│  │  • ci-experts             │  │  • create-prompt                   │    │
│  │  • mcp-management         │  │  • create-meta-prompts             │    │
│  │  • repomix                │  │  • create-subagents                │    │
│  └───────────────────────────┘  └────────────────────────────────────┘    │
│                                                                            │
│  ┌─ Documentation ───────────┐  ┌─ Claude Code ──────────────────────┐    │
│  │  • docs-seeker            │  │  • claude-code                     │    │
│  │  • claude-memory          │  │  • create-hooks                    │    │
│  │                           │  │  • create-slash-commands           │    │
│  │                           │  │  • create-agent-skills             │    │
│  └───────────────────────────┘  └────────────────────────────────────┘    │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

### Agents (`agents/`)

```
┌────────────────────────────────────────────────────────────────────────────┐
│ AUTONOMOUS AGENTS (via Task tool)                                          │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  Agent                    │  Purpose                                       │
│  ─────────────────────────┼────────────────────────────────────────────    │
│  explore-codebase         │  Deep codebase exploration                     │
│  explore-docs             │  Documentation search with Context7            │
│  code-reviewer            │  PR review with structured findings            │
│  snipper                  │  Ultra-fast minimal edits                      │
│  websearch                │  Quick web search for current info             │
│  vision-analyzer          │  Analyze UI screenshots (Opus)                 │
│  apex-executor            │  Complex multi-step implementations            │
│  db-migrate               │  Supabase + Drizzle migrations                 │
│  fix-grammar              │  Fix grammar while preserving format           │
│  translate-french         │  French → English code comments                │
│  resolve-package-conflicts│  package.json conflict resolution              │
│  intelligent-search       │  Multi-provider search with routing            │
│  setup-optimizer          │  Claude Code config optimization               │
│  action                   │  Conditional action executor                   │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

### Hooks (`scripts/`)

```
┌────────────────────────────────────────────────────────────────────────────┐
│ AUTOMATION HOOKS                                                           │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  ┌─ git-context ─────────────────────────────────────────────────────┐    │
│  │  Event: SessionStart                                               │    │
│  │  Action: Injects git branch, status, and recent commits           │    │
│  │  Benefit: Always aware of repository state                         │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                            │
│  ┌─ skill-suggester ─────────────────────────────────────────────────┐    │
│  │  Event: UserPromptSubmit                                           │    │
│  │  Action: Analyzes prompt, suggests relevant tools                  │    │
│  │  Benefit: Never forget about specialized capabilities              │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                            │
│  ┌─ ts-quality-gate ─────────────────────────────────────────────────┐    │
│  │  Event: PreToolUse (Write/Edit on .ts/.tsx)                       │    │
│  │  Action: Validates TypeScript quality standards                    │    │
│  │  Benefit: Catches type errors before they're written              │     │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                            │
│  ┌─ completion-handler ──────────────────────────────────────────────┐     │
│  │  Event: Stop                                                       │    │
│  │  Action: Post-processes completion results                         │    │
│  │  Benefit: Consistent output formatting                             │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
~/.claude/
├── CLAUDE.md                 # Global instructions (tool router, aliases, git)
├── README.md                 # This file
├── CHANGELOG.md              # Version history
│
├── commands/                 # Slash commands (57 total)
│   ├── apex/                 #   APEX workflow (brainstorm → test)
│   ├── apex-quick/           #   Quick APEX variants
│   ├── git/                  #   Git operations
│   ├── marketing/            #   Marketing copy
│   ├── skills/               #   Skill creation commands
│   ├── tasks/                #   Task management
│   ├── utils/                #   Utility commands
│   └── *.md                  #   Individual commands
│
├── skills/                   # Domain expertise (22 total)
│   ├── aesthetic/            #   Beautiful UI design
│   ├── ai-multimodal/        #   Audio/video/image processing
│   ├── databases/            #   SQL, PostgreSQL, MongoDB
│   ├── debugging/            #   Systematic debugging
│   ├── typescript-strict/    #   Type safety patterns
│   └── .../                  #   And 17 more
│
├── agents/                   # Autonomous agents (14 total)
│   ├── explore-codebase.md   #   Deep exploration
│   ├── code-reviewer.md      #   PR reviews
│   ├── snipper.md            #   Quick edits
│   └── .../                  #   And 11 more
│
├── scripts/                  # Hook implementations
│   ├── hook-git-context.ts
│   ├── hook-skill-suggester.ts
│   ├── hook-ts-quality-gate.ts
│   └── hook-completion-handler.ts
│
├── rules/                    # Context rules
│   └── typescript.md         # TypeScript strict mode rules
│
├── plugins/                  # Plugin system
│   ├── cache/                #   Plugin cache
│   ├── local/                #   Local plugins
│   └── marketplaces/         #   Plugin sources
│
├── chrome/                   # Chrome extension integration
│   └── chrome-native-host/   #   Native messaging host
│
└── debug/                    # Debug logs
    └── *.txt                 #   Session debug files
```

## Getting Started

### Prerequisites

- Claude Code CLI installed
- Node.js >= 18 (for hooks)
- pnpm (preferred package manager)

### Installation

```bash
# Clone the configuration
git clone <your-repo> ~/.claude

# Or symlink from your dotfiles
ln -s ~/dotfiles/claude ~/.claude
```

### Quick Start

```bash
# Discover all features
/cc-discover

# Debug an issue
/debug "Login fails with 401 error"

# Explore a codebase
/explore "How does the payment system work?"

# Create a commit
/git:commit
```

## Usage Examples

### APEX Workflow (Complex Implementation)

```bash
# Step 1: Brainstorm approaches
/0-brainstorm "Add real-time notifications"

# Step 2: Analyze existing code
/1-analyze

# Step 3: Create implementation plan
/2-plan

# Step 4: Execute the plan
/3-execute

# Step 5: Review and verify
/4-examine

# Step 6: Test in browser
/5-browser-test
```

### Quick Commands

```bash
# Smart git commit
/git:commit

# Deploy (build + test + push)
/deploy

# Fix TypeScript errors
/fix-errors

# Generate README
/readme src/

# Deep code explanation
/explain src/auth/middleware.ts
```

### Using Skills

Skills are invoked automatically when relevant, or explicitly:

```bash
# Database queries
"Help me optimize this SQL query"  # → databases skill

# TypeScript typing
"How do I avoid any in this function?"  # → typescript-strict skill

# UI design
"Make this page beautiful"  # → aesthetic skill
```

## Configuration

### CLAUDE.md (Global Instructions)

The `CLAUDE.md` file contains:

- **Tool Router**: Mandatory tool selection based on context
- **Shell Aliases**: Use absolute paths to avoid alias issues
- **Code Quality**: Run typecheck/lint/format before commits
- **Git**: Conventional commit format
- **Core Principles**: Best practices for exploration and safety

### Rules (`rules/`)

- **typescript.md**: Strict TypeScript patterns (no `any`, use Zod, type guards)

### Settings

Configure in `~/.claude.json`:

```json
{
  "mcpServers": {
    "omnisearch": { ... }
  },
  "projects": {
    "/path/to/project": {
      "disabledMcpServers": ["playwright"]
    }
  }
}
```

## Documentation

Detailed guides for the main features:

| Guide | Description |
|-------|-------------|
| [**APEX Workflow**](docs/apex-workflow.md) | Complete 6-phase orchestrator with `--yolo` automation, smart model selection, parallel execution |
| [**Tool Router**](docs/tool-router.md) | 31-pattern skill-suggester hook that analyzes prompts and suggests optimal tools |
| [**TS Quality Gate**](docs/ts-quality-gate.md) | PostToolUse hook for automatic Prettier, ESLint, and TypeScript validation |
| [**Command Validator**](docs/command-validator.md) | Security rules database blocking dangerous bash commands |

## Contributing

To extend this configuration:

1. **Add a command**: Create `commands/your-command.md`
2. **Add a skill**: Create `skills/your-skill/SKILL.md`
3. **Add an agent**: Create `agents/your-agent.md`
4. **Add a hook**: Create `scripts/hook-your-hook.ts` and register in `settings.json`

## License

Personal configuration - feel free to fork and adapt.

---

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│   "The right tool for the right job, automatically selected."                │
│                                                                              │
│                                              - Tool Router Philosophy        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```
