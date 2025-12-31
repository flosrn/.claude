# Task: Créer /apex:handoff - Transfert de contexte optimisé pour APEX

## Quick Summary (TL;DR)

**Key files to create:**
- `~/.claude/commands/apex/handoff.md` - Commande slash principale
- `~/.claude/scripts/handoff-action.ts` - Script Bun pour popup et actions

**Patterns to follow:**
- `/new-session-prompt.md` pour structure de génération de prompt
- `hook-apex-clipboard.ts:122-133` pour pattern pbcopy
- `apex-yolo-continue.ts:62-125` pour patterns osascript

**Dependencies:** Aucune bloquante

**Estimation:** ~3 tasks, ~2h total

---

## Objectif

Créer une commande `/apex:handoff` qui permet de :
1. **Capturer** le contexte de la session actuelle (connaissances acquises, fichiers explorés, décisions)
2. **Générer** un prompt optimisé pour la prochaine tâche APEX
3. **Proposer** 3 actions via popup macOS : Copier | Éditer dans Zed | Sauvegarder

## Cas d'usage principal

```
Session actuelle : /Users/flo/Code/nextjs/gapila/.claude/tasks/83-optimize-ai-campaign-creator-prompt
                   └─ Claude a appris des choses sur le codebase

/apex:handoff "Optimiser le flow de l'agent IA"

                   ↓ Claude génère un prompt enrichi ↓

┌─────────────────────────────────────────────────────────┐
│  # Nouvelle tâche : Optimiser le flow de l'agent IA     │
│                                                          │
│  ## Contexte hérité                                     │
│  - Fichiers clés : conversation-flow.md, chat-panel.tsx │
│  - Patterns découverts : InteractiveTemplateCard        │
│  - Décisions : Questions interactives > texte libre     │
│                                                          │
│  ## Prochaine étape                                     │
│  /apex:1-analyze .../conversation-flow.md               │
└─────────────────────────────────────────────────────────┘

                   ↓ Popup osascript ↓

        ┌────────────────────────────────────┐
        │ Que voulez-vous faire ?            │
        │                                    │
        │  [Copier]  [Éditer]  [Sauvegarder] │
        └────────────────────────────────────┘
```

---

## Codebase Context

### Workflow APEX Complet

Le workflow APEX suit 6 phases :

```
Phase 1: ANALYZE (/apex:1-analyze)
├─ Gather context (codebase, docs, web)
├─ Create analyze.md
└─ Flags: --background, --yolo

Phase 2: PLAN (/apex:2-plan)
├─ File-by-file implementation strategy
├─ Create plan.md
└─ Flags: --yolo

Phase 3: EXECUTE (/apex:3-execute)
├─ Task-by-task or plan mode
├─ Create/update implementation.md
└─ Flags: task numbers, --parallel, --dry-run, --quick

Phase 4: EXAMINE (/apex:4-examine)
├─ Build, lint, typecheck validation
├─ Auto-fix errors with snipper agents
└─ Flags: --background, --skip-patterns

Phase 5: TASKS (/apex:5-tasks)
├─ Divide plan into task-NN.md files
├─ Create tasks/index.md
└─ Flags: --yolo (stops for safety)

Phase 6: TEST-LIVE (/apex:test-live)
├─ Browser testing with GIF recording
├─ Update implementation.md
└─ Flags: --url, --no-gif, --parallel
```

### Commandes convenience existantes

- `/apex:next` - Exécute la prochaine tâche automatiquement
- `/apex:status` - Affiche l'état visuel des tâches

### Pattern de /new-session-prompt.md

**Workflow en 6 étapes :**
1. UNDERSTAND THE GOAL (argument ou question)
2. CAPTURE SESSION CONTEXT (ULTRA THINK)
3. STRUCTURE THE PROMPT (template markdown)
4. ASK FOR REFINEMENT
5. SAVE THE PROMPT → `.claude/session-prompts/YYYY-MM-DD-[name].md`
6. PROVIDE USAGE INSTRUCTIONS

