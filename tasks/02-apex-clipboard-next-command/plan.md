# Implementation Plan: APEX Clipboard - Next Command Auto-Copy

## Overview

Créer un hook PostToolUse **optimisé pour la performance** qui :
1. Détecte automatiquement les fichiers APEX (`analyze.md`, `plan.md`, `tasks/index.md`)
2. **Analyse intelligemment** la complexité du plan pour choisir la bonne commande
3. Copie la commande suivante dans le presse-papiers

**Stratégie** : Script TypeScript avec **early-exit ultra-rapide** (~60 lignes) :
- Exit en < 1ms pour 99% des fichiers (non-APEX)
- Logique complète seulement pour les 3 fichiers APEX

## Dependencies

- **Aucune** - Le hook est indépendant des autres hooks
- **Runtime** : Bun (déjà installé)
- **Système** : pbcopy (natif macOS)

---

## File Changes

### 1. `scripts/hook-apex-clipboard.ts` (CRÉER)

#### Performance : Early-Exit Strategy

**CRITIQUE** : Le hook se déclenche à CHAQUE Write/Edit. L'optimisation clé est de sortir **avant** de parser le JSON complet.

```
┌─────────────────────────────────────────────────────────────┐
│ FLOW OPTIMISÉ                                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Lire stdin (obligatoire)                    ~0.1ms      │
│  2. Regex sur JSON brut pour extraire file_path ~0.01ms     │
│  3. Regex APEX sur file_path                    ~0.01ms     │
│     └─→ Si non-APEX: process.exit(0)  ← FAST PATH          │
│                                                             │
│  4. [SLOW PATH - rare] Parser JSON complet      ~0.1ms      │
│  5. Analyser complexité (si plan.md)            ~0.1ms      │
│  6. pbcopy                                      ~5ms        │
│  7. Output systemMessage                        ~0.1ms      │
│                                                             │
│  TOTAL non-APEX: ~15ms (spawn Bun) + ~0.2ms = ~15ms        │
│  TOTAL APEX: ~15ms (spawn) + ~5ms (logic) = ~20ms          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Structure du Code

- **Pas d'interface HookInput complète** - On parse manuellement pour la perf

- **STEP 1 : Lecture stdin**
  - `const input = await Bun.stdin.text()`

- **STEP 2 : Fast path - extraction file_path via regex sur JSON brut**
  - Regex : `/"file_path"\s*:\s*"([^"]+)"/`
  - Si pas de match → `process.exit(0)`

- **STEP 3 : Fast path - détection APEX via regex**
  - Regex : `/\.claude\/tasks\/([^/]+)\/(analyze|plan|tasks\/index)\.md$/`
  - Capture : `folder` (groupe 1), `phase` (groupe 2)
  - Si pas de match → `process.exit(0)` (EXIT RAPIDE)

- **STEP 4 : Slow path - Parse JSON complet** (seulement si APEX)
  - `const hookData = JSON.parse(input)`
  - Extraire `tool_input.content` (pour analyse plan.md)
  - Vérifier `tool_response.success === true`

- **STEP 5 : Déterminer la commande suivante**

  **Fonction getNextCommand(phase, folder, content?)**

  | Phase | Logique | Commande |
  |-------|---------|----------|
  | `analyze` | Toujours | `/apex:2-plan <folder>` |
  | `plan` | **Intelligent** - voir ci-dessous | `/apex:5-tasks` ou `/apex:3-execute` |
  | `tasks/index` | Toujours | `/apex:3-execute <folder> 1` |

  **Logique intelligente pour plan.md** :
  - Compter les occurrences de `### \`` dans `content` (= nombre de fichiers à modifier)
  - Si `count >= 6` → `/apex:5-tasks <folder>` (complexe, décomposer)
  - Si `count < 6` → `/apex:3-execute <folder>` (simple, exécuter directement)

- **STEP 6 : Copier dans le presse-papiers**

  **Fonction copyToClipboard(text: string)**
  - Utiliser `Bun.spawn(["pbcopy"], { stdin: new TextEncoder().encode(text) })`
  - Attendre completion avec `.exited`
  - Retourner `exitCode === 0`

- **STEP 7 : Output structuré**

  ```typescript
  const output = {
    systemMessage: `📋 Copied: ${command}${reason}`,
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: "APEX next command copied to clipboard"
    }
  };
  console.log(JSON.stringify(output));
  ```

  **Message enrichi pour plan.md** :
  - Simple : `📋 Copied: /apex:3-execute folder`
  - Complexe : `📋 Copied: /apex:5-tasks folder (8 files detected)`

#### Edge Cases

| Cas | Comportement |
|-----|--------------|
| `file_path` absent | Exit silencieux (fast path) |
| Fichier non-APEX | Exit silencieux (fast path) |
| `tool_response.success === false` | Exit silencieux |
| `content` absent pour plan.md | Défaut vers `/apex:3-execute` |
| pbcopy échoue | Log erreur, ne pas bloquer |

---

### 2. `settings.json` (MODIFIER)

**Position** : Dans l'array `hooks.PostToolUse`, APRÈS le hook existant

