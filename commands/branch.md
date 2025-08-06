---
description: "Advanced branch management with intelligent naming, automated cleanup, and workflow optimization"
allowed-tools:
  [
    "Bash(git branch:*)",
    "Bash(git checkout:*)",
    "Bash(git switch:*)",
    "Bash(git stash:*)",
    "Bash(git fetch:*)",
    "Bash(git merge:*)",
    "Bash(git rebase:*)",
    "Bash(gh repo:*)",
  ]
---

# Claude Command: Branch

Advanced branch management with intelligent naming conventions, automated cleanup, smart switching, and upstream synchronization.

## Usage

```
/branch                        # Show branch status and recommendations
/branch create <name>          # Create new branch with smart naming
/branch switch <name>          # Smart switch with stash management
/branch clean                  # Clean up merged and stale branches
/branch sync                   # Sync with upstream/origin
/branch rename <old> <new>     # Rename branch locally and remotely
/branch protect <name>         # Set up branch protection rules
/branch flow                   # Initialize git-flow branching model
```

## Smart Branch Creation

### Naming Conventions
- **Feature branches**: `feature/JIRA-123-short-description`
- **Bugfix branches**: `bugfix/JIRA-456-fix-description`
- **Hotfix branches**: `hotfix/JIRA-789-critical-fix`
- **Release branches**: `release/v1.2.0`
- **Chore branches**: `chore/update-dependencies`

### Auto-Detection
- Analyzes commit messages and current work context
- Suggests appropriate branch type and naming
- Validates naming against team conventions
- Prevents duplicate or conflicting branch names

### Branch Templates
```
# Feature Branch Template
feature/
├── Initial setup commit
├── Implementation commits
├── Test addition commits
└── Documentation updates

# Hotfix Branch Template  
hotfix/
├── Issue identification
├── Minimal fix implementation
└── Verification tests
```

## Intelligent Switching

### Smart Stash Management
- **Auto-stash**: Automatically stashes uncommitted changes
- **Selective stashing**: Stashes only relevant files
- **Smart restoration**: Applies stash when switching back
- **Conflict prevention**: Warns about potential conflicts

### Context Preservation
- Saves current working directory
- Preserves environment variables
- Maintains editor state
- Tracks recent branch history

### Dependency Handling
- Checks for node_modules/build artifacts
- Manages package.json changes
- Handles database migrations
- Updates environment configurations

## Automated Cleanup

### Merged Branch Detection
- Identifies branches merged into main/develop
- Distinguishes between squash-merged and regular merges
- Preserves important historical branches
- Handles remote branch cleanup

### Stale Branch Analysis
- Detects branches with no recent activity
- Analyzes commit recency and relevance
- Considers PR status and review activity
- Provides interactive cleanup options

### Safe Deletion Process
```
Cleanup Process:
1. Fetch latest remote changes
2. Identify merged branches
3. Confirm deletion candidates
4. Backup branch references
5. Delete local branches
6. Clean remote tracking branches
7. Prune remote references
```

## Upstream Synchronization

### Fork Management
- Automatically detects upstream repositories
- Configures upstream remotes (READ-ONLY)
- Handles fork-specific workflows
- Manages multiple remotes
- **NEVER pushes to upstream** - only to origin (user's fork)

### Sync Strategies
- **Fast-forward**: When no local changes exist
- **Rebase**: Replays local commits on latest upstream
- **Merge**: Creates merge commit for complex histories
- **Interactive**: Manual conflict resolution guidance
- **Fork-safe**: Always pushes to origin, never to upstream

### Conflict Resolution
- Pre-sync conflict detection
- Interactive merge tool integration
- Rollback capabilities
- Backup creation before sync operations

## Branch Protection

### Protection Rules
- Require pull request reviews
- Dismiss stale reviews on new commits
- Require status checks to pass
- Require branches to be up to date
- Require signed commits
- Restrict pushes to matching branches

### Quality Gates
- Enforce code coverage thresholds
- Require passing CI/CD pipelines
- Validate commit message format
- Check for security vulnerabilities
- Ensure documentation updates

## Git Flow Integration

### Branch Types
- **main**: Production-ready code
- **develop**: Integration branch for features
- **feature/***: Feature development branches
- **release/***: Release preparation branches
- **hotfix/***: Emergency production fixes

### Flow Commands
```
/branch flow init              # Initialize git-flow
/branch flow feature start     # Start new feature
/branch flow feature finish    # Complete feature
/branch flow release start     # Start release
/branch flow release finish    # Complete release
/branch flow hotfix start      # Start hotfix
/branch flow hotfix finish     # Complete hotfix
```

## Workflow Optimization

### Branch Metrics
- Track branch age and activity
- Monitor merge frequency
- Analyze code review cycles
- Measure time to production

### Performance Insights
- Identify bottleneck branches
- Suggest workflow improvements
- Highlight stale work
- Recommend cleanup actions

### Team Collaboration
- Show branch ownership
- Track collaborative branches
- Identify conflict-prone areas
- Suggest pair programming opportunities

## Advanced Features

### Interactive Mode
- Visual branch tree display
- Interactive selection menus
- Real-time status updates
- Keyboard shortcuts for common actions

### Integration Support
- JIRA ticket linking
- Slack notifications
- GitHub/GitLab integration
- CI/CD pipeline triggers

### Backup and Recovery
- Automatic branch backups before operations
- Recovery from failed operations
- Branch history preservation
- Commit reference tracking

## Options

- `--force`: Force operations (use with caution)
- `--dry-run`: Preview changes without executing
- `--interactive`: Enable interactive mode
- `--preserve-stash`: Keep stash after operations
- `--upstream <remote>`: Specify upstream remote
- `--pattern <regex>`: Use custom naming pattern
- `--no-verify`: Skip pre-operation hooks
- `--backup`: Create backup before destructive operations

## Safety Features

### Fork Protection
- **Upstream safety**: NEVER allows push to upstream
- **Remote validation**: Ensures operations target correct remote
- **Origin verification**: Confirms origin is user's fork
- **Push destination check**: Validates push target before execution

### Pre-Operation Checks
- Verify clean working directory
- Check for uncommitted changes
- Validate remote connectivity
- Confirm destructive operations

### Rollback Capabilities
- Undo recent branch operations
- Restore deleted branches
- Recover from failed merges
- Reset to previous states

### Audit Trail
- Log all branch operations
- Track operation timestamps
- Record operation outcomes
- Maintain operation history

## Notes

- Integrates seamlessly with existing Git workflows
- Supports multiple branching strategies (Git Flow, GitHub Flow, GitLab Flow)
- Respects repository-specific configurations
- Provides educational guidance for Git best practices
- Maintains compatibility with all Git hosting platforms

## Attribution Rules

- **NEVER add Claude Code attribution to branch commits**
- **NEVER include Co-Authored-By: Claude in any Git operations**
- All branch operations must appear as authored solely by the human developer