---
description: "Intelligent repository synchronization for multi-repo workflows, fork management, and workspace coordination"
allowed-tools:
  [
    "Bash(git fetch:*)",
    "Bash(git pull:*)",
    "Bash(git push:*)",
    "Bash(git remote:*)",
    "Bash(git status:*)",
    "Bash(gh repo:*)",
    "Bash(gh auth:*)",
  ]
---

# Claude Command: Sync

Intelligent repository synchronization system for managing multi-repo workflows, fork relationships, workspace coordination, and upstream maintenance.

## Usage

```
/sync                          # Smart sync current repository
/sync workspace               # Sync entire workspace/organization
/sync upstream                # Sync fork with upstream repository
/sync fork                    # Sync upstream changes to all forks
/sync status                  # Show sync status across repositories
/sync config                  # Configure sync preferences
/sync conflicts              # Handle sync conflicts interactively
```

## Repository Synchronization

### Smart Detection
- **Fork relationships**: Automatically detects upstream repositories
- **Remote configuration**: Validates and configures necessary remotes
- **Branch mapping**: Maps local branches to correct upstream branches
- **Conflict prediction**: Analyzes potential conflicts before sync

### Sync Strategies
```
Strategy Selection:
├── Fast-forward: Clean linear history
├── Rebase: Replay local commits on upstream
├── Merge: Create merge commit for complex cases
└── Interactive: Manual resolution for conflicts
```

### Upstream Management
- Automatic upstream remote configuration
- Multi-upstream support for complex workflows
- Upstream branch tracking and mapping (READ-ONLY)
- Divergence detection and reporting
- **NEVER pushes to upstream** - upstream is read-only

## Workspace Synchronization

### Multi-Repository Coordination
- **Workspace detection**: Finds related repositories in workspace
- **Dependency mapping**: Understands inter-repo dependencies
- **Batch operations**: Synchronizes multiple repos efficiently
- **Rollback coordination**: Maintains consistency across repos

### Organization-Level Sync
```
Organization Sync Process:
1. Discover all accessible repositories
2. Analyze fork relationships and dependencies
3. Create synchronization plan
4. Execute sync with conflict handling
5. Verify consistency across workspace
6. Generate sync report
```

### Selective Synchronization
- Include/exclude specific repositories
- Filter by topics, languages, or patterns
- Respect repository access permissions
- Handle archived and disabled repositories

## Fork Management

### Upstream Tracking
- **Auto-discovery**: Finds original repository for forks
- **Branch synchronization**: Keeps fork branches up-to-date
- **Pull request coordination**: Manages PRs during sync
- **Conflict resolution**: Handles upstream conflicts intelligently

### Triangular Workflow Support
```
Fork Workflow:
origin (your fork) ←→ local repository ←→ upstream (original)

Sync Operations:
1. Fetch from upstream (READ-ONLY)
2. Merge/rebase local changes
3. Push ONLY to origin fork (NEVER to upstream)
4. Update pull requests

⚠️  CRITICAL: NEVER push to upstream remote
```

### Multiple Fork Management
- Manage multiple forks of same repository
- Cross-fork synchronization
- Selective branch management
- Fork-specific configurations

## Conflict Resolution

### Intelligent Conflict Detection
- **Pre-sync analysis**: Identifies potential conflicts
- **Change classification**: Categorizes types of conflicts
- **Resolution suggestions**: Recommends resolution strategies
- **Impact assessment**: Evaluates conflict resolution effects

### Interactive Resolution Tools
```
Conflict Resolution Workflow:
1. Conflict identification and categorization
2. Side-by-side diff visualization
3. Interactive merge tool integration
4. Resolution validation and testing
5. Commit conflict resolution
6. Continue sync process
```

### Automated Resolution
- Safe automatic resolution for simple conflicts
- Configuration-based resolution rules
- Learning from previous resolutions
- Fallback to manual resolution when needed

## Workspace Intelligence

### Dependency Awareness
- **Monorepo support**: Handles internal dependencies
- **Cross-repo dependencies**: Tracks external dependencies
- **Version coordination**: Maintains compatible versions
- **Build order optimization**: Syncs in dependency order

### Project Relationships
```
Relationship Types:
├── Parent-Child: Monorepo structures
├── Peer: Related projects in workspace
├── Upstream-Fork: Fork relationships
└── Template-Instance: Template-based repos
```

