#!/bin/bash
# Auto-trigger memory search at session start (conditional)
# Usage: Used by SessionStart hook
# Control: Set CLAUDE_MEMORY_SEARCH_AUTO=false to disable

# Check if auto memory search is enabled (default: true for backward compatibility)
if [[ "${CLAUDE_MEMORY_SEARCH_AUTO:-true}" == "true" ]]; then
    echo "🧠 SESSION STARTED: Search memory for context about: $(basename $(pwd)) project, previous conversations, and related work. Do this before responding to user queries."
else
    # Silent mode - no automatic memory search at session start
    # User can still trigger manually with /memory-search command
    exit 0
fi