- **Ajouter une nouvelle entrée** dans `hooks.PostToolUse[]` :

```json
{
  "matcher": "Write|Edit|MultiEdit",
  "hooks": [
    {
      "type": "command",
      "command": "bun /Users/flo/.claude/scripts/hook-apex-clipboard.ts"
    }
  ]
}
```

**Ordre d'exécution** : Le hook APEX sera exécuté APRÈS hook-post-file-enhanced
- Correct car la validation TypeScript doit se faire d'abord
- Le hook APEX ne dépend pas du résultat du hook précédent

---

## Testing Strategy

### Tests manuels

1. **Test analyze.md**
   - Créer : `.claude/tasks/test-clipboard/analyze.md`
   - Attendu : `📋 Copied: /apex:2-plan test-clipboard`
   - Vérifier : `pbpaste` = `/apex:2-plan test-clipboard`

2. **Test plan.md SIMPLE (< 6 fichiers)**
   - Contenu avec 3x `### \`path/file.ts\``
   - Attendu : `📋 Copied: /apex:3-execute test-clipboard`

3. **Test plan.md COMPLEXE (>= 6 fichiers)**
   - Contenu avec 8x `### \`path/file.ts\``
   - Attendu : `📋 Copied: /apex:5-tasks test-clipboard (8 files detected)`

4. **Test tasks/index.md**
   - Créer : `.claude/tasks/test-clipboard/tasks/index.md`
   - Attendu : `📋 Copied: /apex:3-execute test-clipboard 1`

5. **Test non-APEX file (performance)**
   - Écrire : `.claude/scripts/test.ts`
   - Attendu : Aucun message, clipboard inchangé
   - Vérifier : Hook exit en < 20ms

6. **Test échec d'écriture**
   - Simuler : `{"tool_response":{"success":false}}`
   - Attendu : Exit silencieux

### Vérification rapide CLI

```bash
# Test analyze.md
echo '{"tool_input":{"file_path":"/Users/flo/.claude/tasks/test/analyze.md","content":"# Test"},"tool_response":{"success":true}}' | bun /Users/flo/.claude/scripts/hook-apex-clipboard.ts
# → Devrait afficher JSON avec "/apex:2-plan test"

# Test plan.md simple (3 fichiers)
echo '{"tool_input":{"file_path":"/Users/flo/.claude/tasks/test/plan.md","content":"### `a.ts`\n### `b.ts`\n### `c.ts`"},"tool_response":{"success":true}}' | bun /Users/flo/.claude/scripts/hook-apex-clipboard.ts
# → Devrait afficher "/apex:3-execute test"

# Test plan.md complexe (8 fichiers)
echo '{"tool_input":{"file_path":"/Users/flo/.claude/tasks/test/plan.md","content":"### `1.ts`\n### `2.ts`\n### `3.ts`\n### `4.ts`\n### `5.ts`\n### `6.ts`\n### `7.ts`\n### `8.ts`"},"tool_response":{"success":true}}' | bun /Users/flo/.claude/scripts/hook-apex-clipboard.ts
# → Devrait afficher "/apex:5-tasks test (8 files detected)"

# Test non-APEX (fast path)
time echo '{"tool_input":{"file_path":"/Users/flo/project/src/app.ts"},"tool_response":{"success":true}}' | bun /Users/flo/.claude/scripts/hook-apex-clipboard.ts
# → Aucune sortie, temps ~15-20ms
```

---

## Documentation

**Aucune mise à jour nécessaire** - Fonctionnalité transparente et automatique.

---

## Rollout Considerations

### Performance Impact

| Scénario | Overhead | Fréquence |
|----------|----------|-----------|
| Fichier non-APEX | +15ms (spawn only) | ~99% |
| Fichier APEX | +20ms (spawn + logic) | ~1% |

**Acceptable** : 15ms est imperceptible pour l'utilisateur.

### Risques et Mitigations

| Risque | Probabilité | Mitigation |
|--------|-------------|------------|
| Hook ralentit le workflow | Très faible | Early-exit optimisé |
| Mauvais comptage de fichiers | Faible | Regex robuste `### \`` |
| pbcopy échoue | Très faible | Gérer erreur, ne pas bloquer |
| Conflits avec autres hooks | Nulle | Hook séparé, non-bloquant |

### Rollback

Supprimer l'entrée dans `settings.json` :
```json
// Supprimer ce bloc de hooks.PostToolUse[]
{
  "matcher": "Write|Edit|MultiEdit",
  "hooks": [{ "type": "command", "command": "bun .../hook-apex-clipboard.ts" }]
}
```

---

## Summary

| Fichier | Action | Lignes estimées |
|---------|--------|-----------------|
| `scripts/hook-apex-clipboard.ts` | CRÉER | ~60 lignes |
| `settings.json` | MODIFIER | +6 lignes |

**Features** :
- ✅ Auto-copy next APEX command
- ✅ Intelligent plan complexity detection
- ✅ Performance-optimized early-exit
- ✅ Rich feedback message

**Complexité** : Faible - Pattern existant à suivre
**Risque** : Très faible - Hook non-bloquant, early-exit
**Temps estimé** : ~30 minutes
