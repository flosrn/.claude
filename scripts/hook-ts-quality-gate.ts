#!/usr/bin/env bun

// APEX mode guard — skip quality gate in automated sessions (no human at keyboard)
// NOTIFY_TMUX_SESSION is set by launch-claude.sh for all APEX runs
if (process.env.NOTIFY_TMUX_SESSION) {
  process.exit(0);
}

/**
 * PostToolUse hook — Fast per-file quality gate
 * Runs after every Edit|Write|NotebookEdit on TypeScript files.
 *
 * Does: Format (oxfmt or prettier) + Lint --fix + Lint check (oxlint or eslint)
 * Does NOT: TypeScript compilation (too slow per-file → moved to Stop hook)
 *
 * Tool detection: uses whichever binaries exist in node_modules/.bin.
 * Both can coexist (e.g. during migration) — each runs independently.
 */

interface HookInput {
  session_id: string;
  transcript_path: string;
  cwd: string;
  hook_event_name: string;
  tool_name: string;
  tool_use_id: string;
  tool_input: {
    file_path: string;
    content?: string;
  };
  tool_response: {
    filePath?: string;
    success: boolean;
  };
}

interface HookOutput {
  systemMessage?: string;
  hookSpecificOutput: {
    hookEventName: string;
    additionalContext: string;
  };
}

interface LogEntry {
  timestamp: string;
  session_id: string;
  tool_use_id: string;
  tool_name: string;
  file_path: string;
  status: "success" | "error";
  errors?: string[];
}

import { dirname, join } from "node:path";
import { existsSync, appendFileSync, statSync, renameSync } from "node:fs";

const DEBUG = process.env.CLAUDE_HOOK_DEBUG === "1";
const LOG_FILE = "/Users/flo/.claude/tool-usage.log";

async function findProjectRoot(filePath: string): Promise<string | null> {
  let dir = dirname(filePath);
  const root = "/";

  while (dir !== root) {
    const pnpmWorkspace = Bun.file(join(dir, "pnpm-workspace.yaml"));
    if (await pnpmWorkspace.exists()) return dir;

    const packageJson = Bun.file(join(dir, "package.json"));
    if (await packageJson.exists()) {
      try {
        const content = await packageJson.json();
        if (content.workspaces) return dir;
      } catch {}
    }
    dir = dirname(dir);
  }

  dir = dirname(filePath);
  while (dir !== root) {
    const packageJson = Bun.file(join(dir, "package.json"));
    if (await packageJson.exists()) return dir;
    dir = dirname(dir);
  }

  return null;
}

function log(message: string, ...args: unknown[]) {
  if (DEBUG) console.error(`[${new Date().toISOString()}] ${message}`, ...args);
}

// Cap the log at ~5 MB, keeping one previous generation, so it never grows unbounded.
const MAX_LOG_BYTES = 5_000_000;

function logToolUsage(entry: LogEntry) {
  try {
    if (existsSync(LOG_FILE) && statSync(LOG_FILE).size > MAX_LOG_BYTES) {
      renameSync(LOG_FILE, `${LOG_FILE}.1`);
    }
    appendFileSync(LOG_FILE, JSON.stringify(entry) + "\n");
  } catch (error) {
    log("Failed to write log:", error);
  }
}

const COMMAND_TIMEOUT_MS = 10000;

async function runCommand(
  command: string[],
  cwd?: string,
  timeoutMs: number = COMMAND_TIMEOUT_MS,
): Promise<{ stdout: string; stderr: string; success: boolean }> {
  // The timeout timer MUST be cleared once the command settles. Bun keeps the
  // process alive until every pending timer fires, so an uncleared 10s timer
  // makes the hook idle for 10s after finishing ~300ms of real work — which
  // Claude Code experiences as a 10s stall on every edit.
  let timer: ReturnType<typeof setTimeout> | undefined;
  try {
    const proc = Bun.spawn(command, { stdout: "pipe", stderr: "pipe", cwd });

    const timeoutPromise = new Promise<never>((_, reject) => {
      timer = setTimeout(() => {
        proc.kill();
        reject(new Error(`Timed out after ${timeoutMs}ms`));
      }, timeoutMs);
    });

    const resultPromise = (async () => {
      // Drain both pipes concurrently: draining stdout to completion first can
      // deadlock when the child fills the stderr pipe buffer and blocks.
      const [stdout, stderr] = await Promise.all([
        new Response(proc.stdout).text(),
        new Response(proc.stderr).text(),
      ]);
      const success = (await proc.exited) === 0;
      return { stdout, stderr, success };
    })();

    return await Promise.race([resultPromise, timeoutPromise]);
  } catch (error) {
    return { stdout: "", stderr: String(error), success: false };
  } finally {
    if (timer !== undefined) clearTimeout(timer);
  }
}

