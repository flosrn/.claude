---
description: Browser test phase - live browser validation with GIF recording
argument-hint: <task-folder-path> [--url=<url>] [--no-gif] [--parallel]
allowed-tools: mcp__claude-in-chrome__*, Read, Write, Bash, Task
---

You are a QA specialist. Validate implemented features through live browser testing with visual documentation.

## Argument Parsing

Parse the argument for flags:
- `--url=<url>` → **EXPLICIT URL** (navigate directly to this URL)
- `--no-gif` → **NO GIF RECORDING** (skip recording, just test)
- `--parallel` → **PARALLEL MODE** (run test scenarios concurrently on separate tabs)
- No flags → **STANDARD MODE** (detect URL from task context, record GIF)

## Workflow

1. **SET TASKS DIRECTORY**: Standard path
   ```bash
   TASKS_DIR="./.claude/tasks"
   ```

2. **VALIDATE INPUT**: Check task folder exists
   - Verify `$TASKS_DIR/<task-folder>/` exists
   - Read `analyze.md` to understand what was implemented
   - Read `implementation.md` to see current status and changes
   - **If missing**: Ask user to specify task folder

2. **IDENTIFY TEST FLOWS**: Extract testable user flows

   **Option A: Manual identification**
   - Parse task description for user-facing actions
   - Look for:
     - Form submissions
     - Button clicks
     - Navigation flows
     - API interactions
     - Visual changes

   **Option B: Use Explore agent** (recommended for complex features)
   - Launch `explore-codebase` agent to analyze implementation:
     ```
     Task(subagent_type="explore-codebase", prompt="
       Analyze the implementation in $TASKS_DIR/<task-folder>/ and identify
       all testable user flows. For each flow, provide:
       1. Flow name (e.g., 'Login form submission')
       2. Starting URL or component
       3. Steps to execute (clicks, inputs, expected results)
       4. Success criteria
     ")
     ```
   - Agent returns structured test scenarios

   - **If no clear flows**: Ask user what to test

3. **DETERMINE TEST URL**: Find where to test
   - **If `--url` provided**: Use that URL directly
   - **If not provided**:
     - Look for URL hints in `analyze.md` or `implementation.md`
     - Detect port using step 3a below
     - **Ask user** if URL cannot be determined

3a. **DETECT DEV SERVER PORT**: Find the correct port
   ```bash
   # Try multiple sources in priority order (BSD grep compatible)
   # 1. Check root package.json for --port flag (supports --port 3000 and --port=3000)
   PORT=$(/usr/bin/grep -oE 'port[= ]+[0-9]+' package.json 2>/dev/null | /usr/bin/grep -oE '[0-9]+' | head -1)

   # 2. Monorepo: Check apps/web first (main app), then other apps
   [ -z "$PORT" ] && PORT=$(/usr/bin/grep -oE 'port[= ]+[0-9]+' apps/web/package.json 2>/dev/null | /usr/bin/grep -oE '[0-9]+' | head -1)

   # 3. Check vite.config.* for server.port setting
   [ -z "$PORT" ] && PORT=$(/usr/bin/grep -oE 'port:[[:space:]]*[0-9]+' vite.config.* 2>/dev/null | /usr/bin/grep -oE '[0-9]+' | head -1)

   # 4. Check next.config.* for port setting
   [ -z "$PORT" ] && PORT=$(/usr/bin/grep -oE 'port:[[:space:]]*[0-9]+' next.config.* 2>/dev/null | /usr/bin/grep -oE '[0-9]+' | head -1)

   # 5. Apply framework-specific defaults
   [ -z "$PORT" ] && [ -f "vite.config.ts" -o -f "vite.config.js" ] && PORT=5173
   [ -z "$PORT" ] && [ -f "next.config.js" -o -f "next.config.mjs" -o -d "apps/web" ] && PORT=3000

   # 6. Final fallback
   PORT="${PORT:-3000}"

   echo "Detected port: $PORT"
   ```

   - Use detected port in URL: `http://localhost:${PORT}`
   - **If detection fails**: Ask user for correct port

4. **CHECK DEV SERVER**: Verify server is running
   - Attempt to fetch the test URL
   - **If not responding**:
     - Look for `dev` script in `package.json`
     - Suggest: "Dev server not running. Start with `pnpm run dev` and retry."
     - **HALT** - Do not proceed until server is confirmed

5. **GET/CREATE BROWSER TAB**: Set up test environment
   - Call `mcp__claude-in-chrome__tabs_context_mcp` to see existing tabs
   - If suitable tab exists in MCP group: Use it
   - If no suitable tab: Call `mcp__claude-in-chrome__tabs_create_mcp`
   - Store the `tabId` for all subsequent operations

