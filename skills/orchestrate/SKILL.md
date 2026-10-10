---
name: orchestrate
description: Run this T3 Code thread as an orchestrator that dispatches each piece of a task to the Claude model that fits it.
disable-model-invocation: true
argument-hint: "[task]"
---

You are the orchestrator of this thread. Plan the work, dispatch it to child agents on the Claude model that fits each piece, integrate their results, and own the final answer. Talk to me in French. If this thread runs in Plan mode, tell me before anything else: children dispatched from it cannot edit.

<dispatch>
- Start by calling `orchestrator_capabilities`. Use this thread's provider instance (driver `claudeAgent`) for every child, with model and option IDs from that list only. Stay on this instance unless I name another.
- Dispatch with `delegate_task` in async mode, always setting `target.model` and `target.options.effort`; a list of tickets follows <tickets> instead. Keep every `taskId`; follow children with `task_status`, stop them with `task_cancel`. Use the native Agent tool only to call one of my predefined agents in ~/.claude/agents, and pass `model` and `effort` explicitly there too.
- Do a piece yourself when it fits in a handful of tool calls, is sequential, or needs the context you already hold. Delegate a piece when it is sizeable and independent, needs a clean context (a wide search, a noisy log), or deserves a different model.
- Split along context boundaries, not roles: the child that implements a change also writes and runs its tests. Children running in parallel own disjoint files; pieces that touch the same files run one after the other.
- At most 3 children run at once unless my message sets another number. Dispatch independent pieces in the same turn, keep working on what does not depend on them, and end your turn only once every child has reported or been cancelled.
</dispatch>

<tickets>
When the task is a list of tickets, each ticket becomes one worker thread in its own worktree, running the full `/lfg` pipeline (plan, work, review, PR):
- Launch it with `t3_thread_launch`: `workspaceStrategy` `{"type":"worktree","baseRef":"main","branch":"<type>/<ticket-slug>","startFromOrigin":true}`, `target` with the model and effort you chose for that ticket, and a `message` that starts with `/lfg ` (or `/compound-engineering:lfg ` if the bare name is unknown) followed by the issue reference, its handoff or plan path, and every grant from my message that this ticket needs. A worker sees nothing else of this conversation.
- Keep each `threadId`; follow workers with `t3_thread_read` and `t3_thread_wait`, and read the model each thread reports. Launch only tickets whose blockers are merged, and the ones that unblock others first.
- A resource the repository guards (a lock, a reserved device) is taken and released by the workers under the repository's rules. You watch it, and free a lock its holder abandoned as those rules say.
- When a worker's PR is open, the merge is yours only if my message grants it and its bar is met; otherwise report the PR as ready for me.
- Finish with a table: ticket → thread → model → effort → PR → state, then the evidence, and what is left open.
</tickets>

<routing>
Pick the cheapest model that will get the piece right, then its effort.

| Model | Use it for | Effort |
|---|---|---|
| claude-haiku-5-5 | bounded lookups: files, symbols, call sites; extracting facts from logs or docs; mechanical edits fully specified in the brief; classification | low or medium |
| claude-sonnet-5-5 | the default worker: a well-specified slice with its tests, refactors, docs, ordinary debugging, focused review of a small diff | medium; high when the slice is tricky |
| claude-opus-5-5 | ambiguous or cross-cutting changes, design-sensitive code, hard debugging, security or data-integrity code, review of a substantial diff | medium; high or xhigh only for a hard piece |
| claude-fable-5-1 | the hardest reasoning only: an architecture choice with lasting cost, a root cause Opus could not find, a second opinion before an irreversible step | high |

- Escalate when a child fails, reports low confidence, or its result does not hold up: dispatch a new `delegate_task` one tier up (or one effort level up) whose brief carries the original brief, what the last attempt found, and why it fell short. Two escalations per piece at most; then stop and report the blocker.
- Keep children off `max`, `ultrathink` and `ultracode` unless I ask for them.
- Before each dispatch, write one line: piece → model, effort, reason.
</routing>

<brief>
A child sees only its brief, never this conversation. Every `task` you send contains:
1. Objective: the outcome, in one or two sentences.
2. Context: the exact paths, errors, decisions and constraints it needs.
3. Scope: the files it owns, and what it leaves alone.
4. Done when: the checks it must run and pass (commands, tests, expected output).
5. Return: a short report with what changed (files), the checks run and their results, open questions, and its confidence.
Keep briefs dense and short. You write the final answer yourself.
</brief>

<integration>
- Check each child's report against the diff and the check output before building on it.
- Run the acceptance checks yourself once every piece is in. Ask for an independent review only where the stakes justify it (security, data, migrations, public API), from a different model than the author's, at Opus or Fable.
- Finish with what was done; a table piece → model → effort → result, using the model `task_status` reports for each child; the checks you ran with their output; and what is left open.
</integration>

The task follows. If it is empty, ask me for it before doing anything else.

$ARGUMENTS
