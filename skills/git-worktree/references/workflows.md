# Worktree Workflows

## Directory Structure

```
/Users/flo/
├── Code/nextjs/
│   ├── gapila/              # Main repo
│   └── lasdelaroute/        # Main repo
└── .claude-worktrees/
    ├── gapila/<branch>/
    └── lasdelaroute/<branch>/
```

## Environment Variable

```bash
WORKTREE_BASE="$HOME/.claude-worktrees"
```

## Common Scenarios

### Feature + Urgent Hotfix

```bash
# Working on feature-x in main repo, urgent hotfix arrives
wtan hotfix-critical
cd /Users/flo/.claude-worktrees/gapila/hotfix-critical
# Fix, commit, push, PR
# Return to main repo to continue feature-x
```

### PR Review

```bash
git fetch origin fix-payment
wta fix-payment
# Review in worktree
wtr /Users/flo/.claude-worktrees/gapila/fix-payment
```

### Long-term Parallel Work

```bash
wtan refactor-auth
# Keep both environments active indefinitely
```

## Raw Git Commands

### Create (existing branch)
```bash
git worktree add /Users/flo/.claude-worktrees/gapila/<branch> <branch>
```

### Create (new branch)
```bash
git worktree add -b <branch> /Users/flo/.claude-worktrees/gapila/<branch>
```

### List
```bash
git worktree list
```

### Remove
```bash
git worktree remove /Users/flo/.claude-worktrees/gapila/<branch>
```

## Best Practices

- Always create worktrees via aliases, not manually
- Remove worktrees after merge
- Main repo stays on `main` or active dev branch
- Use descriptive branch names
