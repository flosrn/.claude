---
description: Browser test phase - live browser validation with optional GIF recording
argument-hint: <task-folder> [--url=<url>] [--gif] [--scenario="<description>"]
allowed-tools: Task
---

Delegate this task to the **browser-tester** agent.

## Flags

- `--url=<url>` - Explicit test URL (required if not detectable from task)
- `--gif` - Enable GIF recording (disabled by default for speed)
- `--scenario="<description>"` - Describe what to test

## Examples

```bash
# Test with auto-detected URL
/apex:5-browser-test 68-ai-template-creator

# Test specific URL
/apex:5-browser-test my-feature --url=http://localhost:3000/dashboard

# Record GIF of test
/apex:5-browser-test my-feature --gif

# Test specific scenario
/apex:5-browser-test my-feature --scenario="Submit login form and verify redirect"
```

Context to pass: $ARGUMENTS