**Template de sortie :**
```markdown
# New Session Prompt: [Feature/Task Name]

## Context
### Project Overview
### Current State
### Session Learnings

## Task
### Objective
### User Story
### Acceptance Criteria

## Technical Context
### Key Files
### Patterns to Follow
### Technical Decisions
### Dependencies & APIs

## Constraints
### Must Do
### Must Avoid

## Starting Point
### Recommended First Steps
### Files to Read First

## Additional Notes
```

---

## Documentation Insights

### osascript - Popup avec choix

**Pattern `choose from list` :**
```bash
osascript -e 'choose from list {"Copier", "Éditer", "Sauvegarder"} with title "Handoff" with prompt "Action ?"'
```

**Résultat :** Retourne `{selected_item}` ou `false` si annulé

**Pattern avec gestion d'erreur :**
```applescript
try
  set result to choose from list {"Copier", "Éditer", "Sauvegarder"} \
    with title "Claude Handoff" \
    with prompt "Que faire avec le prompt généré ?"
  if result is false then
    return "CANCEL"
  else
    return item 1 of result
  end if
on error
  return "ERROR"
end try
```

### Zed Editor CLI

```bash
zed /path/to/file              # Ouvrir fichier
zed -n /path/to/file           # Nouvelle fenêtre
zed --wait /path/to/file       # Attendre fermeture ($EDITOR)
```

### pbcopy pattern Bun

```typescript
async function copyToClipboard(text: string): Promise<boolean> {
  try {
    const proc = Bun.spawn(["pbcopy"], {
      stdin: new TextEncoder().encode(text),
    });
    const exitCode = await proc.exited;
    return exitCode === 0;
  } catch {
    return false;
  }
}
```

---

## Research Findings

### Patterns scripts existants

**hook-apex-clipboard.ts** - Référence pour clipboard :
- Lines 122-133 : Pattern pbcopy avec Bun.spawn

**apex-yolo-continue.ts** - Référence pour osascript :
- Lines 62-125 : Patterns Ghostty, iTerm, Terminal.app
- Terminal detection : tmux > ghostty > iterm > terminal

**hook-stop.ts** - Référence pour gestion de fin de session :
- Interface `StopHookInput` : `{session_id, transcript_path, cwd}`
- Pattern de lecture du transcript pour contexte

---

## Key Files

### À créer

| Fichier | Rôle |
|---------|------|
| `~/.claude/commands/apex/handoff.md` | Commande slash principale |
| `~/.claude/scripts/handoff-action.ts` | Script pour popup + actions |

### Références existantes

| Fichier | Lignes | Rôle |
|---------|--------|------|
| `commands/new-session-prompt.md` | All | Template de génération de prompt |
| `commands/apex/1-analyze.md` | All | Structure de commande APEX |
| `scripts/hook-apex-clipboard.ts` | 122-133 | Pattern pbcopy |
| `scripts/apex-yolo-continue.ts` | 62-125 | Patterns osascript terminals |
| `scripts/hook-stop.ts` | 19-24 | Interface StopHookInput |

---

## Patterns to Follow

### Structure commande APEX

```markdown
---
description: [Description courte]
allowed-tools: [Tools needed]
argument-hint: <task-folder> [next-task-description]
---

You are a [specialist role].

**You need to ULTRA THINK [about what].**

## Argument Parsing
[Parse flags et arguments]

## Workflow
### 1. [ÉTAPE]
### 2. [ÉTAPE]
...

## Execution Rules
- [Non-négociables]

## Priority
[Ce qui compte le plus]

---

User: $ARGUMENTS
```

### Pattern de sortie APEX

```
══════════════════════════════════════════════════
[SECTION TITLE]
══════════════════════════════════════════════════
├── Item 1
│   └── Details
└── Item 2
══════════════════════════════════════════════════
📋 Next Step:
   [Suggested command]
══════════════════════════════════════════════════
```

---

## Dependencies

### Système
- macOS (pour osascript, pbcopy)
- Bun runtime (pour scripts .ts)
- Zed editor (optionnel, pour action "Éditer")

