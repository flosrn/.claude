# Flashbacker Integration

**Source**: https://github.com/agentsea/flashbacker  
**Version**: 2.3.5  
**Purpose**: Session continuity and memory management for Claude Code

## Installation

```bash
# Installed globally via npm
npm install -g flashbacker

# Initialized in project
cd ~/.claude
flashback init --refresh
```

## Core Features

### Session Management Commands

- **`/fb:session-start`** - Restore context after compaction
- **`/fb:save-session`** - Capture session insights before compaction  
- **`/fb:working-plan`** - Update development priorities
- **`/fb:remember`** - Add key insights to persistent memory

### Memory Files

- **`memory/REMEMBER.md`** - Long-term project knowledge
- **`memory/WORKING_PLAN.md`** - Current development priorities
- **`memory/CURRENT_SESSION.md`** - Latest session snapshot

### Hooks

- **SessionStart** - Automatically loads context when starting new session
- Configured in `.claude/settings.json` to run `session-start.sh`

## Usage Workflow

### Before Context Compaction (~90% full)
1. Run `/fb:save-session` to capture session insights
2. Or run `/fb:working-plan` to update development priorities

### After Compaction
1. SessionStart hook automatically runs
2. Or manually run `/fb:session-start` to restore context

### Adding Persistent Memory
- Use `/fb:remember "important insight"` for key information

## File Locations

```
.claude/
├── flashback/
│   ├── config/          # Configuration
│   ├── memory/          # Memory files (REMEMBER.md, WORKING_PLAN.md)
│   ├── personas/        # AI personas (13 available)
│   ├── prompts/         # Analysis prompts
│   └── scripts/         # Hook scripts
└── commands/
    └── fb/              # Slash commands (17 total)
```

## Verification

```bash
flashback status   # Check installation
flashback doctor   # Detailed diagnostics
flashback memory --show  # View current memory
```

## Notes

- No automatic memory management (manual commands required)
- SessionStart hook provides automatic context restoration
- Preserves memory across sessions via REMEMBER.md
- Archives old sessions automatically (keeps 10 most recent)