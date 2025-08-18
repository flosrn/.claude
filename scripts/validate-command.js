#!/usr/bin/env bun

/**
 * Claude Code "Before Tools" Hook - Command Validation Script
 *
 * This script validates commands before execution to prevent harmful operations.
 * It receives command data via stdin and returns exit code 0 (allow) or 1 (block).
 *
 * Usage: Called automatically by Claude Code PreToolUse hook
 * Manual test: echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | bun validate-command.js
 */

// Comprehensive dangerous command patterns database
const SECURITY_RULES = {
  // Critical system destruction commands
  CRITICAL_COMMANDS: [
    "del",
    "format",
    "mkfs",
    "shred",
    "dd",
    "fdisk",
    "parted",
    "gparted",
    "cfdisk",
  ],

  // Privilege escalation and system access
  PRIVILEGE_COMMANDS: [
    "sudo",
    "su",
    "passwd",
    "chpasswd",
    "usermod",
    "chmod",
    "chown",
    "chgrp",
    "setuid",
    "setgid",
  ],

  // Network and remote access tools
  NETWORK_COMMANDS: [
    "nc",
    "netcat",
    "nmap",
    "telnet",
    "ssh-keygen",
    "iptables",
    "ufw",
    "firewall-cmd",
    "ipfw",
  ],

  // System service and process manipulation
  SYSTEM_COMMANDS: [
    "systemctl",
    "service",
    "kill",
    "killall",
    "pkill",
    "mount",
    "umount",
    "swapon",
    "swapoff",
  ],

  // Dangerous regex patterns
  DANGEROUS_PATTERNS: [
    // File system destruction - block rm -rf with absolute paths
    /rm\s+.*-rf\s*\/\s*$/i, // rm -rf ending at root directory
    /rm\s+.*-rf\s*\/\w+/i, // rm -rf with any absolute path
    /rm\s+.*-rf\s*\/etc/i, // rm -rf in /etc
    /rm\s+.*-rf\s*\/usr/i, // rm -rf in /usr
    /rm\s+.*-rf\s*\/bin/i, // rm -rf in /bin
    /rm\s+.*-rf\s*\/sys/i, // rm -rf in /sys
    /rm\s+.*-rf\s*\/proc/i, // rm -rf in /proc
    /rm\s+.*-rf\s*\/boot/i, // rm -rf in /boot
    /rm\s+.*-rf\s*\/home\/[^\/]*\s*$/i, // rm -rf entire home directory
    /rm\s+.*-rf\s*\.\.+\//i, // rm -rf with parent directory traversal
    /rm\s+.*-rf\s*\*.*\*/i, // rm -rf with multiple wildcards
    /rm\s+.*-rf\s*\$\w+/i, // rm -rf with variables (could be dangerous)
    />\s*\/dev\/(sda|hda|nvme)/i,
    /dd\s+.*of=\/dev\//i,
    /shred\s+.*\/dev\//i,
    /mkfs\.\w+\s+\/dev\//i,

    // Supabase production database protection
    /DELETE\s+FROM\s+\w+\s*;?\s*$/i, // DELETE without WHERE clause
    /DROP\s+(TABLE|DATABASE|SCHEMA)\s+/i, // DROP operations
    /TRUNCATE\s+TABLE\s+/i, // TRUNCATE operations
    /ALTER\s+TABLE\s+.*DROP\s+COLUMN/i, // Destructive schema changes

    // Fork bomb and resource exhaustion
    /:\(\)\{\s*:\|:&\s*\};:/,
    /while\s+true\s*;\s*do.*done/i,
    /for\s*\(\(\s*;\s*;\s*\)\)/i,

    // Command injection and chaining
    /;\s*(rm|dd|mkfs|format)/i,
    /&&\s*(rm|dd|mkfs|format)/i,
    /\|\|\s*(rm|dd|mkfs|format)/i,

    // Remote code execution
    /\|\s*(sh|bash|zsh|fish)$/i,
    /(wget|curl)\s+.*\|\s*(sh|bash)/i,
    /(wget|curl)\s+.*-O-.*\|\s*(sh|bash)/i,

    // Command substitution with dangerous commands
    /`.*rm.*`/i,
    /\$\(.*rm.*\)/i,
    /`.*dd.*`/i,
    /\$\(.*dd.*\)/i,

    // Sensitive file access
    /cat\s+\/etc\/(passwd|shadow|sudoers)/i,
    />\s*\/etc\/(passwd|shadow|sudoers)/i,
    /echo\s+.*>>\s*\/etc\/(passwd|shadow|sudoers)/i,

    // Network exfiltration
    /\|\s*nc\s+\S+\s+\d+/i,
    /curl\s+.*-d.*\$\(/i,
    /wget\s+.*--post-data.*\$\(/i,

    // Log manipulation
    />\s*\/var\/log\//i,
    /rm\s+\/var\/log\//i,
    /echo\s+.*>\s*~?\/?\.bash_history/i,

    // Backdoor creation
    /nc\s+.*-l.*-e/i,
    /nc\s+.*-e.*-l/i,
    /ncat\s+.*--exec/i,
    /ssh-keygen.*authorized_keys/i,

    // Crypto mining and malicious downloads
    /(wget|curl).*\.(sh|py|pl|exe|bin).*\|\s*(sh|bash|python)/i,
    /(xmrig|ccminer|cgminer|bfgminer)/i,

    // Hardware direct access
    /cat\s+\/dev\/(mem|kmem)/i,
    /echo\s+.*>\s*\/dev\/(mem|kmem)/i,

    // Kernel module manipulation
    /(insmod|rmmod|modprobe)\s+/i,

    // Cron job manipulation
    /crontab\s+-e/i,
    /echo\s+.*>>\s*\/var\/spool\/cron/i,

    // Environment variable exposure
    /env\s*\|\s*grep.*PASSWORD/i,
    /printenv.*PASSWORD/i,

    // Fork safety: NEVER push to upstream
    /git\s+push\s+upstream/i,
    /git\s+push\s+.*upstream/i,
    /gh\s+.*--repo\s+(?!flosrn\/)\w+\//i, // Dangerous repo targeting (except flosrn/)
    /git\s+remote\s+set-url\s+origin.*upstream/i, // Switching origin to upstream
  ],

  // Paths that should never be written to
  PROTECTED_PATHS: [
    "/etc/",
    "/usr/bin/",
    "/usr/sbin/",
    "/usr/lib/",
    "/sbin/",
    "/boot/",
    "/sys/",
    "/proc/",
    "/dev/",
    "/root/",
  ],
};

// Allowlist of safe commands (when used appropriately)
const SAFE_COMMANDS = [
  "ls",
  "dir",
  "pwd",
  "whoami",
  "date",
  "echo",
  "cat",
  "head",
  "tail",
  "grep",
  "find",
  "wc",
  "sort",
  "uniq",
  "cut",
  "awk",
  "sed",
  "git",
  "npm",
  "pnpm",
  "node",
  "bun",
  "python",
  "pip",
  "cd",
  "cp",
  "mv",
  "mkdir",
  "touch",
  "ln",
];

class CommandValidator {
  constructor() {
    this.logFile = "/Users/flo/.claude/logs/security.log";
  }

  /**
   * Fork safety validation
   */
  validateForkSafety(command) {
    const violations = [];
    
    // Check for upstream push attempts
    if (/git\s+push\s+upstream/i.test(command)) {
      violations.push("CRITICAL: Attempting to push to upstream remote");
    }
    
    if (/git\s+push\s+.*upstream/i.test(command)) {
      violations.push("CRITICAL: Attempting to push to upstream remote");
    }
    
    // Check for dangerous repo targeting in gh commands
    if (/gh\s+.*--repo\s+\w+\//i.test(command) && !/--repo\s+flosrn\//i.test(command)) {
      violations.push("WARNING: Using --repo flag with non-fork repository");
    }
    
    // Check for origin remote manipulation
    if (/git\s+remote\s+set-url\s+origin.*upstream/i.test(command)) {
      violations.push("CRITICAL: Attempting to change origin to upstream");
    }
    
    return violations;
  }

  /**
   * Supabase production safety validation
   */
  validateSupabaseCommand(command) {
    const violations = [];
    
    // Skip if not a Supabase command
    if (!/supabase\s+/i.test(command) && !/DELETE|DROP|TRUNCATE|ALTER/i.test(command)) {
      return violations;
    }
    
    // Detect production environment
    const isProduction = 
      // Project ref explicite (production - 20+ chars alphanumeric)
      /--project-ref\s+[a-z0-9]{20,}/i.test(command) ||
      // Variable d'env pointant vers prod (pas local)
      (process.env.SUPABASE_PROJECT_REF && !process.env.SUPABASE_PROJECT_REF.includes('local')) ||
      // URL de production
      /--db-url\s+.*\.supabase\.co/i.test(command) ||
      // Commandes avec --remote
      /--remote/i.test(command) ||
      // Supabase CLI sans --local (par défaut = remote)
      (/supabase\s+(db|functions|projects|secrets)/i.test(command) && !/--local/i.test(command));

    // Production-specific dangerous operations
    if (isProduction) {
      // Database reset
      if (/supabase\s+db\s+reset/i.test(command)) {
        violations.push("CRITICAL: Tentative de reset de la base de données en production");
      }
      
      // Project deletion
      if (/supabase\s+projects\s+delete/i.test(command)) {
        violations.push("CRITICAL: Tentative de suppression du projet Supabase en production");
      }
      
      // Function deletion
      if (/supabase\s+functions\s+delete/i.test(command)) {
        violations.push("HIGH: Tentative de suppression de fonction en production");
      }
      
      // Branch deletion
      if (/supabase\s+db\s+branch\s+delete/i.test(command)) {
        violations.push("HIGH: Tentative de suppression de branche DB en production");
      }
      
      // Secrets modification with production keywords
      if (/supabase\s+secrets\s+set/i.test(command) && /prod|production|live/i.test(command)) {
        violations.push("HIGH: Modification de secrets de production détectée");
      }
      
      // Direct SQL dangerous operations
      if (/DELETE\s+FROM/i.test(command) && !/WHERE/i.test(command)) {
        violations.push("CRITICAL: DELETE sans clause WHERE en production");
      }
      
      if (/DROP\s+(TABLE|DATABASE|SCHEMA)/i.test(command)) {
        violations.push("CRITICAL: Opération DROP détectée en production");
      }
      
      if (/TRUNCATE\s+TABLE/i.test(command)) {
        violations.push("CRITICAL: TRUNCATE TABLE détecté en production");
      }
      
      if (/ALTER\s+TABLE\s+.*DROP\s+COLUMN/i.test(command)) {
        violations.push("HIGH: Suppression de colonne détectée en production");
      }
    }
    
    return violations;
  }

  /**
   * Main validation function
   */
  validate(command, toolName = "Unknown") {
    const result = {
      isValid: true,
      severity: "LOW",
      violations: [],
      sanitizedCommand: command,
    };
    
    // Fork safety checks first
    const forkViolations = this.validateForkSafety(command);
    if (forkViolations.length > 0) {
      result.isValid = false;
      result.severity = "CRITICAL";
      result.violations.push(...forkViolations);
    }

    // Supabase production safety checks
    const supabaseViolations = this.validateSupabaseCommand(command);
    if (supabaseViolations.length > 0) {
      result.isValid = false;
      // Set severity based on violation type
      const hasCritical = supabaseViolations.some(v => v.startsWith("CRITICAL"));
      if (hasCritical || result.severity === "CRITICAL") {
        result.severity = "CRITICAL";
      } else {
        result.severity = "HIGH";
      }
      result.violations.push(...supabaseViolations);
    }

    if (!command || typeof command !== "string") {
      result.isValid = false;
      result.violations.push("Invalid command format");
      return result;
    }

    // Normalize command for analysis
    const normalizedCmd = command.trim().toLowerCase();
    const cmdParts = normalizedCmd.split(/\s+/);
    const mainCommand = cmdParts[0];

    // Check against critical commands
    if (SECURITY_RULES.CRITICAL_COMMANDS.includes(mainCommand)) {
      result.isValid = false;
      result.severity = "CRITICAL";
      result.violations.push(`Critical dangerous command: ${mainCommand}`);
    }

    // Check privilege escalation commands
    if (SECURITY_RULES.PRIVILEGE_COMMANDS.includes(mainCommand)) {
      // Allow chmod for Claude directories (scripts and hooks)
      if (mainCommand === "chmod" && (command.includes("/.claude/scripts/") || command.includes("/.claude/hooks/"))) {
        // Allow chmod for Claude scripts and hooks
      } else {
        result.isValid = false;
        result.severity = "HIGH";
        result.violations.push(`Privilege escalation command: ${mainCommand}`);
      }
    }

    // Check network commands
    if (SECURITY_RULES.NETWORK_COMMANDS.includes(mainCommand)) {
      result.isValid = false;
      result.severity = "HIGH";
      result.violations.push(`Network/remote access command: ${mainCommand}`);
    }

    // Check system commands
    if (SECURITY_RULES.SYSTEM_COMMANDS.includes(mainCommand)) {
      result.isValid = false;
      result.severity = "HIGH";
      result.violations.push(`System manipulation command: ${mainCommand}`);
    }

    // Check dangerous patterns
    for (const pattern of SECURITY_RULES.DANGEROUS_PATTERNS) {
      if (pattern.test(command)) {
        result.isValid = false;
        result.severity = "CRITICAL";
        result.violations.push(`Dangerous pattern detected: ${pattern.source}`);
      }
    }

    // Check for protected path access (but allow common redirections like /dev/null)
    for (const path of SECURITY_RULES.PROTECTED_PATHS) {
      if (command.includes(path)) {
        // Allow common safe redirections
        if (
          path === "/dev/" &&
          (command.includes("/dev/null") ||
            command.includes("/dev/stderr") ||
            command.includes("/dev/stdout"))
        ) {
          continue;
        }
        // Allow project-specific /bin/ directories (not system /bin/)
        if ((path === "/usr/bin/" || path === "/usr/sbin/") && !command.includes("/usr/")) {
          continue;
        }
        result.isValid = false;
        result.severity = "HIGH";
        result.violations.push(`Access to protected path: ${path}`);
      }
    }

    // Git-specific safety checks
    if (command.includes('git push') && !command.includes('origin')) {
      // If git push without explicit remote, warn about potential upstream push
      result.violations.push("WARNING: git push without explicit origin remote");
      if (result.severity === "LOW") result.severity = "MEDIUM";
    }

    // Additional safety checks
    // Increased limit to 10000 for long gh pr create commands with detailed descriptions
    if (command.length > 10000) {
      result.isValid = false;
      result.severity = "MEDIUM";
      result.violations.push("Command too long (potential buffer overflow)");
    }

    // Check for binary/encoded content (but allow UTF-8 characters for internationalization)
    // Only block actual control characters and null bytes
    if (/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/.test(command)) {
      result.isValid = false;
      result.severity = "HIGH";
      result.violations.push("Binary or control characters detected");
    }

    return result;
  }

  /**
   * Log security events
   */
  async logSecurityEvent(command, toolName, result, sessionId = null) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      sessionId,
      toolName,
      command: command.substring(0, 500), // Truncate for logs
      blocked: !result.isValid,
      severity: result.severity,
      violations: result.violations,
      source: "claude-code-hook",
    };

    try {
      // Write to log file
      const logLine = JSON.stringify(logEntry) + "\n";
      await Bun.write(this.logFile, logLine, { createPath: true, flag: "a" });

      // Also output to stderr for immediate visibility
      console.error(
        `[SECURITY] ${
          result.isValid ? "ALLOWED" : "BLOCKED"
        }: ${command.substring(0, 100)}`
      );
    } catch (error) {
      console.error("Failed to write security log:", error);
    }
  }

  /**
   * Check if command matches any allowed patterns from settings
   */
  isExplicitlyAllowed(command, allowedPatterns = []) {
    for (const pattern of allowedPatterns) {
      // Convert Claude Code permission pattern to regex
      // e.g., "Bash(git *)" becomes /^git\s+.*$/
      if (pattern.startsWith("Bash(") && pattern.endsWith(")")) {
        const cmdPattern = pattern.slice(5, -1); // Remove "Bash(" and ")"
        const regex = new RegExp(
          "^" + cmdPattern.replace(/\*/g, ".*") + "$",
          "i"
        );
        if (regex.test(command)) {
          return true;
        }
      }
    }
    return false;
  }
}

