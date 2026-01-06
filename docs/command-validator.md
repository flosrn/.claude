# Command Validator - Complete Documentation

> A security validation package that intercepts bash commands before execution to prevent dangerous operations.

## Overview

The Command Validator is a **PreToolUse hook** that validates every bash command Claude attempts to run. It acts as a security gate, blocking dangerous commands while allowing safe operations.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    COMMAND VALIDATOR FLOW                                    │
└─────────────────────────────────────────────────────────────────────────────┘

    Claude wants to run            Validator checks             Decision
    ─────────────────              ────────────────             ────────
┌────────────────────┐         ┌─────────────────────┐     ┌─────────────────┐
│ Bash: rm -rf /tmp  │    →    │ 1. Check base cmd   │  →  │ ✅ ALLOWED      │
│                    │         │ 2. Check patterns   │     │ Safe rm path    │
└────────────────────┘         │ 3. Check paths      │     └─────────────────┘
                               └─────────────────────┘

┌────────────────────┐         ┌─────────────────────┐     ┌─────────────────┐
│ Bash: rm -rf /     │    →    │ 1. Check base cmd   │  →  │ ⚠️ ASK USER     │
│                    │         │ 2. PATTERN MATCH:   │     │ Dangerous!      │
└────────────────────┘         │    "rm -rf /"       │     │ Confirm?        │
                               └─────────────────────┘     └─────────────────┘
