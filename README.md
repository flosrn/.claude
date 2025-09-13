# My Personal Claude Code Setup

> **My custom Claude Code configuration - a tailored setup that evolves with my dev needs, optimized for my personal projects and AI experiments**

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Optimized-blue)](https://claude.ai/code)
[![TypeScript](https://img.shields.io/badge/TypeScript-Strict-blue)](https://www.typescriptlang.org/)
[![Security](https://img.shields.io/badge/Security-Fork--Safe-green)](https://github.com)

## 🚀 Overview

This repo contains my personal Claude Code configuration, crafted over time for my specific development needs. An evolving setup that grows with my projects and AI experiments

### Key Features

- **🔐 Fork-Safe Security**: Never accidentally push to upstream repositories
- **🔋 Smart Status Line**: Real-time usage tracking with color-coded progress bars
- **🛡️ Security-First**: Multi-level command validation and production safeguards
- **📊 Real-Time Observability**: Track all operations with built-in dashboard
- **🔄 Smart Git Workflows**: Automated branch → commit → PR orchestration
- **✨ TypeScript Excellence**: Strict type checking, no `any` types allowed
- **🔔 Ghostty Integration**: Notifications that bring you back to your terminal session
- **🔌 MCP Integrations**: Context7, Vercel, Playwright, and more

## 📁 Architecture

```
~/.claude/
├── 📝 commands/           # Slash commands for workflows
│   ├── core/             # Utility commands
│   ├── git/              # Git workflow automation
│   ├── typescript/       # TypeScript utilities
│   └── observability/    # Monitoring commands
├── 🔗 hooks/             # Automation & validation hooks
│   ├── ts/               # TypeScript quality gates
│   └── observability/    # Event tracking
├── 📊 observability/     # Real-time monitoring
│   ├── apps/server/      # Event server (port 4000)
│   ├── apps/client/      # Dashboard UI (port 5173)
│   └── statusline-ccusage.sh  # Enhanced status line
├── 🔔 ccnotify/          # Ghostty-integrated notifications
├── 🛡️ scripts/           # Security & validation
├── 📁 projects/          # Project contexts
├── 🎵 songs/             # Audio notifications
└── ⚙️ settings.json      # Core configuration
```

## 🛡️ Security Features

### Fork Safety

- **Upstream Protection**: Blocks all attempts to push to upstream remotes
- **Origin-Only Push**: Ensures changes only go to your fork
- **Remote Validation**: Validates all git remote operations

### Command Validation

- **Dangerous Command Blocking**: Prevents `rm -rf /`, `sudo`, system modifications
- **Production Database Protection**: Blocks destructive Supabase operations
- **Path Protection**: Restricts access to system directories
- **Comprehensive Logging**: All security events logged to `logs/security.log`

### TypeScript Quality Gates

- **No `any` Types**: Automatically blocks any usage of `any` type
- **Strict Compilation**: TypeScript strict mode enforcement
- **Auto-Formatting**: Prettier + ESLint on every file modification
- **Cache System**: Smart caching for instant re-validation

## 🤖 Active Agents

_Coming soon - Development, Infrastructure, Quality & Specialized agents for comprehensive workflow automation_

## 📝 Command System

### Observability (`/observability:*`)

```bash
/start-monitoring      # Start observability dashboard
/stop-monitoring       # Stop monitoring system
```

### Git Workflows (`/git:*`)

```bash
/workflow "feature description"    # Complete git workflow
/branch "feature-name"            # Create feature branch
/commit                           # Smart conventional commit
/pr                              # Create pull request
/sync-upstream                   # Safe fork synchronization
```

### Utility Commands (`/core:*`)

```bash
/cleanup-context           # Optimize token usage
/refactor-code            # Analyze for refactoring
/check-best-practices     # Verify code standards
/create-readme-section    # Generate documentation
```

## 📊 Enhanced Status Line

The intelligent status line provides real-time usage tracking with visual indicators:

### Features

- **🔋 Progress Bar**: Color-coded block usage (green → yellow → red)
- **💰 Cost Tracking**: Session, daily, and block costs with distinct colors
- **⏱ Time Remaining**: Smart formatting for remaining block time
- **🧩 Token Counter**: Real-time token usage with smart formatting

### Status Line Format

```
🌿 main* | 📁 .claude | 🤖 Sonnet 4 | 💰 $20.25 / 📅 $30.10 / 🧊 $13.48 (4h 24m left) | 🔋 ██░░░░░░░░ 11% | 🧩 16.5K tokens
```

## 🔗 Hooks & Automation

### PreToolUse Hooks

- **Command Validation**: Security checks before execution
- **Observability**: Event tracking for all tool usage

### PostToolUse Hooks

- **TypeScript Quality**: Auto-format and type checking
- **Event Logging**: Operation result tracking

### Session Hooks

- **SessionStart**: Auto-restore context on new session
- **Stop**: Audio notification on task completion
- **UserPromptSubmit**: Track user interactions

## 📊 Observability System

Real-time monitoring of all Claude Code operations with enhanced status line:

### Components

- **Event Server**: SQLite-backed server (port 4000)
- **Dashboard**: React-based UI (port 5173)
- **Status Line**: Enhanced with progress bars and cost tracking
- **Event Types**: PreToolUse, PostToolUse, Stop, Notification

### Usage

```bash
cd observability
./start.sh    # Start monitoring system
./stop.sh     # Stop monitoring system
```

### Notification System (ccnotify)

- **Smart Notifications**: Task completion alerts with duration tracking
- **Ghostty Integration**: Click notifications to return to your terminal session
- **Audio Feedback**: Sound notifications for task completion

## 🔌 MCP Integrations

Active MCP (Model Context Protocol) servers:

1. **`context7`** - Library documentation retrieval
2. **`shadcn-ui`** - UI component library v4
3. **`vercel`** - Deployment and platform docs
4. **`youtube-transcript`** - Video transcript extraction
5. **`playwright`** - Browser automation
6. **`brave-search`** - Web search functionality

## 🚀 Getting Started

### Prerequisites

- Claude Code CLI installed
- Bun runtime for performance
- Git configured with fork setup
- Node.js for certain tools

### Installation

1. **Clone to Claude directory**:

   ```bash
   git clone <your-fork> ~/.claude
   cd ~/.claude
   ```

2. **Install dependencies**:

   ```bash
   bun install
   # or
   npm install
   ```

3. **Configure MCP servers** (optional):

   ```bash
   claude mcp add <server-name>
   ```

4. **Start observability** (optional):
   ```bash
   cd observability && ./start.sh
   ```

### Daily Workflow

1. **Start new session**:
   - Automatic context restoration
   - Or manual: `/fb:session-start`

2. **Development**:

   ```bash
   /workflow "implement new feature"
   # Creates branch → guides development → commits → creates PR
   ```

3. **Before context fills**:
   ```bash
   /fb:save-session
   # Preserves session for next time
   ```

## 🔧 Configuration

### Core Settings (`settings.json`)

```json
{
  "permissions": {
    "allow": ["Bash(*)", "Edit(*)", "Write(*)", "Read(*)"]
  },
  "hooks": {
    "PreToolUse": [...],
    "PostToolUse": [...],
    "SessionStart": [...],
    "Stop": [...]
  }
}
```

### Environment Variables

- `CLAUDE_NO_TS_CHECK`: Skip TypeScript checking (not recommended)
- `CLAUDE_HOOKS_DEBUG`: Enable debug logging

## 🔒 Security Considerations

### Protected Operations

- No `sudo` or privilege escalation
- No system directory modifications
- No upstream repository pushes
- No production database destructive operations

### Audit Trail

- All commands logged to `logs/security.log`
- Blocked operations tracked with reasons
- Session-based correlation IDs

## 📚 Documentation

- [`GUIDE.md`](./GUIDE.md) - Complete usage guide (French)
- [`commands/create-command.md`](./commands/create-command.md) - Creating custom commands
- Individual agent docs in [`agents/`](./agents/) directory

## 🤝 Contributing

This setup combines best practices from multiple sources:

- [CORE](https://github.com/RedPlanetHQ/core) - Persistent memory
- [Centminmod](https://github.com/centminmod/my-claude-code-setup) - Utility commands
- [Scopecraft](https://github.com/scopecraft/command) - Command system
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code) - Community-driven resources

## 📄 License

This configuration is provided as-is for use with Claude Code. Feel free to adapt and modify for your needs.

## 🙏 Acknowledgments

Built with inspiration from the Claude Code community and designed for developers who demand excellence in their AI-assisted development workflow.

---

**Note**: This setup enforces strict TypeScript standards and will never allow `any` types in your code. This is by design to maintain code quality and type safety.
