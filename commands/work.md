---
description: "Smart workflow for any change type: branch creation, commit, and PR preparation"
allowed-tools:
  [
    "Bash(git:*)",
    "Bash(gh:*)",
  ]
---

# Claude Command: Work

Smart development workflow that handles branch creation, commits, and PR preparation in the correct order for ANY type of change.

## Usage

```
/work <name>              # Start new work: auto-detects type (feat/fix/chore/etc)
/work commit              # Commit current work with proper conventional format
/work pr                  # Create PR for current work
/work finish              # Complete workflow: commit + PR + merge
```

## Complete Workflow

### 1. Smart Work Start
```bash
/work login-bug-fix
```
**Actions:**
1. **Auto-detects type** from name/changes: `fix/login-bug-fix`
2. Check if on main/master - switch if needed  
3. Create appropriate branch based on work type
4. Switch to work branch
5. Ready for development

### 2. Work Commit
```bash
/work commit  
```
**Actions:**
1. Validate on work branch (not main)
2. **Auto-detects commit type** from changes and branch name
3. Stage changes
4. Create conventional commit with appropriate emoji
5. Keep on work branch for more commits

### 3. Work PR
```bash
/work pr
```
**Actions:**
1. Validate work branch has commits
2. Push work branch to origin (user's fork) 
3. **Auto-selects PR template** based on work type
4. Create PR from work branch to main
5. FORK-SAFE: Never touches upstream

### 4. Work Finish
```bash
/work finish
```
**Actions:**
1. Commit any pending changes
2. Push work branch to origin
3. Create PR with appropriate template
4. Optionally auto-merge if checks pass

## Branch Naming Conventions

**Auto-Generated Names:**
- `feat/user-authentication` (from "/work user-authentication")
- `fix/login-validation-bug` (from "/work login-validation-bug")  
- `chore/update-dependencies` (from "/work update-dependencies")
- `perf/optimize-database` (from "/work optimize-database")
- `docs/api-documentation` (from "/work api-documentation")

**Intelligent Type Detection:**
```
Analyzes work name + current changes:
├── feat/ → "add", "create", "implement", "new"
├── fix/ → "fix", "bug", "error", "issue", "broken"  
├── perf/ → "optimize", "performance", "speed", "faster"
├── docs/ → "documentation", "readme", "guide", "docs"
├── style/ → "format", "styling", "css", "design"
├── refactor/ → "refactor", "restructure", "cleanup"
├── test/ → "test", "testing", "spec", "coverage"
├── chore/ → "update", "upgrade", "config", "build"
├── security/ → "security", "auth", "vulnerable", "exploit"
└── hotfix/ → "urgent", "critical", "emergency", "hotfix"
```

## Safety Checks

### Pre-Branch Creation
```
Validation Checklist:
□ Working directory clean
□ Not already on feature branch
□ Branch name follows conventions
□ No conflicting branch exists
□ Ready to switch context
```

### Pre-Commit Validation
```
Work Commit Checklist:  
□ On work branch (not main)
□ Changes match branch type (feat/fix/chore/etc)
□ Commit message follows conventions
□ No breaking changes without notice
□ Tests added/updated as appropriate for change type
```

### Pre-PR Validation
```
PR Creation Checklist:
□ Work branch has commits ahead of main
□ Branch pushed to origin (user's fork)
□ No merge conflicts with main
□ PR targets correct repository (fork)
□ NEVER targets upstream
□ Appropriate PR template selected based on work type
```

## Smart Context Switching

### Auto-Stash Management
When starting new feature:
1. Check for uncommitted changes
2. Auto-stash current work if exists
3. Create and switch to feature branch
4. Optionally restore stash if same context

### Work Preservation
- Saves current branch reference
- Preserves working directory state
- Maintains recent branch history
- Enables quick context switching

## Integration with Other Commands

### With `/commit`
- Feature workflow takes precedence
- Validates branch before committing
- Suggests feature branch if on main

### With `/pr`
- Uses feature branch context
- Auto-detects feature type for PR template
- Ensures fork-safe PR creation

### With `/merge`
- Validates feature is complete
- Ensures PR is approved
- Safe merge within user's fork

## Advanced Features

### Automatic Branch Cleanup
```
Post-Merge Cleanup:
1. Switch back to main
2. Pull latest changes
3. Delete merged feature branch
4. Clean remote tracking
5. Update local references
```

### Feature Status Tracking
```
Track feature progress:
├── Created → Branch exists
├── In Progress → Has commits
├── Ready → PR created
├── Reviewed → PR approved
└── Completed → Merged and cleaned
```

### Conflict Prevention
- Analyzes main branch changes
- Suggests rebase if behind
- Warns about potential conflicts
- Provides conflict resolution guidance

## Options

- `--draft`: Create draft PR
- `--no-cleanup`: Skip post-merge cleanup
- `--rebase`: Rebase on main before PR
- `--template <type>`: Force specific PR template
- `--reviewer <users>`: Add reviewers to PR
- `--urgent`: Mark as urgent/hotfix

## Error Recovery

### Branch Issues
```bash
# If branch creation fails
/feature recover <name>    # Recover from failed branch creation
/feature switch <name>     # Switch to existing feature branch
```

### Commit Problems
```bash
# If commit fails
git reset HEAD~1           # Undo last commit
/feature commit --amend    # Amend previous commit
```

### PR Failures
```bash
# If PR creation fails
/feature pr --retry        # Retry PR creation
/feature pr --force        # Force PR despite issues
```

## Notes

- **FORK-FIRST APPROACH**: Always assumes fork workflow
- **MAIN BRANCH PROTECTION**: Prevents commits directly to main
- **INTELLIGENT NAMING**: Suggests branch names based on changes
- **COMPLETE WORKFLOW**: Handles entire feature lifecycle
- **SAFETY-FOCUSED**: Multiple validation points

## Attribution Rules

- **NEVER add Claude Code attribution to any Git operations**
- **NEVER include Co-Authored-By: Claude in commits**
- All feature operations must appear as authored solely by the human developer