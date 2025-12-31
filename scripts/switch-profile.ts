#!/usr/bin/env bun
/**
 * Claude Code Profile Switcher v3
 *
 * Uses Base + Overrides pattern:
 * - _base.json contains shared settings (hooks, statusLine, etc.)
 * - Profile files only contain deltas (plugins, MCPs, permissions)
 *
 * Usage:
 *   bun switch-profile.ts <profile-name>   Switch to profile
 *   bun switch-profile.ts --list           List profiles with details
 *   bun switch-profile.ts --current        Show current profile
 *   bun switch-profile.ts --revert         Revert to previous profile
 *   bun switch-profile.ts --save <name>    Save current config as new profile
 *   bun switch-profile.ts --sync           Update all profiles from current base
 */

import { readdir, readFile, writeFile } from "fs/promises";
import { join } from "path";
import { existsSync } from "fs";

// Paths
const HOME = process.env.HOME!;
const CLAUDE_DIR = join(HOME, ".claude");
const PROFILES_DIR = join(CLAUDE_DIR, "profiles");
const SETTINGS_FILE = join(CLAUDE_DIR, "settings.json");
const CLAUDE_JSON_FILE = join(HOME, ".claude.json");
const CURRENT_PROFILE_FILE = join(PROFILES_DIR, ".current");
const PREVIOUS_PROFILE_FILE = join(PROFILES_DIR, ".previous");
const BASE_FILE = join(PROFILES_DIR, "_base.json");

