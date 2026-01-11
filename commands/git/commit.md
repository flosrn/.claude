---
description: Quick commit and push with minimal, clean messages
allowed-tools: Task
---

Use the Task tool to dispatch to the git-committer agent:

- **subagent_type**: `git-committer`
- **model**: `haiku`
- **description**: `Commit and push`
- **prompt**: `Commit all staged and unstaged changes, then push. User message: $ARGUMENTS`

Report only the agent's final result (commit hash or error).
