#!/usr/bin/env bun

import { join } from "node:path";
import type { SecurityConfig } from "./lib/types";

const CONFIG_PATH = join(import.meta.dir, "../data/security-config.json");

async function loadConfig(): Promise<SecurityConfig> {
	try {
		const file = Bun.file(CONFIG_PATH);
		const content = await file.text();
		return JSON.parse(content) as SecurityConfig;
	} catch {
		return {
			gitSecurity: {
				enabled: true,
				blockCommit: true,
				blockPush: true,
				blockForcePush: true,
			},
			updatedAt: null,
		};
	}
}

async function saveConfig(config: SecurityConfig): Promise<void> {
	config.updatedAt = new Date().toISOString();
	await Bun.write(CONFIG_PATH, JSON.stringify(config, null, 2));
}

function printStatus(config: SecurityConfig): void {
	const git = config.gitSecurity;
	const status = git.enabled ? "\x1b[32mON\x1b[0m" : "\x1b[31mOFF\x1b[0m";

	console.log("\n\x1b[1m=== Git Security Status ===\x1b[0m\n");
	console.log(`  Global:      ${status}`);

	if (git.enabled) {
		console.log(
			`  Commit:      ${git.blockCommit ? "\x1b[33mblocked\x1b[0m" : "\x1b[32mallowed\x1b[0m"}`,
		);
		console.log(
			`  Push:        ${git.blockPush ? "\x1b[33mblocked\x1b[0m" : "\x1b[32mallowed\x1b[0m"}`,
		);
		console.log(
			`  Force Push:  ${git.blockForcePush ? "\x1b[33mblocked\x1b[0m" : "\x1b[32mallowed\x1b[0m"}`,
		);
	}

	if (config.updatedAt) {
		console.log(`\n  Last update: ${config.updatedAt}`);
	}
	console.log("");
}

function printHelp(): void {
	console.log(`
\x1b[1mGit Security Toggle\x1b[0m

Usage: bun git-security.ts <command>

Commands:
  status        Show current security status
  on            Enable all git security checks
  off           Disable all git security checks
  toggle        Toggle git security on/off

  commit on     Enable commit blocking
  commit off    Disable commit blocking
  push on       Enable push blocking
  push off      Disable push blocking
  force on      Enable force-push blocking
  force off     Disable force-push blocking

Examples:
  bun git-security.ts off       # Disable all git security
  bun git-security.ts on        # Re-enable all git security
  bun git-security.ts commit off # Allow commits, keep other rules
`);
}

async function main(): Promise<void> {
	const args = process.argv.slice(2);
	const config = await loadConfig();

	if (args.length === 0 || args[0] === "status") {
		printStatus(config);
		return;
	}

	if (args[0] === "help" || args[0] === "--help" || args[0] === "-h") {
		printHelp();
		return;
	}

	if (args[0] === "on") {
		config.gitSecurity.enabled = true;
		config.gitSecurity.blockCommit = true;
		config.gitSecurity.blockPush = true;
		config.gitSecurity.blockForcePush = true;
		await saveConfig(config);
		console.log("\x1b[32m✓ Git security ENABLED\x1b[0m");
		printStatus(config);
		return;
	}

	if (args[0] === "off") {
		config.gitSecurity.enabled = false;
		await saveConfig(config);
		console.log("\x1b[31m✗ Git security DISABLED\x1b[0m");
		printStatus(config);
		return;
	}

	if (args[0] === "toggle") {
		config.gitSecurity.enabled = !config.gitSecurity.enabled;
		await saveConfig(config);
		console.log(
			config.gitSecurity.enabled
				? "\x1b[32m✓ Git security ENABLED\x1b[0m"
				: "\x1b[31m✗ Git security DISABLED\x1b[0m",
		);
		printStatus(config);
		return;
	}

	// Handle specific rule toggles
	if (args.length >= 2) {
		const rule = args[0];
		const state = args[1] === "on";

		switch (rule) {
			case "commit":
				config.gitSecurity.blockCommit = state;
				await saveConfig(config);
				console.log(
					state
						? "\x1b[33m✓ Commit blocking ENABLED\x1b[0m"
						: "\x1b[32m✓ Commit blocking DISABLED\x1b[0m",
				);
				break;
			case "push":
				config.gitSecurity.blockPush = state;
				await saveConfig(config);
				console.log(
					state
						? "\x1b[33m✓ Push blocking ENABLED\x1b[0m"
						: "\x1b[32m✓ Push blocking DISABLED\x1b[0m",
				);
				break;
			case "force":
				config.gitSecurity.blockForcePush = state;
				await saveConfig(config);
				console.log(
					state
						? "\x1b[33m✓ Force-push blocking ENABLED\x1b[0m"
						: "\x1b[32m✓ Force-push blocking DISABLED\x1b[0m",
				);
				break;
			default:
				console.error(`Unknown rule: ${rule}`);
				printHelp();
				process.exit(1);
		}
		printStatus(config);
		return;
	}

	printHelp();
}

main().catch((error) => {
	console.error("Error:", error.message);
	process.exit(1);
});
