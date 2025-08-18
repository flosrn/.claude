# Smart Git Commit

**Intelligent commit with conventional format, emojis, and validation**
*Based on proven community practices from SteadyStart and best practices*

## Task Workflow
1. **Check Staged Changes**: Verify what files are staged for commit
2. **Analyze Changes**: Understand the nature and scope of modifications
3. **Generate Best Message**: Automatically select the most appropriate commit message
4. **Pre-commit Validation**: Run quality checks if available
5. **Execute Commit**: Perform git commit with selected message

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
3. **Intelligent Selection**: Automatically determine the best commit message based on:
   - File patterns and locations
   - Change types (new files, modifications, deletions)
   - Scope identification from directory structure
   - Impact analysis (breaking changes, features, fixes)
4. **Quality Checks**: Run linting/tests if configured
5. **Commit**: Execute `git commit -m "auto-selected message"`

## Validation Rules
- **NEVER stage files automatically** - only work with pre-staged files
- **AUTO-SELECT best commit message** - no user confirmation needed
- **Abort if no staged changes** detected
- **Use English** for all commit messages
- **Keep descriptions concise** but descriptive
- **Include scope** when changes affect specific modules/features

## Auto-Selection Logic
**Priority order for message selection:**
1. **Breaking changes** → 💥 BREAKING CHANGE
2. **New features** → ✨ feat
3. **Bug fixes** → 🐛 fix  
4. **Documentation** → 📚 docs
5. **Refactoring** → ♻️ refactor
6. **Tests** → 🧪 test
7. **Configuration/Dependencies** → 🔧 chore

**Scope detection:**
- Analyze primary directory of changes
- Use most specific scope (component > feature > general)
- Default to project name if no clear scope

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