---
description: "Export Claude Code responses to markdown file for perfect formatting preservation"
allowed-tools:
  [
    "Write(*)",
    "Read(*)", 
    "Bash(date:*)",
    "Bash(ls:*)",
    "Bash(/Users/flo/.raycast-scripts/claude-file-to-obsidian.sh)",
  ]
---

# Claude Command: Export Markdown

Export Claude Code responses to markdown file with perfect formatting preservation, ready for import into Obsidian or other markdown editors.

## Usage

```
/export-md                    # Export last response and auto-import to Obsidian (default)
/export-md "title"            # Set auto-export for next response with custom title
/export-md --full             # Export entire conversation to Obsidian
/export-md --file-only        # Export to file without Obsidian import
```

## Process

1. **Content Preparation**: Takes the last Claude response with all formatting
2. **Auto-Export Mode**: When title provided, sets up automatic export after next response
3. **File Creation**: Creates clean markdown file in `/tmp/` directory  
4. **Format Preservation**: Maintains all bold, italic, code blocks, and structure
5. **Obsidian Integration**: ALWAYS run `/Users/flo/.raycast-scripts/claude-file-to-obsidian.sh` immediately after file creation

## Critical Instructions

**MANDATORY BEHAVIOR**: After creating any file in `/tmp/`, you MUST immediately execute:
```bash
/Users/flo/.raycast-scripts/claude-file-to-obsidian.sh
```

**NEVER** tell the user to "use Raycast" or "import manually". **ALWAYS** run the script automatically.

## File Structure

```markdown
# Claude Code Export

## Response Content

[Your original response with perfect markdown formatting]

---
**Export Details:**
- Created: [timestamp]
- Source: Claude Code Terminal
- Format: Markdown
- Tags: #claude-code #exported

**Usage Tip:**
Use Raycast "Claude File → Obsidian" to import this file automatically.
```

## Export Locations

- **Default**: `/tmp/claude_output.md`
- **Custom**: `/tmp/[filename].md`
- **Timestamped**: `/tmp/claude_[YYYYMMDD_HHMMSS].md`

## Integration

### Raycast Import
After export, use your Raycast script:
- "Claude File → Obsidian" - Imports latest exported file
- Automatically creates new note in `00_Capture/`
- Preserves all markdown formatting perfectly

### Manual Import
```bash
# View exported content
cat /tmp/claude_output.md

# Copy to clipboard
pbcopy < /tmp/claude_output.md

# Move to specific location
mv /tmp/claude_output.md ~/Documents/notes/
```

## File Management

### Auto-Cleanup
- Files older than 7 days are automatically cleaned
- Prevents `/tmp/` directory clutter
- Keeps recent exports accessible

### Backup Options
- `--keep`: Prevent auto-cleanup for important exports  
- `--backup`: Copy to permanent location after export
- `--archive`: Move to dated archive folder

## Quality Features

### Content Processing
- **Markdown Validation**: Ensures proper markdown syntax
- **Link Processing**: Converts relative links to absolute when needed
- **Code Block Handling**: Preserves syntax highlighting information
- **Table Formatting**: Maintains table structure and alignment

### Metadata Enrichment
- **Source Tracking**: Records original command/query context
- **Timestamp Precision**: Exact creation time for organization
- **Tag Generation**: Auto-generates relevant tags based on content
- **Cross-References**: Links to related exports when detected

## Options

- `--full`: Export entire conversation instead of just last response
- `--file-only`: Export to file without auto-import to Obsidian
- `--raw`: Export without header/metadata (pure content only)
- `--timestamped`: Add timestamp to filename automatically  
- `--clipboard`: Also copy to clipboard after file creation

## Examples

```bash
# Basic export (last response)
/export-md

# Set auto-export for next response
/export-md "Analyse du problème Amethyst"

# Export entire conversation
/export-md --full

# Export without Obsidian import
/export-md --file-only
```

## Notes

- Perfect solution for preserving Claude's markdown formatting
- **Auto-Export Mode**: When you provide a title, Claude will automatically export the next response
- Eliminates copy-paste formatting loss
- Integrates seamlessly with existing Raycast workflow
- Files in `/tmp/` are safe and automatically managed
- Compatible with all markdown editors and note-taking apps

## Auto-Export Workflow

1. **Setup**: `/export-md "Mon titre personnalisé"`
2. **Claude responds**: "✅ Auto-export configuré pour la prochaine réponse avec le titre: Mon titre personnalisé"
3. **Ask your question**: Continue the conversation normally
4. **Auto-export**: Claude automatically exports his response to Obsidian with your custom title and opens it

## Attribution Rules

- **NEVER add Claude Code attribution to exported content**
- **NEVER include "Generated with Claude Code" in exports**
- **NEVER mention AI assistance in exported files**
- Exported content appears as natural markdown documentation