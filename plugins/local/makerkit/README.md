# Makerkit Plugin

Comprehensive plugin for managing Makerkit-based projects: **gapila** and **lasdelaroute**.

## Features

- **Codebase Migration**: Safely update from upstream Makerkit with intelligent conflict resolution
- **Health Checks**: Verify project integrity (typecheck, lint, dependencies)
- **Database Sync**: Supabase + Drizzle migration workflow with automatic fixes
- **Dependency Audit**: Track custom packages, added libraries, and version mismatches
- **Documentation Access**: Makerkit docs via Context7 MCP

## Commands

| Command | Description |
|---------|-------------|
| `/makerkit:update` | Full codebase migration from upstream |
| `/makerkit:health` | Run health checks (typecheck, lint, syncpack) |
| `/makerkit:db-sync` | Database migration and Drizzle sync |
| `/makerkit:audit` | Dependency audit and custom package tracking |
| `/makerkit:diff` | Show differences from upstream Makerkit |

## Agents

| Agent | Purpose |
|-------|---------|
| `makerkit-updater` | Orchestrates full update workflow |
| `package-conflict-resolver` | Resolves package.json conflicts intelligently |
| `update-reporter` | Generates detailed update reports |
| `db-migrate` | Handles database migration workflow |

## Skills

- **makerkit-docs**: Makerkit documentation and best practices
- **supabase-drizzle**: Database migration patterns and Drizzle fixes

## Project Detection

On session start, the plugin automatically detects if you're in:
- `/Users/flo/Code/nextjs/gapila`
- `/Users/flo/Code/nextjs/lasdelaroute`

And displays project status with version info.

## Settings

Create `.claude/makerkit.local.md` in your project to configure:
- Custom packages to track
- Modified packages from upstream
- Added libraries not in upstream

## Requirements

- Context7 MCP (for documentation access)
- Existing Makerkit MCP per project (makerkit-gapila, makerkit-las)
- pnpm package manager
- Git with upstream remote configured

## Installation

```bash
# Add as local plugin
claude plugins add /Users/flo/.claude/plugins/local/makerkit
```
