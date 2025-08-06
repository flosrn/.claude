---
description: "Fork-safe Git operations that NEVER push to upstream"
allowed-tools:
  [
    "Bash(git:*)",
    "Bash(gh:*)",
  ]
---

# Claude Command: Fork Safe

Fork-safe Git operations with bulletproof protection against accidentally pushing to upstream repositories.

## Usage

```
/fork-safe push                # Safe push to origin only
/fork-safe pr                  # Create PR with fork validation
/fork-safe sync               # Sync from upstream, push to origin
/fork-safe check              # Verify fork setup and remotes
/fork-safe setup              # Configure fork remotes properly
```

## Core Principles

🚫 **NEVER PUSH TO UPSTREAM**
✅ **ALWAYS PUSH TO ORIGIN (your fork)**
🔍 **VALIDATE BEFORE EVERY OPERATION**

## Fork Safety Checks

### Pre-Operation Validation
```
Fork Safety Checklist:
□ Current repo is a fork
□ Origin points to your username
□ Upstream points to original repo  
□ Current branch has local commits
□ Remote validation passed
□ Push destination is origin
```

### Remote Configuration Validation
```bash
# Expected configuration:
origin    git@github.com:flosrn/repo-name.git (your fork)
upstream  git@github.com:original-owner/repo-name.git (original)

# NEVER:
upstream  git@github.com:flosrn/repo-name.git (wrong!)
origin    git@github.com:original-owner/repo-name.git (dangerous!)
```

## Safe Operations

### Safe Push
- Always validates destination is origin
- Confirms branch doesn't exist on upstream
- Sets upstream tracking to origin/branch
- NEVER pushes to upstream remote

### Safe PR Creation
```
PR Creation Process:
1. Validate fork setup
2. Ensure commits exist locally
3. Push branch to origin (your fork)
4. Create PR from origin to upstream
5. Verify PR targets correct repositories
```

### Safe Sync
```
Sync Process:
1. Fetch from upstream (read-only)
2. Merge/rebase with local commits
3. Push result to origin (your fork)
4. Update tracking branches
```

## Fork Setup

### Auto-Configuration
```bash
# Detects and configures:
git remote add upstream <original-repo-url>
git remote set-url origin <your-fork-url>
git config push.default simple
git config remote.pushdefault origin
```

### Multiple Fork Support
- Manages multiple forks of same project
- Per-project remote configuration
- Workspace-wide fork policies
- Cross-fork synchronization

## Error Prevention

### Push Guards
- Intercepts git push commands
- Validates destination remote
- Blocks upstream pushes
- Provides safe alternatives

### Remote Validation
```
Validation Rules:
✅ origin = your GitHub username
❌ origin = upstream owner
✅ upstream = original repository  
❌ upstream = your fork
```

### Branch Protection
- Prevents pushing main/master to upstream
- Validates feature branch destinations
- Confirms commit ownership
- Checks push permissions

## Recovery Operations

### Accidental Push Recovery
```
If upstream push occurs:
1. Immediately create backup
2. Force push to correct remote
3. Contact upstream maintainers
4. Document incident
```

### Configuration Repair
- Detects incorrect remote setup
- Repairs broken fork relationships
- Restores proper configurations
- Validates repair success

## Integration

### GitHub CLI Integration
```bash
# Safe PR creation
gh pr create --repo original-owner/repo-name \
             --head flosrn:feature-branch \
             --base main
```

### Git Hooks
- Pre-push hooks for validation
- Post-receive confirmation
- Remote validation checks
- Error notification system

## Monitoring

### Operation Logging
- Logs all fork operations
- Tracks push destinations
- Records safety violations
- Maintains audit trail

### Health Checks
- Regular remote validation
- Fork relationship verification
- Configuration integrity checks
- Workspace consistency monitoring

## Configuration

### Global Settings
```yaml
# ~/.claude/fork-safe-config.yml
enforce_fork_safety: true
allow_upstream_push: false  # NEVER change this
validate_remotes: true
log_operations: true
backup_before_push: true
```

### Repository Settings
```yaml
# .git/config additions
[remote "origin"]
    url = git@github.com:flosrn/repo-name.git
    fetch = +refs/heads/*:refs/remotes/origin/*
    pushurl = git@github.com:flosrn/repo-name.git
[remote "upstream"]
    url = git@github.com:original-owner/repo-name.git
    fetch = +refs/heads/*:refs/remotes/upstream/*
    # NO pushurl = upstream is READ-ONLY
[push]
    default = simple
    pushdefault = origin
```

## Emergency Procedures

### Locked Out of Push
```
Recovery Steps:
1. Verify remote configuration
2. Check authentication tokens
3. Validate repository permissions
4. Test with simple push
```

### Fork Relationship Broken
```
Repair Process:
1. Backup current state
2. Remove broken remotes
3. Re-add correct remotes
4. Validate configuration
5. Test operations
```

## Options

- `--force-check`: Extra validation before operations
- `--dry-run`: Preview operations without execution
- `--backup`: Create backup before risky operations
- `--repair`: Attempt automatic configuration repair
- `--strict`: Enable maximum safety checks
- `--log`: Enable detailed operation logging

## Attribution Rules

- **NEVER add Claude Code attribution to any Git operations**
- **NEVER include Co-Authored-By: Claude in commits or PRs**
- All operations must appear as authored solely by the human developer

## Critical Reminders

🚨 **UPSTREAM IS READ-ONLY**
🚨 **ORIGIN IS YOUR FORK**  
🚨 **VALIDATE BEFORE EVERY PUSH**
🚨 **WHEN IN DOUBT, DON'T PUSH**

Never trust, always verify. Your fork safety depends on it.