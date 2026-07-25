---
name: efficient-frontier
description: >
  Orchestrate any high-cost frontier model (Fable, Opus) on codebase-heavy or token-heavy
  work - delegate research, coding, and testing to cheaper subagents, write self-contained
  handoffs, pick and escalate delegate models, and vet delegated output before relying on
  it. Hard routing gates, binding whether or not this skill is loaded: never Haiku;
  anything user-facing (UI, copy, API design) goes to opus-5, fable-5, or gpt-5.6-sol,
  never grok-4.5 or a cheaper tier; when axes conflict on something that ships,
  intelligence > taste > cost; opus-5 is the session default. Load this skill for the
  model table and escalation policy before routing anything else.
---

# Efficient Frontier

Use the expensive frontier model where its marginal judgment matters. Push
repeatable, bounded, or token-heavy work to cheaper/faster subagents.

## Reserve for the Frontier Model

- Decomposing ambiguous work into clean parallel slices.
- Architecture, product, and safety tradeoffs.
- Reading conflicting subagent reports and deciding what matters.
- Integrating partial implementations into one coherent plan.
- Final review, risk assessment, and user-facing synthesis.

## Workflow

1. Identify the frontier-only decisions: architecture, prioritization,
   ambiguity resolution, risk, synthesis, and final review.
2. Identify delegable work: research scans, repository inventory, search, docs
   extraction, browser/testing passes, log reduction, test failure clustering,
   narrow coding, and mechanical edits.
3. Spawn parallel subagents for independent slices with clear ownership,
   bounded scope, verification gates, and expected evidence.
4. Require compact returns: findings, changed files, commands run, residual
   risk, stop conditions hit, and anything the frontier model must decide.
5. Integrate and review centrally before presenting the result.

## Choosing the Delegate Model

**This section is the single source of truth for the model table.** The hard gates
(never Haiku, opus-5/fable-5/gpt-5.6-sol for anything user-facing,
intelligence > taste > cost, opus-5 as default) live in this skill's `description:`
frontmatter, which is always in context — so they bind even when this file never loads.
Keep the numbers below here; never copy them into a CLAUDE.md.

Higher = better on every axis, including **cheapness** (`cheapness 9` = cheapest).
Intelligence = how hard a problem you can hand it unsupervised.
Taste = UI/UX, code quality, API design, copy. **Verified 2026-07-25.**

| model       | $/MTok in·out | ctx  | cheapness | intelligence | taste | reach it via |
|-------------|---------------|------|-----------|--------------|-------|--------------|
| grok-4.5    | 2 · 6         | 500K | 9         | 7            | 6     | `grok` CLI (`-m grok-4.5`) → `/delegate-code`, `/grok-maker` |
| sonnet-5    | 3 · 15        | 1M   | 7         | 7            | 7     | `model: sonnet` |
| opus-5      | 5 · 25        | 1M   | 5         | 9            | 9     | `model: opus` — the session default |
| gpt-5.6-sol | 5 · 30        | 1M   | 4         | 8            | 8     | `codex` CLI → `/codex-review`, `sol-advisor` |
| fable-5     | 10 · 50       | 1M   | 2         | 10           | 9     | `model: fable` → `fable-advisor` |

Nuances the numbers don't carry:

- **Opus 5 over Fable 5 by default.** Fable costs 2× for a sliver more capability,
  earning it only on world-knowledge long-tail work (obscure library internals,
  version history, deep domain minutiae). Opus 5 is faster and more agentic.
- **grok-4.5 ≈ sonnet-5 on capability.** Grok wins the standard agentic-coding
  benchmarks (SWE-Bench Pro 64.7 vs 63.2, Terminal-Bench 83.3 vs 80.4) and costs
  less; Sonnet buys 2× the context and steadier structured reasoning. Pick on
  context size, not on a capability gap. Grok falls off hard on novel one-shot
  problems — route those up, not to Grok.
- **Grok's toolchain fit beats its score.** It wasn't trained on Codex's
  `apply_patch` and degrades badly inside a Codex harness. Keep it on the `grok`
  CLI path.
- Prices and scores decay fast (Grok 4.6/4.7 are weeks out). Re-verify against
  the `claude-api` skill for Claude pricing and vendor docs for the rest before
  trusting a routing call that hinges on a close margin.

