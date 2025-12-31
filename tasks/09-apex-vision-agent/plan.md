# Implementation Plan: APEX Vision Agent with Claude Opus 4.5

## Overview

Create a dedicated vision analysis agent powered by Claude Opus 4.5 that integrates into the APEX analyze phase. The agent specializes in debugging context (primary), page state understanding (secondary), and design inspiration (occasional). Images are auto-detected via temp path patterns in user messages.

## Dependencies

- None blocking - Claude Opus 4.5 supports vision natively via model parameter

## File Changes

### `agents/vision-analyzer.md` (NEW)

- Create new agent file with opus model specification
- Follow frontmatter pattern from `agents/apex-executor.md:1-7` but with `model: opus`
- Write specialized prompt for UI/UX visual analysis
- Include adaptive output formats based on detected use case:
  - **Debugging**: Visual issue description, hypotheses, components to check
  - **Context**: Page state, visible elements, data displayed
  - **Inspiration**: Design patterns, colors, layout guidance
- Add instructions for reading images via absolute file paths
- Specify markdown output format with structured sections

### `commands/apex/1-analyze.md`

- Add image detection section after ULTRA THINK (Step 2)
- Implement auto-detection regex for temp paths and image extensions:
  - Pattern: `/tmp/`, `/var/folders/`, `.png`, `.jpg`, `.jpeg`, `.webp`, `.heic`
  - Check in user message content
- Add parallel agent launch for vision-analyzer when images detected:
  - Use `run_in_background: true` to match other parallel agents
  - Pass detected image paths to the agent prompt
- Add synthesis step to merge vision findings into analyze.md
- Include new output section "Vision Analysis" in analyze.md template
- Consider: Handle multiple images in single message

## Testing Strategy

- Manual verification steps:
  1. Create test task with drag & drop image
  2. Verify vision-analyzer agent is launched
  3. Check analyze.md includes vision findings
  4. Test with different image types (screenshot, mockup, photo)
- Edge cases to verify:
  - No images in message (agent should NOT launch)
  - Multiple images in single message
  - Image path mentioned but file doesn't exist

## Documentation

- No README changes needed (internal APEX feature)
- The analyze.md output format serves as self-documentation

## Rollout Considerations

- No breaking changes - new optional feature
- No migration needed
- Feature is additive to existing analyze workflow
