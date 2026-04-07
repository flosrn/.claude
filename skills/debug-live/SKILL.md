---
name: debug-live
description: "Debug Live Session \u2014 full-stack live debugging on the running Next.js dev server. Orchestrates dev server startup, server+client log analysis, browser automation (screenshots, console, network, DOM), error diagnosis, fix application, and visual verification in a loop. ALWAYS use when: user says 'debug', 'debug live', 'debug this page', 'check the page', 'regarde la page', 'teste \u00e7a', 'pourquoi \u00e7a marche pas', 'why isn't this working', 'verify this works', 'v\u00e9rifie que \u00e7a marche', 'debug on mobile', 'check mobile', 'what does the page look like', 'can you see the page', mentions a localhost URL, wants to investigate a running page, or when you need to verify your own changes visually after implementing a fix. Also trigger after applying code fixes to visually confirm the result."
---

# Debug Live Session

You are a full-stack debugger with eyes on the server AND the browser. Unlike reading code and guessing, you can **see** what renders, **hear** what the server logs, **watch** network traffic, and **read** the console — all in real-time. Use every tool at your disposal.

**The cardinal rule of debug-live: the dev server MUST be running.** If it's not running, start it. If it can't start, that's the first bug to fix. Never fall back to "just reading the code" — that's what the `debugging` skill is for. debug-live means live observation with real runtime data, real browser rendering, real network requests. If you catch yourself skipping the server, browser, or logs — you're doing it wrong.

## Arguments

The user may provide (in any combination):
- **A URL path**: `/dashboard`, `/settings/billing` — navigate directly
- **An error description**: "TypeError in the pricing page" — investigate that error
- **"mobile"** or **"responsive"**: use `playwright-mobile` alongside desktop
- **Nothing**: general health check — scan for any errors on the current page or home

---

## Phase 0: Dev Server — MANDATORY

The whole point of this skill is to debug LIVE. Reading code without a running server is just guessing — you're the `debugging` skill at that point, not `debug-live`. The server MUST be running before you proceed.

Check if the dev server is alive on port 3001:

```bash
lsof -ti :3001
```

**Running** → proceed to Phase 1.

**Not running** → start it NOW. Do not skip this. Do not say "that's fine". Start the server:

```bash
cd /Users/flo/Code/nextjs/gapila && pnpm dev > /tmp/nextjs-dev.log 2>&1 &
```

Then poll until ready (max 30s):

```bash
for i in {1..15}; do curl -s -o /dev/null -w "%{http_code}" http://localhost:3001 && break; sleep 2; done
```

If it still won't start, read `/tmp/nextjs-dev.log` for the error. Common causes: port already taken by a zombie process (`kill $(lsof -ti :3001)`), missing env vars, broken build. If the server can't start, tell the user why — don't silently fall back to static code reading.

**Gate**: Do NOT proceed to Phase 1 until the dev server responds on port 3001. No server = no debug-live session.

---

## Phase 1: Collect Evidence

The server is running. Now use it. Run as many of these in parallel as possible — speed matters.

### 1a. Discover server MCP tools

```
mcp__next-devtools__nextjs_index(port: "3001")
```

This reveals every MCP tool the running server exposes. Memorize the list — you'll need it.

### 1b. Get server errors

```
mcp__next-devtools__nextjs_call(port: "3001", toolName: "get_errors")
```

Build errors, TypeScript errors, runtime errors — this is your first and strongest signal. If this returns errors, you likely already have a lead.

### 1c. Read server logs

Two complementary approaches — use both:

1. **Structured via MCP**:
   ```
   mcp__next-devtools__nextjs_call(port: "3001", toolName: "get_logs")
   ```

2. **Raw log file** (more complete, includes historical context):
   ```
   Read tool → apps/web/.next/logs/next-development.log (last 150 lines)
   ```
   Scan for: `[Error]`, `[Warning]`, stack traces, unhandled rejections, slow queries.

### 1d. Browser: see what the user sees

Navigate to the target page (default: `/`) and capture everything at once.

**Desktop:**
```
mcp__playwright-desktop__browser_navigate(url: "http://localhost:3001{path}")
```

Then immediately in parallel:
```
mcp__playwright-desktop__browser_snapshot()               → DOM structure for interaction
mcp__playwright-desktop__browser_console_messages(level: "error")  → client errors
mcp__playwright-desktop__browser_network_requests()       → failed fetches, slow requests
mcp__playwright-desktop__browser_take_screenshot(type: "png")      → visual state
```

**Mobile** (if requested or relevant):
Same sequence with `mcp__playwright-mobile__*` prefix.

### 1e. Deep inspection (if page seems stuck or blank)

```
mcp__playwright-desktop__browser_evaluate(script: "document.readyState")
mcp__playwright-desktop__browser_evaluate(script: "JSON.stringify({title: document.title, bodyChildren: document.body?.children?.length, errors: window.__NEXT_DATA__?.err})")
```

For slow page loads:
```
mcp__playwright-desktop__browser_evaluate(script: "performance.getEntriesByType('resource').filter(r => r.duration > 1000).map(r => ({name: r.name.split('/').pop(), ms: Math.round(r.duration)}))")
```

---

## Phase 2: Analyze & Correlate

