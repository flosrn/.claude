# Create Pull Request

**Intelligent PR creation with context analysis and GitHub CLI integration**
*Adapted from Liam-HQ and community best practices*

## Task Workflow
1. **Pre-flight Checks**: Verify branch state and remote sync
2. **Push Changes**: Ensure current branch is pushed to remote
3. **Analyze Context**: Generate intelligent PR title and description
4. **Create PR**: Use GitHub CLI with smart defaults
5. **Link Issues**: Auto-detect and link related issues

## Implementation Steps
1. **Remote Security Check**: Verify we're NOT pushing to upstream remote
2. **Branch Validation**: Ensure current branch follows conventions (feature/, fix/, etc.)
3. **Check Branch Status**: Verify current branch and commit status
4. **Safe Push**: `git push -u origin current-branch` (origin only, never upstream)
5. **Analyze Changes**: Review commit history and file changes since main
6. **Generate PR Content**: Create title and description based on commits
7. **Detect Issues**: Look for issue references in commits
8. **Create PR**: Execute `gh pr create` with generated content
9. **Provide Links**: Show PR URL and next steps

## PR Title Format
**Conventional format with emoji:**
```
<emoji>(<scope>): Descriptive title explaining the change
```

Examples:
- `✨(auth): Add social login functionality`
- `🐛(mobile): Fix navigation menu on small screens`
- `📚(docs): Update API documentation with examples`

## PR Description Template
```markdown
## 🎯 Summary
Brief description of what this PR accomplishes.

## 📋 Changes
- **Added**: New features or files
- **Fixed**: Bug fixes and issues resolved  
- **Changed**: Modified behavior or implementation
- **Removed**: Deleted features or files

## 🧪 Testing
- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] Edge cases considered

## 📷 Screenshots (if applicable)
[Add screenshots for UI changes]

## 🔗 Related Issues
Closes #123
Fixes #456

## 📝 Notes
Additional context or considerations for reviewers.
```

## GitHub CLI Commands Used
```bash
# Create draft PR with auto-generated content
gh pr create --draft \
  --title "Generated title" \
  --body "Generated description" \
  --base main

# Useful follow-up commands shown to user
gh pr ready        # Convert draft to ready for review
gh pr list --author "@me"  # Show your PRs
gh pr view         # View current PR details
```

## Smart Content Generation
- **Analyze commit messages** since divergence from main
- **Identify patterns** in changed files to determine scope
- **Extract issue references** from commit messages
- **Generate summary** based on actual changes made
- **Suggest appropriate emoji** based on change type

## Security Validations (CRITICAL)
- **NEVER push to UPSTREAM** remotes (only origin allowed)
- **ABORT if branch name doesn't follow conventions** (feature/, fix/, docs/, etc.)
- Verify GitHub CLI is authenticated (`gh auth status`)
- Check if current branch has commits ahead of main
- Ensure branch is pushed to origin remote only
- Confirm no uncommitted changes

## Protected Remotes (NO PUSH ALLOWED)
- upstream (NEVER push to upstream)
- Any remote other than origin
- Allow push to origin/main, origin/develop etc. (your fork)

## Branch Analysis
- **Compare with main**: `git log main..HEAD --oneline`
- **File changes**: `git diff main --name-only`
- **Commit count**: Count commits since branch point
- **Issue detection**: Parse commit messages for `#123`, `fixes #456`, etc.

## Auto-detection Features
- **Scope identification**: Based on primary directory of changes
- **Change type**: Determined from commit types and file patterns
- **Related issues**: Extracted from commit messages and branch names
- **Breaking changes**: Detected from commit body content

## Safety Features
- **Create as draft** by default for review before publishing
- **Show preview** of title and description before creation
- **Verify base branch** (usually main/master)
- **Handle errors** gracefully with helpful messages

## Integration
- **CCNotify**: Notification when PR is created successfully
- **Observability**: Log PR creation events
- **Context tracking**: PR context logged in observability system
- **Project standards**: Respect CLAUDE.md guidelines

## Error Handling
- Missing GitHub CLI installation
- Authentication issues
- No changes to create PR for
- Network connectivity problems
- Repository access permissions

Usage: `/pr`

**Note**: Ensure you're on a feature branch with pushed commits before using this command.