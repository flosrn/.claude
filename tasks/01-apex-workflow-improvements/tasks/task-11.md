# Task: Add System Notification for Background Tasks

## Problem

When tasks complete in background mode, users have no notification that work is done. They must manually check status.

## Proposed Solution

Modify the `Stop` hook in settings.json to include a macOS notification when background tasks complete, in addition to the existing sound.

## Dependencies

- None (independent settings change)

## Context

- File: `settings.json`
- Current Stop hook: plays sound on completion
- Add macOS notification command: `osascript -e 'display notification "APEX task completed" with title "Claude Code"'`
- Consider: May need hook condition to only trigger for background tasks

## Success Criteria

- Stop hook includes notification command
- Notification displays "APEX task completed" with "Claude Code" title
- Sound continues to play (existing behavior preserved)
- Works on macOS (using osascript)
