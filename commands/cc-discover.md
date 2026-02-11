# CC-Discover - Claude Code Features Inventory

Explore and inventory all available features in this Claude Code setup.

**Mode**: {{mode}} (empty = normal, "verbose" = full details)

## Instructions

### Step 1: Explore the structure

Run this bash script to discover all features:

```bash
#!/bin/bash
CLAUDE_DIR="$HOME/.claude"

echo ""
echo "┌─────────────────────────────────────────────────────────────────┐"
echo "│              CLAUDE CODE FEATURES DISCOVERY                     │"
echo "└─────────────────────────────────────────────────────────────────┘"

# === COMMANDS ===
echo ""
echo "📁 COMMANDS"
echo "───────────────────────────────────────────────────────────────────"
CMD_COUNT=$(/usr/bin/find "$CLAUDE_DIR/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "   Total: $CMD_COUNT commands"
echo ""
/usr/bin/find "$CLAUDE_DIR/commands" -name "*.md" -type f 2>/dev/null | while read f; do
  basename "$f" .md
done | sort | xargs -n3 | while read a b c; do
  printf "   %-25s %-25s %-25s\n" "$a" "$b" "$c"
done

# === SKILLS ===
echo ""
echo "🧠 SKILLS"
echo "───────────────────────────────────────────────────────────────────"
SKILL_COUNT=$(/usr/bin/find "$CLAUDE_DIR/skills" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
echo "   Total: $SKILL_COUNT skills"
echo ""
/usr/bin/find "$CLAUDE_DIR/skills" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | while read d; do
  basename "$d"
done | sort | xargs -n3 | while read a b c; do
  printf "   %-25s %-25s %-25s\n" "$a" "$b" "$c"
done

# === PLUGINS ===
echo ""
echo "🔌 PLUGINS"
echo "───────────────────────────────────────────────────────────────────"
PLUGIN_COUNT=$(/usr/bin/find "$CLAUDE_DIR/plugins" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
echo "   Total: $PLUGIN_COUNT plugins"
echo ""
if [ "$PLUGIN_COUNT" -gt 0 ]; then
  /usr/bin/find "$CLAUDE_DIR/plugins" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | while read d; do
    basename "$d"
  done | sort | xargs -n3 | while read a b c; do
    printf "   %-25s %-25s %-25s\n" "$a" "$b" "$c"
  done
else
  echo "   (none)"
fi

# === HOOKS ===
echo ""
echo "🪝 HOOKS"
echo "───────────────────────────────────────────────────────────────────"
HOOK_COUNT=$(/usr/bin/find "$CLAUDE_DIR/scripts" -name "hook-*.ts" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "   Total: $HOOK_COUNT hooks"
echo ""
/usr/bin/find "$CLAUDE_DIR/scripts" -name "hook-*.ts" -type f 2>/dev/null | while read f; do
  basename "$f" .ts | sed 's/^hook-//'
done | sort | xargs -n3 | while read a b c; do
  printf "   %-25s %-25s %-25s\n" "$a" "$b" "$c"
done

# === AGENTS ===
echo ""
echo "🤖 AGENTS"
echo "───────────────────────────────────────────────────────────────────"
echo "   Built-in Task subagent_type:"
echo ""
printf "   %-25s %-25s %-25s\n" "Explore" "Plan" "code-reviewer"
printf "   %-25s %-25s %-25s\n" "Snipper" "websearch" "vision-analyzer"
printf "   %-25s %-25s %-25s\n" "db-migrate" "apex-executor" "fix-grammar"

# === MCP SERVERS ===
echo ""
echo "🌐 MCP SERVERS"
echo "───────────────────────────────────────────────────────────────────"
export CWD=$(pwd)
python3 << 'PYEOF'
import json
import os

cwd = os.environ.get('CWD', os.getcwd())
proj_name = os.path.basename(cwd)

# Load config
config_path = os.path.expanduser('~/.claude.json')
data = {}
if os.path.exists(config_path):
    with open(config_path) as f:
        data = json.load(f)

# Get project-specific disabled list from projects.<path>.disabledMcpServers
project_data = data.get('projects', {}).get(cwd, {})
disabled_mcp = set(project_data.get('disabledMcpServers', []))
disabled_mcpjson = set(project_data.get('disabledMcpjsonServers', []))

def get_type(config):
    """Extract server type from config"""
    if config.get('type') == 'http' or config.get('url'):
        return 'http'
    return 'stdio'

def print_scope_box(servers, label, disabled_set):
    """Print servers in a nice box format"""
    if not servers:
        print(f"   ┌─ {label} ─────────────────────────────────────────────────")
        print(f"   │  (none)")
        print(f"   └────────────────────────────────────────────────────────────")
        return

    active = [(n, get_type(c)) for n, c in servers.items() if n not in disabled_set]
    disabled = [(n, get_type(c)) for n, c in servers.items() if n in disabled_set]

    # Header
    print(f"   ┌─ {label} ─────────────────────────────────────────────────")

    # Active servers first
    if active:
        for i in range(0, len(active), 2):
            row = active[i:i+2]
            line = "   │  " + "  ".join(f"🟢 {n} ({t})" .ljust(30) for n, t in row)
            print(line.rstrip())

    # Disabled servers
    if disabled:
        for i in range(0, len(disabled), 2):
            row = disabled[i:i+2]
            line = "   │  " + "  ".join(f"🔴 {n} ({t})".ljust(30) for n, t in row)
            print(line.rstrip())

    # Footer with counts
    print(f"   └───────────────────────────────────── {len(active)} active, {len(disabled)} disabled")

# 1. User scope: ~/.claude.json → mcpServers (available across all projects)
user_mcp = data.get('mcpServers', {})
print_scope_box(user_mcp, "User scope (all projects)", disabled_mcp)

# 2. Local scope: ~/.claude.json → projects.<path>.mcpServers (private, current project)
local_mcp = project_data.get('mcpServers', {})
print("")
print_scope_box(local_mcp, f"Local scope ({proj_name})", disabled_mcp)

# 3. Project scope: .mcp.json in project root (shared with team, version controlled)
project_mcp_path = os.path.join(cwd, '.mcp.json')
print("")
if os.path.exists(project_mcp_path):
    with open(project_mcp_path) as f:
        project_mcp_data = json.load(f)
    project_mcp = project_mcp_data.get('mcpServers', {})
    print_scope_box(project_mcp, f"Project scope (.mcp.json)", disabled_mcpjson)
else:
    print(f"   ┌─ Project scope (.mcp.json) ────────────────────────────────")
    print(f"   │  (none)")
    print(f"   └────────────────────────────────────────────────────────────")

# 4. Enterprise managed (if exists)
enterprise_paths = [
    '/Library/Application Support/ClaudeCode/managed-mcp.json',  # macOS
    '/etc/claude-code/managed-mcp.json',  # Linux
]
print("")
for ep in enterprise_paths:
    if os.path.exists(ep):
        with open(ep) as f:
            enterprise_data = json.load(f)
        enterprise_mcp = enterprise_data.get('mcpServers', {})
        print_scope_box(enterprise_mcp, "Enterprise managed", set())
        break
else:
    print(f"   ┌─ Enterprise managed ───────────────────────────────────────")
    print(f"   │  (none)")
    print(f"   └────────────────────────────────────────────────────────────")
PYEOF

echo ""
echo "└─────────────────────────────────────────────────────────────────┘"
```

