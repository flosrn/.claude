# Implementation Plan: APEX System Overview Documentation

## Overview

Create a permanent, polished documentation file (`commands/apex/overview.md`) that serves as the definitive reference for the APEX system. This extracts and refines the comprehensive analysis into a standalone documentation file that users and Claude Code can reference.

**Approach**: Single-file documentation with clear structure, preserving ASCII diagrams (more portable than Mermaid), and adding practical usage examples.

## Dependencies

- `analyze.md` - Source content (already complete)
- No code dependencies - this is pure documentation

## File Changes

### `commands/apex/overview.md` (NEW FILE)

Create new documentation file with the following structure:

**Section 1: Header & Quick Reference**
- Title: "APEX System Overview"
- One-sentence description
- Quick command table (command → purpose → common flags)
- Link to each command's detailed docs

**Section 2: Workflow Diagram**
- Copy and polish ASCII workflow diagram from analyze.md
- Keep ASCII format (more portable, works in terminals)
- Add brief explanation of each phase transition

**Section 3: Phase Details**
- For each phase (1-analyze through 4-examine):
  - Purpose
  - Input requirements
  - Output artifacts
  - Key flags with behavior
- Pattern: Brief bullet points, not walls of text

**Section 4: Utility Commands**
- `/apex:next` - auto-execute
- `/apex:status` - progress display
- `/apex:handoff` - context transfer
- `/apex:test-live` - browser testing
- Same format as phases

**Section 5: YOLO Mode**
- Copy automation flow diagram from analyze.md
- Explain the hook chain (PostToolUse → Stop → Terminal)
- Important: Document safety stop at execute phase

**Section 6: File Structure**
- Task folder template
- Artifact descriptions
- When each file is created

**Section 7: Key Patterns**
- ULTRA THINK
- BLUF structure
- Lazy loading
- Parallel notation (→ and ‖)
- File-centric planning

**Section 8: Troubleshooting**
- Common issues from audit findings
- Bash portability notes
- Flag combinations to avoid

**Section 9: Future Improvements**
- Suggested enhancements from audit (rollback, watch, templates)

**Writing Guidelines:**
- Keep sections scannable (bullets > paragraphs)
- Preserve ASCII diagrams exactly
- Add practical "when to use" guidance
- Include example invocations for each command

### `commands/apex/1-analyze.md`

- Add link to overview.md in header comment (optional, for discoverability)
- Pattern: `## See Also\n- [APEX Overview](./overview.md)`

### `.claude/settings.json` (VERIFY ONLY)

- Verify skill registration includes overview.md if skills auto-register from commands/
- No changes expected (skills scan directory)

## Testing Strategy

**Manual Verification:**
- Read overview.md and verify all commands are documented
- Verify ASCII diagrams render correctly in terminal
- Check that flag documentation matches actual command files
- Confirm links work (if any relative links added)

**No automated tests** - this is documentation only

## Documentation

- This IS the documentation task
- No additional docs needed
- README.md doesn't need updates (APEX is internal tooling)

## Rollout Considerations

- **No breaking changes** - adding new file only
- **No migration needed**
- **Immediate availability** - file accessible once created
- **Consider**: Adding to skill triggers so `/apex:overview` shows the docs