6. **START GIF RECORDING** (unless --no-gif)
   - Call `mcp__claude-in-chrome__gif_creator`:
     ```json
     {
       "action": "start_recording",
       "tabId": <tabId>
     }
     ```
   - **IMMEDIATELY** take initial screenshot:
     ```json
     {
       "action": "screenshot",
       "tabId": <tabId>
     }
     ```

7. **NAVIGATE TO FEATURE**: Go to test URL
   - Call `mcp__claude-in-chrome__navigate`:
     ```json
     {
       "url": "http://localhost:${PORT}/<path>",
       "tabId": <tabId>
     }
     ```
   - Wait for page load
   - **Screenshot after navigation**

8. **EXECUTE TEST SCENARIOS**: Run through test flows

   ### Parallel Mode (with `--parallel` flag)

   Run independent test scenarios concurrently using `apex-executor` agents:

   1. **Create one tab per scenario**:
      ```
      For each scenario: mcp__claude-in-chrome__tabs_create_mcp()
      ```

   2. **Launch agents in parallel** (single message with multiple Task calls):
      ```
      Task(subagent_type="apex-executor", description="Test scenario 1", prompt="
        Test: Login flow
        Tab ID: <tabId1>
        URL: http://localhost:${PORT}/login

        Steps:
        1. Navigate to URL
        2. Fill email field with test@example.com
        3. Fill password field
        4. Click submit
        5. Verify redirect to dashboard

        Take screenshots before/after each action.
        Report: pass/fail with details.
      ")

      Task(subagent_type="apex-executor", description="Test scenario 2", prompt="
        Test: Form submission
        Tab ID: <tabId2>
        URL: http://localhost:${PORT}/form
        ...
      ")
      ```

   3. **Wait for all agents**, aggregate results
   4. **Note**: GIF recording disabled in parallel mode (each agent screenshots instead)

   ---

   ### Sequential Mode (default)

   ### Screenshot Strategy (CRITICAL for smooth GIFs)

   For each action, follow this pattern:
   1. **Screenshot BEFORE** - Capture initial state
   2. **Perform action** - Click, type, etc.
   3. **Wait** - Let UI update (use `browser_wait_for` if needed)
   4. **Screenshot AFTER** - Capture result

   ### Available Tools

   | Tool | Purpose |
   |------|---------|
   | `read_page` | Get accessibility tree (understand structure) |
   | `find` | Locate elements by natural language |
   | `computer` | Click, type, screenshot, scroll, wait |
   | `form_input` | Fill form fields by ref |
   | `navigate` | Go to URL, back, forward |

   ### Test Flow Template

   ```
   For each test scenario:
   1. Screenshot current state
   2. read_page to understand structure
   3. find element (e.g., "submit button")
   4. Screenshot before action
   5. computer(action="left_click", ref=<element_ref>)
   6. Wait for result (computer action="wait" or wait_for text)
   7. Screenshot after action
   8. Validate expected result appears
   ```

9. **VALIDATE RESULTS**: Check for errors
   - Call `mcp__claude-in-chrome__read_console_messages`:
     ```json
     {
       "tabId": <tabId>,
       "onlyErrors": true
     }
     ```
   - Call `mcp__claude-in-chrome__read_network_requests`:
     ```json
     {
       "tabId": <tabId>
     }
     ```
   - Look for:
     - JavaScript errors in console
     - Failed API requests (4xx, 5xx status)
     - Network timeouts
   - **Final screenshot** for visual validation

10. **STOP & EXPORT GIF** (unless --no-gif)
    - Stop recording:
      ```json
      {
        "action": "stop_recording",
        "tabId": <tabId>
      }
      ```
    - Export GIF:
      ```json
      {
        "action": "export",
        "tabId": <tabId>,
        "download": true,
        "filename": "<feature-name>-test.gif",
        "options": {
          "showClickIndicators": true,
          "showActionLabels": true,
          "showProgressBar": true,
          "quality": 5
        }
      }
      ```

11. **ORGANIZE RECORDINGS**: Move GIF from Downloads to task folder

    **CRITICAL**: The `gif_creator` tool downloads to the browser's default Downloads folder.
    You MUST move the file to the task folder using bash commands.

    ### Step 11a: Create folder structure
    ```bash
    mkdir -p $TASKS_DIR/<task-folder>/recordings/success
    mkdir -p $TASKS_DIR/<task-folder>/recordings/errors
    ```

    ### Step 11b: Move GIF from Downloads
    ```bash
    # Find the most recent GIF in Downloads matching the filename
    GIF_NAME="<feature-name>-test.gif"

    # If test passed:
    mv ~/Downloads/$GIF_NAME $TASKS_DIR/<task-folder>/recordings/success/001-<feature>.gif

    # If errors found:
    mv ~/Downloads/$GIF_NAME $TASKS_DIR/<task-folder>/recordings/errors/001-<bug>.gif
    ```

    ### Step 11c: Verify move succeeded
    ```bash
    /bin/ls -la $TASKS_DIR/<task-folder>/recordings/
    ```

    **Naming convention:**
    - Success: `001-login-flow.gif`, `002-form-submit.gif`
    - Errors: `001-button-not-responding.gif`, `002-api-timeout.gif`

    **If move fails** (file not found in Downloads):
    - Check `~/Downloads/` for the exact filename
    - The GIF may have a timestamp suffix if filename already existed
    - Report the GIF location to user if it cannot be moved

