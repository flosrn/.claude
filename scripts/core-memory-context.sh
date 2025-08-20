#!/bin/bash
# Auto-trigger context search before responding (conditional)
# Usage: Used by UserPromptSubmit hook
# Control: Set CLAUDE_MEMORY_SEARCH_AUTO=false to disable

# Check if auto memory search is enabled (default: true for backward compatibility)
if [[ "${CLAUDE_MEMORY_SEARCH_AUTO:-true}" == "true" ]]; then
    echo "💭 CONTEXT SEARCH: Before responding, use memory-search to search for: previous discussions about this topic, related project context, and similar problems solved before."
else
    # Silent mode - no automatic memory search
    # User can still trigger manually with /memory-search command
    exit 0
fi