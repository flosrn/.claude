# Analysis: Cleanup Scripts Directory

**Analyzed**: 2026-01-05
**Status**: Complete

## Quick Summary (TL;DR)

> This section is the PRIMARY content consumed by lazy loading.
> Keep it dense and actionable.

**Key files to delete (safe):**
- `hook-mcp-inject.log` (109KB) - Large log file, safe to delete
- `hook-post-file.ts` (3.8KB) - Deprecated, replaced by enhanced version
- `validate-command.js` (26KB) - Deprecated, replaced by TypeScript validator
- `analyze-tool-usage.ts` (4KB) - Orphan utility, not referenced
- `cleanup.ts` (4KB) - Manual utility, not referenced
- `sign-node-files.sh` (281B) - Test utility, not used
- `test-terminal-automation.sh` (760B) - Test utility, not used

**Files to keep (actively used in settings.json):**
- `hook-tool-router.ts` - UserPromptSubmit hook (main tool router)
- `hook-session-start.ts` - SessionStart hook (git context)
- `hook-post-file-enhanced.ts` - PostToolUse hook (code quality)
- `hook-apex-clipboard.ts` - PostToolUse hook (APEX workflow)
- `hook-stop.ts` - Stop hook (completion handler)
- `apex-yolo-continue.ts` - Called by hook-stop.ts (APEX automation)
- `command-validator/` - PreToolUse hook (security validation)
- `statusline/` - StatusLine display (always-on)

**Files confirmed for deletion (user decision):**
- `switch-profile.ts` (17KB) + `claude-profile` - Profile switching not used ✓
- `hook-mcp-inject.ts` (3.9KB) - MCP injection not needed ✓

**Space to reclaim:** ~168KB total (log + deprecated + user-confirmed deletions)

**⚠️ Gotchas discovered:**
- Don't delete `hook-post-file-enhanced.ts` thinking it's a duplicate - it's the ACTIVE version
- `apex-yolo-continue.ts` isn't in settings.json but IS called by `hook-stop.ts` - don't delete!
- `command-validator/` and `statusline/` subdirectories are CRITICAL packages

**Dependencies:** None blocking

**Refactoring inclus:**
- Renommer `hook-post-file-enhanced.ts` → `hook-ts-quality-gate.ts` (nom plus explicite)
- Mettre à jour la référence dans `settings.json`

**Estimation:** ~5 tasks, ~20min total

---

## Codebase Context

### Active Scripts (Referenced in settings.json)

| Script | Hook Event | Purpose | Lines |
|--------|------------|---------|-------|
| `hook-tool-router.ts` | UserPromptSubmit | Suggests specialized skills based on keywords | 380 |
| `hook-session-start.ts` | SessionStart | Injects git context at conversation start | 91 |
| `hook-post-file-enhanced.ts` | PostToolUse (Edit\|Write\|MultiEdit) | Prettier + ESLint + TypeScript validation | 409 |
| `hook-apex-clipboard.ts` | PostToolUse (Edit\|Write\|MultiEdit) | APEX workflow clipboard automation | 205 |
| `hook-stop.ts` | Stop | Plays sounds, handles APEX YOLO continuation | 117 |
| `apex-yolo-continue.ts` | (called by hook-stop) | Terminal spawning for APEX automation | 180 |

### Active Packages (Subdirectories)

**`command-validator/`** - Security validation for Bash commands
- Entry: `src/cli.ts` (PreToolUse hook)
- 82+ tests in `__tests__/validator.test.ts`
- Blocks dangerous patterns: `rm -rf /`, `sudo`, fork bombs, etc.

**`statusline/`** - Real-time status display
- Entry: `src/index.ts` (statusLine config)
- Shows: git branch, session cost, context tokens, API rate limits
- Uses OAuth token from macOS Keychain

### Deprecated/Unused Scripts

| Script | Size | Status | Reason |
|--------|------|--------|--------|
| `hook-post-file.ts` | 3.8KB | DEPRECATED | Replaced by `hook-post-file-enhanced.ts` |
| `validate-command.js` | 26KB | DEPRECATED | Replaced by TypeScript `command-validator/` |
| `analyze-tool-usage.ts` | 4KB | ORPHAN | Manual analytics, no hook reference |
| `cleanup.ts` | 4KB | ORPHAN | Manual maintenance, no hook reference |
| `sign-node-files.sh` | 281B | ORPHAN | Test utility |
| `test-terminal-automation.sh` | 760B | ORPHAN | Test utility |

### Files Needing Decision

**`switch-profile.ts` (17KB) + `claude-profile` (182B)**
- Full profile switching infrastructure
- Not referenced in settings.json
- Could be useful for managing different Claude configurations
- **Recommendation**: Ask user if they use profile switching

**`hook-mcp-inject.ts` (3.9KB)**
- Detects "MCP" in prompts and injects context
- Not in settings.json but could be re-enabled
- **Recommendation**: Ask user if MCP injection is needed

### Log Files

| File | Size | Last Modified | Status |
|------|------|---------------|--------|
| `hook-mcp-inject.log` | 109KB | Dec 22 10:47 | SAFE TO DELETE |

---

## User Clarifications

- **Profile switching**: Not used → Delete `switch-profile.ts` + `claude-profile` ✓
- **MCP injection**: Not needed → Delete `hook-mcp-inject.ts` ✓

---

## Recommended Cleanup Actions

### All Files to Delete (confirmed)
```bash
# Log file (109KB)
rm ~/.claude/scripts/hook-mcp-inject.log

# Deprecated scripts
rm ~/.claude/scripts/hook-post-file.ts
rm ~/.claude/scripts/validate-command.js

# Orphan utilities
rm ~/.claude/scripts/analyze-tool-usage.ts
rm ~/.claude/scripts/cleanup.ts
rm ~/.claude/scripts/sign-node-files.sh
rm ~/.claude/scripts/test-terminal-automation.sh

# User-confirmed deletions
rm ~/.claude/scripts/switch-profile.ts
rm ~/.claude/scripts/claude-profile
rm ~/.claude/scripts/hook-mcp-inject.ts
```

**Total: 11 files, ~168KB saved**

---

## Key Files Reference

### Configuration
- `~/.claude/settings.json` - Hook definitions (lines 20-98)
- `~/.claude/scripts/package.json` - Root scripts package
- `~/.claude/scripts/tsconfig.json` - TypeScript configuration

### Active Hooks (DO NOT DELETE)
- `~/.claude/scripts/hook-tool-router.ts:1` - Main tool routing
- `~/.claude/scripts/hook-session-start.ts:1` - Session initialization
- `~/.claude/scripts/hook-post-file-enhanced.ts:1` - Code quality validation
- `~/.claude/scripts/hook-apex-clipboard.ts:1` - APEX clipboard automation
- `~/.claude/scripts/hook-stop.ts:1` - Session completion handler
- `~/.claude/scripts/apex-yolo-continue.ts:1` - APEX automation engine

### Active Packages (DO NOT DELETE)
- `~/.claude/scripts/command-validator/src/cli.ts` - Security validation entry
- `~/.claude/scripts/statusline/src/index.ts` - Status display entry