// Colors for terminal output
const c = {
  reset: "\x1b[0m",
  bold: "\x1b[1m",
  dim: "\x1b[2m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  magenta: "\x1b[35m",
  cyan: "\x1b[36m",
  gray: "\x1b[90m",
};

// ─────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────

interface BaseConfig {
  settings: Record<string, unknown>;
}

interface ProfileConfig {
  name: string;
  description?: string;
  permissions?: {
    allow?: string[];
    deny?: string[];
    ask?: string[];
    defaultMode?: string;
  };
  enabledPlugins?: Record<string, boolean>;
  mcpServers?: Record<string, unknown>;
}

interface MergedConfig {
  settings: Record<string, unknown>;
  mcpServers: Record<string, unknown>;
}

interface ProfileInfo {
  name: string;
  description: string;
  plugins: string[];
  mcpServers: string[];
  mcpPermissions: string[];
}

// ─────────────────────────────────────────────────────────────
// Profile Management Functions
// ─────────────────────────────────────────────────────────────

async function listProfiles(): Promise<string[]> {
  const files = await readdir(PROFILES_DIR);
  return files
    .filter((f) => f.endsWith(".json") && !f.startsWith("_") && !f.startsWith("."))
    .map((f) => f.replace(".json", ""));
}

async function getCurrentProfile(): Promise<string | null> {
  try {
    if (existsSync(CURRENT_PROFILE_FILE)) {
      return (await readFile(CURRENT_PROFILE_FILE, "utf-8")).trim();
    }
  } catch {
    // ignore
  }
  return null;
}

async function loadBase(): Promise<BaseConfig> {
  if (!existsSync(BASE_FILE)) {
    throw new Error("Base config not found: " + BASE_FILE);
  }
  return JSON.parse(await readFile(BASE_FILE, "utf-8"));
}

async function loadProfile(name: string): Promise<ProfileConfig> {
  const profilePath = join(PROFILES_DIR, `${name}.json`);
  return JSON.parse(await readFile(profilePath, "utf-8"));
}

function mergeConfigs(base: BaseConfig, profile: ProfileConfig): MergedConfig {
  // Start with base settings
  const settings = { ...base.settings };

  // Overlay profile-specific settings
  if (profile.permissions) {
    settings.permissions = profile.permissions;
  }
  if (profile.enabledPlugins) {
    settings.enabledPlugins = profile.enabledPlugins;
  }

  return {
    settings,
    mcpServers: profile.mcpServers || {},
  };
}

async function getProfileInfo(name: string): Promise<ProfileInfo> {
  const profile = await loadProfile(name);

  // Get enabled plugins
  const plugins = profile.enabledPlugins
    ? Object.entries(profile.enabledPlugins)
        .filter(([, enabled]) => enabled)
        .map(([name]) => name.split("@")[0]!)
    : [];

  // Get MCP servers
  const mcpServers = Object.keys(profile.mcpServers || {});

  // Get MCP permissions
  const mcpPermissions = (profile.permissions?.allow || []).filter(
    (p): p is string => typeof p === "string" && p.startsWith("mcp__")
  );

  return {
    name,
    description: profile.description || "",
    plugins,
    mcpServers,
    mcpPermissions,
  };
}

async function loadCurrentConfig(): Promise<MergedConfig> {
  // Load settings.json
  const settings = existsSync(SETTINGS_FILE)
    ? JSON.parse(await readFile(SETTINGS_FILE, "utf-8"))
    : {};

  // Load mcpServers from claude.json
  let mcpServers = {};
  if (existsSync(CLAUDE_JSON_FILE)) {
    const claudeJson = JSON.parse(await readFile(CLAUDE_JSON_FILE, "utf-8"));
    mcpServers = claudeJson.mcpServers || {};
  }

  return { settings, mcpServers };
}

async function applyConfig(config: MergedConfig): Promise<void> {
  // Write settings.json
  await writeFile(SETTINGS_FILE, JSON.stringify(config.settings, null, 2));

  // Update mcpServers in claude.json (preserve other fields)
  if (existsSync(CLAUDE_JSON_FILE)) {
    const claudeJson = JSON.parse(await readFile(CLAUDE_JSON_FILE, "utf-8"));
    claudeJson.mcpServers = config.mcpServers;

    // Determine if this is a "bare" profile (no MCPs) or "full" profile (has MCPs)
    const hasGlobalMcps = Object.keys(config.mcpServers).length > 0;

    if (claudeJson.projects) {
      for (const projectPath of Object.keys(claudeJson.projects)) {
        const project = claudeJson.projects[projectPath];

        if (hasGlobalMcps) {
          // Full profile: clear disabledMcpServers to enable all MCPs
          project.disabledMcpServers = [];
        } else {
          // Bare profile: collect ALL known MCPs and disable them
          const allMcpNames = new Set<string>();

          // Add global MCPs (from current state before we clear them)
          if (claudeJson.mcpServers) {
            Object.keys(claudeJson.mcpServers).forEach((name) => allMcpNames.add(name));
          }

          // Add project-specific MCPs
          if (project.mcpServers) {
            Object.keys(project.mcpServers).forEach((name) => allMcpNames.add(name));
          }

          // Add plugin MCPs (common patterns)
          allMcpNames.add("plugin:makerkit:context7");
          allMcpNames.add("plugin:next-react-optimizer:context7");
          allMcpNames.add("plugin:compound-engineering:context7");
          allMcpNames.add("plugin:compound-engineering:pw");

          // Add any already disabled MCPs to preserve them
          if (project.disabledMcpServers) {
            project.disabledMcpServers.forEach((name: string) => allMcpNames.add(name));
          }

          project.disabledMcpServers = Array.from(allMcpNames);
        }
      }
    }

    await writeFile(CLAUDE_JSON_FILE, JSON.stringify(claudeJson, null, 2));
  }
}

async function saveBackup(config: MergedConfig): Promise<void> {
  // Save as _previous for revert
  const backupPath = join(PROFILES_DIR, "_previous.json");
  await writeFile(
    backupPath,
    JSON.stringify(
      {
        settings: config.settings,
        mcpServers: config.mcpServers,
      },
      null,
      2
    )
  );
}

// ─────────────────────────────────────────────────────────────
// Commands
// ─────────────────────────────────────────────────────────────

async function cmdList(): Promise<void> {
  const profiles = await listProfiles();
  const current = await getCurrentProfile();

  console.log(`\n${c.bold}📦 Available Profiles${c.reset}\n`);

  for (const name of profiles) {
    const info = await getProfileInfo(name);
    const isCurrent = name === current;
    const marker = isCurrent ? `${c.green} ← active${c.reset}` : "";

    console.log(`${c.bold}${isCurrent ? c.green : c.cyan}  ${name}${c.reset}${marker}`);

    // Description
    if (info.description) {
      console.log(`${c.gray}    ${info.description}${c.reset}`);
    }

    // Plugins
    if (info.plugins.length > 0) {
      console.log(`${c.gray}    📦 Plugins: ${c.reset}${info.plugins.join(", ")}`);
    } else {
      console.log(`${c.gray}    📦 Plugins: ${c.dim}none${c.reset}`);
    }

    // MCP Servers
    if (info.mcpServers.length > 0) {
      console.log(`${c.gray}    🔌 MCPs:    ${c.reset}${info.mcpServers.join(", ")}`);
    } else {
      console.log(`${c.gray}    🔌 MCPs:    ${c.dim}none${c.reset}`);
    }

    // MCP Permissions
    if (info.mcpPermissions.length > 0) {
      const perms = info.mcpPermissions.map((p) => p.replace("mcp__", "").replace("__*", ""));
      console.log(`${c.gray}    🔓 Auto:    ${c.reset}${perms.join(", ")}`);
    }

    console.log();
  }
}

async function cmdCurrent(): Promise<void> {
  const current = await getCurrentProfile();

  if (current) {
    const info = await getProfileInfo(current);
    console.log(`\n${c.bold}Current profile: ${c.green}${current}${c.reset}`);
    if (info.description) {
      console.log(`${c.gray}${info.description}${c.reset}`);
    }
    console.log();
    console.log(`  📦 Plugins: ${info.plugins.length > 0 ? info.plugins.join(", ") : c.dim + "none" + c.reset}`);
    console.log(`  🔌 MCPs:    ${info.mcpServers.length > 0 ? info.mcpServers.join(", ") : c.dim + "none" + c.reset}`);
  } else {
    console.log(`\n${c.yellow}No profile currently set${c.reset}`);
    console.log(`${c.dim}Using default configuration${c.reset}`);
  }
  console.log();
}

async function cmdSwitch(name: string): Promise<void> {
  const profilePath = join(PROFILES_DIR, `${name}.json`);

  if (!existsSync(profilePath)) {
    console.error(`\n${c.yellow}❌ Profile "${name}" not found${c.reset}\n`);
    console.log("Available profiles:");
    const profiles = await listProfiles();
    for (const p of profiles) {
      console.log(`  - ${p}`);
    }
    process.exit(1);
  }

  // Save current state for revert
  const currentConfig = await loadCurrentConfig();
  const currentProfile = await getCurrentProfile();
  if (currentProfile) {
    await writeFile(PREVIOUS_PROFILE_FILE, currentProfile);
  }
  await saveBackup(currentConfig);

  // Load base and profile, merge them
  const base = await loadBase();
  const profile = await loadProfile(name);
  const merged = mergeConfigs(base, profile);

  // Apply merged config
  await applyConfig(merged);

  // Save current profile name
  await writeFile(CURRENT_PROFILE_FILE, name);

  const info = await getProfileInfo(name);

  console.log(`\n${c.green}✅ Switched to profile: ${c.bold}${name}${c.reset}`);
  if (info.description) {
    console.log(`${c.gray}   ${info.description}${c.reset}`);
  }
  console.log();
  console.log(`  📦 Plugins: ${info.plugins.length > 0 ? info.plugins.join(", ") : c.dim + "none" + c.reset}`);
  console.log(`  🔌 MCPs:    ${info.mcpServers.length > 0 ? info.mcpServers.join(", ") : c.dim + "none" + c.reset}`);

  if (info.mcpServers.length > 0) {
    console.log(`${c.dim}  ✓ Enabled all MCPs (cleared disabledMcpServers)${c.reset}`);
  } else {
    console.log(`${c.dim}  ✓ Disabled all MCPs (including project-specific)${c.reset}`);
  }

  console.log(`\n${c.yellow}⚠️  Restart Claude Code for changes to take effect${c.reset}\n`);
}

async function cmdRevert(): Promise<void> {
  const previousPath = join(PROFILES_DIR, "_previous.json");

  if (!existsSync(previousPath)) {
    console.error(`\n${c.yellow}❌ No previous state to revert to${c.reset}\n`);
    process.exit(1);
  }

  // Load previous config (full format, not profile format)
  const previousData = JSON.parse(await readFile(previousPath, "utf-8"));
  const previousConfig: MergedConfig = {
    settings: previousData.settings,
    mcpServers: previousData.mcpServers,
  };

  const previousProfileName = existsSync(PREVIOUS_PROFILE_FILE)
    ? (await readFile(PREVIOUS_PROFILE_FILE, "utf-8")).trim()
    : null;

  // Apply previous config
  await applyConfig(previousConfig);

  // Update current profile marker
  if (previousProfileName) {
    await writeFile(CURRENT_PROFILE_FILE, previousProfileName);
  }

  console.log(`\n${c.green}✅ Reverted to previous configuration${c.reset}`);
  if (previousProfileName) {
    console.log(`   Profile: ${c.bold}${previousProfileName}${c.reset}`);
  }
  console.log(`\n${c.yellow}⚠️  Restart Claude Code for changes to take effect${c.reset}\n`);
}

async function cmdSave(name: string): Promise<void> {
  if (name.startsWith("_") || name.startsWith(".")) {
    console.error(`\n${c.yellow}❌ Profile name cannot start with _ or .${c.reset}\n`);
    process.exit(1);
  }

  const currentConfig = await loadCurrentConfig();

  // Extract profile-specific parts from current config
  const profile: ProfileConfig = {
    name,
    description: `Saved on ${new Date().toISOString().split("T")[0]}`,
    permissions: currentConfig.settings.permissions as ProfileConfig["permissions"],
    enabledPlugins: currentConfig.settings.enabledPlugins as Record<string, boolean>,
    mcpServers: currentConfig.mcpServers,
  };

  const profilePath = join(PROFILES_DIR, `${name}.json`);
  await writeFile(profilePath, JSON.stringify(profile, null, 2));

  const info = await getProfileInfo(name);

  console.log(`\n${c.green}✅ Saved current config as profile: ${c.bold}${name}${c.reset}\n`);
  console.log(`  📦 Plugins: ${info.plugins.length > 0 ? info.plugins.join(", ") : c.dim + "none" + c.reset}`);
  console.log(`  🔌 MCPs:    ${info.mcpServers.length > 0 ? info.mcpServers.join(", ") : c.dim + "none" + c.reset}`);
  console.log();
}

async function cmdSync(): Promise<void> {
  // Update _base.json from current settings (preserving structure)
  const currentConfig = await loadCurrentConfig();

  // Extract base settings (everything except permissions, enabledPlugins)
  const baseSettings = { ...currentConfig.settings };
  delete baseSettings.permissions;
  delete baseSettings.enabledPlugins;

  const base: BaseConfig = { settings: baseSettings };
  await writeFile(BASE_FILE, JSON.stringify(base, null, 2));

  console.log(`\n${c.green}✅ Updated _base.json from current configuration${c.reset}`);
  console.log(`${c.dim}   Hooks, statusLine, and other shared settings synced${c.reset}\n`);
}

function showHelp(): void {
  console.log(`
${c.bold}Claude Code Profile Switcher v3${c.reset}
${c.dim}Base + Overrides pattern for minimal duplication${c.reset}

${c.cyan}Usage:${c.reset}
  bun switch-profile.ts <profile>      Switch to a profile
  bun switch-profile.ts --list         List all profiles with details
  bun switch-profile.ts --current      Show current profile
  bun switch-profile.ts --revert       Revert to previous profile
  bun switch-profile.ts --save <name>  Save current config as new profile
  bun switch-profile.ts --sync         Update base from current config

${c.cyan}Architecture:${c.reset}
  profiles/
  ├── _base.json    ${c.dim}# Shared: hooks, statusLine, marketplaces${c.reset}
  ├── bare.json     ${c.dim}# Delta: no plugins, no MCPs${c.reset}
  └── full.json     ${c.dim}# Delta: all plugins and MCPs${c.reset}

${c.cyan}Examples:${c.reset}
  bun switch-profile.ts bare           ${c.dim}# Minimal mode${c.reset}
  bun switch-profile.ts full           ${c.dim}# Full power${c.reset}
  bun switch-profile.ts --save dev     ${c.dim}# Save current as "dev"${c.reset}
  bun switch-profile.ts --sync         ${c.dim}# Update base settings${c.reset}
`);
}

// ─────────────────────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────────────────────

async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args[0] === "--help" || args[0] === "-h") {
    showHelp();
    return;
  }

  switch (args[0]) {
    case "--list":
    case "-l":
      await cmdList();
      break;

    case "--current":
    case "-c":
      await cmdCurrent();
      break;

    case "--revert":
    case "-r":
      await cmdRevert();
      break;

    case "--save":
    case "-s":
      if (!args[1]) {
        console.error(`\n${c.yellow}❌ Please provide a profile name${c.reset}\n`);
        process.exit(1);
      }
      await cmdSave(args[1]);
      break;

    case "--sync":
      await cmdSync();
      break;

    default:
      await cmdSwitch(args[0]!);
      break;
  }
}

main().catch(console.error);
