# Task: APEX Workflow Improvements - Examine Skills + Live Browser Testing

## Quick Summary (TL;DR)

**Key files to modify:**
- `commands/apex/4-examine.md` - Add React 19/Next.js pattern verification
- `commands/apex/test-live.md` *(NEW)* - Browser-based live testing command

**Patterns to follow:**
- Existing APEX command structure in `commands/apex/3-execute.md:1-200`
- Skill integration via prompt instructions (not programmatic invocation)
- MCP tools from `browser-testing` skill in `skills/browser-testing/SKILL.md`

**Key Finding:** Skills cannot be programmatically invoked from slash commands. Instead, embed skill content or reference patterns directly in the command.

**Dependencies:** None blocking

**Estimation:** ~2 tasks, ~1.5h total

---

## Codebase Context

### Current APEX Examine Command (`commands/apex/4-examine.md`)

The examine command focuses on **deployment readiness** through:
1. Discovering build/lint/typecheck commands from `package.json`
2. Running build and all diagnostics
3. Analyzing and categorizing errors by file
4. Launching parallel snipper agents to fix errors (max 5 files per area)
5. Formatting code
6. Re-running verification
7. Updating `implementation.md` with results

**Current validation coverage:**
- ✅ Build errors
- ✅ ESLint errors
- ✅ TypeScript errors
- ✅ Code formatting
- ❌ React 19 patterns (not checked)
- ❌ Next.js optimizations (not checked)
- ❌ Live browser testing (not included)

### Skills Available for Integration

#### 1. React 19 Patterns (`skills/react19-patterns/SKILL.md`)
**Key patterns to validate:**
- Context shorthand: `<Context value={}>` NOT `<Context.Provider>`
- `use()` hook instead of `useContext()`
- No manual memoization (`useMemo`, `useCallback`, `memo`) - React Compiler handles it
- ViewTransition + Suspense: All children in Suspense boundaries

#### 2. React Compiler (`plugins/local/next-react-optimizer/skills/react-compiler/SKILL.md`)
**Additional patterns:**
- `experimental.reactCompiler: true` in `next.config.ts`
- Watch for `CannotPreserveMemoization` errors
- Idiomatic React without manual optimization

#### 3. Browser Testing (`skills/browser-testing/SKILL.md`)
**MCP Tools for live testing:**
- `mcp__playwright__browser_navigate` - Navigate to URL
- `mcp__playwright__browser_snapshot` - Get accessibility tree (preferred)
- `mcp__playwright__browser_click` - Click elements
- `mcp__playwright__browser_fill_form` - Fill forms
- `mcp__playwright__browser_wait_for` - Wait for text/elements
- `mcp__playwright__browser_console_messages` - Check for JS errors
- `mcp__playwright__browser_take_screenshot` - Visual validation

**Also available:** `mcp__claude-in-chrome__*` tools for Chrome DevTools integration

---

## Research Findings

### Can Skills Be Invoked from Slash Commands?

**Short answer: NO** - There is no mechanism for programmatic skill invocation.

**What IS possible:**

| Approach | Works? | How |
|----------|--------|-----|
| Slash command → Skill | ❌ | Not supported |
| Slash command → Slash command | ✅ | Via `SlashCommand` tool |
| Mention skill in prompt | ⚠️ | Indirect - Claude may activate based on keywords |
| Embed skill content | ✅ | Copy relevant patterns into the command |

**Recommended approach for `/apex:examine`:**
1. **Embed React 19/Next.js patterns** directly in the command as validation rules
2. **Add grep-based pattern detection** to find anti-patterns in code
3. **Report findings** alongside build/lint/type errors

### MCP Tools for Live Browser Testing

**Using Chrome DevTools MCP** (`mcp__claude-in-chrome__*`):

| Tool | Purpose |
|------|---------|
| `tabs_context_mcp` | Get available tabs in MCP group |
| `tabs_create_mcp` | Create new tab for testing |
| `navigate` | Navigate to URL |
| `read_page` | Get accessibility tree of page |
| `find` | Find elements by natural language |
| `computer` | Click, type, screenshot, scroll |
| `form_input` | Fill form fields |
| `read_console_messages` | Check for JS errors |
| `read_network_requests` | Monitor API calls |
| `gif_creator` | Record test session as GIF |

**Advantages of claude-in-chrome:**
- Tests in user's actual Chrome browser
- Can record GIFs for documentation/demos
- Natural language element finding
- Direct integration with Chrome DevTools

---

## Key Files

| File | Purpose |
|------|---------|
| `commands/apex/4-examine.md:1-226` | Current examine command - needs enhancement |
| `commands/apex/3-execute.md:1-200` | Reference for command structure patterns |
| `skills/react19-patterns/SKILL.md:1-203` | React 19 patterns to validate |
| `skills/browser-testing/SKILL.md:1-109` | Playwright MCP workflow reference |
| `plugins/local/next-react-optimizer/skills/react-compiler/SKILL.md:1-300` | React Compiler patterns |

---

## Patterns to Follow

### APEX Command Structure
```markdown
---
description: [Phase description]
argument-hint: <task-folder-path> [flags]
allowed-tools: [List of allowed tools]
---

[Role statement]

## Argument Parsing
[Parse flags]

## Workflow
[Numbered steps with clear actions]

## Execution Rules
[Non-negotiable rules]

## Usage Examples
[bash examples]

## Priority
[Single priority statement]
```

### Pattern Detection via Grep
```bash
# Find old Context.Provider usage
grep -r "\.Provider" --include="*.tsx" --include="*.jsx"

# Find useContext usage (should be use())
grep -r "useContext(" --include="*.tsx" --include="*.jsx"

# Find manual memoization (useMemo, useCallback, memo)
grep -rE "(useMemo|useCallback|memo)\(" --include="*.tsx" --include="*.jsx"
```

