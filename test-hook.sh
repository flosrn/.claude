#!/bin/bash

# Test script for Claude Code TypeScript hooks
export CLAUDE_HOOKS_DEBUG=true
export CLAUDE_FILE_PATHS="/Users/flo/Code/nextjs/gapila/apps/web/app/robots.ts"

echo '{"tool_input":{"file_path":"/Users/flo/Code/nextjs/gapila/apps/web/app/robots.ts"}}' | bun $HOME/.claude/hooks/ts/run-ts-quality.js