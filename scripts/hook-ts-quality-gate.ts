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
 * Does: Prettier (format) + ESLint --fix + ESLint check
 * Does NOT: TypeScript compilation (too slow per-file → moved to Stop hook)
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
import { existsSync } from "node:fs";

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

async function logToolUsage(entry: LogEntry) {
  try {
    const logLine = JSON.stringify(entry) + "\n";
    const file = Bun.file(LOG_FILE);
    const existingContent = (await file.exists()) ? await file.text() : "";
    await Bun.write(LOG_FILE, existingContent + logLine);
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
  try {
    const proc = Bun.spawn(command, { stdout: "pipe", stderr: "pipe", cwd });

    const timeoutPromise = new Promise<never>((_, reject) =>
      setTimeout(() => { proc.kill(); reject(new Error(`Timed out after ${timeoutMs}ms`)); }, timeoutMs),
    );

    const resultPromise = (async () => {
      const stdout = await new Response(proc.stdout).text();
      const stderr = await new Response(proc.stderr).text();
      const success = (await proc.exited) === 0;
      return { stdout, stderr, success };
    })();

    return await Promise.race([resultPromise, timeoutPromise]);
  } catch (error) {
    return { stdout: "", stderr: String(error), success: false };
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

  const prettierBin = join(projectRoot, "node_modules", ".bin", "prettier");
  const eslintBin = join(projectRoot, "node_modules", ".bin", "eslint");
  const hasPrettier = existsSync(prettierBin);
  const hasEslintBin = existsSync(eslintBin);
  const hasEslintConfig =
    existsSync(join(projectRoot, "eslint.config.js")) ||
    existsSync(join(projectRoot, "eslint.config.mjs")) ||
    existsSync(join(projectRoot, "eslint.config.cjs"));
  const hasEslint = hasEslintBin && hasEslintConfig;

  // 1. Prettier — format in place
  if (hasPrettier) {
    const result = await runCommand([prettierBin, "--write", filePath], projectRoot);
    if (!result.success) errors.push(`Prettier failed: ${result.stderr}`);
  }

  // 2. ESLint --fix then check
  if (hasEslint) {
    await runCommand([eslintBin, "--fix", filePath], projectRoot);
    const checkResult = await runCommand([eslintBin, filePath], projectRoot);
    const eslintErrors = (checkResult.stdout + checkResult.stderr).trim();
    if (eslintErrors && !eslintErrors.includes("0 problems")) {
      errors.push(`ESLint errors:\n${eslintErrors}`);
    }
  }

  await logToolUsage({
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
    const eslintMatches = allErrorsText.match(/\d+:\d+\s+(error|warning)/g);
    const eslintErrorCount = eslintMatches ? eslintMatches.length : 0;

    const prettyErrors = errors
      .map((e) => e.replace(/ESLint errors:\n?/g, "").replace(new RegExp(projectRoot + "/", "g"), "").replace(/✖ \d+ problems?.*\n?/g, "").trim())
      .filter((e) => e.length > 0)
      .join("\n");

    const indentedErrors = prettyErrors.split("\n").map((l) => `│ ${l}`).join("\n");
    const header = eslintErrorCount > 0
      ? `🔴 ${eslintErrorCount} ESLint error${eslintErrorCount > 1 ? "s" : ""} in ${fileName}`
      : `⚠️ Issues in ${fileName}`;

    const output: HookOutput = {
      systemMessage: `\n${header}\n${indentedErrors}`,
      hookSpecificOutput: {
        hookEventName: "PostToolUse",
        additionalContext: `Fix NOW the following errors in ${fileName}:\n\n${errors.join("\n\n")}`,
      },
    };

    console.log(JSON.stringify(output, null, 2));
  }
}

main().catch(() => process.exit(1));