---

## Dependencies

**No blockers.** All required MCP tools are already available:
- ✅ Playwright MCP connected
- ✅ Claude-in-Chrome MCP connected
- ✅ Grep/Glob tools for pattern detection
- ✅ Task tool for parallel agent execution

---

## Implementation Approach

### Task 1: Enhance `/apex:examine` with React 19/Next.js Validation

**Add new step between current steps 5 and 6:**

```markdown
5B. **PATTERN VALIDATION**: Check React 19 and Next.js best practices
    - Search for old Context.Provider pattern
    - Search for useContext() (should use use())
    - Search for manual memoization (useMemo, useCallback, memo)
    - Search for ViewTransition without proper Suspense boundaries
    - Report findings as warnings (don't block deployment)
```

**Output format:**
```
══════════════════════════════════════════════════
PATTERN VALIDATION
══════════════════════════════════════════════════

React 19 Patterns:
⚠️  Found 3 files using Context.Provider (should use shorthand)
⚠️  Found 5 files using useContext() (should use use() hook)
⚠️  Found 12 files with manual memoization (React Compiler handles this)

Recommendation: Run /react19-patterns to review and fix
══════════════════════════════════════════════════
```

### Task 2: Create New `/apex:test-live` Command

**Purpose:** Browser-based live testing of implemented features using claude-in-chrome

**Key Feature: GIF Recording with Maximum Screenshots**

Capture every step as a screenshot for smooth, detailed GIFs that document the entire test flow.

**Screenshot Strategy:**
- Screenshot BEFORE each action (initial state)
- Screenshot AFTER each action (result state)
- Screenshot on page load / navigation complete
- Screenshot on wait completion
- Screenshot on form fill
- Screenshot on validation success/failure

**Workflow:**
1. Read task context (analyze.md, implementation.md)
2. Identify testable user flows from task description
3. Check if dev server is running (or start it)
4. Get/create Chrome tab via `tabs_context_mcp` / `tabs_create_mcp`
5. **START GIF RECORDING** via `gif_creator(action="start_recording")`
6. **Screenshot initial state**
7. Navigate to feature URL via `navigate`
8. **Screenshot after navigation**
9. Execute test scenarios with screenshots between EACH action:
   - `read_page` to understand page structure
   - `find` to locate elements by description
   - **Screenshot** → `computer` click → **Screenshot**
   - **Screenshot** → `form_input` fill → **Screenshot**
   - **Screenshot** → wait for result → **Screenshot**
10. Validate results:
    - `read_console_messages` for JS errors
    - `read_network_requests` for API failures
    - **Final screenshot** for visual validation
11. **STOP & EXPORT GIF** via `gif_creator(action="stop_recording")` then `gif_creator(action="export", download=true)`
12. Report results with GIF path
13. If bugs found: Create follow-up tasks or fix immediately

**GIF Export Options:**
```
gif_creator(
  action="export",
  tabId=<id>,
  download=true,
  filename="test-<feature-name>.gif",
  options={
    showClickIndicators: true,  // 🟠 Orange circles on clicks
    showActionLabels: true,     // 🏷️ Labels describing actions
    showProgressBar: true,      // 📊 Progress bar at bottom
    quality: 5                  // High quality (1-30, lower=better)
  }
)
```

**GIF Storage Structure:**

```
.claude/tasks/<task-folder>/
├── analyze.md
├── plan.md
├── implementation.md      ← References to GIFs
├── tasks/
└── recordings/            ← GIF recordings folder
    ├── success/           ← Successful test runs
    │   ├── 001-login-flow.gif
    │   └── 002-form-submit.gif
    └── errors/            ← Failed tests / bugs found
        ├── 001-button-not-responding.gif
        └── 002-api-timeout.gif
```

**Naming Convention:**
- Success: `recordings/success/<NNN>-<feature-name>.gif`
- Error: `recordings/errors/<NNN>-<bug-description>.gif`

**Debug Workflow:**
1. Test runs → GIF recorded automatically
2. Success? → Save to `recordings/success/`
3. Bug found? → Save to `recordings/errors/` + document in implementation.md
4. Fix applied → Re-test → New GIF to `recordings/success/`
5. Before/after comparison available for review

**Integration with implementation.md:**
```markdown
## Test Live Results

### ❌ Bug Found - Test #001
**GIF**: `recordings/errors/001-button-not-responding.gif`
**Issue**: Submit button doesn't respond on first click
**Action**: Fixed in commit abc123

### ✅ Verified - Test #002
**GIF**: `recordings/success/002-login-flow-fixed.gif`
**Verification**: Full flow works after fix
```

**Naming alternatives:**
- `/apex:test-live` - Clear, descriptive ✅
- `/apex:browser` - Shorter
- `/apex:e2e` - Technical but less clear

**Recommendation:** Use `/apex:test-live` (not numbered, as it's optional/complementary)

---

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Pattern detection false positives | Use strict regex, provide file:line context |
| Dev server not running | Add check and start command |
| Browser tests flaky | Use wait_for, retry logic |
| Too many warnings | Categorize as blocking vs informational |

---

## Questions for User

1. **Naming:** Prefer `/apex:test-live` or another name for the browser testing command?
2. **Pattern validation:** Should React 19 pattern violations be warnings or errors (blocking)?
3. **Auto-fix:** Should examine automatically fix React 19 patterns, or just report them?

*(Browser choice: claude-in-chrome ✅ confirmed)*
