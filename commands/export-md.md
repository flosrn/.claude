---
description: "Export current response content to markdown with Obsidian integration"
allowed-tools:
  [
    "Write(*)",
    "Read(*)", 
    "Bash(date:*)",
    "Bash(ls:*)",
    "Bash(pbcopy:*)",
    "Bash(open:*)",
  ]
---

# Claude Command: Export Markdown

Export Claude Code responses to markdown file with perfect formatting preservation and Obsidian integration.

## Usage

```
/export-md                     # Export this response with default title
/export-md "Custom Title"      # Export with custom title  
/export-md --clipboard         # Also copy to clipboard
/export-md --open              # Open file after creation
```

## How It Works

Since Claude Code doesn't retain conversation history between sessions, this command works by:

1. **User provides content**: You tell Claude what content to export in the same message
2. **Real-time export**: Claude exports the content you specify immediately
3. **File creation**: Creates timestamped markdown file in `/tmp/`
4. **Obsidian integration**: Uses `open` command to trigger Obsidian import workflow

## Correct Usage Examples

```
/export-md "Analyse du bug" 

Voici l'analyse complète du problème :
- Bug identifié dans la fonction X
- Solution proposée : Y
- Tests à effectuer : Z
```

**CRITICAL**: You must provide the content to export in the same message, as Claude cannot access previous responses.

## Implementation Process

When `/export-md` is called with content, Claude will:

1. **Parse the request**: Extract title and content from the user's message
2. **Create markdown file**: Generate timestamped file in `/tmp/`
3. **Format content**: Apply proper markdown structure with metadata
4. **Copy to clipboard** (if requested)
5. **Trigger Obsidian**: Use `open` command to import via Obsidian

## File Structure

```markdown
# [Title or "Claude Code Export"]

[User-provided content with perfect markdown formatting]

---
**Export Details:**
- Created: [timestamp]
- Source: Claude Code
- Session: [date/time]
- Tags: #claude-code #exported
```

## Export Locations

- **Default**: `/tmp/claude_export_[YYYYMMDD_HHMMSS].md`
- **Custom**: `/tmp/claude_[title_sanitized]_[timestamp].md`

## Real Implementation Example

```bash
# User runs:
/export-md "Solution Bug Auth"

Mon analyse du bug d'authentification :
- Problème dans JWT validation
- Solution : mise à jour middleware
- Tests requis

# Claude creates:
/tmp/claude_solution_bug_auth_20250106_190423.md
# And triggers Obsidian import
```

## Options

- `--clipboard`: Also copy to clipboard after file creation  
- `--open`: Open file in default markdown app after creation
- `--raw`: Export without metadata footer

## Correct Usage Examples

### Example 1: Technical Analysis
```
/export-md "Analyse Performance Database"

## Problème Identifié
La requête SQL sur la table `users` prend 3.2s en moyenne.

## Cause Root
- Manque d'index sur la colonne `email`
- Query scan complet de 2M lignes

## Solution
```sql
CREATE INDEX idx_users_email ON users(email);
```

## Impact Attendu  
- Réduction à ~50ms
- 98% d'amélioration performance
```

### Example 2: Bug Report  
```
/export-md "Bug Critical Auth JWT" --clipboard

# Bug Report: JWT Authentication

## Symptômes
- Users disconnectés randomly
- Error 401 après 10min
- JWT expire avant refresh

## Fix Applied
Mise à jour du middleware avec refresh automatique.
```

## Technical Implementation

Claude will:
1. Extract title from first parameter (or use timestamp)
2. Capture all content after the command
3. Create formatted markdown file with metadata
4. Optionally copy to clipboard or open file
5. Use macOS `open` command to trigger Obsidian workflow

## File Naming Convention

- Format: `claude_{title_sanitized}_{YYYYMMDD_HHMMSS}.md`
- Safe characters only (no spaces/special chars in filename)
- Timestamp ensures uniqueness

## Notes  

- **Real-time export**: Content must be provided in the same message
- **Perfect formatting**: Preserves all markdown syntax
- **Obsidian ready**: Compatible with Obsidian auto-import
- **Cross-platform**: Works with any markdown editor
- **No session dependency**: Works in any Claude Code session

## Attribution Rules

- **NEVER add Claude Code attribution to exported content**
- **NEVER include "Generated with Claude Code" in exports**  
- **NEVER mention AI assistance in exported files**
- Exported content appears as natural documentation