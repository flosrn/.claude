---
description: "Creates well-formatted commits with conventional commit messages and emoji"
allowed-tools:
  [
    "Bash(git add:*)",
    "Bash(git status:*)",
    "Bash(git commit:*)",
    "Bash(git diff:*)",
    "Bash(git log:*)",
  ]
---

# Claude Command: Commit

Creates well-formatted commits with conventional commit messages and emoji.

## Usage

```
/commit
/commit --no-verify
```

## Process

1. **Check current branch** - If on main/master, suggest creating feature branch first
2. Check staged files, commit only staged files if any exist
3. Analyze diff for multiple logical changes
4. Suggest splitting if needed
5. Create commit with emoji conventional format
6. Husky handles pre-commit hooks automatically

## Branch Safety

**CRITICAL**: Before committing, validate:
- Not on main/master branch (unless explicitly intended)
- Feature branch exists for new features
- Hotfix branch for urgent fixes
- Branch naming follows conventions (feat/, fix/, chore/, etc.)

## Commit Format

`<emoji> <type>: <description>`

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `perf`: Performance
- `test`: Tests
- `chore`: Build/tools

**Rules:**

- Imperative mood ("add" not "added")
- First line <72 chars
- Atomic commits (single purpose)
- Split unrelated changes

## Emoji Map

✨ feat | 🐛 fix | 📝 docs | 💄 style | ♻️ refactor | ⚡ perf | ✅ test | 🔧 chore | 🚀 ci | 🚨 warnings | 🔒️ security | 🚚 move | 🏗️ architecture | ➕ add-dep | ➖ remove-dep | 🌱 seed | 🧑‍💻 dx | 🏷️ types | 👔 business | 🚸 ux | 🩹 minor-fix | 🥅 errors | 🔥 remove | 🎨 structure | 🚑️ hotfix | 🎉 init | 🔖 release | 🚧 wip | 💚 ci-fix | 📌 pin-deps | 👷 ci-build | 📈 analytics | ✏️ typos | ⏪️ revert | 📄 license | 💥 breaking | 🍱 assets | ♿️ accessibility | 💡 comments | 🗃️ db | 🔊 logs | 🔇 remove-logs | 🙈 gitignore | 📸 snapshots | ⚗️ experiment | 🚩 flags | 💫 animations | ⚰️ dead-code | 🦺 validation | ✈️ offline

## Split Criteria

Different concerns | Mixed types | File patterns | Large changes

## Options

`--no-verify`: Skip Husky hooks

## Notes

- Husky handles pre-commit checks
- Only commit staged files if any exist
- Analyze diff for splitting suggestions

## Attribution Rules

- **NEVER add Claude signature to commits**
- **NEVER include Co-Authored-By: Claude <noreply@anthropic.com>**
- **NEVER mention "Generated with Claude Code"**
- Commits must appear as authored solely by the human developer
