# Exploration: APEX YOLO Mode - Autonomous Workflow Execution

## Concept

Permettre à APEX de s'exécuter de manière entièrement autonome en vidant le contexte entre chaque phase et en démarrant automatiquement la phase suivante.

```
/apex:1-analyze my-feature --yolo
    ↓ (analyse complète)
    ↓ (contexte vidé automatiquement)
/apex:2-plan my-feature --yolo
    ↓ (plan créé)
    ↓ (contexte vidé automatiquement)
/apex:5-tasks my-feature --yolo
    ↓ (tâches générées)
    ↓ (contexte vidé automatiquement)
/apex:3-execute my-feature 1
    ↓ ... et ainsi de suite
```

## Faisabilité: ✅ POSSIBLE

Après exploration, voici les mécanismes disponibles :

### Mécanisme 1: AppleScript Keystrokes (RECOMMANDÉ)

**Comment ça marche:**
1. Le hook Stop détecte qu'une phase APEX YOLO s'est terminée
2. Lance un processus background qui attend que Claude exit
3. Envoie des frappes clavier via AppleScript :
   - `/clear` + Enter (vide le contexte)
   - Cmd+V + Enter (colle et exécute la commande suivante)

**Avantages:**
- ✅ Reste interactif (l'utilisateur voit tout)
- ✅ Fonctionne avec la session Claude existante
- ✅ Pas de dépendance externe (macOS natif)

**Inconvénients:**
- ⚠️ Nécessite que le terminal reste au premier plan
- ⚠️ Timing sensible (délais fixes)
- ⚠️ macOS seulement

### Mécanisme 2: claude -p Headless (Alternative)

```bash
# Le Stop hook pourrait lancer:
claude -p "$(pbpaste)" --allowedTools "Edit,Write,Read,Bash,Glob,Grep"
```

**Avantages:**
- ✅ Plus fiable (pas de keystrokes)
- ✅ Fonctionne même si terminal pas au premier plan

**Inconvénients:**
- ❌ Perd l'interactivité visuelle
- ❌ L'utilisateur ne voit pas ce qui se passe
- ❌ Moins de contrôle

---

## Architecture Proposée

### Flux de données

```
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  1. COMMANDE APEX                                                    │
│     /apex:1-analyze folder --yolo                                    │
│                    │                                                 │
│                    ▼                                                 │
│  2. APEX COMMAND (commands/apex/1-analyze.md)                        │
│     - Détecte --yolo dans les arguments                              │
│     - Crée flag: .claude/tasks/folder/.yolo                          │
│     - Exécute l'analyse normalement                                  │
│                    │                                                 │
│                    ▼                                                 │
│  3. APEX CLIPBOARD HOOK (PostToolUse)                                │
│     - Détecte écriture de analyze.md                                 │
│     - Copie /apex:2-plan folder dans clipboard                       │
│     - Vérifie si .yolo flag existe                                   │
│     - Si oui: crée /tmp/.apex-yolo-continue avec nextCommand         │
│                    │                                                 │
│                    ▼                                                 │
│  4. STOP HOOK                                                        │
│     - Vérifie si /tmp/.apex-yolo-continue existe                     │
│     - Si oui: lance apex-yolo-continue.ts en background              │
│                    │                                                 │
│                    ▼                                                 │
│  5. CLAUDE SE TERMINE                                                │
│                    │                                                 │
│                    ▼                                                 │
│  6. BACKGROUND PROCESS (après 1.5s)                                  │
│     - Envoie /clear + Enter                                          │
│     - Attend 0.8s                                                    │
│     - Envoie Cmd+V + Enter                                           │
│                    │                                                 │
│                    ▼                                                 │
│  7. NOUVELLE SESSION CLAUDE                                          │
│     - /apex:2-plan folder --yolo s'exécute                           │
│     - Le cycle recommence...                                         │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Fichiers à modifier/créer

| Fichier | Action | Description |
|---------|--------|-------------|
| `commands/apex/*.md` | MODIFIER | Ajouter détection --yolo, créer flag |
| `scripts/hook-apex-clipboard.ts` | MODIFIER | Détecter .yolo flag, créer YOLO continue |
| `scripts/apex-yolo-continue.ts` | CRÉER | Script d'automatisation terminal |
| `scripts/hook-stop.ts` | MODIFIER | Appeler apex-yolo-continue si flag présent |
| `settings.json` | OK | Pas de modification nécessaire |

---

## Détails d'implémentation

### 1. Modification des commandes APEX

Chaque commande APEX doit :

```markdown
## Workflow

1. **PARSE ARGUMENTS**: Detect --yolo flag
   - Check if argument contains `--yolo`
   - If yes: Create flag file `.claude/tasks/<folder>/.yolo`
   - Store original --yolo flag for next phase

2. [... reste du workflow normal ...]

13. **YOLO MODE**: Propagate flag to next command
    - If .yolo flag exists, append --yolo to clipboard command
```

### 2. Modification de hook-apex-clipboard.ts

```typescript
// After copying to clipboard...

// Check for YOLO mode
const yoloFlagPath = filePath.replace(/(analyze|plan|tasks\/index)\.md$/, '.yolo');
const yoloFlag = Bun.file(yoloFlagPath);

if (await yoloFlag.exists()) {
  // Create YOLO continue flag for Stop hook
  const yoloData = {
    nextCommand: command + " --yolo",  // Propagate --yolo
    folder,
    phase: getNextPhase(phase),
  };
  await Bun.write("/tmp/.apex-yolo-continue", JSON.stringify(yoloData));
}
```

### 3. Modification de hook-stop.ts

```typescript
// At the end of main(), before playing sound:

// Check for YOLO mode continuation
const yoloContinue = Bun.file("/tmp/.apex-yolo-continue");
if (await yoloContinue.exists()) {
  // Launch YOLO continue script in background
  Bun.spawn(["bun", "/Users/flo/.claude/scripts/apex-yolo-continue.ts"], {
    stdout: "inherit",
    stderr: "inherit",
    stdin: await Bun.stdin.text(),
  });
}
```

### 4. Script apex-yolo-continue.ts

Déjà créé ! Il :
1. Lit le flag YOLO
2. Le supprime
3. Lance un processus background qui attend et envoie les keystrokes

---

## Gestion des conditions d'arrêt

### Quand YOLO doit s'arrêter automatiquement :

1. **Après /apex:3-execute** - Ne pas continuer automatiquement car :
   - L'exécution peut nécessiter intervention humaine
   - Chaque tâche peut avoir des erreurs à corriger

2. **Si une erreur se produit** - Le hook Stop détecte les erreurs via tool-usage.log

3. **Si l'utilisateur interrompt** - Ctrl+C supprime le flag YOLO

### Propagation du flag --yolo

| Phase | Commande copiée | Continue YOLO? |
|-------|-----------------|----------------|
| analyze → plan | `/apex:2-plan folder --yolo` | ✅ Oui |
| plan → tasks (complexe) | `/apex:5-tasks folder --yolo` | ✅ Oui |
| plan → execute (simple) | `/apex:3-execute folder` | ❌ Non (fin auto) |
| tasks → execute | `/apex:3-execute folder 1` | ❌ Non (fin auto) |

---

## Risques et Mitigations

| Risque | Probabilité | Mitigation |
|--------|-------------|------------|
| Terminal pas au premier plan | Moyenne | Message d'avertissement + timeout |
| Timing trop court/long | Faible | Délais configurables |
| Boucle infinie | Très faible | Flag supprimé immédiatement |
| Perte de contrôle | Moyenne | Ctrl+C interrompt tout |
| Erreurs non détectées | Faible | Intégration avec hook-stop erreurs |

---

## Test Manuel Préalable

Avant d'implémenter, tester si l'automatisation terminal fonctionne :

```bash
# 1. Rendre le script de test exécutable
chmod +x ~/.claude/scripts/test-terminal-automation.sh

# 2. Exécuter le test (garder le terminal au premier plan!)
~/.claude/scripts/test-terminal-automation.sh

# 3. Si "YOLO_TEST_SUCCESS" s'affiche, l'automatisation fonctionne!
```

---

## Estimation

| Tâche | Temps estimé |
|-------|--------------|
| Modifier commandes APEX (×5) | 30 min |
| Modifier hook-apex-clipboard.ts | 20 min |
| Créer apex-yolo-continue.ts | ✅ Fait |
| Modifier hook-stop.ts | 15 min |
| Tests et debug | 30 min |
| **Total** | ~1h30 |

---

## Alternative: Mode Semi-Automatique

Si l'automatisation complète est trop risquée, on pourrait avoir un mode intermédiaire :

```
/apex:1-analyze folder --yolo

[Phase terminée]
📋 Copied: /apex:2-plan folder --yolo
🔄 YOLO Mode: Press Enter to continue, or Ctrl+C to stop

[L'utilisateur appuie sur Enter]
→ /clear s'exécute
→ Commande collée et exécutée
```

Cela donnerait un contrôle manuel tout en simplifiant le workflow.

---

## Décision

**Recommandation: Implémenter le mode YOLO complet** avec les safeguards suivants :

1. ✅ Message clair avant chaque transition
2. ✅ Délai de 2s pour permettre Ctrl+C
3. ✅ Arrêt automatique après /apex:3-execute (première tâche)
4. ✅ Arrêt si erreurs détectées

Veux-tu que je procède à l'implémentation complète ?
