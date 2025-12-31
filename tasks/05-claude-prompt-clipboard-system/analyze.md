# Task: Claude Prompt Clipboard System

## Quick Summary (TL;DR)

**Objectif:** Créer une commande `/copy-prompt` qui extrait le dernier message Claude en markdown propre et offre un choix via popup : "Copier" ou "Éditer dans Zed".

**Key files to modify:**
- `~/.claude/commands/copy-prompt.md` - Nouvelle slash command (à créer)
- `~/.claude/scripts/copy-prompt-action.ts` - Script d'action avec popup (à créer)

**Patterns to follow:**
- Pattern slash command: `~/.claude/commands/new-session-prompt.md`
- Pattern hook avec stdin: `~/.claude/scripts/hook-stop.ts:19-23`
- Pattern osascript dialog: recherche web

**Dependencies:** Aucun bloquant - osascript et pbcopy sont natifs macOS

**Estimation:** ~4 tasks, ~1h total

---

## User Clarifications

- **Q:** Quel éditeur préfères-tu pour modifier le prompt une fois extrait ?
  **A:** Zed

- **Q:** Comment veux-tu déclencher cette action ?
  **A:** Commande /copy-prompt (slash command dans Claude Code)

- **Q:** Que veux-tu faire du prompt extrait principalement ?
  **A:** Choix via popup : soit "juste copier coller", soit "éditer dans Zed"

---

## Codebase Context

### Script Raycast Existant (trouvé)

**Emplacement:** `/Users/flo/Library/Application Support/Code - Insiders/User/History/384257d3/RFfW.sh`

```bash
#!/bin/bash
# @raycast.title Claude → Obsidian
# @raycast.mode compact
# @raycast.description Copy Claude Code output to new Obsidian note

content=$(pbpaste)
timestamp=$(date +"%Y%m%d_%H%M%S")
vault_path="/Users/flo/Obsidian Vault/00_Capture"
mkdir -p "$vault_path"

cat > "${vault_path}/${filename}.md" << EOF
# Claude Code Output
${content}
---
Created: $(date)
Tags: #claude-code
EOF

open "obsidian://open?vault=Obsidian%20Vault&file=00_Capture/${filename}"
```

**Problème identifié:** Le script utilise `pbpaste` qui récupère le clipboard actuel - pas le dernier message Claude directement. Il faut copier manuellement depuis le terminal.

### Exemple de Fichier Généré

**Fichier:** `/Users/flo/Obsidian Vault/00_Capture/claude_code-nextjs-gapila_20251229_153048.md`

Format YAML frontmatter + markdown structuré avec :
- `title`, `date`, `tags`, `project`, `model`
- Sections: Objectif, Problème, Vision, Solutions, Contexte technique, Tâches suggérées

### Système Claude Code Existant

**Structure `~/.claude/`:**
```
~/.claude/
├── commands/           # Slash commands (.md files)
│   ├── new-session-prompt.md  # Exemple de commande
│   └── apex/                  # Sous-commandes
├── scripts/            # Scripts hooks (.ts files)
│   ├── hook-stop.ts           # Hook fin de session
│   ├── hook-session-start.ts  # Hook début
│   └── hook-apex-clipboard.ts # Hook clipboard APEX
├── settings.json       # Config hooks + plugins
└── history.jsonl       # Historique messages user
```

### Hooks Disponibles

| Hook | Trigger | Input JSON |
|------|---------|------------|
| `SessionStart` | startup/resume/clear | `{session_id, cwd, source}` |
| `PostToolUse` | après Edit/Write/etc | `{tool_input, tool_response}` |
| `Stop` | fin de session | `{session_id, transcript_path, cwd}` |

**Important:** Le hook `Stop` reçoit `transcript_path` qui pointe vers le fichier de conversation complet !

### Pattern Slash Command

**Exemple `new-session-prompt.md`:**
```markdown
---
description: Generate a structured prompt for a new Claude Code session
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion
argument-hint: [feature-description]
---

[Instructions pour Claude...]

User: $ARGUMENTS
```

---

## Documentation Insights

### osascript Dialogs (macOS natif)

```bash
# Dialog avec boutons
result=$(osascript -e 'button returned of (display dialog "Choisir:" buttons {"Copier", "Éditer"} default button 1)')

# Avec timeout
osascript -e 'display dialog "Message" giving up after 5'

# Input texte
osascript -e 'text returned of (display dialog "Entrez:" default answer "")'
```

### pbcopy (Clipboard macOS)

```bash
# Copier du texte
echo "contenu" | pbcopy

# Copier un fichier
cat /path/to/file.md | pbcopy
```

### Ouvrir dans Zed

```bash
# Ouvrir un fichier
zed /path/to/file.md

# Ouvrir et attendre fermeture
zed --wait /path/to/file.md
```

---

## Research Findings

### Solutions Popup macOS

| Solution | Avantages | Inconvénients |
|----------|-----------|---------------|
| **osascript** | Natif, zéro install | Interface basique |
| **swiftDialog** | UI moderne | Requires install |
| **Hammerspoon** | Très puissant | Courbe apprentissage |

