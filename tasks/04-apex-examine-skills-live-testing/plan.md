# Implementation Plan: APEX Examine Skills + Live Testing

## Overview

Enhance the APEX workflow with two key improvements:
1. **Pattern Validation in `/apex:4-examine`**: Add React 19 and Next.js pattern detection as blocking errors (report only, no auto-fix)
2. **New `/apex:test-live` Command**: Browser-based live testing with GIF recording using claude-in-chrome MCP

Both features integrate with the existing APEX workflow and follow established command conventions.

## Dependencies

**Execution Order:**
1. First: Modify `4-examine.md` (foundational - other commands depend on validate-then-test flow)
2. Second: Create `test-live.md` (new command, references examine output)

**No external blockers** - all required MCP tools already available.

---

## File Changes

### `commands/apex/4-examine.md`

**Location:** `/Users/flo/.claude/commands/apex/4-examine.md`

**Action 1:** Update description in frontmatter
- Change description to include pattern validation
- Update to: "Examine phase - validate deployment readiness with build/lint/typecheck and React 19/Next.js pattern checks"

**Action 2:** Add new step 5B "PATTERN VALIDATION" between existing step 5 and step 6
- Insert new section after "ANALYZE ERRORS" (step 5) and before "CREATE FIX AREAS" (step 6)
- This step runs grep-based detection for React 19 anti-patterns:
  - `Context.Provider` usage (should use shorthand `<Context value={}>`)
  - `useContext()` calls (should use `use()` hook)
  - Manual memoization (`useMemo`, `useCallback`, `memo`)
  - ViewTransition without Suspense boundaries
- Behavior: **Blocking errors** - if patterns found, report and halt before fix areas
- Output format: Table with file paths and line numbers for each violation type

**Action 3:** Add pattern validation results to FINAL REPORT (step 11)
- Add new section "Pattern Validation" to the deployment readiness summary
- Include count of violations found per category
- Mark as blocking if any violations exist

**Action 4:** Add allowed-tools for pattern detection
- Add `Grep` to allowed-tools in frontmatter if not already present

**Action 5:** Update implementation.md section format
- Add "Pattern Validation" row to the Results table in step 10
- Include violation counts in the validation report

**Consider:** Pattern detection must run on the project's src directory, not the task folder. Use current working directory context.

---

### `commands/apex/test-live.md` *(NEW)*

**Location:** `/Users/flo/.claude/commands/apex/test-live.md`

**Action 1:** Create new file with APEX command structure
- Follow pattern from `3-execute.md` for frontmatter and workflow structure
- Description: "Live browser testing of implemented features with GIF recording"
- Argument-hint: `<task-folder-path> [--url=<url>] [--no-gif]`

**Action 2:** Define allowed MCP tools
- `mcp__claude-in-chrome__tabs_context_mcp` - Get available tabs
- `mcp__claude-in-chrome__tabs_create_mcp` - Create test tab
- `mcp__claude-in-chrome__navigate` - Navigate to URL
- `mcp__claude-in-chrome__read_page` - Get accessibility tree
- `mcp__claude-in-chrome__find` - Find elements by description
- `mcp__claude-in-chrome__computer` - Click, type, screenshot, scroll
- `mcp__claude-in-chrome__form_input` - Fill form fields
- `mcp__claude-in-chrome__read_console_messages` - Check for JS errors
- `mcp__claude-in-chrome__read_network_requests` - Monitor API calls
- `mcp__claude-in-chrome__gif_creator` - Record test sessions
- Also: `Read`, `Write`, `Bash`, `Task`

