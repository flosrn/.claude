#!/bin/bash
# Affiche l'état de synchronisation customCommands ↔ Skills d'un bot
# Usage: ssh vps 'bash -s' < vps-telegram-sync.sh [bot]
# Produit un rapport JSON lisible par Claude Code qui décide des actions
set -euo pipefail

BOT="${1:-gapibot}"
CONFIG="/root/.openclaw/openclaw.json"

python3 << 'PYEOF'
import os, sys, json

BOT = sys.argv[1] if len(sys.argv) > 1 else "gapibot"
CONFIG = "/root/.openclaw/openclaw.json"

with open(CONFIG) as f:
    cfg = json.load(f)

tg = cfg.get("channels", {}).get("telegram", {})
account = tg.get("accounts", {}).get(BOT)
if not account:
    print(json.dumps({"error": f"Compte '{BOT}' non trouvé"}))
    sys.exit(1)

# Workspace du bot
if BOT in ("default", "main"):
    workspace_dir = "/root/.openclaw/workspace"
else:
    workspace_dir = f"/root/.openclaw/workspace-{BOT}"

skills_dir = os.path.join(workspace_dir, "skills")
if not os.path.isdir(skills_dir):
    print(json.dumps({"error": f"Répertoire skills non trouvé : {skills_dir}"}))
    sys.exit(1)

# Lire les skills
skills = {}
for name in sorted(os.listdir(skills_dir)):
    skill_md = os.path.join(skills_dir, name, "SKILL.md")
    if not os.path.isfile(skill_md):
        continue
    with open(skill_md) as f:
        content = f.read()
    if not content.startswith("---"):
        continue
    try:
        end = content.index("---", 3)
    except ValueError:
        continue
    frontmatter = content[3:end]
    desc = ""
    in_desc = False
    desc_lines = []
    for line in frontmatter.split("\n"):
        stripped = line.strip()
        if stripped.startswith("description:"):
            val = stripped.split(":", 1)[1].strip()
            if val.startswith('"') or val.startswith("'"):
                desc = val.strip("\"'")
                break
            elif val.startswith(">") or val.startswith("|"):
                in_desc = True
                continue
            else:
                desc = val
                break
        elif in_desc:
            if stripped and not stripped.endswith(":"):
                desc_lines.append(stripped)
            else:
                break
    if desc_lines and not desc:
        desc = " ".join(desc_lines)
    skills[name] = desc

# Lire les customCommands
commands = {c["command"]: c["description"] for c in account.get("customCommands", [])}

# Match direct uniquement (skill_name avec - → _)
matched = {}
for skill_name in skills:
    cmd = skill_name.replace("-", "_")
    if cmd in commands:
        matched[cmd] = skill_name

report = {
    "bot": BOT,
    "workspace": skills_dir,
    "skills": skills,
    "commands": commands,
    "matched": matched,
    "unmatched_skills": [s for s in skills if s not in matched.values()],
    "unmatched_commands": [c for c in commands if c not in matched],
}

print(json.dumps(report, indent=2, ensure_ascii=False))
PYEOF