How to apply when delegating:

- **Defaults, not limits.** Standing permission to override: if a cheaper
  model's output doesn't meet the bar, rerun or redo the work with a smarter
  model without asking. Judge the output, not the price tag. Escalating costs
  less than shipping mediocre work.
- **Bulk/mechanical work** (clear-spec implementation, migrations, wide
  mechanical sweeps): grok-4.5 — cheapest per token and tops the standard
  agentic-coding benchmarks. Don't send it hard novel one-shot problems.
- **Reviews of plans/implementations:** fable-5 or opus-5, optionally
  gpt-5.6-sol as an independent non-Anthropic perspective.
- **Mechanics — the three CLI lanes are separate:**
  - gpt-5.6-sol → Codex CLI (`~/.codex/config.toml` pins `model = "gpt-5.6-sol"`).
    `codex exec` / `codex review`; for work without a dedicated skill, run
    `codex exec -s read-only` with a self-contained prompt.
  - grok-4.5 → `grok` CLI (`grok --prompt-file <f> -m grok-4.5`, headless),
    driven by `/delegate-code` and `/grok-maker`. Never route Grok through the
    Codex harness: it wasn't trained on `apply_patch` and falls back to shell
    redirection, halving throughput and quality.
  - Claude models (sonnet-5, opus-5, fable-5) → the Agent/Workflow `model`
    parameter directly.
- **Non-Claude models inside workflows/subagents** (the `model` parameter only
  takes Claude models): spawn a thin Claude wrapper agent with
  `model: 'sonnet', effort: 'low'` whose prompt instructs it to write a
  self-contained prompt, shell out to `codex exec` or `grok` via Bash, and
  return the output verbatim.
- In `Workflow` scripts, set per-agent `model:` so cheap stages run cheap and
  only the hard verify/judge stages reach opus/fable - never fan a whole
  pipeline out on the top tier by default.

## Handoff Packets

Write delegated prompts as self-contained packets. Assume the receiving agent
has not seen the conversation. Include:

- The repo path and exact objective.
- The files, packages, or surfaces in scope and anything explicitly out of
  scope.
- The evidence format to return: files, line refs, commands, diffs, failures,
  screenshots, and uncertainty.
- The verification commands or browser flows to run, plus what success should
  look like when that is knowable.

Useful stop conditions:

- The live code does not match the assumption in the handoff.
- A verification command fails twice after a reasonable fix or retry.
- The work appears to require files outside the assigned scope.
- The agent cannot produce concrete evidence for its claim.

## Review Loop

Treat delegated output as leads to inspect, not facts to forward. Before using
a high-impact finding, opening a PR, or telling the user the work is done:
reopen the important cited files, confirm the relevant line refs or failures,
skim high-risk diffs, and rerun or spot-check the verification that matters.
If delegated agents disagree, resolve the disagreement at the frontier-model
layer. If the delegated output doesn't pass the bar, escalate the model and
redo rather than patching mediocre work.

## Common Scenarios

Use these as soft suggestions:

- Research: delegate broad repo scans, docs extraction, and source comparison;
  the frontier model keeps the judgment about what matters.
- Coding: delegate bounded patches, refactors, or mechanical edits when file
  ownership is clear; integrate and review centrally.
- Testing: let the frontier model choose the validation strategy and scripts,
  then use cheaper agents to run unit checks, browser flows, screenshots, and
  log reduction. Ask them to return exact commands, failures, likely causes, and
  whether the signal looks flaky, environmental, or product-relevant.
- Debugging: send independent agents after separate theories, logs, or repro
  paths; keep the final diagnosis with the frontier model.

## Guardrails

- Do not delegate the immediate blocker if your next step depends on it.
- Do not ask multiple agents to edit the same files at the same time.
- Do not trust subagent conclusions blindly when the risk is high; inspect the
  important evidence yourself.
- Do not claim universal savings. The pattern works best when exploration and
  implementation, testing, or research can be parallelized.

## Default Framing

"I will use the frontier model as the orchestrator and reviewer, and use
cheaper subagents for token-heavy research, coding, or testing so the expensive
tokens go to judgment, synthesis, and final quality."
