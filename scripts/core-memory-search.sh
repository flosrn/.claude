#!/bin/bash
# Auto-trigger memory search at session start
# Usage: Used by SessionStart hook

echo "🧠 SESSION STARTED: Search memory for context about: $(basename $(pwd)) project, previous conversations, and related work. Do this before responding to user queries."