```

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Comprehensive rules** | 80+ patterns covering system destruction, privilege escalation, network attacks |
| **Smart path handling** | Blocks `/etc/`, `/usr/`, etc. but allows safe paths like `~/Developer/`, `/tmp/` |
| **Chain validation** | Validates chained commands (`&&`, `||`, `;`) individually |
| **Severity levels** | CRITICAL, HIGH, MEDIUM severity for prioritized blocking |
| **Security logging** | All events logged for audit |
| **User confirmation** | Dangerous commands can proceed with explicit approval |

---

## Security Rules Categories

### 1. Critical Commands (ALWAYS BLOCKED)

Commands that can cause immediate, irreversible system damage:

| Command | Purpose | Why Blocked |
|---------|---------|-------------|
| `del` | Windows delete | System destruction |
| `format` | Disk format | Data loss |
| `mkfs` | Make filesystem | Data loss |
| `shred` | Secure delete | Data destruction |
| `dd` | Disk dump | Can overwrite disks |
| `fdisk` | Partition editor | System corruption |
| `parted` | Partition manager | System corruption |
| `gparted` | GUI partition | System corruption |
| `cfdisk` | Curses fdisk | System corruption |

### 2. Privilege Escalation Commands

Commands that modify permissions or elevate privileges:

| Command | Purpose | Why Blocked |
|---------|---------|-------------|
| `sudo` | Superuser do | Privilege escalation |
| `su` | Switch user | Privilege escalation |
| `passwd` | Change password | Credential modification |
| `chpasswd` | Batch password | Credential modification |
| `usermod` | Modify user | Permission changes |
| `chmod` | Change mode | Permission changes |
| `chown` | Change owner | Permission changes |
| `chgrp` | Change group | Permission changes |
| `setuid` | Set user ID | Privilege escalation |
| `setgid` | Set group ID | Privilege escalation |

### 3. Network Commands

Commands that could be used for network attacks or reconnaissance:

| Command | Purpose | Why Blocked |
|---------|---------|-------------|
| `nc` / `netcat` | Network utility | Data exfiltration |
| `nmap` | Port scanner | Network reconnaissance |
| `telnet` | Remote access | Insecure protocol |
| `ssh-keygen` | Key generation | Credential creation |
| `iptables` | Firewall rules | Network manipulation |
| `ufw` | Ubuntu firewall | Network manipulation |
| `firewall-cmd` | Firewalld | Network manipulation |
| `ipfw` | macOS firewall | Network manipulation |

### 4. System Commands

Commands that manipulate system services or processes:

| Command | Purpose | Why Blocked |
|---------|---------|-------------|
| `systemctl` | Service manager | System state changes |
| `service` | Init scripts | System state changes |
| `kill` | Terminate process | Process termination |
| `killall` | Kill by name | Mass process termination |
| `pkill` | Pattern kill | Mass process termination |
| `mount` | Mount filesystem | System modification |
| `umount` | Unmount filesystem | System modification |
| `swapon` | Enable swap | System modification |
| `swapoff` | Disable swap | System modification |

---

## Dangerous Patterns

The validator uses regex patterns to detect dangerous command constructions:

### File System Destruction

```regex
/rm\s+.*-rf\s*\/\s*$/i           # rm -rf /
/rm\s+.*-rf\s*\/etc/i            # rm -rf /etc
/rm\s+.*-rf\s*\/usr/i            # rm -rf /usr
/rm\s+.*-rf\s*\/bin/i            # rm -rf /bin
/rm\s+.*-rf\s*\.\.+\//i          # rm -rf ../../../
/rm\s+.*-rf\s*\$\w+/i            # rm -rf $VARIABLE (variable expansion)
```

### Fork Bombs & Infinite Loops

```regex
/:\(\)\{\s*:\|:&\s*\};:/         # :(){ :|:& };:
/while\s+true\s*;\s*do.*done/i   # while true; do ...; done
/for\s*\(\(\s*;\s*;\s*\)\)/i     # for ((;;))
```

### Remote Code Execution

```regex
/(wget|curl)\s+.*\|\s*(sh|bash)/i          # curl ... | bash
/(wget|curl)\s+.*-O-.*\|\s*(sh|bash)/i     # wget -O- ... | bash
/\|\s*(sh|bash|zsh|fish)$/i                # ... | sh
```

### Credential Access

```regex
/cat\s+\/etc\/(passwd|shadow|sudoers)/i    # cat /etc/passwd
/>\s*\/etc\/(passwd|shadow|sudoers)/i      # > /etc/shadow
/env\s*\|\s*grep.*PASSWORD/i               # env | grep PASSWORD
/printenv.*PASSWORD/i                       # printenv PASSWORD
```

### Backdoor Installation

```regex
/nc\s+.*-l.*-e/i                 # nc -l -e (reverse shell)
/ncat\s+.*--exec/i               # ncat --exec
/ssh-keygen.*authorized_keys/i   # Adding SSH keys
```

### Log Manipulation

```regex
/>\s*\/var\/log\//i              # > /var/log/...
/rm\s+\/var\/log\//i             # rm /var/log/...
/echo\s+.*>\s*~?\/?\.bash_history/i  # Clearing history
```

### Git Operations (Require Approval)

```regex
/git\s+commit/i                              # git commit (needs review)
/git\s+push\s+(--force|-f)/i                 # git push --force
/git\s+push\s+.*\b(main|master|production)\b/i  # push to protected branches
```

### Docker Destructive Operations

```regex
/docker\s+system\s+prune.*-a/i   # docker system prune -a
/docker\s+container\s+prune.*-f/i # docker container prune -f
/docker\s+(rm|rmi|kill|stop)\s+.*\$\(/i  # docker rm $(...)
```

---

## Protected Paths

These system directories are protected from writes:

| Path | Contains |
|------|----------|
| `/etc/` | System configuration |
| `/usr/` | User programs |
| `/sbin/` | System binaries |
| `/boot/` | Boot files |
| `/sys/` | Kernel interface |
| `/proc/` | Process information |
| `/dev/` | Device files |
| `/root/` | Root home |

---

## Safe Paths for `rm -rf`

These paths allow `rm -rf` without blocking:

| Path | Reason |
|------|--------|
| `~/Developer/` | Development directories |
| `/tmp/` | Temporary files |
| `/var/tmp/` | Persistent temp |
| `$(pwd)/` | Current working directory |

**Example**:
- `rm -rf /tmp/cache` → ✅ Allowed
- `rm -rf /etc/hosts` → ❌ Blocked

---

## Safe Commands (Always Allowed)

```
ls, dir, pwd, whoami, date, echo, cat, head, tail, grep, find, wc, sort,
uniq, cut, awk, sed, git, npm, pnpm, node, bun, python, pip, source, cd,
cp, mv, mkdir, touch, ln, psql, mysql, sqlite3, mongo
```

---

## How Blocking Works

When a dangerous command is detected, the validator returns a **permission decision** to Claude Code:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "⚠️  Potentially dangerous command detected!\n\nCommand: rm -rf /\nViolations: Dangerous rm pattern\nSeverity: CRITICAL\n\nDo you want to proceed with this command?"
  }
}
```

**User options**:
1. **Approve** - Command executes
2. **Deny** - Command blocked
3. **Modify** - Rewrite the command

---

## Security Logging

All command executions are logged to `~/.claude/scripts/command-validator/data/security.log`:

```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "sessionId": "abc123",
  "toolName": "Bash",
  "command": "rm -rf /tmp/cache",
  "blocked": false,
  "severity": "safe",
  "violations": [],
  "source": "claude-code-hook"
}
```

**Logged information**:
- Timestamp (ISO 8601)
- Session ID (for correlation)
- Tool name (always "Bash")
- Command (truncated to 500 chars)
- Blocked status
- Severity level
- Violations detected

---

## Architecture

```
~/.claude/scripts/command-validator/
├── src/
│   ├── cli.ts                 # Hook entry point
│   ├── lib/
│   │   ├── types.ts           # TypeScript interfaces
│   │   ├── security-rules.ts  # All security rules
│   │   └── validator.ts       # Core validation logic
│   └── __tests__/
│       └── validator.test.ts  # 82+ test cases
├── data/
│   └── security.log           # Security events (gitignored)
├── package.json
└── README.md
```

### Key Files

| File | Purpose |
|------|---------|
| `cli.ts` | Hook entry point, handles stdin/stdout |
| `security-rules.ts` | Database of all security rules |
| `validator.ts` | Core `CommandValidator` class |
| `validator.test.ts` | Comprehensive test suite |

---

## Configuration

### Hook Registration

In `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bun ~/.claude/scripts/command-validator/src/cli.ts"
          }
        ]
      }
    ]
  }
}
```

---

## Programmatic Usage

The validator can be used as a library:

```typescript
import { CommandValidator } from "./src/lib/validator";

const validator = new CommandValidator();
const result = validator.validate("rm -rf /");

if (!result.isValid) {
  console.log(`Blocked: ${result.violations.join(", ")}`);
  console.log(`Severity: ${result.severity}`);
}
```

### Result Interface

```typescript
interface ValidationResult {
  isValid: boolean;
  violations: string[];
  severity: "safe" | "MEDIUM" | "HIGH" | "CRITICAL";
}
```

---

## Command Chain Handling

The validator splits chained commands and validates each:

```bash
# Input
ls && rm -rf / && echo "done"

# Validated as:
# 1. ls          → ✅ Safe
# 2. rm -rf /    → ❌ Dangerous pattern
# 3. echo "done" → ✅ Safe

# Result: ❌ Blocked (any dangerous = blocked)
```

---

## Testing

The validator includes 82+ tests covering:

### Safe Commands (Must Allow)
- Standard utilities: `ls`, `git`, `npm`, `pnpm`, `node`, `python`
- File operations: `cat`, `cp`, `mv`, `mkdir`, `touch`
- Safe command chains with `&&`

### Dangerous Commands (Must Block)
- System destruction: `rm -rf /`, `dd`, `mkfs`, `fdisk`
- Privilege escalation: `sudo`, `chmod`, `chown`, `passwd`
- Network attacks: `nc`, `nmap`, `telnet`
- Malicious patterns: fork bombs, backdoors, log manipulation
- Sensitive file access: `/etc/passwd`, `/etc/shadow`, `/etc/sudoers`

### Special Cases
- rm -rf safety: Allows deletions in safe paths
- Protected paths: Blocks operations on system directories
- Binary content detection
- Command length limits

**Run tests**:
```bash
cd ~/.claude/scripts/command-validator
bun test
```

---

## Severity Levels

| Severity | Meaning | Example |
|----------|---------|---------|
| `safe` | Command is allowed | `ls -la` |
| `MEDIUM` | Some caution needed | `git commit` |
| `HIGH` | Potentially dangerous | `chmod 777` |
| `CRITICAL` | System-threatening | `rm -rf /` |

---

## Troubleshooting

### "No command found in tool input"

**Cause**: Hook received malformed input
**Solution**: Check Claude Code version, ensure Bash tool is being used correctly

### Commands blocked unexpectedly

**Cause**: Pattern matching is aggressive by design
**Solution**: Use more specific paths, avoid variable expansion in dangerous contexts

### Security log not writing

**Cause**: `data/` directory doesn't exist or permissions issue
**Solution**: `mkdir -p ~/.claude/scripts/command-validator/data`

---

## Best Practices

1. **Trust the validator** - It exists to prevent accidents
2. **Use specific paths** - `/tmp/myproject/cache` vs `/tmp/*`
3. **Avoid variable expansion in rm** - `rm -rf $DIR` is blocked for safety
4. **Review approval prompts carefully** - Don't blindly approve dangerous commands
5. **Check security logs** - Audit what's being blocked and why
