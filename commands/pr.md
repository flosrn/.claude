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
/pr                    # Create PR from current branch
/pr create             # Create PR with interactive options
/pr list               # List open PRs with status
/pr review <number>    # Review specific PR
/pr merge <number>     # Merge PR with validation
/pr conflicts          # Check and resolve merge conflicts
/pr draft              # Create draft PR
/pr ready              # Mark draft PR as ready
```

## Features

### Smart PR Creation
- **Auto-detection**: Detects branch type and suggests appropriate PR template
- **Template selection**: Chooses between feature, bugfix, hotfix, or documentation templates
- **Intelligent targeting**: Automatically targets correct base branch (main, develop, release)
- **Draft handling**: Creates draft PRs for WIP branches, ready PRs for complete features
- **Fork safety**: NEVER pushes to upstream, always pushes to origin (your fork)

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
- **Branch protection**: Respects repository branch protection rules
- **Triangular workflow**: Full support for fork-to-upstream workflows

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
- Current repository is a fork (not upstream)
- Origin remote points to your fork
- NEVER push to upstream remote

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

- Supports GitHub's triangular workflow for open source contributions
- Integrates with GitHub Actions for automated workflows
- Respects repository settings and branch protection rules
- Provides rollback capabilities for all operations
- Maintains audit trail of all PR activities
- **CRITICAL**: NEVER pushes to upstream remote, only to origin (your fork)
- Always validates that you're pushing to your own repository before creating PR
- Ensures proper fork workflow: origin (your fork) → upstream (original repo)

## Attribution Rules

- **NEVER add Claude Code attribution to PR descriptions**
- **NEVER include "🤖 Generated with Claude Code" footer**
- **NEVER mention Claude or AI assistance in PR templates**
- **NEVER add Co-Authored-By: Claude <noreply@anthropic.com> to commits**
- All PRs must appear as created solely by the human developer