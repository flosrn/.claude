---
name: browser-testing
description: Browser automation, E2E testing, and visual validation using Playwright MCP. ALWAYS use when user asks about testing UI, E2E tests, browser automation, taking screenshots, validating pages, testing flows, filling forms, clicking buttons, or navigating websites. Triggers on "test", "E2E", "end-to-end", "browser", "automation", "screenshot", "validate", "click", "fill form", "navigate to", "check page".
---

# Browser Testing & Automation (Playwright MCP)

This skill ensures Claude uses **Playwright MCP** for browser automation and testing instead of manual approaches.

## CRITICAL RULE

**When user asks about testing UI or browser automation, ALWAYS use Playwright MCP tools.**

## Available MCP Tools

| Tool | Purpose |
|------|---------|
| `mcp__playwright__browser_navigate` | Navigate to URL |
| `mcp__playwright__browser_click` | Click element |
| `mcp__playwright__browser_type` | Type text into input |
| `mcp__playwright__browser_snapshot` | Get accessibility tree (better than screenshot) |
| `mcp__playwright__browser_take_screenshot` | Take visual screenshot |
| `mcp__playwright__browser_fill_form` | Fill multiple form fields |
| `mcp__playwright__browser_wait_for` | Wait for text/element |
| `mcp__playwright__browser_evaluate` | Execute JavaScript |
| `mcp__playwright__browser_console_messages` | Read console logs |
| `mcp__playwright__browser_network_requests` | Monitor network |

## When to Use (Automatic Triggers)

Use Playwright MCP when user asks:
- "Test the login flow"
- "Check if the page loads correctly"
- "Fill out this form"
- "Click the submit button"
- "Take a screenshot of the page"
- "Navigate to localhost:3000"
- "Validate the UI"
- "Run E2E test"
- "Check for visual regressions"

## Workflow

### 1. Navigate to Page
```
mcp__playwright__browser_navigate(url="http://localhost:3000")
```

### 2. Get Page State
```
# Prefer snapshot over screenshot for understanding page structure
mcp__playwright__browser_snapshot()
```

### 3. Interact with Elements
```
# Click using ref from snapshot
mcp__playwright__browser_click(element="Submit button", ref="ref_5")

# Type into input
mcp__playwright__browser_type(element="Email input", ref="ref_3", text="test@example.com")
```

### 4. Validate Results
```
# Wait for expected text
mcp__playwright__browser_wait_for(text="Success!")

# Check console for errors
mcp__playwright__browser_console_messages(level="error")
```

## Best Practices

1. **Use `browser_snapshot`** over screenshots for understanding page structure
2. **Get refs from snapshot** before clicking/typing
3. **Wait for elements** before interacting
4. **Check console** for JavaScript errors
5. **Monitor network** for API issues

## Testing Flow Example

```
# 1. Navigate
mcp__playwright__browser_navigate(url="http://localhost:3000/login")

# 2. Snapshot to get element refs
mcp__playwright__browser_snapshot()

# 3. Fill form (using refs from snapshot)
mcp__playwright__browser_fill_form(fields=[
  {"name": "Email", "type": "textbox", "ref": "ref_3", "value": "test@example.com"},
  {"name": "Password", "type": "textbox", "ref": "ref_5", "value": "password123"}
])

# 4. Click submit
mcp__playwright__browser_click(element="Login button", ref="ref_7")

# 5. Validate
mcp__playwright__browser_wait_for(text="Welcome")
mcp__playwright__browser_snapshot()  # Verify final state
```

## Current Configuration

The Playwright MCP is configured with:
- Browser: webkit
- Device: iPhone 15 (mobile viewport)
