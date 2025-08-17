# Smart Git Commit

**Intelligent commit with conventional format, emojis, and validation**
*Based on proven community practices from SteadyStart and best practices*

## Task Workflow
1. **Check Staged Changes**: Verify what files are staged for commit
2. **Analyze Changes**: Understand the nature and scope of modifications
3. **Generate Messages**: Create 5 conventional commit message options
4. **User Confirmation**: Display options and await selection
5. **Pre-commit Validation**: Run quality checks if available
6. **Execute Commit**: Perform git commit with selected message

## Commit Message Format
**Conventional Commits with Emojis:**
```
<emoji><type>(<scope>): <description>

[optional body]
```

## Commit Types & Emojis
- **✨ feat**: New features
- **🐛 fix**: Bug fixes  
- **📚 docs**: Documentation changes
- **♻️ refactor**: Code refactoring (no functional changes)
- **🧪 test**: Adding or updating tests
- **🔧 chore**: Maintenance tasks, deps updates
- **💄 style**: Code style/formatting (no logic changes)
- **⚡ perf**: Performance improvements
- **🔒 security**: Security improvements

## Implementation Steps
1. **Check Status**: `git status` to see staged files
2. **Analyze Diff**: `git diff --cached` to understand changes
3. **Generate Options**: Create 5 commit message suggestions
4. **Display Messages**: Show options with numbers for selection
5. **Await Confirmation**: User selects preferred message
6. **Quality Checks**: Run linting/tests if configured
7. **Commit**: Execute `git commit -m "selected message"`

## Validation Rules
- **NEVER stage files automatically** - only work with pre-staged files
- **NEVER commit without explicit user confirmation**
- **Abort if no staged changes** detected
- **Use English** for all commit messages
- **Keep descriptions concise** but descriptive
- **Include scope** when changes affect specific modules/features

## Message Generation Guidelines
- **Analyze file patterns** to determine appropriate type
- **Identify scope** from file locations (components, utils, docs, etc.)
- **Focus on the WHY** not just the WHAT
- **Use lowercase** for descriptions
- **Be specific** about the actual impact

## Pre-commit Checks (if available)
- Code formatting (Prettier/ESLint)
- Type checking (TypeScript)
- Unit tests
- Build verification

## Safety Features
- Confirm staged files before proceeding
- Show diff summary for context
- Allow abort at any stage
- Clear error messages for issues

## Example Good Messages
```
✨ feat(auth): add social login with Google OAuth
🐛 fix(header): resolve mobile navigation menu overflow
📚 docs(api): update authentication endpoint examples
♻️ refactor(utils): extract validation helpers to separate module
```

## Integration
- Compatible with CCNotify progress tracking
- Logged in observability system
- Respects existing pre-commit hooks
- Works with all git hosting platforms

Usage: `/commit`