### Claude Code
- TodoWrite tool (pour tracking)
- Read/Write tools
- Bash tool (pour exécuter script)

---

## Architecture Proposée

### Flux de données

```
┌─────────────────────────────────────────────────────────────────────┐
│  /apex:handoff "Optimiser le flow" [task-folder]                    │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  1. DETECT CONTEXT                                                  │
│     - Auto-detect task folder (most recent or provided)             │
│     - Read: analyze.md, plan.md, implementation.md                  │
│     - Extract: files modified, patterns discovered, decisions       │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  2. PARSE NEXT TASK                                                 │
│     - From $ARGUMENTS or AskUserQuestion                            │
│     - Validate it's a clear, actionable description                 │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  3. GENERATE HANDOFF PROMPT (ULTRA THINK)                           │
│     - Filter: only include learnings NOT in CLAUDE.md               │
│     - Structure: Context hérité → Tâche → Démarrage                 │
│     - Optimize for APEX /analyze entry point                        │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  4. WRITE TEMP FILE                                                 │
│     - /tmp/handoff-{timestamp}.md                                   │
│     - Content = prompt généré                                       │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│  5. EXECUTE ACTION SCRIPT                                           │
│     - bun ~/.claude/scripts/handoff-action.ts /tmp/handoff-xxx.md   │
│     - Script shows popup with 3 choices                             │
└─────────────────────────────────────────────────────────────────────┘
                                │
                    ┌───────────┼───────────┐
                    ▼           ▼           ▼
            ┌───────────┐ ┌───────────┐ ┌───────────────┐
            │  Copier   │ │  Éditer   │ │  Sauvegarder  │
            │           │ │           │ │               │
            │ pbcopy    │ │ zed file  │ │ Move to       │
            │ + notif   │ │           │ │ session-prompts│
            └───────────┘ └───────────┘ └───────────────┘
```

### Script handoff-action.ts

```typescript
#!/usr/bin/env bun

// Input: chemin vers fichier temp avec prompt
const filePath = process.argv[2];

// 1. Lire le contenu
const content = await Bun.file(filePath).text();

// 2. Afficher popup avec 3 choix
const choice = await showChoicePopup();

// 3. Exécuter l'action
switch (choice) {
  case "Copier":
    await copyToClipboard(content);
    await showNotification("Prompt copié !");
    break;
  case "Éditer":
    await openInZed(filePath);
    break;
  case "Sauvegarder":
    await saveToSessionPrompts(filePath, content);
    break;
}
```

---

## Template de sortie /apex:handoff

```markdown
# Nouvelle session : [Nom de la tâche]

## Contexte hérité de la session précédente

### Projet
[Nom du projet + chemin]

### Fichiers explorés (pertinents pour cette tâche)
- `path/to/file.ts:line` - [Rôle découvert]
- `path/to/other.ts` - [Pattern identifié]

### Décisions prises
- [Décision 1 et pourquoi]
- [Décision 2]

### Ce que j'ai appris
- [Insight 1 sur le codebase]
- [Insight 2 sur les patterns]

## Tâche demandée

[Description claire de ce que l'utilisateur veut accomplir]

## Démarrage recommandé

```bash
/apex:1-analyze "[description]" --yolo
```

### Fichiers à lire en premier
- `path/to/start.ts` - [Pourquoi commencer ici]
```

---

## Risques et Mitigation

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Pas de task folder détecté | Medium | Fallback sur contexte conversation courante |
| Zed pas installé | Low | Fallback message d'erreur + suggestion |
| SSH/headless (pas de popup) | Low | Fallback clipboard silencieux |

---

## Critères de Succès

- [ ] Commande `/apex:handoff "description"` fonctionne
- [ ] Auto-détection du task folder actuel
- [ ] Prompt généré inclut uniquement le contexte NON présent dans CLAUDE.md
- [ ] Popup 3 boutons fonctionne sur macOS
- [ ] Action "Copier" → clipboard
- [ ] Action "Éditer" → Zed ouvre le fichier
- [ ] Action "Sauvegarder" → fichier dans `.claude/session-prompts/`
