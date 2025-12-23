#!/bin/bash
# Auto-sign .node files in /tmp to bypass Gatekeeper
# Run this before launching Claude Code

for f in /tmp/.7fd3ff*.node 2>/dev/null; do
  if [ -f "$f" ]; then
    codesign --sign - --force "$f" 2>/dev/null
    xattr -d com.apple.quarantine "$f" 2>/dev/null
  fi
done
