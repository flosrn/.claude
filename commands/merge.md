---
description: "Intelligent merge management with conflict resolution and safety checks"
allowed-tools:
  [
    "Bash(git:*)",
    "Bash(gh:*)",
    "Read(*)",
  ]
---

# Claude Command: Merge

Intelligent merge management with conflict resolution, safety checks, and fork-aware operations.

## Usage

```
/merge                    # Interactive merge current branch
/merge <branch>          # Merge specified branch  
/merge --fast-forward    # Fast-forward merge only
/merge --no-ff           # Force merge commit
/merge --squash          # Squash merge
/merge pr <number>       # Merge pull request
/merge --abort           # Abort current merge
/merge --continue        # Continue after conflict resolution
```

## Smart Merge Strategies

### Auto-Strategy Selection
```
Merge Strategy Decision Tree:
├── No conflicts + linear history → Fast-forward
├── Feature branch + clean history → Squash merge  
├── Collaborative branch → Merge commit
└── Complex history → Interactive resolution
```

### Fork-Safe Merging
- **NEVER merges from upstream directly**
- Always validates merge source and destination
- Ensures merges happen within user's fork
- Protects against accidental upstream modifications

## Merge Types

### Fast-Forward Merge
```bash
# Clean linear history
git checkout main
git merge feature/my-feature --ff-only
```

### Squash Merge  
```bash
# Single commit for feature
git checkout main
git merge feature/my-feature --squash
git commit -m "✨ feat: complete feature implementation"
```

### Merge Commit
```bash
# Preserves branch history
git checkout main  
git merge feature/my-feature --no-ff
```

## Conflict Resolution

### Pre-Merge Validation
```
Pre-Merge Checklist:
□ Working directory clean
□ Target branch up-to-date
□ No uncommitted changes
□ Source branch exists
□ Merge permissions valid
□ Fork safety confirmed
```

### Interactive Conflict Resolution
```
Conflict Resolution Workflow:
1. Detect conflicts automatically
2. Show conflicted files with context
3. Provide resolution guidance
4. Validate resolution completeness
5. Complete merge with safety checks
```

### Automatic Resolution
- Simple conflicts resolved automatically
- Configuration-based resolution rules
- Learning from previous resolutions
- Fallback to manual when uncertain

## Pull Request Merging

### GitHub Integration
```bash
# Merge PR with validation
gh pr merge <number> --squash
gh pr merge <number> --merge  
gh pr merge <number> --rebase
```

### Pre-Merge PR Checks
```
PR Merge Validation:
□ All checks passed
□ Required reviews approved
□ No merge conflicts
□ Branch up-to-date
□ PR not draft
□ Fork safety confirmed
```

### Post-Merge Cleanup
- Automatically deletes merged branch
- Updates local branch tracking
- NEVER syncs with upstream automatically
- Notifies relevant stakeholders

## Safety Features

### Fork Protection
```
Fork Safety Rules:
✅ Merge within user's fork only
❌ Never merge from upstream directly  
✅ Validate source branch ownership
❌ Block cross-fork merges without review
```

### Rollback Capabilities
```bash
# Undo last merge
git reset --hard HEAD~1

# Reset to specific commit
git reset --hard <commit-hash>

# Create revert commit
git revert -m 1 <merge-commit>
```

### Backup Before Merge
- Creates automatic backup branch
- Stores merge state snapshots  
- Enables easy recovery
- Maintains operation audit trail

## Branch Cleanup

### Automatic Cleanup
```
Post-Merge Cleanup:
1. Delete merged feature branch locally
2. Delete remote tracking branch
3. Update branch references
4. Prune obsolete remotes
5. Clean up backup branches (after confirmation)
```

### Manual Cleanup Commands
```bash
# Clean merged branches
git branch --merged | grep -v main | xargs -n 1 git branch -d

# Clean remote tracking branches
git remote prune origin

# Cleanup backup branches (interactive)
git branch | grep backup- | xargs -n 1 git branch -D
```

## Workflow Integration

### Commit Integration
When used with `/commit`:
1. Creates quality commit
2. Prepares branch for merge
3. Validates merge readiness
4. Executes safe merge

### PR Integration
When used with `/pr`:
1. Creates pull request
2. Waits for approvals/checks
3. Automatically merges when ready
4. Cleans up post-merge

### Local Integration  
When used with local commands:
1. Works within user's fork only
2. Merges/rebases local changes
3. Executes merge operation
4. Pushes results to origin (user's fork)

## Advanced Features

### Merge Conflict Prevention
```
Conflict Prevention:
├── Pre-merge file analysis
├── Dependency impact assessment
├── Automatic small conflict resolution
└── Risk assessment reporting
```

### Interactive Merge Tools
- Integration with VS Code merge editor
- Command-line merge tool support
- Visual diff presentation
- Side-by-side conflict resolution

### Merge Metrics
- Track merge success rates
- Analyze conflict patterns
- Monitor merge performance
- Report merge statistics

## Error Recovery

### Failed Merge Recovery
```bash
# If merge fails midway
git merge --abort
git reset --hard HEAD
git clean -fd

# Recovery workflow
git stash save "pre-merge-recovery"
git checkout safe-point
git branch recovery-$(date +%s)
```

### State Validation
- Validates repository state before merge
- Confirms merge completion
- Verifies expected outcomes
- Reports any anomalies

## Configuration

### Merge Preferences
```yaml
# .gitconfig
[merge]
    tool = vscode
    ff = only  # Prefer fast-forward
    conflictstyle = diff3

[pull]
    rebase = true
    ff = only
```

### Repository Settings
```yaml
# Repository-specific merge rules
merge_strategy: squash
auto_cleanup: true
require_pr: true
fork_safety: strict
```

## Options

- `--dry-run`: Preview merge without executing
- `--strategy <strategy>`: Force specific merge strategy
- `--no-cleanup`: Skip post-merge cleanup
- `--backup`: Create backup before merge
- `--interactive`: Enable interactive mode
- `--verify`: Extra validation checks
- `--force`: Override safety checks (dangerous)

## Attribution Rules

- **NEVER add Claude Code attribution to merge commits**
- **NEVER include Co-Authored-By: Claude in merge messages**
- All merge operations must appear as authored solely by the human developer

## Critical Safety

🚨 **FORK SAFETY FIRST**
- NEVER merge from upstream automatically
- ALWAYS confirm source and destination branches are within user's fork
- VALIDATE merge permissions before execution
- BACKUP before any destructive operations

The merge command works ONLY within user's fork, NEVER with upstream.