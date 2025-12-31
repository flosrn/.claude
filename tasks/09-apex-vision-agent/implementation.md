# Implementation: APEX Vision Agent with Claude Opus 4.5

## Overview
Add a dedicated vision analysis agent to the APEX workflow that uses Claude Opus 4.5 to analyze screenshots and images for debugging context, page state understanding, and design inspiration.

## Status: ✅ Complete
**Progress**: 2/2 tasks completed

## Task Status

| Task | Description | Status | Session |
|------|-------------|--------|---------|
| 1 | Create vision-analyzer agent with Opus model | ✅ Complete | Session 1 |
| 2 | Integrate vision detection into 1-analyze.md | ✅ Complete | Session 1 |

---

## Session Log

### Session 1 - 2025-12-31

**Task(s) Completed**: Tasks 1 & 2 - Vision analyzer agent and APEX integration

#### Changes Made
- Created dedicated vision analysis agent powered by Claude Opus 4.5
- Added image detection logic to APEX analyze phase
- Integrated vision agent into parallel agent launch
- Added Vision Analysis section to analyze.md output template

#### Files Changed

**New Files:**
- `agents/vision-analyzer.md` - Opus-powered vision agent for UI/UX analysis

**Modified Files:**
- `commands/apex/1-analyze.md` - Added vision detection (Step 2b), vision-analyzer to agent list, Vision Analysis output section

#### Implementation Details

**Agent Features:**
- Uses `model: opus` for Claude Opus 4.5's superior vision capabilities
- Auto-detects use case (Debugging > Context > Inspiration > Design-to-Code)
- Structured markdown output for each use case type
- Integrates seamlessly with parallel agent execution

**Detection Patterns:**
- File paths: `/tmp/`, `/var/folders/`, `/Users/*/Desktop/`
- Extensions: `.png`, `.jpg`, `.jpeg`, `.webp`, `.heic`, `.heif`
- Keywords: "screenshot", "image", "mockup", "photo", "picture"

#### Notes
- No tests to run (this is a prompt/configuration feature)
- Feature is additive - no breaking changes to existing workflow
- Vision agent only launches when images are detected (saves tokens)

---

### Session 2 - 2025-12-31

**Task(s) Completed**: Image cache discovery and automatic detection

#### Problem Discovered
- Subagents via Task tool cannot access inline images from parent conversation
- Task tool `prompt` parameter is `type: string` - no multimodal support
- Images must be passed as file paths for the agent to read them

#### Solution Found
**Claude Code Image Cache**: When images are shared (drag & drop or Ctrl+V), Claude Code stores them in:
```
~/.claude/image-cache/<session-uuid>/N.png
```

#### Changes Made
- Updated Step 2b in `1-analyze.md` to auto-detect images from cache
- Added bash command to find recent images (< 5 min old)
- Documented priority order: explicit path > cache detection

#### Files Changed

**Modified Files:**
- `commands/apex/1-analyze.md` - Improved vision detection with automatic cache lookup

#### Key Discovery
```bash
# Find most recent image shared in Claude Code
/usr/bin/find ~/.claude/image-cache -name "*.png" -type f -mmin -5 -print0 2>/dev/null | \
  xargs -0 ls -t 2>/dev/null | head -1
```

#### Workflow
1. User shares image (drag & drop) → Claude Code caches it
2. `/apex:1-analyze` detects recent image in cache
3. Launches `vision-analyzer` agent with the file path
4. Agent reads image via `Read` tool and analyzes it

---

## Technical Notes
- Claude Opus 4.5 has superior semantic understanding for UI screenshots
- The `model: opus` frontmatter parameter routes the Task tool to use Opus
- Images are read natively by Claude Code via the `Read` tool
- **Task tool limitation**: `prompt` is string-only, no multimodal content blocks
- **Image cache location**: `~/.claude/image-cache/<uuid>/N.png`
- **CleanShot cache** (alternative): `~/Library/Application Support/CleanShot/media/media_*/`

## Suggested Commit

```
feat: add APEX vision agent with Claude Opus 4.5

- Create vision-analyzer agent for UI screenshot analysis
- Add automatic image detection from ~/.claude/image-cache/
- Support debugging, context, inspiration, and design-to-code use cases
- Integrate into parallel agent workflow for optimal speed

Image workflow: drag & drop → cache → auto-detect → vision agent
```