12. **UPDATE IMPLEMENTATION.MD**: Document test results

    Find or create "## Test Live Results" section:

    ```markdown
    ## Test Live Results

    **Tested**: [YYYY-MM-DD]
    **Command**: `/apex:5-browser-test <task-folder>`
    **URL**: [test URL]

    ### Test Scenarios

    | Scenario | Status | GIF |
    |----------|--------|-----|
    | [Flow 1] | ✅ Pass | `recordings/success/001-flow.gif` |
    | [Flow 2] | ❌ Fail | `recordings/errors/001-bug.gif` |

    ### Console Errors
    - [List any JS errors found, or "None"]

    ### Network Issues
    - [List any failed requests, or "None"]

    ### Screenshots
    - [List key screenshots taken, or link to GIF]
    ```

13. **FINAL REPORT**: Summarize test results

    ```
    ══════════════════════════════════════════════════
    TEST LIVE RESULTS
    ══════════════════════════════════════════════════

    Feature: [Task name]
    URL: [Test URL]

    Tests:
    ✓ [Scenario 1] - Passed
    ✗ [Scenario 2] - Failed: [reason]

    Console Errors: [count or "None"]
    Network Failures: [count or "None"]

    GIF: recordings/[success|errors]/NNN-feature.gif

    ══════════════════════════════════════════════════
    ```

    - **If all pass**: Feature is validated, ready for deployment
    - **If failures found**: Document bugs in implementation.md with GIF references

## GIF Recording Best Practices

### Screenshot Frequency
- **MORE IS BETTER**: Capture 10-20+ screenshots for smooth playback
- Screenshot on every state change
- Don't skip intermediate states

### Timing
- Use `wait` action (1-2 seconds) between screenshots for readable GIFs
- Let animations complete before capturing

### Naming
- Use descriptive names: `login-success.gif` not `test1.gif`
- Include test number prefix: `001-`, `002-`

## Error Handling

### Common Issues

| Issue | Solution |
|-------|----------|
| Dev server not running | Ask user to start it |
| Tab not responding | Create new tab with `tabs_create_mcp` |
| Element not found | Use `read_page` to understand structure |
| GIF export fails | Continue without GIF, report screenshots instead |
| URL not determined | Ask user for explicit URL |

### Debug Workflow

When tests fail:
1. Capture GIF of failure
2. Save to `recordings/errors/`
3. Document bug in `implementation.md`
4. User fixes manually or creates follow-up task

## Execution Rules

- **ALWAYS READ CONTEXT**: Understand what was implemented before testing
- **SCREENSHOT LIBERALLY**: More frames = smoother GIFs
- **CHECK CONSOLE**: JS errors indicate bugs
- **CHECK NETWORK**: Failed requests indicate backend issues
- **DOCUMENT EVERYTHING**: Update implementation.md with results
- **NO ASSUMPTIONS**: If unsure what to test, ask user

## Usage Examples

```bash
# Test implemented feature (auto-detect URL)
/apex:5-browser-test 68-ai-template-creator

# Test with specific URL
/apex:5-browser-test my-feature --url=http://localhost:3000/dashboard

# Test without GIF recording (faster)
/apex:5-browser-test my-feature --no-gif

# Run test scenarios in parallel (fastest, for regression testing)
/apex:5-browser-test my-feature --parallel

# Combined: specific URL, no GIF
/apex:5-browser-test my-feature --url=http://localhost:5173 --no-gif
```

## Integration with APEX Workflow

```
/apex:1-analyze feature     # Understand requirements
/apex:2-plan feature        # Create implementation plan
/apex:3-execute feature     # Implement the feature
/apex:4-examine feature     # Validate build/lint/types
/apex:5-browser-test feature     # Live browser testing ← YOU ARE HERE
```

**Note**: This command is optional but recommended for user-facing features. It provides visual proof that the implementation works as expected.

## Priority

Visual validation through live testing. GIF recordings provide proof of functionality and help debug issues.

---

User: $ARGUMENTS
