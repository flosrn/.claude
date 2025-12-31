# Task: APEX Clipboard - Copier automatiquement la prochaine commande

## Quick Summary (TL;DR)

**Deux approches possibles :**

| Approche | Fiabilité | Complexité | Maintenance |
|----------|-----------|------------|-------------|
| **Hook PostToolUse** | 100% automatique | Moyenne | Faible |
| **Instruction Markdown** | ~95% (dépend de Claude) | Faible | Très faible |

**Recommandation : Hook PostToolUse** → Fiabilité 100% garantie, détection automatique des fichiers APEX.

**Fichiers à créer/modifier :**
- `scripts/hook-apex-clipboard.ts` - Script de détection et copie (CRÉER)
- `settings.json` - Ajouter le hook PostToolUse (MODIFIER)

**Patterns à suivre :**
- Structure de `hook-post-file-enhanced.ts` pour parsing stdin
- Détection de fichier par path pattern

**Estimation :** 1 tâche, ~30min

---

## User Clarifications

- **Priorité** : Fiabilité 100% (même si code plus complexe)
- **Scope** : APEX seulement (pas extensible à d'autres workflows)

---

## Analyse Détaillée des Approches

### Approche 1 : Hook PostToolUse (RECOMMANDÉE)

#### Comment ça marche

```
┌─────────────────────────────────────────────────────────────┐
│ FLUX D'EXÉCUTION                                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Claude écrit un fichier (Edit/Write)                       │
│                    ↓                                        │
│  PostToolUse hook reçoit tool_input.file_path               │
│                    ↓                                        │
│  Script détecte si c'est un fichier APEX:                   │
│    - .claude/tasks/*/analyze.md → copie /apex:2-plan        │
│    - .claude/tasks/*/plan.md → copie /apex:5-tasks          │
│    - .claude/tasks/*/tasks/index.md → copie /apex:3-execute │
│                    ↓                                        │
│  pbcopy copie la commande dans le presse-papiers            │
│                    ↓                                        │
│  systemMessage affiche "📋 Copied: /apex:..."               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Données disponibles (stdin JSON)

```typescript
interface PostToolUseInput {
  session_id: string;
  tool_name: "Write" | "Edit" | "MultiEdit";
  tool_input: {
    file_path: string;  // ← C'est ce qu'on utilise
    content?: string;
  };
  tool_response: {
    success: boolean;
  };
  cwd: string;
}
```

#### Avantages

1. **Fiabilité 100%** - S'exécute automatiquement, pas de dépendance sur Claude
2. **Détection précise** - Regex sur le chemin du fichier
3. **Feedback immédiat** - `systemMessage` affiché à l'utilisateur
4. **Pattern existant** - `hook-post-file-enhanced.ts` montre exactement comment faire

#### Inconvénients

1. **Complexité légèrement plus élevée** - Script TypeScript à maintenir
2. **Overhead minimal** - Exécution à chaque Write/Edit (mais exit rapide si non-APEX)

#### Patterns à réutiliser de hook-post-file-enhanced.ts

```typescript
// Lecture stdin
const input = await Bun.stdin.text();
const hookData = JSON.parse(input);
const filePath = hookData.tool_input?.file_path;

// Sortie structurée
const output = {
  systemMessage: "📋 Copied: /apex:2-plan folder-name",
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: "Next APEX command copied to clipboard"
  }
};
console.log(JSON.stringify(output));
```

---

### Approche 2 : Instruction Markdown

#### Comment ça marche

Ajouter une étape dans chaque commande APEX :

```markdown
7. **COPY NEXT COMMAND**: Copy next phase command to clipboard
   - Run: `echo "/apex:2-plan <folder>" | pbcopy`
   - Display: "📋 Copied to clipboard"
```

#### Avantages

1. **Simplicité** - Juste du texte dans les fichiers markdown
2. **Pas de code** - Aucun script à maintenir

#### Inconvénients

1. **Fiabilité ~95%** - Dépend de Claude qui suit l'instruction
2. **Peut être oublié** - Si Claude est interrompu ou distrait
3. **Pas de garantie** - L'instruction est suggestive, pas impérative

---

## Analyse Technique de pbcopy

### Fiabilité

| Contexte | Fonctionne ? | Notes |
|----------|--------------|-------|
| Terminal local | ✅ Oui | 100% fiable |
| Claude Code local | ✅ Oui | Via Bash tool |
| SSH session | ❌ Non | Échec silencieux (exit code 1) |
| tmux moderne (2.6+) | ✅ Oui | Support natif |

### Best Practices

```typescript
// 1. Toujours vérifier la disponibilité
if (!await commandExists("pbcopy")) {
  return; // Pas de pbcopy = pas de copie
}

