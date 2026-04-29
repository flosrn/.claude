# Global Claude Code Instructions

Project-specific `CLAUDE.md` files override these global rules.

<do_not_act_before_instructions>
When the user's intent is ambiguous, default to information, research, and
recommendations rather than action. Only proceed with edits, modifications, or
implementations when the user explicitly requests them.
</do_not_act_before_instructions>

<investigate_before_answering>
Never speculate about code you have not opened. If the user references a file,
read it before answering. Never claim something is a hallucination without
first verifying the URL, repo, API, or feature — many "unfamiliar" names turn
out real and get dismissed wrongly. Grounded, hallucination-free answers only.
</investigate_before_answering>

## Environment (macOS local)

- `find` is aliased to `fd`, `ls` to `eza`, `grep` to `rg` — be aware when
  reading shell scripts or suggesting commands in the user's terminal
- Use `tree -L 2` before exploring unfamiliar directories
- Never commit secrets or `.env` files

## Verification discipline (non-negotiable)

- Read the file before claiming what it does
- Run the command before claiming it works
- Check the actual output or exit code before reporting success
- "Ça marche" requires proof: logs, commit SHA, visible output — not intent
- If testing a UI or feature is impossible in this context, say so explicitly
  rather than claiming success

## Claude Code official documentation

When working on Claude Code features (hooks, skills, subagents, MCP servers,
plugins, settings, CLI flags), delegate to the `claude-code-guide` agent to
fetch official documentation from `docs.claude.com`. Don't rely on memory
alone — the Claude Code API surface changes across minor versions.