### Step 2: Analyze the results

For each discovered item:

**Normal mode** (default):
- List names and types only
- Generate a summary table

**Verbose mode**:
- Read the content of each SKILL.md or README.md file
- Extract descriptions and usage examples
- For commands: read the first 10 lines of each .md
- For skills: read the full SKILL.md
- For plugins: read plugin.json and README.md

### Step 3: Generate inventory

Produce a structured table with all features:

```
| Type    | Name              | Description                    | Usage                    |
|---------|-------------------|--------------------------------|--------------------------|
| command | /cook             | Step-by-step implementation    | /cook add auth           |
| command | /debug            | Systematic debugging           | /debug error message     |
| skill   | databases         | PostgreSQL/MongoDB patterns    | Skill "databases"        |
| skill   | typescript-strict | Strict TypeScript typing       | Skill "typescript-strict"|
| agent   | code-reviewer     | PR code review                 | Task "code-reviewer"     |
| agent   | Explore           | Codebase exploration           | Task "Explore"           |
| hook    | tool-router       | Automatic tool routing         | (automatic)              |
| mcp     | chrome-devtools   | Chrome control                 | mcp__chrome-devtools__*  |
```

### Step 4: Recommendations

End with:
1. **Statistics**: Total count per type
2. **Suggestions**: Useful but underused features
3. **Common commands**: Top 5 to remember

## Notes

- This command is **read-only** (no modifications)
- Verbose mode may take longer
- Paths are relative to current project and ~/.claude/
