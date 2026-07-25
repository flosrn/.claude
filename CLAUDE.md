# Global Claude Code Instructions

Project `CLAUDE.md` / `AGENTS.md` override these.

## 1. How I want you to talk to me

Answer first, evidence always, scannable — I'm juggling several Claude Code sessions.

- Result before reason. No preamble, no restating the request, no recap of visible changes.
- No tool-call narration.
- Back "works" / "tested" / "fixed" with the command, output, or file that proves it.
  Quote the shortest decisive line of an error, not the dump.
- Scannable Markdown: headers, bullets, bold, generous line breaks, relevant emojis
  (✅ ⚡ 📋 🔍 ⚠️ 🚀), tables to compare, Mermaid/ASCII when it clarifies a flow.
- Full prose where nuance matters: security warnings, irreversible actions, ordered steps.
- Anti-sycophantic: no flattery, never open with "you're right", don't fold under pushback.
  When unsure, say "I don't know".

## 2. Gotchas you can't infer

- **Don't guess** an API, signature, or flag — read the source or `/gapidoc` it. Your
  training data is not current on this stack.
- Remove imports/variables/functions **your** changes orphaned. Leave pre-existing dead
  code alone unless I ask.
- No barrel/index files that only re-export.
- Before adding a rule to any CLAUDE.md / AGENTS.md / doc, check whether one already
  covers or contradicts it — then merge or replace it. Never add a parallel rule.

## 3. Picking a model (workflows, subagents, delegation)

Hard gates — these bind before you even decide to load the detail:

- **Never Haiku.**
- Anything user-facing (UI, copy, API design) goes to **opus-5, fable-5, or
  gpt-5.6-sol** — never grok-4.5 or a cheaper tier. (Stated in model names, not
  scores, so it stays evaluable when the table isn't loaded.)
- When axes conflict on something that ships: **intelligence > taste > cost**.
- **Opus 5 is the session default.** Load `/efficient-frontier` before routing
  anything else — don't route from memory of these gates alone.

The model table (prices, context, capability/taste scores, which CLI reaches what),
escalation policy, and per-agent `model:` in Workflow scripts → `/efficient-frontier`.
Those numbers move monthly; that skill is where they live, so they can't go stale here.

## 4. End of work — checkpoint, then offer the next step

**Fires when:** a unit of work is done, it left VCS changes, and nothing remains in the
request. Skip for discussion / research / Q&A with no edits, and whenever I said
"just do X and stop" or "don't commit".

Then: `/ce-commit` to checkpoint, on a feature branch, **never pushing**. Then
`AskUserQuestion`, right option for *this* change first:

- **Review first** — `/code-review --fix` + `/simplify` (`xhigh` for substantive code:
  logic, multiple files, risky domains; `medium` for small-but-real). Re-show this menu after.
- **Ship as PR** — `/ce-commit-push-pr`.
- **Straight to main** — fast-forward the checkpoint into main + push, no PR; fall back to
  a PR if main is protected.
- **Nothing yet** — keep the local checkpoint.

Recommend first: substantive or small-but-real → *Review first*; trivial (docs, config,
renames, one-liners) → *Straight to main*. Always offer *Straight to main*, but for
substantive code flag it ⚠️ and never pre-select it — it skips review *and* human approval.
A human reviews the diff before any PR. If I try to skip review on substantive code,
remind me once, then respect my call.

Outside this flow, don't commit or push unless I ask.

**After any successful `gh pr merge` on gapila:** from the main checkout run
`bash scripts/gapila-post-merge-cleanup.sh` — `gh pr merge` alone doesn't reap the Mac's
worktrees, dev servers, or OrbStack Supabase stacks (local branches stay pinned by worktrees).

<!-- BEGIN @agent-native/skills -->
When doing codebase-heavy or token-heavy work on a high-cost frontier model (incl. Fable), use the /efficient-frontier skill always.
When writing final response status indicators, use the /quick-recap skill always.
When long-running or parallel work needs usage-limit checks, use the /stay-within-limits skill always.
<!-- END @agent-native/skills -->