async function main() {
  const input = await Bun.stdin.text();
  let hookData: HookInput;
  try {
    hookData = JSON.parse(input);
  } catch {
    process.exit(0);
  }

  const { tool_use_id, tool_name, session_id } = hookData;
  const filePath = hookData.tool_input?.file_path;

  if (!filePath) process.exit(0);
  if (!filePath.endsWith(".ts") && !filePath.endsWith(".tsx")) process.exit(0);

  const projectRoot = await findProjectRoot(filePath);
  if (!projectRoot) process.exit(0);

  const file = Bun.file(filePath);
  if (!(await file.exists())) process.exit(0);

  const errors: string[] = [];

  // ── Detect available tools ──────────────────────────────────────
  const oxfmtBin = join(projectRoot, "node_modules", ".bin", "oxfmt");
  const oxlintBin = join(projectRoot, "node_modules", ".bin", "oxlint");
  const prettierBin = join(projectRoot, "node_modules", ".bin", "prettier");
  const eslintBin = join(projectRoot, "node_modules", ".bin", "eslint");

  const hasOxfmt = existsSync(oxfmtBin);
  const hasOxlint = existsSync(oxlintBin);
  const hasPrettier = existsSync(prettierBin);
  const hasEslintBin = existsSync(eslintBin);
  const hasEslintConfig =
    existsSync(join(projectRoot, "eslint.config.js")) ||
    existsSync(join(projectRoot, "eslint.config.mjs")) ||
    existsSync(join(projectRoot, "eslint.config.cjs"));
  const hasEslint = hasEslintBin && hasEslintConfig;

  // ── Helper: detect broken native bindings (worktrees, incomplete installs) ──
  const isNativeBindingError = (output: string) =>
    output.includes("native binding") || output.includes("MODULE_NOT_FOUND");

  // ── 1. Format in place ──────────────────────────────────────────
  if (hasOxfmt) {
    const result = await runCommand([oxfmtBin, filePath], projectRoot);
    if (!result.success && !isNativeBindingError(result.stderr)) {
      errors.push(`oxfmt failed: ${result.stderr}`);
    }
  }
  if (hasPrettier) {
    const result = await runCommand([prettierBin, "--write", filePath], projectRoot);
    if (!result.success) errors.push(`Prettier failed: ${result.stderr}`);
  }

  // ── 2. Lint --fix then check ────────────────────────────────────
  if (hasOxlint) {
    // One spawn, not two: `oxlint --fix` already reports what it could NOT fix
    // (exit 1 + diagnostics on stdout) and stays silent when the file ends up
    // clean (exit 0), so it never re-reports an issue it just fixed.
    const fixResult = await runCommand([oxlintBin, "--fix", filePath], projectRoot);
    const lintOutput = (fixResult.stdout + fixResult.stderr).trim();
    if (isNativeBindingError(lintOutput)) {
      log("oxlint native binding unavailable (worktree?), skipping");
    } else if (!fixResult.success && lintOutput) {
      errors.push(`oxlint errors:\n${lintOutput}`);
    }
  }
  if (hasEslint) {
    // Same single-spawn shape as oxlint above: `eslint --fix` reports only what
    // it could NOT fix (non-zero exit + diagnostics) and is silent when the file
    // ends up clean, so the old second full ESLint run was a wasted cold start.
    const fixResult = await runCommand([eslintBin, "--fix", filePath], projectRoot);
    const eslintErrors = (fixResult.stdout + fixResult.stderr).trim();
    if (isNativeBindingError(eslintErrors)) {
      log("eslint native binding unavailable (worktree?), skipping");
    } else if (eslintErrors && !eslintErrors.includes("0 problems")) {
      errors.push(`ESLint errors:\n${eslintErrors}`);
    }
  }

  logToolUsage({
    timestamp: new Date().toISOString(),
    session_id,
    tool_use_id,
    tool_name,
    file_path: filePath,
    status: errors.length > 0 ? "error" : "success",
    errors: errors.length > 0 ? errors : undefined,
  });

  if (errors.length > 0) {
    const fileName = filePath.split("/").pop();
    const allErrorsText = errors.join("\n");
    // Count severities across BOTH reporter formats, keeping them distinct so a
    // warning is never announced as an error (which would push Claude to "fix"
    // rules the project deliberately set to warn):
    //   ESLint stylish  "  2:9  error  '...'"       → digits:digits WS severity
    //   oxlint          "f.tsx:2:9: error eslint(…)" → digits:digits ':' WS severity
    const severityMatches = allErrorsText.match(/\d+:\d+:?\s+(error|warning)\b/g) ?? [];
    const errorCount = severityMatches.filter((m) => m.endsWith("error")).length;
    const warningCount = severityMatches.length - errorCount;
    const plural = (n: number, word: string) => `${n} ${word}${n > 1 ? "s" : ""}`;

    const prettyErrors = errors
      .map((e) => e.replace(/(?:ESLint|oxlint) errors:\n?/g, "").replace(new RegExp(projectRoot + "/", "g"), "").replace(/✖ \d+ problems?.*\n?/g, "").trim())
      .filter((e) => e.length > 0)
      .join("\n");

    const indentedErrors = prettyErrors.split("\n").map((l) => `│ ${l}`).join("\n");
    const counted = [
      errorCount > 0 ? plural(errorCount, "lint error") : "",
      warningCount > 0 ? plural(warningCount, "warning") : "",
    ].filter(Boolean);
    const header = counted.length > 0
      ? `${errorCount > 0 ? "🔴" : "⚠️"} ${counted.join(" + ")} in ${fileName}`
      : `⚠️ Issues in ${fileName}`;

    const output: HookOutput = {
      systemMessage: `\n${header}\n${indentedErrors}`,
      hookSpecificOutput: {
        hookEventName: "PostToolUse",
        additionalContext: `Fix NOW the following ${counted.length > 0 ? counted.join(" + ") : "issues"} in ${fileName}:\n\n${errors.join("\n\n")}`,
      },
    };

    console.log(JSON.stringify(output, null, 2));
  }
}

main().catch(() => process.exit(1));