// 2. Gérer les erreurs
const result = await $`echo "${command}" | pbcopy`;
if (result.exitCode !== 0) {
  console.error("Failed to copy to clipboard");
}

// 3. UTF-8 encoding
process.env.LANG = "en_US.UTF-8";
```

---

## Logique de Détection APEX

```typescript
function detectApexFile(filePath: string): { phase: string; folder: string } | null {
  // Pattern: .claude/tasks/<folder>/analyze.md
  const analyzeMatch = filePath.match(/\.claude\/tasks\/([^/]+)\/analyze\.md$/);
  if (analyzeMatch) {
    return { phase: "analyze", folder: analyzeMatch[1] };
  }

  // Pattern: .claude/tasks/<folder>/plan.md
  const planMatch = filePath.match(/\.claude\/tasks\/([^/]+)\/plan\.md$/);
  if (planMatch) {
    return { phase: "plan", folder: planMatch[1] };
  }

  // Pattern: .claude/tasks/<folder>/tasks/index.md
  const tasksMatch = filePath.match(/\.claude\/tasks\/([^/]+)\/tasks\/index\.md$/);
  if (tasksMatch) {
    return { phase: "tasks", folder: tasksMatch[1] };
  }

  return null;
}

function getNextCommand(phase: string, folder: string): string {
  switch (phase) {
    case "analyze": return `/apex:2-plan ${folder}`;
    case "plan": return `/apex:5-tasks ${folder}`;  // ou /apex:3-execute
    case "tasks": return `/apex:3-execute ${folder} 1`;
    default: return "";
  }
}
```

---

## Key Files

### Existants à analyser

- `scripts/hook-post-file-enhanced.ts:1-200` - Pattern complet de hook PostToolUse
- `settings.json:16-24` - Configuration PostToolUse actuelle

### À créer

- `scripts/hook-apex-clipboard.ts` - Nouveau script de détection APEX

---

## Patterns to Follow

### Structure du hook (de hook-post-file-enhanced.ts)

```typescript
#!/usr/bin/env bun

// 1. Lire stdin
const input = await Bun.stdin.text();
const hookData = JSON.parse(input);

// 2. Extraire les données
const filePath = hookData.tool_input?.file_path;
const toolName = hookData.tool_name;

// 3. Vérifier si pertinent
if (!isApexFile(filePath)) {
  process.exit(0);  // Exit silencieux si non-APEX
}

// 4. Exécuter l'action
await copyToClipboard(command);

// 5. Retourner le feedback
console.log(JSON.stringify({
  systemMessage: "📋 Copied: ...",
  hookSpecificOutput: { ... }
}));
```

### Configuration settings.json

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bun /Users/flo/.claude/scripts/hook-apex-clipboard.ts"
          }
        ]
      }
    ]
  }
}
```

---

## Dependencies

- **Bun** - Déjà installé et utilisé par les autres hooks
- **pbcopy** - Natif macOS, aucune installation requise

---

## Décision Finale

### Recommandation : Hook PostToolUse

**Pourquoi ?**

1. ✅ **Fiabilité 100%** - Critère principal de l'utilisateur
2. ✅ **Pattern établi** - `hook-post-file-enhanced.ts` fournit le template exact
3. ✅ **Scope limité** - Facile de filtrer uniquement les fichiers APEX
4. ✅ **Feedback intégré** - `systemMessage` affiche la confirmation
5. ✅ **Maintenance faible** - Script simple, ~50 lignes

**Trade-off accepté :**
- Légèrement plus de code que l'approche markdown
- Mais garantie de fonctionnement à 100%

---

## Risques et Mitigations

| Risque | Probabilité | Mitigation |
|--------|-------------|------------|
| pbcopy échoue silencieusement | Faible (local uniquement) | Vérifier exit code |
| Hook ralentit le workflow | Très faible | Exit immédiat si non-APEX |
| Mauvaise détection de fichier | Faible | Tests regex exhaustifs |
| Conflits avec hooks existants | Nulle | Hook séparé, non-bloquant |

---

## Next Steps

1. `/apex:2-plan 02-apex-clipboard-next-command` - Créer le plan d'implémentation
2. Implémenter `hook-apex-clipboard.ts`
3. Modifier `settings.json` pour ajouter le hook
4. Tester avec chaque phase APEX