You now have 5 data sources. The power is in cross-referencing them — a single source rarely tells the full story.

| Source | What to look for |
|--------|-----------------|
| **Server errors** (get_errors) | Build failures, type errors, runtime exceptions |
| **Server logs** (log file) | Unhandled rejections, API errors, RSC render crashes, slow DB queries |
| **Browser console** | Client errors, hydration mismatches, failed imports, React errors |
| **Network requests** | 4xx/5xx responses, failed fetches, CORS, timeouts |
| **Visual state** (screenshot + snapshot) | Blank page, missing UI, broken layout, error boundary fallback |

### Diagnosis patterns

| Server | Browser | Network | Likely cause |
|--------|---------|---------|-------------|
| Error in logs | Blank page | — | Server component crash → read the stack trace |
| Clean | Console error | — | Client-only bug → missing "use client", bad hook usage, hydration |
| Clean | Clean | 401/403 | Auth/RLS issue → check session, cookies, RLS policies |
| Clean | Clean | 500 | API route crash → find the route handler, read server logs |
| Clean | Clean | Slow (>2s) | DB query or missing index → check Supabase query plans |
| Clean | Clean | Clean | Logic bug, wrong data → need to read component code |
| Build error | — | — | Fix the build error first — nothing else matters until it compiles |

---

## Phase 3: Fix

Once you have a hypothesis from Phase 2:

1. **Locate** the relevant source code (Grep, Read, Glob)
2. **Understand** the code around the bug — don't fix what you don't understand
3. **Apply the minimal fix** — one change, one hypothesis at a time
4. **No "while I'm here" improvements** — stay focused on the bug

### When root cause isn't clear

Instrument the code with temporary logging:

```typescript
console.log('[DEBUG] variableName:', variableName);
```

Then:
1. Save the file (HMR will reload)
2. Re-navigate in Playwright
3. Re-read console messages
4. The logs will reveal the state at that point
5. **Remove all `[DEBUG]` logs after diagnosis**

### When dealing with server-side issues

Server component or API route bugs won't show in the browser console. For these:
1. Add `console.log` in the server code
2. Re-read `apps/web/.next/logs/next-development.log` after reload
3. Or use `mcp__next-devtools__nextjs_call(port: "3001", toolName: "get_errors")` to check for new runtime errors

---

## Phase 4: Verify the Fix

Non-negotiable. Every fix must be verified with fresh evidence — never claim "fixed" from memory.

### 4a. Server-side clean

```
mcp__next-devtools__nextjs_call(port: "3001", toolName: "get_errors")
```
Expected: no errors, or fewer than before.

### 4b. Browser verification

```
mcp__playwright-desktop__browser_navigate(url: "http://localhost:3001{path}")
mcp__playwright-desktop__browser_console_messages(level: "error")
mcp__playwright-desktop__browser_network_requests()
mcp__playwright-desktop__browser_take_screenshot(type: "png")
```

Compare mentally with Phase 1:
- Console errors gone?
- Network requests succeeding?
- Visual rendering correct?

### 4c. Mobile verification (if applicable)

```
mcp__playwright-mobile__browser_navigate(url: "http://localhost:3001{path}")
mcp__playwright-mobile__browser_console_messages(level: "error")
mcp__playwright-mobile__browser_take_screenshot(type: "png")
```

### 4d. Type safety

```bash
pnpm typecheck
```

No new type errors introduced by the fix.

---

## Phase 5: Loop or Report

**Fix worked:**
Report concisely:
- What was wrong (root cause)
- What you fixed (the change)
- Evidence it's fixed (clean console, working screenshot, passing typecheck)

**Fix didn't work:**
Go back to Phase 1 with fresh evidence. You now have more data — use it to refine your hypothesis. Maximum 3 loops before asking the user for direction.

**After 3 failed attempts:**
Something deeper is at play. Present:
- All evidence collected across loops
- Hypotheses tried and why they failed
- What you think the actual problem might be
- Ask the user for guidance or additional context

---

## Tool Quick Reference

| Need | Tool |
|------|------|
| Server running? | `Bash: lsof -ti :3001` |
| Start server | `Bash: pnpm dev` (background) |
| Server errors | `nextjs_call` → `get_errors` |
| Server logs | `Read` → `apps/web/.next/logs/next-development.log` |
| Server log path | `nextjs_call` → `get_logs` |
| Available MCP tools | `nextjs_index(port: "3001")` |
| Open page (desktop) | `playwright-desktop: browser_navigate` |
| Open page (mobile) | `playwright-mobile: browser_navigate` |
| DOM snapshot | `playwright-*: browser_snapshot` |
| Screenshot | `playwright-*: browser_take_screenshot` |
| Console errors | `playwright-*: browser_console_messages` |
| Network | `playwright-*: browser_network_requests` |
| Run JS in page | `playwright-*: browser_evaluate` |
| Type check | `Bash: pnpm typecheck` |

---

## Integration with Other Skills

This skill focuses on **live observation and tool orchestration**. For deeper methodology:
- **Root cause analysis**: defer to `debugging` / `superpowers:systematic-debugging`
- **Verification discipline**: defer to `verification-before-completion`
- **Post-fix validation layers**: defer to `defense-in-depth`

These skills complement each other. debug-live gives you the eyes and ears; the debugging skills give you the brain.
