#!/usr/bin/env bun
// @ts-nocheck

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

// Check for debug mode
const DEBUG = process.env.CLAUDE_HOOK_DEBUG === "1";
const LOG_FILE = "/Users/flo/.claude/tool-usage.log";

function log(message: string, ...args: unknown[]) {
  if (DEBUG) {
    console.error(`[${new Date().toISOString()}] ${message}`, ...args);
  }
}

async function logToolUsage(entry: LogEntry) {
  try {
    const logLine = JSON.stringify(entry) + "\n";
    await Bun.write(LOG_FILE, logLine, { flags: "a" });
  } catch (error) {
    log("Failed to write log:", error);
  }
}

async function runCommand(
  command: string[],
): Promise<{ stdout: string; stderr: string; success: boolean }> {
  try {
    const proc = Bun.spawn(command, {
      stdout: "pipe",
      stderr: "pipe",
    });

    const stdout = await new Response(proc.stdout).text();
    const stderr = await new Response(proc.stderr).text();
    const success = (await proc.exited) === 0;

    return { stdout, stderr, success };
  } catch (error) {
    return { stdout: "", stderr: String(error), success: false };
  }
}

async function main() {
  log("Hook started for file processing");

  // Read input JSON from stdin
  const input = await Bun.stdin.text();
  log("Input received, length:", input.length);

  let hookData: HookInput;
  try {
    hookData = JSON.parse(input);
  } catch (error) {
    log("Error parsing JSON input:", error);
    process.exit(0);
  }

  const { tool_use_id, tool_name, session_id } = hookData;
  const filePath = hookData.tool_input?.file_path;

  if (!filePath) {
    log("Unable to extract file path from input");
    process.exit(0);
  }

  log("Processing tool use:", { tool_use_id, tool_name, filePath });

  // Check that it's a TypeScript file only
  if (!filePath.endsWith(".ts") && !filePath.endsWith(".tsx")) {
    log(`Skipping ${filePath}: not a TypeScript file`);
    process.exit(0);
  }

  log("Processing file:", filePath);

  // Check that the file exists
  const file = Bun.file(filePath);
  if (!(await file.exists())) {
    log("File not found:", filePath);
    process.exit(1);
  }

  const errors: string[] = [];

  // 1. Execute Prettier
  log("Running Prettier formatting");
  const prettierResult = await runCommand([
    "bun",
    "x",
    "prettier",
    "--write",
    filePath,
  ]);
  if (!prettierResult.success) {
    log("Prettier failed:", prettierResult.stderr);
    errors.push(`Prettier failed: ${prettierResult.stderr}`);
  }

  // 2. ESLint --fix
  log("Running ESLint --fix");
  await runCommand(["bun", "x", "eslint", "--fix", filePath]);

  // 3. Run ESLint check and TypeScript check in parallel
  log("Running ESLint and TypeScript checks in parallel");
  const [eslintCheckResult, tscResult] = await Promise.all([
    runCommand(["bun", "x", "eslint", filePath]),
    runCommand(["bun", "x", "tsc", "--noEmit", "--pretty", "false"]),
  ]);

  const eslintErrors = (
    eslintCheckResult.stdout + eslintCheckResult.stderr
  ).trim();

  const tsErrors = tscResult.stderr
    .split("\n")
    .filter((line) => line.includes(filePath))
    .join("\n");

  if (tsErrors) errors.push(`TypeScript errors:\n${tsErrors}`);
  if (eslintErrors) errors.push(`ESLint errors:\n${eslintErrors}`);

  // Log tool usage with tool_use_id for traceability
  await logToolUsage({
    timestamp: new Date().toISOString(),
    session_id,
    tool_use_id,
    tool_name,
    file_path: filePath,
    status: errors.length > 0 ? "error" : "success",
    errors: errors.length > 0 ? errors : undefined,
  });

  log("Error count:", errors.length);

  // Output the result
  if (errors.length > 0) {
    const errorMessage = `Fix NOW the following errors AND warning detected in ${filePath
      .split("/")
      .pop()}:\n\n${errors.join("\n\n")}`;

    const output: HookOutput = {
      hookSpecificOutput: {
        hookEventName: "PostToolUse",
        additionalContext: errorMessage,
      },
    };

    log("Output", JSON.stringify(output, null, 2));
    console.log(JSON.stringify(output, null, 2));
  } else {
    console.error(
      `✓ No errors detected in ${filePath.split("/").pop()} [${tool_use_id}]`,
    );
  }
}

main().catch((error) => {
  log("Error in hook:", error);
  process.exit(1);
});
