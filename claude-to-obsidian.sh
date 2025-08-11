#!/bin/bash
exit 0  # Script désactivé

# Raycast Script Command Template
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Claude → Obsidian (Simple)
# @raycast.mode compact
# @raycast.packageName Claude Code
#
# Optional parameters:
# @raycast.icon 📝
# @raycast.description Copy Claude Code output to new Obsidian note

# Récupère le contenu du clipboard
clipboard_content=$(pbpaste)

# Méthode 1: Si c'est un fichier avec codes ANSI, convertir via AHA
if echo "$clipboard_content" | od -c | grep -q '033'; then
    # ANSI → HTML → Markdown avec pandoc
    content=$(echo "$clipboard_content" | aha --no-header | pandoc -f html -t markdown --wrap=none 2>/dev/null || echo "$clipboard_content")
else
    # Texte brut classique
    content="$clipboard_content"
fi

# Supprime les espaces en début de chaque ligne
content=$(echo "$content" | sed 's/^[[:space:]]*//')

# Timestamp pour le nom du fichier
timestamp=$(date +"%Y%m%d_%H%M%S")
filename="Claude_${timestamp}"

# Chemin vers ton vault Obsidian
vault_path="/Users/flo/Obsidian Vault/00_Capture"

# Crée le dossier s'il n'existe pas
mkdir -p "$vault_path"

# Crée la note avec le contenu
cat > "${vault_path}/${filename}.md" << EOF
# Claude Code Output

${content}

---
Created: $(date)
Tags: #claude-code
EOF

# Ouvre dans Obsidian
open "obsidian://open?vault=Obsidian%20Vault&file=00_Capture/${filename}"

echo "✅ Note créée: ${filename}.md"
echo ""
echo "💡 Astuce : Pour du markdown parfait, demande à Claude :"
echo "   'Écris ta réponse précédente dans /tmp/claude_output.md'"