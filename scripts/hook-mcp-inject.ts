#!/usr/bin/env bun

/**
 * UserPromptSubmit Hook: MCP Tools Injection
 *
 * Detects "MCP" keyword in user prompt and injects available MCP tools context.
 * Output via stdout is automatically injected as context for Claude.
 *
 * Reads MCP config from ~/.claude.json and respects project-specific disabled servers.
 */

import { execSync } from "child_process";
import { appendFileSync, readFileSync, existsSync } from "fs";
import { homedir } from "os";
import { join } from "path";

const LOG_FILE = "/Users/flo/.claude/scripts/hook-mcp-inject.log";
const CLAUDE_CONFIG_PATH = join(homedir(), ".claude.json");

function log(message: string) {
  const timestamp = new Date().toISOString();
  appendFileSync(LOG_FILE, `[${timestamp}] ${message}\n`);
}

interface HookInput {
  hook_event_name: string;
  user_prompt: string;
  session_id: string;
  cwd: string;
  prompt?: string;
  message?: string;
}

interface ClaudeConfig {
  mcpServers?: Record<string, unknown>;
  projects?: Record<
    string,
    {
      mcpServers?: Record<string, unknown>;
      disabledMcpServers?: string[];
    }
  >;
}

/**
 * Get disabled MCP servers for a project from ~/.claude.json
 */
function getDisabledMcpServers(cwd: string): string[] {
  try {
    if (!existsSync(CLAUDE_CONFIG_PATH)) {
      log(`Config not found at ${CLAUDE_CONFIG_PATH}`);
      return [];
    }

    const configContent = readFileSync(CLAUDE_CONFIG_PATH, "utf-8");
    const config: ClaudeConfig = JSON.parse(configContent);

    // Get project-specific disabled servers
    const projectConfig = config.projects?.[cwd];
    const disabledServers = projectConfig?.disabledMcpServers || [];

    log(`Project: ${cwd}`);
    log(`Disabled MCP servers: ${disabledServers.join(", ") || "none"}`);

    return disabledServers;
  } catch (e) {
    log(`Error reading config: ${e}`);
    return [];
  }
}

/**
 * Get connected MCP server names using claude mcp list
 */
function getConnectedMcpServers(): string[] {
  try {
    const output = execSync("claude mcp list 2>/dev/null", { encoding: "utf-8" });
    return output
      .split("\n")
      .filter((line) => line.includes("✓ Connected"))
      .map((line) => {
        const match = line.match(/^(\S+):/);
        return match?.[1] ?? null;
      })
      .filter((s): s is string => s !== null);
  } catch {
    return [];
  }
}

// Read hook input from stdin
let input: HookInput;
try {
  input = await Bun.stdin.json();
  log(`Raw input: ${JSON.stringify(input)}`);
} catch (e) {
  log(`Failed to parse input: ${e}`);
  process.exit(0);
}

// Handle different possible property names
const prompt = input.user_prompt ?? input.prompt ?? input.message ?? "";
const cwd = input.cwd || process.cwd();
log(`Received prompt: "${prompt.substring(0, 50)}..."`);
log(`Working directory: ${cwd}`);

// Check if prompt contains "MCP" (case insensitive, word boundary)
const hasMcpKeyword = /\bmcp\b/i.test(prompt);
log(`MCP keyword detected: ${hasMcpKeyword}`);

if (!hasMcpKeyword) {
  log("No MCP keyword, exiting without injection");
  process.exit(0);
}

log("Injecting MCP tools context...");

// Strategy: Get connected servers, filter out disabled ones
const connectedServers = getConnectedMcpServers();
const disabledServers = getDisabledMcpServers(cwd);

log(`Connected servers: ${connectedServers.join(", ") || "none"}`);

// Filter connected servers to remove disabled ones
const mcpServers = connectedServers.filter((s) => !disabledServers.includes(s));
log(`Enabled servers: ${mcpServers.join(", ") || "none"}`);

// Build MCP tools reference - simple and fast
const mcpToolsContext = `
<mcp-tools-available>
## Available MCP Servers (${mcpServers.length})

${mcpServers.map((s) => `- **${s}**: \`mcp__${s}__*\``).join("\n")}

Use these MCP tools proactively when relevant to the task.
</mcp-tools-available>
`;

// Output context to stdout (will be injected)
console.log(mcpToolsContext);

process.exit(0);
