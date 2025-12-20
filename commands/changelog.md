# Claude Code Changelog & Setup Optimizer

Fetch the latest Claude Code features, explain them, and suggest improvements for the current setup.

## Instructions

You are a Claude Code expert. Your mission is to:

1. **Fetch Latest Changelog**
   - Use WebSearch to find "Claude Code changelog December 2025" and "Claude Code release notes"
   - Check https://github.com/anthropics/claude-code/releases
   - Look for features from the last 30 days

2. **Analyze Current Setup**
   Read these files to understand the current configuration:
   - `~/.claude/settings.json` - Main settings, hooks, plugins
   - `~/.claude/CLAUDE.md` - Global instructions
   - `~/.claude/agents/` - Custom agents
   - `~/.claude/commands/` - Custom commands
   - `~/.claude/hooks/hooks.json` - Hook configurations
   - `~/.claude/plugins/installed_plugins.json` - Installed plugins

3. **Generate Report**
   Create a structured report with:

   ### New Features Summary
   List the 5-10 most impactful new features with:
   - Feature name
   - Brief description (1-2 sentences)
   - Version introduced
   - Relevance score (High/Medium/Low) based on current setup

   ### Setup Improvements
   For each relevant new feature, provide:
   - **What**: The feature
   - **Why**: How it benefits the user's workflow
   - **How**: Exact steps or code to implement
   - **Priority**: High/Medium/Low

   ### Quick Wins
   List 3-5 immediate improvements that can be made in under 5 minutes.

   ### Advanced Optimizations
   Suggest deeper integrations that require more setup time.

4. **Output Format**
   Use clear markdown with:
   - Tables for feature comparisons
   - Code blocks for config changes
   - Checkboxes for actionable items

## Example Output Structure

```markdown
# Claude Code Changelog Report - [DATE]

## New Features (Last 30 Days)

| Feature | Version | Description | Relevance |
|---------|---------|-------------|-----------|
| LSP Tool | v2.0.74 | Code intelligence | High |
| ... | ... | ... | ... |

## Recommended Improvements

### 1. [Feature Name]
**Current**: Not configured
**Recommended**: Add to settings.json
```json
{
  "permissions": {
    "allow": ["new-feature"]
  }
}
```
**Impact**: [Description]

## Quick Wins
- [ ] Enable X in settings
- [ ] Add Y permission
- [ ] Configure Z hook

## Next Steps
1. ...
2. ...
```

## Execution

Start by searching for the latest changelog, then analyze the setup, then generate the report. Be thorough but concise.
