---
description: "Comprehensive pull request management with automated workflows and intelligent assignment"
allowed-tools:
  [
    "Bash(gh pr:*)",
    "Bash(gh repo:*)",
    "Bash(git:*)",
    "Bash(git status:*)",
    "Bash(git diff:*)",
    "Bash(git push:*)",
    "Bash(git fetch:*)",
  ]
---

# Claude Command: Pull Request

Comprehensive pull request management with automated workflows, intelligent reviewer assignment, and merge conflict resolution.

## Usage

```
/pr                    # Create PR from current branch (user's fork only)
/pr create             # Create PR with interactive options (user's fork only)
/pr list               # List open PRs with status (user's fork only)
/pr review <number>    # Review specific PR (user's fork only)
/pr merge <number>     # Merge PR with validation (user's fork only)
/pr conflicts          # Check and resolve merge conflicts (user's fork only)
/pr draft              # Create draft PR (user's fork only)
/pr ready              # Mark draft PR as ready (user's fork only)
```

## CRITICAL IMPLEMENTATION

**EVERY `gh pr create` command MUST use:**
```bash
gh pr create --repo flosrn/$(basename $(git remote get-url origin) .git) --base main --head feature-branch
```

**NEVER EVER:**
```bash
gh pr create  # This targets upstream = FORBIDDEN
```

## Features

### Smart PR Creation
- **Auto-detection**: Detects branch type and suggests appropriate PR template
- **Template selection**: Chooses between feature, bugfix, hotfix, or documentation templates
- **FORK-ONLY TARGETING**: ALWAYS targets user's fork with `--repo flosrn/repo-name`
- **Draft handling**: Creates draft PRs for WIP branches, ready PRs for complete features
- **NO UPSTREAM**: NEVER mentions, touches, or references upstream EVER

### Reviewer Assignment
- **Code ownership**: Analyzes changed files and suggests reviewers based on CODEOWNERS
- **Workload balancing**: Considers current reviewer workload and availability
- **Team expertise**: Matches reviewers to relevant code areas and technologies
- **Escalation rules**: Assigns additional reviewers for critical changes

### Conflict Resolution
- **Pre-merge validation**: Checks for conflicts before attempting merge
- **Interactive resolution**: Guides through conflict resolution with context
- **Auto-rebase**: Attempts automatic rebase when safe
- **Rollback safety**: Provides easy rollback options if resolution fails

### Workflow Integration
- **CI/CD awareness**: Waits for required checks before allowing merge
- **Status validation**: Ensures all requirements met (reviews, tests, builds)
- **Branch protection**: Respects user's repository branch protection rules
- **SIMPLE FORK WORKFLOW**: Internal PRs within user's fork ONLY

## PR Templates

### Feature Template
```
## Summary
Brief description of the feature and its purpose.

## Changes
- [ ] Implementation details
- [ ] Tests added/updated
- [ ] Documentation updated

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Breaking Changes
None / Describe any breaking changes

## Screenshots/Demos
If applicable, add screenshots or demo links
```

### Bugfix Template
```
## Bug Description
Clear description of the bug being fixed.

## Root Cause
Explanation of what caused the issue.

## Solution
How the bug was fixed and why this approach was chosen.

## Testing
- [ ] Bug reproduction test added
- [ ] Regression tests pass
- [ ] Manual verification completed

## Impact
Describe the impact of this fix on users/system
```

### Hotfix Template
```
## Critical Issue
Description of the critical issue requiring immediate fix.

## Urgency Justification
Why this cannot wait for the normal release cycle.

## Solution
Minimal changes to fix the critical issue.

## Risk Assessment
- Risk level: [Low/Medium/High]
- Affected systems: [List]
- Rollback strategy: [Describe]

## Post-Deploy Actions
- [ ] Monitor system metrics
- [ ] Verify fix in production
- [ ] Plan proper long-term solution
```

## Merge Strategies

### Fast-Forward Merge
- Clean linear history
- Used for small, atomic changes
- Requires up-to-date branch

### Squash and Merge
- Single commit per feature
- Clean main branch history
- Preserves PR discussion context

### Merge Commit
- Preserves branch structure
- Shows feature development history
- Used for complex features

## Validation Rules

### Pre-Creation Checks
- Branch has commits ahead of base
- Branch name follows conventions
- No uncommitted changes in working directory
- Remote branch exists or will be created
- ALWAYS use `--repo flosrn/repo-name` flag
- Target user's fork only
- UPSTREAM IS FORBIDDEN

### Pre-Merge Validation
- All required reviews approved
- All CI checks passing
- No merge conflicts
- Branch protection rules satisfied
- Up-to-date with base branch

### Quality Gates
- Code coverage threshold met
- Linting passes
- Type checking passes
- Security scans clean
- Performance benchmarks met

## Automation Features

### Auto-Labeling
- Automatically applies labels based on:
  - File paths changed
  - Size of change
  - Type of change (feature/fix/docs)
  - Priority indicators

### Smart Notifications
- Notifies relevant stakeholders
- Escalates stale PRs
- Reminds about pending reviews
- Updates on CI status changes

### Integration Support
- Links to related issues
- Updates project boards
- Triggers deployment workflows
- Generates release notes

## Options

- `--draft`: Create as draft PR
- `--auto-merge`: Enable auto-merge when requirements met
- `--no-template`: Skip PR template
- `--target <branch>`: Override target branch detection
- `--reviewer <users>`: Add specific reviewers
- `--label <labels>`: Add custom labels
- `--milestone <milestone>`: Assign to milestone
- `--linked-issue <issue>`: Link to specific issue

## Notes

- **FORK-ONLY OPERATIONS**: ALL PRs created within user's fork
- **UPSTREAM = FORBIDDEN**: NEVER touches, mentions, or references upstream
- **COMMAND SYNTAX**: ALWAYS uses `gh pr create --repo flosrn/repo-name`
- Integrates with GitHub Actions for automated workflows
- Respects user's repository settings and branch protection rules
- Provides rollback capabilities for all operations
- Maintains audit trail of all PR activities
- **FORK ONLY**: feature-branch → main (within user's fork)

## Attribution Rules

- **NEVER add Claude Code attribution to PR descriptions**
- **NEVER include "🤖 Generated with Claude Code" footer**
- **NEVER mention Claude or AI assistance in PR templates**
- **NEVER add Co-Authored-By: Claude <noreply@anthropic.com> to commits**
- All PRs must appear as created solely by the human developer