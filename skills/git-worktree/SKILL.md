---
name: worktree
description: Git worktree management for gapila and lasdelaroute. Use when user mentions worktree, wt, parallel branches, or needs separate dev environment.
argument-hint: [branch-name]
---

# Git Worktree Management

Centralized worktree structure for Flo's projects.

## Key Paths

| Project | Main Repo | Worktrees |
|---------|-----------|-----------|
| gapila | `/Users/flo/Code/nextjs/gapila` | `/Users/flo/.claude-worktrees/gapila/<branch>` |
| lasdelaroute | `/Users/flo/Code/nextjs/lasdelaroute` | `/Users/flo/.claude-worktrees/lasdelaroute/<branch>` |

## Shell Aliases

| Alias | Description |
|-------|-------------|
| `wta <branch>` | Add worktree for existing branch |
| `wtan <branch>` | Add worktree + create new branch |
| `wtl` | List all worktrees |
| `wtr <path>` | Remove worktree |
| `wtc <branch>` | cd to worktree |

## Instructions

1. Navigate to main repo first: `cd /Users/flo/Code/nextjs/gapila`
2. Use `wtan <branch>` for new branches, `wta <branch>` for existing
3. Worktree created at `/Users/flo/.claude-worktrees/<project>/<branch>`
4. Clean up with `wtr <path>` after merge

## Raw Git Commands

```bash
# Create (existing branch)
git worktree add /Users/flo/.claude-worktrees/gapila/<branch> <branch>

# Create (new branch)
git worktree add -b <branch> /Users/flo/.claude-worktrees/gapila/<branch>

# List
git worktree list

# Remove
git worktree remove /Users/flo/.claude-worktrees/gapila/<branch>
```

For detailed workflows, see `references/workflows.md`.