/**
 * Main execution function
 */
async function main() {
  const validator = new CommandValidator();

  try {
    // Read hook input from stdin
    const stdin = process.stdin;
    const chunks = [];

    for await (const chunk of stdin) {
      chunks.push(chunk);
    }

    const input = Buffer.concat(chunks).toString();

    if (!input.trim()) {
      console.error("No input received from stdin");
      process.exit(1);
    }

    // Parse Claude Code hook JSON format
    let hookData;
    try {
      hookData = JSON.parse(input);
    } catch (error) {
      console.error("Invalid JSON input:", error.message);
      process.exit(1);
    }

    const toolName = hookData.tool_name || "Unknown";
    const toolInput = hookData.tool_input || {};
    const sessionId = hookData.session_id || null;

    // Only validate Bash commands for now
    if (toolName !== "Bash") {
      console.log(`Skipping validation for tool: ${toolName}`);
      process.exit(0);
    }

    const command = toolInput.command;
    if (!command) {
      console.error("No command found in tool input");
      process.exit(1);
    }

    // Validate the command
    const result = validator.validate(command, toolName);

    // Log the security event
    await validator.logSecurityEvent(command, toolName, result, sessionId);

    // Output result and exit with appropriate code
    if (result.isValid) {
      console.log("Command validation passed");
      process.exit(0); // Allow execution
    } else {
      console.error(
        `Command validation failed: ${result.violations.join(", ")}`
      );
      console.error(`Severity: ${result.severity}`);
      process.exit(2); // Block execution (Claude Code requires exit code 2)
    }
  } catch (error) {
    console.error("Validation script error:", error);
    // Fail safe - block execution on any script error
    process.exit(2);
  }
}

// Execute main function
main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(2);
});