### Sync Scheduling
- Automated sync scheduling
- Peak hour avoidance
- CI/CD integration timing
- Team timezone consideration

## Status and Reporting

### Comprehensive Status
- **Repository health**: Sync status, conflicts, issues
- **Branch divergence**: Ahead/behind commit counts
- **Remote status**: Connection and authentication status
- **Last sync**: Timestamp and outcome information

### Visual Dashboard
```
Sync Status Dashboard:
┌─────────────────────────────────────────┐
│ Repository Sync Status                  │
├─────────────────────────────────────────┤
│ ✅ repo-1       │ Up to date            │
│ ⚠️  repo-2       │ 3 commits behind      │
│ ❌ repo-3       │ Merge conflicts       │
│ 🔄 repo-4       │ Syncing...            │
└─────────────────────────────────────────┘
```

### Sync Reports
- Detailed sync operation logs
- Performance metrics and timing
- Error reporting and resolution
- Historical sync trends

## Advanced Features

### Batch Operations
- **Parallel synchronization**: Multiple repos simultaneously
- **Progress tracking**: Real-time sync progress
- **Error handling**: Robust error recovery
- **Resource management**: Memory and network optimization

### Security and Authentication
- **Token management**: GitHub token validation and refresh
- **Permission verification**: Ensures necessary permissions
- **Secure credential storage**: Safe credential handling
- **Multi-account support**: Handle multiple GitHub accounts

### Integration Support
```
CI/CD Integration:
- GitHub Actions workflow triggers
- Webhook notifications
- Status check updates
- Deployment coordination
```

## Configuration Management

### Global Settings
```yaml
# ~/.claude/sync-config.yml
default_strategy: rebase
conflict_resolution: interactive
workspace_paths:
  - ~/projects
  - ~/work
exclude_patterns:
  - "**/node_modules"
  - "**/.git"
upstream_naming: upstream
```

### Repository-Specific Config
- Per-repository sync strategies
- Custom remote configurations
- Branch-specific rules
- Sync frequency settings

### Team Configuration
- Shared workspace configurations
- Organization-wide policies
- Role-based sync permissions
- Compliance requirements

## Safety Features

### Fork Protection
- **Upstream write protection**: NEVER allows push to upstream
- **Remote validation**: Ensures push destination is your fork
- **Origin verification**: Confirms origin points to your repository
- **Upstream read-only**: Treats upstream as read-only source

### Backup and Recovery
- **Pre-sync backups**: Automatic state snapshots
- **Rollback capabilities**: Undo sync operations
- **State verification**: Validate sync outcomes
- **Recovery procedures**: Restore from failures

### Validation Checks
```
Pre-Sync Validation:
□ Working directory clean
□ Remote connectivity verified
□ Authentication valid
□ No uncommitted changes
□ Branch protection respected
```

### Dry Run Mode
- Preview sync operations
- Conflict simulation
- Impact assessment
- Risk evaluation

## Performance Optimization

### Efficient Operations
- **Incremental sync**: Only sync changed content
- **Parallel processing**: Concurrent operations
- **Bandwidth optimization**: Minimal data transfer
- **Caching strategies**: Reduce redundant operations

### Resource Management
- Memory usage optimization
- Network bandwidth control
- CPU usage balancing
- Storage space management

## Options

- `--dry-run`: Preview sync operations without executing
- `--force`: Force sync ignoring safety checks
- `--strategy <method>`: Override default sync strategy
- `--parallel <n>`: Set parallel operation limit
- `--timeout <seconds>`: Set operation timeout
- `--exclude <pattern>`: Exclude repositories matching pattern
- `--include <pattern>`: Only include repositories matching pattern
- `--no-fetch`: Skip fetching from remotes

## Notes

- Supports GitHub, GitLab, Bitbucket, and custom Git servers
- Integrates with existing Git workflows and tools
- Maintains audit trails for compliance requirements
- Provides comprehensive error reporting and recovery
- Scales from single repositories to large organizations
- Respects repository permissions and access controls

## Attribution Rules

- **NEVER add Claude Code attribution to sync commits**
- **NEVER include Co-Authored-By: Claude in merge commits**
- All Git operations must appear as authored solely by the human developer