**Action 3:** Implement workflow with 13 steps
1. VALIDATE INPUT - Check task folder exists, read analyze.md and implementation.md
2. IDENTIFY TEST FLOWS - Extract testable user flows from task description
3. CHECK DEV SERVER - Verify dev server running (or provide start command)
4. GET/CREATE TAB - Use `tabs_context_mcp` to find or `tabs_create_mcp` to create
5. START GIF RECORDING - `gif_creator(action="start_recording")`
6. SCREENSHOT INITIAL STATE - Capture before any navigation
7. NAVIGATE - Go to feature URL using `navigate`
8. EXECUTE TESTS - For each test scenario:
   - Use `read_page` to understand structure
   - Use `find` to locate elements
   - Screenshot → action → screenshot pattern for smooth GIFs
   - Validate expected results appear
9. VALIDATE RESULTS - Check console for errors, network for failures
10. STOP & EXPORT GIF - `gif_creator(action="stop_recording")` then export
11. ORGANIZE RECORDINGS - Save to `recordings/success/` or `recordings/errors/`
12. UPDATE IMPLEMENTATION.MD - Add test results section with GIF references
13. REPORT - Summarize pass/fail with GIF paths

**Action 4:** Define GIF recording folder structure
```
.claude/tasks/<task-folder>/
├── recordings/
│   ├── success/
│   │   └── NNN-feature-name.gif
│   └── errors/
│       └── NNN-bug-description.gif
```

**Action 5:** Define GIF export options
- `showClickIndicators: true` - Orange circles on clicks
- `showActionLabels: true` - Labels describing actions
- `showProgressBar: true` - Progress bar at bottom
- `quality: 5` - High quality (lower number = better)

**Action 6:** Add screenshot strategy documentation
- Screenshot BEFORE each action (initial state)
- Screenshot AFTER each action (result state)
- Screenshot on page load, wait completion, form fill
- This ensures smooth GIF playback with ~10-20 frames per test

**Action 7:** Define error handling workflow
- Bug found → Save GIF to `recordings/errors/`
- Document in implementation.md with GIF reference
- Optionally create follow-up task or fix immediately
- Re-test after fix → Save success GIF

**Action 8:** Add usage examples section
```bash
# Test implemented feature
/apex:test-live 04-apex-examine-skills-live-testing

# Test with specific URL
/apex:test-live my-feature --url=http://localhost:3000/dashboard

# Test without GIF recording
/apex:test-live my-feature --no-gif
```

**Consider:** The command should gracefully handle cases where no testable flows are identified - ask user for manual guidance.

---

## Testing Strategy

### Manual Verification

**Test 1: Pattern Validation in Examine**
1. Create test file with React 19 anti-patterns:
   - Add `<SomeContext.Provider>` usage
   - Add `useContext()` call
   - Add `useMemo()` usage
2. Run `/apex:4-examine <test-folder>`
3. Verify: Patterns detected and reported as blocking errors
4. Verify: Validation halts before fix areas

**Test 2: Live Testing Command**
1. Have a running dev server on localhost:3000
2. Run `/apex:test-live <task-folder>`
3. Verify: Chrome tab created/used
4. Verify: GIF recording starts
5. Verify: Test executes with screenshots
6. Verify: GIF exported to correct folder
7. Verify: implementation.md updated with results

**Test 3: Full APEX Workflow Integration**
1. Run complete APEX flow: analyze → plan → execute → examine → test-live
2. Verify each phase integrates correctly
3. Verify implementation.md accumulates results from all phases

---

## Documentation

**No external documentation updates required.**

Both commands are self-documenting through their SKILL.md-style structure with usage examples.

---

## Rollout Considerations

### Feature Flags
- None needed - both features are additive and opt-in

### Breaking Changes
- **Pattern validation**: This adds blocking behavior to examine. Existing codebases with React 19 anti-patterns will now fail examine phase.
- **Mitigation**: Users can temporarily skip pattern validation by not running on React 19 projects, or update patterns before running examine.

### Migration Steps
- None required - new commands work immediately

### Risks

| Risk | Mitigation |
|------|------------|
| Pattern detection false positives | Use strict regex, report file:line for manual review |
| Dev server not running | Add clear error message with start command |
| Chrome browser not available | Fall back to Playwright MCP if needed |
| GIF recording fails | Make GIF optional with `--no-gif` flag |
