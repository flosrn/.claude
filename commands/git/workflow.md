# Complete Git Workflow

**Meta-command that handles the complete git workflow from feature creation to PR**
*Combines all git commands in the logical order*

## Task Workflow
Execute the complete git workflow in the correct order:
1. **Create Feature Branch** (`/branch` logic)
2. **Make Changes** (user works on code)
3. **Smart Commit** (`/commit` logic)  
4. **Create Pull Request** (`/pr` logic)

## Implementation Strategy
This command will:
1. **Understand the task** from user description or conversation context
2. **Execute each step** of the workflow with user confirmation
3. **Handle errors** at each stage gracefully
4. **Provide progress updates** throughout the process

## Workflow Steps

### Step 1: Branch Creation
- Analyze task description to generate branch name
- Create and switch to new feature branch
- Confirm successful branch creation

### Step 2: Development Pause
- Inform user that they should now make their code changes
- Provide guidance on what to implement
- Wait for user to indicate changes are complete

### Step 3: Staging & Commit
- Guide user to stage files (`git add`)
- Execute smart commit workflow
- Auto-select best conventional commit message
- Handle pre-commit validations

### Step 4: Pull Request Creation
- Push branch to remote
- Generate intelligent PR content
- Create draft PR with GitHub CLI
- Provide PR link and next steps

## Usage Patterns

### With Task Description
```
/workflow "Add dark mode toggle to header component"
```

### With Issue Reference  
```
/workflow "Fix mobile navigation bug - issue #123"
```

### Interactive Mode
```
/workflow
```
Then describe the task when prompted.

## Smart Defaults
- **Branch naming**: Automatically infer type (feature/fix/docs) from description
- **Commit messages**: Generate based on file changes and task context
- **PR content**: Create comprehensive description from commits and context
- **Scope detection**: Identify affected modules/components automatically

## Progress Tracking
- **Show current step** in the workflow
- **Provide checkmarks** for completed steps
- **Allow resuming** from any point if interrupted
- **Integration with CCNotify** for progress notifications

## Security & Error Recovery
- **Remote Protection**: NEVER push to upstream remote (origin only)
- **Step validation**: Ensure each step succeeds before proceeding
- **Rollback options**: Ability to undo changes if issues occur
- **Resume capability**: Pick up where left off if command fails
- **Clear error messages**: Helpful guidance for resolving issues

## Critical Security Rules
- **NEVER push to upstream** remote (only origin allowed)
- **Allow all local branch operations** (main, develop, feature branches)
- **Always validate remote safety** before push operations
- **Abort immediately** if upstream push detected

## User Confirmations
- **Branch name approval**: Show generated name for confirmation
- **Auto-commit execution**: Best message selected automatically
- **PR content review**: Display title/description before creation
- **Final confirmation**: Summary of all actions before execution

## Integration Features
- **Flashback memory**: Save workflow context for future reference
- **Observability logging**: Track complete workflow execution
- **CCNotify alerts**: Notifications at key milestones
- **Quality gates**: Respect existing CI/CD requirements

## Command Arguments
- `$ARGUMENTS` - Task description for automated workflow
- Interactive prompts if no arguments provided
- Support for issue references (#123)
- Handle multi-step tasks

## Example Execution
```
User: /workflow "Add user authentication with OAuth"

✅ 1. Creating branch: feature/user-authentication-oauth
✅ 2. Branch created and switched
⏸️  3. Please implement the OAuth authentication feature
   
[User implements code]

User: Ready to commit

✅ 4. Analyzing changes in src/auth/
✅ 5. Auto-selected best commit message
✅ 6. Committed: ✨ feat(auth): add OAuth authentication flow
✅ 7. Pushing to remote...
✅ 8. Creating PR...
✅ 9. PR created: https://github.com/user/repo/pull/42

🎉 Workflow complete! PR is ready for review.
```

## Advanced Features
- **Multi-commit workflows**: Handle complex features requiring multiple commits
- **Conflict resolution**: Guide through merge conflicts if they occur  
- **Team notifications**: Integrate with team communication tools
- **Template customization**: Respect project-specific PR templates

Usage: `/workflow [task description]`

**Perfect for**: Complete feature development cycles, bug fixes, and documentation updates.