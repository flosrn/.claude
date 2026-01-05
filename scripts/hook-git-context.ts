#!/usr/bin/env bun
/**
 * SessionStart Hook
 *
 * Injects git context ONCE at the start of a conversation:
 * - Current timestamp
 * - Git branch and status
 * - Recent changes summary
 *
 * Fires on: startup, resume, clear
 */

import { $ } from 'bun';

interface SessionStartInput {
  session_id: string;
  cwd: string;
  source: 'startup' | 'resume' | 'clear';
}

async function main() {
  const stdin = await Bun.stdin.text();
  let input: SessionStartInput;

  try {
    input = JSON.parse(stdin);
  } catch {
    process.exit(0);
  }

  const { cwd, source } = input;

  // Only inject on startup (not resume or clear)
  if (source !== 'startup') {
    process.exit(0);
  }

  const context: string[] = [];

  // Add timestamp
  const now = new Date();
  context.push(`Session started: ${now.toISOString().replace('T', ' ').slice(0, 19)}`);

  // Git context
  try {
    const branch = await $`git -C ${cwd} rev-parse --abbrev-ref HEAD 2>/dev/null`.text();
    if (branch.trim()) {
      context.push(`Git branch: ${branch.trim()}`);
    }

    const status = await $`git -C ${cwd} status --porcelain 2>/dev/null`.text();
    if (status.trim()) {
      const lines = status.trim().split('\n');
      const modified = lines.filter(l => l.startsWith(' M') || l.startsWith('M ')).length;
      const staged = lines.filter(l => l.startsWith('A ') || l.startsWith('M ')).length;
      const untracked = lines.filter(l => l.startsWith('??')).length;

      const statusParts: string[] = [];
      if (staged > 0) statusParts.push(`${staged} staged`);
      if (modified > 0) statusParts.push(`${modified} modified`);
      if (untracked > 0) statusParts.push(`${untracked} untracked`);

      if (statusParts.length > 0) {
        context.push(`Git status: ${statusParts.join(', ')}`);
      }

      if (lines.length > 0) {
        const changedFiles = lines
          .slice(0, 5)
          .map(l => l.slice(3).trim())
          .join(', ');
        context.push(`Changed files: ${changedFiles}${lines.length > 5 ? ` (+${lines.length - 5} more)` : ''}`);
      }
    }

    const lastCommit = await $`git -C ${cwd} log -1 --oneline 2>/dev/null`.text();
    if (lastCommit.trim()) {
      context.push(`Last commit: ${lastCommit.trim().slice(0, 60)}`);
    }
  } catch {
    // Not a git repo - skip git context
  }

  if (context.length > 0) {
    console.log(context.join('\n'));
  }

  process.exit(0);
}

main();
