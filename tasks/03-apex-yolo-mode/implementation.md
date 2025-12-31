# Implementation: APEX YOLO Mode - Autonomous Workflow

## Overview
Mode YOLO pour APEX qui permet l'exécution autonome du workflow en vidant le contexte entre chaque phase et en démarrant automatiquement la phase suivante via AppleScript keystrokes.

## Status: ✅ Complete
**Progress**: All components implemented and tested

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ FLUX YOLO (Fullscreen Compatible!)                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  /apex:1-analyze folder --yolo                                  │
│       │                                                         │
│       ├─→ Crée: .claude/tasks/folder/.yolo                      │
│       │                                                         │
│       ▼                                                         │
│  [Phase APEX s'exécute]                                         │
│       │                                                         │
│       ▼                                                         │
│  PostToolUse Hook (apex-clipboard)                              │
│       ├─→ Copie: /apex:2-plan folder --yolo                     │
│       └─→ Crée: /tmp/.apex-yolo-continue                        │
│       │                                                         │
│       ▼                                                         │
│  Stop Hook                                                      │
│       └─→ Lance: apex-yolo-continue.ts                          │
│       │                                                         │
│       ▼                                                         │
│  [Claude se termine dans pane 1]                                │
│       │                                                         │
│       ▼ (après 0.5s)                                            │
│  Ouvre NOUVEAU SPLIT (Cmd+Shift+D) ou tmux window               │
│       └─→ claude "/apex:2-plan folder --yolo"                   │
│       │                                                         │
│       ▼                                                         │
│  [Split 2: Nouvelle session s'exécute]                          │
│  [Split 1: Libre pour autre travail!]                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Avantage clé**: Fonctionne en fullscreen ! (splits au lieu de tabs)

## Files Changed

### New Files
| File | Purpose |
|------|---------|
| `scripts/apex-yolo-continue.ts` | Background script that sends keystrokes after Claude exits |
| `scripts/test-terminal-automation.sh` | Test script to verify AppleScript works |
| `tasks/03-apex-yolo-mode/analyze.md` | Exploration document |

### Modified Files
| File | Changes |
|------|---------|
| `scripts/hook-apex-clipboard.ts` | Added YOLO mode detection, creates `/tmp/.apex-yolo-continue` flag |
| `scripts/hook-stop.ts` | Launches `apex-yolo-continue.ts` when YOLO flag exists |
| `commands/apex/1-analyze.md` | Added `--yolo` flag support, creates `.yolo` marker file |
| `commands/apex/2-plan.md` | Added `--yolo` flag support |
| `commands/apex/5-tasks.md` | Added `--yolo` flag support |

## Test Results

| Test | Result |
|------|--------|
| Terminal automation (AppleScript) | ✅ Works with Ghostty |
| YOLO flag creation | ✅ `.yolo` file created correctly |
| Clipboard with --yolo | ✅ `/apex:2-plan folder --yolo` copied |
| YOLO continue flag | ✅ `/tmp/.apex-yolo-continue` created |
| Execute phase stops YOLO | ✅ `.yolo` deleted at execute phase |
| apex-yolo-continue.ts | ✅ Spawns background process correctly |

## Usage

```bash
# Start YOLO mode from analyze phase
/apex:1-analyze "Add user authentication" --yolo

# YOLO will automatically chain:
# → /apex:2-plan nn-add-user-auth --yolo
# → /apex:5-tasks nn-add-user-auth --yolo (if complex)
# → /apex:3-execute nn-add-user-auth (STOPS here, no --yolo)
```

## Safety Features

1. **Auto-stops at execute phase** - User reviews each task manually
2. **Error detection** - YOLO stops if errors detected in session
3. **Ctrl+C interruption** - User can always abort
4. **1.5s delay** - Time to abort before automation kicks in
5. **Flag cleanup** - `.yolo` and continue flag deleted to prevent loops

## Technical Notes

- **Terminal detection**: Auto-detects tmux, Ghostty, iTerm2, or Terminal.app
- **New pane/window opening** (in priority order):
  1. **tmux**: `tmux new-window` - works everywhere, no AppleScript needed
  2. **Ghostty**: Split pane via `Cmd+Shift+D` - **works in fullscreen!**
  3. **iTerm2**: AppleScript `create tab with default profile`
  4. **Terminal.app**: AppleScript `do script` (fallback)
- **Fullscreen support**: Ghostty tabs don't work in fullscreen (macOS limitation), but splits do!
- **Multi-session support**: Each YOLO phase opens in its own split/window
- **Flag locations**: `.yolo` in task folder, continue flag in `/tmp/`
- **Working directory**: Preserved from original session via `cd`

## Suggested Commit

```
feat: add YOLO mode for autonomous APEX workflow execution

- Add --yolo flag to apex:1-analyze, apex:2-plan, apex:5-tasks
- Auto-continues to next phase in NEW terminal window
- Supports Ghostty, iTerm2, and Terminal.app
- Multi-session compatible - no foreground focus required
- Stops automatically at execute phase for manual review
- Safety features: error detection, flag cleanup, working dir preserved
```