**Recommandation:** osascript pour simplicité et rapidité

### Approche Recommandée

1. **Slash command `/copy-prompt`** demande à Claude de formater le prompt
2. **Claude écrit le prompt** dans un fichier temporaire `/tmp/prompt-<timestamp>.md`
3. **Script TypeScript** lit le fichier, affiche popup osascript
4. **Selon choix:**
   - "Copier" → `pbcopy`
   - "Éditer" → `zed /tmp/prompt-<timestamp>.md`

---

## Key Files

- `~/.claude/commands/new-session-prompt.md` - Pattern slash command existant
- `~/.claude/scripts/hook-stop.ts:19-23` - Interface StopHookInput avec transcript_path
- `~/.claude/scripts/hook-apex-clipboard.ts` - Pattern clipboard existant
- `~/.claude/settings.json` - Configuration hooks

---

## Patterns to Follow

### Slash Command Pattern

```markdown
---
description: [Description courte]
allowed-tools: [Tools autorisés]
argument-hint: [Hint optionnel]
---

[Instructions détaillées]

User: $ARGUMENTS
```

### Script TypeScript avec Bun

```typescript
#!/usr/bin/env bun
import { $ } from "bun";

async function main() {
  // Lire stdin si hook, sinon args
  const content = process.argv[2] || await Bun.stdin.text();

  // Action...
}

main().catch(console.error);
```

### osascript Dialog

```typescript
async function showDialog(message: string, buttons: string[]): Promise<string> {
  const { stdout } = await $`osascript -e 'button returned of (display dialog "${message}" buttons {"${buttons.join('","')}"} default button 1)'`;
  return stdout.trim();
}
```

---

## Dependencies

- **macOS natif:** osascript, pbcopy (✓ présents)
- **Bun:** Pour scripts TypeScript (✓ installé)
- **Zed:** Éditeur cible (✓ installé)
- **Claude Code hooks:** Système existant (✓ configuré)

---

## Architecture Proposée

```
┌─────────────────────────────────────────────────────────┐
│                    Workflow                              │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  1. User tape "/copy-prompt" dans Claude Code           │
│                    ↓                                     │
│  2. Claude lit les instructions de la commande          │
│                    ↓                                     │
│  3. Claude génère le prompt formaté                     │
│                    ↓                                     │
│  4. Claude écrit dans /tmp/claude-prompt-<ts>.md        │
│                    ↓                                     │
│  5. Claude exécute le script d'action                   │
│                    ↓                                     │
│  6. Script affiche popup osascript                      │
│        ┌──────────┴──────────┐                          │
│        ↓                     ↓                          │
│   "📋 Copier"          "✏️ Éditer"                      │
│        ↓                     ↓                          │
│   pbcopy ← file         zed file                        │
│        ↓                     ↓                          │
│   "✅ Copié!"           Zed s'ouvre                     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Constraints

### Must Do
- Extraire le dernier message Claude en markdown propre (sans formatage terminal)
- Afficher popup avec choix "Copier" / "Éditer"
- Copier dans clipboard OU ouvrir dans Zed selon choix
- Fonctionner via slash command `/copy-prompt`

### Must Avoid
- Ne PAS utiliser le clipboard actuel (comme le script Raycast)
- Ne PAS dépendre de Raycast
- Ne PAS installer de dépendances lourdes (swiftDialog, Hammerspoon)
- Ne PAS modifier les hooks existants (hook-stop.ts)

---

## Technical Decisions

1. **Approche slash command** plutôt que hook automatique
   - *Raison:* L'utilisateur veut déclencher manuellement, pas à chaque fin de session

2. **osascript** plutôt que swiftDialog
   - *Raison:* Natif macOS, zéro installation, suffisant pour 2 boutons

3. **Fichier temporaire** plutôt que pipe direct
   - *Raison:* Permet d'éditer le fichier si choix "Éditer"

4. **Script TypeScript séparé** plutôt que bash inline
   - *Raison:* Plus maintenable, réutilisable, typé

---

## Recommended First Steps

1. Créer `~/.claude/commands/copy-prompt.md` (slash command)
2. Créer `~/.claude/scripts/copy-prompt-action.ts` (script popup)
3. Tester la commande `/copy-prompt`
4. Itérer sur le format de sortie

---

## Files to Read First

- `~/.claude/commands/new-session-prompt.md` - Pattern de slash command à suivre
- `~/.claude/scripts/hook-apex-clipboard.ts` - Pattern d'interaction clipboard

---

## Additional Notes

### Limitation Connue

Le dernier message Claude n'est **pas persisté** dans `history.jsonl` (qui ne contient que les messages user). Il faudra donc que Claude **génère** le prompt au moment de la commande, plutôt que de le récupérer d'un historique.

### Alternative Future

Si besoin d'accéder au vrai transcript de la session en cours, il faudrait :
1. Créer un hook `PostToolUse` qui sauvegarde chaque réponse
2. OU utiliser le `transcript_path` du hook `Stop` (mais seulement en fin de session)

Pour l'instant, la slash command qui demande à Claude de générer le prompt est la solution la plus simple et fonctionnelle.
