# Implementation Plan: Cleanup Scripts Directory

## Overview

Clean up the `~/.claude/scripts/` directory by:
1. Deleting 11 obsolete/unused files (~168KB)
2. Renaming `hook-post-file-enhanced.ts` → `hook-ts-quality-gate.ts` for clarity
3. Updating the reference in `settings.json`

**Approach**: Delete files first, then rename, then update config. This order ensures we don't break anything during the process.

## Dependencies

- None. All deletions are for orphan/deprecated files not referenced anywhere.
- The rename requires updating `settings.json` in the same step to avoid breaking the hook.

## File Changes

### Phase 1: Delete Obsolete Files

#### `~/.claude/scripts/hook-mcp-inject.log`
- Action: Delete this log file (109KB)
- Reason: Large log from deprecated MCP injection hook

#### `~/.claude/scripts/hook-post-file.ts`
- Action: Delete this deprecated script (3.8KB)
- Reason: Replaced by `hook-post-file-enhanced.ts` (soon to be `hook-ts-quality-gate.ts`)

#### `~/.claude/scripts/validate-command.js`
- Action: Delete this deprecated script (26KB)
- Reason: Replaced by TypeScript `command-validator/` package

#### `~/.claude/scripts/analyze-tool-usage.ts`
- Action: Delete this orphan utility (4KB)
- Reason: Manual analytics script, not referenced in any hook

#### `~/.claude/scripts/cleanup.ts`
- Action: Delete this orphan utility (4KB)
- Reason: Manual maintenance script, not referenced in any hook

#### `~/.claude/scripts/sign-node-files.sh`
- Action: Delete this test utility (281B)
- Reason: Development artifact, not used

#### `~/.claude/scripts/test-terminal-automation.sh`
- Action: Delete this test utility (760B)
- Reason: Development artifact, not used

#### `~/.claude/scripts/switch-profile.ts`
- Action: Delete this unused script (17KB)
- Reason: Profile switching feature not used (user confirmed)

#### `~/.claude/scripts/claude-profile`
- Action: Delete this shell wrapper (182B)
- Reason: Wrapper for deleted `switch-profile.ts`

#### `~/.claude/scripts/hook-mcp-inject.ts`
- Action: Delete this unused hook (3.9KB)
- Reason: MCP injection not needed (user confirmed)

### Phase 2: Rename for Clarity

#### `~/.claude/scripts/hook-post-file-enhanced.ts`
- Action: Rename to `hook-ts-quality-gate.ts`
- Reason: New name describes purpose (TypeScript quality validation gate)
- Method: `git mv` to preserve history

### Phase 3: Update Configuration

#### `~/.claude/settings.json`
- Action: Update hook reference from `hook-post-file-enhanced.ts` to `hook-ts-quality-gate.ts`
- Location: Line 47 in `hooks.PostToolUse[0].hooks[0].command`
- Change: `"bun /Users/flo/.claude/scripts/hook-post-file-enhanced.ts"` → `"bun /Users/flo/.claude/scripts/hook-ts-quality-gate.ts"`

### Phase 4: Update Documentation

#### `~/.claude/scripts/README.md`
- Action: Already created with correct naming (`hook-ts-quality-gate.ts`)
- Verify: Ensure all references are accurate after rename

## Testing Strategy

### Manual Verification
1. After deletions: Run `ls ~/.claude/scripts/` to confirm only active files remain
2. After rename: Run a simple Edit operation and verify the hook still triggers
3. After config update: Check Claude Code status line shows no errors

### Expected Final State
```
~/.claude/scripts/
├── README.md                    # Documentation (new)
├── apex-yolo-continue.ts        # APEX automation
├── command-validator/           # Security validation package
├── hook-apex-clipboard.ts       # APEX clipboard hook
├── hook-session-start.ts        # Session start hook
├── hook-stop.ts                 # Stop hook
├── hook-tool-router.ts          # Tool router hook
├── hook-ts-quality-gate.ts      # Quality gate hook (renamed)
├── node_modules/                # Dependencies
├── package.json                 # Package config
├── statusline/                  # Status display package
└── tsconfig.json                # TypeScript config
```

## Rollout Considerations

- **Risk**: Low. All deletions are confirmed orphan/deprecated files.
- **Rollback**: If anything breaks, restore from git (`git checkout -- <file>`)
- **Breaking changes**: None. The rename is transparent as long as `settings.json` is updated simultaneously.

## Execution Order

1. Delete all 11 files (can be done in one `rm` command)
2. Rename hook file with `git mv`
3. Update `settings.json` reference
4. Verify hooks still work
5. Commit changes
