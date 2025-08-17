# Create Feature Branch

**Smart branch creation with intelligent naming and setup**

## Task Workflow
1. **Analyze Context**: Understand the task/feature from conversation or arguments
2. **Generate Branch Name**: Create conventional branch name (feature/, fix/, docs/, etc.)
3. **Create & Switch**: `git checkout -b` to new branch
4. **Verify Setup**: Confirm branch creation and current status

## Branch Naming Conventions
- **feature/**: New features or enhancements
- **fix/**: Bug fixes  
- **docs/**: Documentation changes
- **refactor/**: Code refactoring
- **test/**: Test additions/improvements
- **chore/**: Maintenance tasks

## Implementation Steps
1. **Check Current Status**: Run `git status` to see current state
2. **Analyze Task**: From conversation context or user description
3. **Generate Names**: Suggest 3 branch name options following conventions
4. **Create Branch**: `git checkout -b selected-name`
5. **Confirm Creation**: Show current branch and status

## Branch Name Format
`type/brief-description-kebab-case`

Examples:
- `feature/user-authentication`
- `fix/header-responsive-layout`
- `docs/api-documentation-update`

## Arguments Support
Command accepts optional description: `/branch "Add dark mode toggle"`

## Safety Checks
- Ensure working directory is clean or changes are stashed
- Warn if branch already exists
- Show current branch before and after creation
- **Verify no upstream remote push configurations**

## Remote Safety (CRITICAL)
- **NEVER push to upstream** remote (only origin allowed)
- Allow branching from any local branch (main, develop, feature branches)
- Focus on preventing upstream pushes, not branch creation

## Integration
- Compatible with CCNotify notifications
- Logged in observability system
- Follows project conventions

Usage: `/branch [optional description]`