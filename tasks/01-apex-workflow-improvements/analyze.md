# Task: Amélioration du workflow APEX

## Résumé Exécutif

Après analyse de l'écosystème Claude Code existant et recherche des best practices, voici les améliorations **réellement pertinentes** pour le workflow APEX. Focus sur l'impact utilisateur, pas sur la complexité technique.

---

## État Actuel du Workflow APEX

### Commandes existantes
| Commande | Rôle | Force | Faiblesse |
|----------|------|-------|-----------|
| `/apex:1-analyze` | Exploration + création dossier | Lance agents en parallèle | Output parfois verbeux |
| `/apex:2-plan` | Création du plan.md | Bon template | Pas de validation auto |
| `/apex:5-tasks` | Division en task-XX.md | Génère index.md + deps | ✓ Bien conçu |
| `/apex:3-execute` | Exécution (séq. ou //) | Support parallèle récent | UX peu claire |
| `/apex:4-examine` | Validation finale | Agents Snipper en // | ✓ Solide |

### Hooks existants utilisables
- `SessionStart` : Injection context git au démarrage
- `PostToolUse` : Hook sur Edit/Write (typecheck)
- `Stop` : Son de fin (succès/échec)

### Agents existants réutilisables
- `Snipper` : Édition rapide (model: haiku, mode: acceptEdits)
- `explore-codebase` : Recherche patterns/fichiers
- `explore-docs` : Documentation Context7
- `websearch` : Recherche web

---

## Améliorations Recommandées

### Priorité Haute (Impact fort, Effort faible)

#### 1. Mode `--background` pour `/apex:1-analyze` (Claude Code 2.0.60+)

**Problème** : Pendant que les agents d'exploration (codebase, docs, web) tournent, Claude Code ET l'utilisateur sont bloqués en attente des résultats.

**Solution** : Utiliser les nouveaux background agents pour lancer l'exploration de façon asynchrone

```bash
/apex:1-analyze "Add OAuth authentication" --background
```

**Comportement** :
```
Claude: Je lance l'exploration en background (3 agents).

        Pendant ce temps, quelques questions pour affiner :
        1. OAuth avec quels providers ? (Google, GitHub, autres?)
        2. Tu veux du refresh token automatique ?
        3. Il y a déjà une base d'auth existante à étendre ?

User: Google et GitHub, oui refresh, et oui y'a du JWT existant

Claude: Noté ! Les agents viennent de terminer.
        J'intègre tes précisions au résumé...

        [Génère analyze.md avec le contexte enrichi]
```

**Avantages clés** :
- Claude peut poser des questions de clarification pendant l'exploration
- L'utilisateur peut affiner les requirements en temps réel
- Le temps d'attente devient du temps productif
- Les réponses utilisateur enrichissent l'analyse finale

**Implémentation** : Ajouter `run_in_background: true` aux Task calls des agents

**Effort** : ~15 lignes dans `1-analyze.md`

---

#### 2. Mode `--background` pour `/apex:4-examine`

**Problème** : La validation complète (build + lint + typecheck + fix) peut prendre plusieurs minutes sur un gros projet.

**Solution** : Lancer la validation en background

```bash
/apex:4-examine feature-name --background
```

**Comportement** :
```
Claude: Validation lancée en background.
        Tu peux continuer à travailler.

        Utilise `/tasks` pour voir le statut.
        Je te notifierai quand c'est terminé.

[Plus tard...]

Claude: ✅ Validation terminée !
        - Build: ✓
        - Typecheck: ✓
        - Lint: ✓ (3 warnings auto-fixés)

        implementation.md mis à jour.
```

**Limite connue** : Les agents background ne peuvent PAS écrire de fichiers (Issue #14521).
- **Workaround** : La phase de fix (agents Snipper) reste en foreground, seule l'analyse/diagnostic passe en background.

**Effort** : ~15 lignes dans `4-examine.md`

---

#### 3. Quick Summary en début d'analyze.md

**Problème** : L'output des agents est souvent trop verbeux, difficile à scanner.

**Solution** : Ajouter une section "Quick Summary" en début d'analyze.md

```markdown
## Quick Summary (TL;DR)

**Fichiers clés à modifier** :
- `src/auth/middleware.ts` - Ajouter validation JWT
- `src/routes/api.ts` - Protéger les routes

**Patterns à suivre** :
- Pattern auth existant dans `src/api/auth.ts:45`

**Dépendances** : Aucune bloquante

**Estimation** : 3-4 tâches, ~2h total
```

**Effort** : Modifier le template dans `1-analyze.md` (+10 lignes)

---

#### 4. Mode `--dry-run` pour `/apex:3-execute`

**Problème** : Impossible de prévisualiser ce que l'exécution va faire avant de lancer.

**Solution** : Argument `--dry-run` qui affiche les actions sans les exécuter

```bash
/apex:3-execute feature-name --dry-run
# Output:
# Would execute Task 3: Add JWT middleware
# - Read: src/auth/middleware.ts
# - Edit: src/auth/middleware.ts (add validateToken function)
# - Edit: src/routes/api.ts (add middleware to routes)
# Run without --dry-run to execute
```

**Effort** : Ajouter condition dans `3-execute.md` (~20 lignes)

---

#### 5. Progress dashboard après chaque task

**Problème** : Après exécution d'une tâche, on ne voit pas facilement où on en est.

**Solution** : Ajouter un mini-dashboard en fin de `/apex:3-execute`

```
══════════════════════════════════════════════════
PROGRESS: 3/6 tasks completed (50%)
══════════════════════════════════════════════════
✓ Task 1: Setup base structure
✓ Task 2: Add data models
✓ Task 3: Create API endpoints ← JUST COMPLETED
○ Task 4: Add validation
○ Task 5: Write tests
○ Task 6: Update docs

Next: /apex:3-execute feature-name 4
══════════════════════════════════════════════════
```

**Effort** : Parser index.md et formatter output (~15 lignes)

---

### Priorité Moyenne (Impact moyen, Effort faible)

#### 6. Commande raccourcie `/apex:next`

**Problème** : Taper `/apex:3-execute folder-name` à chaque fois est verbeux.

**Solution** : Créer un alias `/apex:next` qui :
1. Détecte le dernier dossier APEX utilisé
2. Lance la prochaine tâche incomplete automatiquement

```bash
/apex:next
# Équivalent à: /apex:3-execute 01-apex-workflow-improvements
```

**Effort** : Nouveau fichier `commands/apex/next.md` (~30 lignes)

---

#### 7. Améliorer la détection auto des tâches parallélisables

**Problème** : Le flag `--parallel` nécessite que `index.md` ait la notation `[Task X ‖ Task Y]`

**Solution** : Détecter automatiquement les tâches sans dépendances mutuelles

```markdown
# Dans 3-execute.md, section auto-detect:

Si --parallel sans notation explicite:
1. Lire le tableau des dépendances dans index.md
2. Identifier les tâches incompletes dont TOUTES les deps sont complètes
3. Si plusieurs tâches éligibles → proposer exécution parallèle
```

**Effort** : Améliorer la logique de parsing dans `3-execute.md` (~25 lignes)

---

#### 8. Validation rapide post-task (`--quick`)

**Problème** : `/apex:4-examine` est lourd pour une validation rapide après une seule tâche.

**Solution** : Option `--quick` dans `3-execute` qui run juste typecheck+lint à la fin

```bash
/apex:3-execute feature-name 3 --quick
# Exécute la tâche PUIS run: pnpm typecheck && pnpm lint
# Si erreurs: les affiche et demande si continuer
```

**Effort** : Ajouter étape conditionnelle dans `3-execute.md` (~15 lignes)

---

### Priorité Basse (Nice-to-have)

#### 9. Hook pour notifier fin de tâche longue

**Problème** : Les tâches parallèles peuvent prendre du temps, pas de notification.

**Solution** : Utiliser le hook `Stop` existant ou ajouter notification système

```typescript
// Dans settings.json, le hook Stop existe déjà avec afplay
// Alternative: notification macOS
"Stop": [{
  "hooks": [{
    "type": "command",
    "command": "osascript -e 'display notification \"APEX task completed\" with title \"Claude Code\"'"
  }]
}]
```

**Effort** : Modifier `settings.json` (3 lignes) ou réutiliser hook existant

---

#### 10. Template de commit message dans implementation.md

**Problème** : Après avoir terminé toutes les tâches, on doit rédiger le commit message.

**Solution** : Générer automatiquement un draft de commit dans implementation.md

```markdown
## Suggested Commit

```
feat: [Feature name from task folder]

- [Change 1 from session log]
- [Change 2 from session log]

Implements: #issue-number (if applicable)
```
```

**Effort** : Ajouter template dans `3-execute.md` section UPDATE IMPLEMENTATION (~10 lignes)

---

#### 11. Créer l'agent `apex-executor`

**Problème** : Actuellement, `/apex:3-execute` en mode parallèle utilise l'agent **Snipper** qui est inadapté :
- Snipper utilise **Haiku** (modèle rapide mais limité)
- Snipper est conçu pour des **éditions rapides**, pas des tâches complètes
- Snipper ne peut pas run bash (pas de typecheck/tests)

**Solution** : Créer un agent dédié `apex-executor` avec les bonnes caractéristiques

```yaml
# agents/apex-executor.md
name: apex-executor
model: sonnet  # Modèle capable pour tâches complexes
permissionMode: acceptEdits
```

**Responsabilités** :
1. Lire le fichier task-XX.md
2. Implémenter la tâche complètement
3. Run typecheck/lint après modifications
4. Mettre à jour index.md (marquer tâche complète)
5. Mettre à jour implementation.md (ajouter session log)
6. Rapporter le résultat

**Utilisé par** :
- `/apex:next` - Exécution de la prochaine tâche
- `/apex:3-execute` en mode parallèle - Remplace Snipper

**Effort** : `agents/apex-executor.md` (~80 lignes)

---

#### 12. `/apex:next` comme commande

**Problème** : Taper `/apex:3-execute folder-name` à chaque fois est verbeux.

**Solution** : Créer `/apex:next` qui lance `apex-executor` dans un contexte isolé

```bash
/apex:next
# 1. Trouve le dernier dossier APEX utilisé
# 2. Lance l'agent apex-executor
# 3. L'agent exécute la prochaine tâche incomplete
# 4. Rapporte le résultat au contexte principal
```

**Avantages** :
- Contexte frais et focalisé (200k tokens dédiés)
- Main context reste propre pour l'interaction
- Commande courte et intuitive

**Effort** : `commands/apex/next.md` (~25 lignes)

---

#### 13. Mettre à jour `/apex:3-execute` pour utiliser `apex-executor`

**Problème** : Le mode parallèle utilise actuellement Snipper (inadapté).

**Solution** : Modifier la section "PARALLEL EXECUTION" pour utiliser `apex-executor`

```markdown
# Dans 3-execute.md, section Step 2:
- subagent_type: "apex-executor"  # au lieu de "Snipper"
```

**Impact** :
- Exécution parallèle plus robuste
- Chaque tâche a accès à un modèle capable (Sonnet)
- Validation intégrée (typecheck/lint)

**Effort** : Modification mineure dans `3-execute.md` (~5 lignes)

---

#### 14. Nouvelle commande `/apex:status`

**Problème** : Pour voir l'état d'avancement, il faut lire manuellement index.md et implementation.md.

**Solution** : Commande légère qui lance un agent pour générer un résumé visuel

```bash
/apex:status
# ou
/apex:status 01-apex-workflow-improvements
```

**Output** :
```
📊 Status: 01-apex-workflow-improvements
├── analyze.md ✓ (10 améliorations identifiées)
├── plan.md ✗ (not created)
├── tasks/
│   └── (not created yet)
└── Progress: Phase 1 - Analysis complete

📋 Next steps:
   /apex:2-plan 01-apex-workflow-improvements
```

**Avantages** :
- Vue d'ensemble instantanée sans polluer le contexte
- L'agent lit tous les fichiers et synthétise
- Utile pour reprendre une tâche après pause

**Effort** : Nouveau fichier `commands/apex/status.md` (~35 lignes)

---

## Améliorations Rejetées (Over-engineering)

| Idée | Pourquoi rejetée |
|------|------------------|
| Système de checkpoints persistants | Trop complexe, implementation.md suffit |
| DAG automatique des dépendances | Le tableau manuel dans index.md fonctionne bien |
| Recovery automatique sur erreur | Claude demande déjà à l'utilisateur |
| Multi-session orchestration | Overkill, une session = une tâche |
| Métriques de performance | Pas de valeur ajoutée réelle |
| Base de données de patterns | CLAUDE.md + analyze.md suffisent |
| Agent dédié par tâche séquentielle | Overhead, perte de contexte entre tâches, doit relire les fichiers modifiés |

---

## Intégration avec l'Écosystème Existant

### Ce qui existe et fonctionne déjà bien
- **Hooks** : SessionStart pour context git, Stop pour son de fin
- **Agents** : Snipper pour édition rapide, explore-* pour recherche
- **TodoWrite** : Tracking natif des étapes
- **index.md** : Tracking des tâches complétées

### Ce qu'on peut réutiliser sans modification
- Le hook `PostToolUse` pour typecheck automatique après éditions
- L'agent `Snipper` (haiku, acceptEdits) pour les tâches parallèles
- Le hook `Stop` pour notification de fin

---

## Plan d'Implémentation Suggéré

### Phase 1 : Agent apex-executor + Fondations (1h)
11. **Créer `apex-executor`** - Agent central pour exécution de tâches (PRIORITAIRE)
13. Mettre à jour `3-execute.md` pour utiliser `apex-executor` au lieu de Snipper

### Phase 2 : Background Agents + Quick Wins (45 min)
1. Mode `--background` pour `1-analyze.md`
2. Mode `--background` pour `4-examine.md`
3. Quick Summary template dans `1-analyze.md`
4. Progress dashboard dans `3-execute.md`

### Phase 3 : UX Improvements (1h)
5. Mode `--dry-run` dans `3-execute.md`
12. Créer `/apex:next` (utilise apex-executor)
7. Améliorer auto-détection parallèle
8. Ajouter `--quick` validation option

### Phase 4 : Nouvelles commandes + Polish (30 min)
14. `/apex:status` - nouvelle commande de statut
9. Notification système pour background tasks
10. Template commit message

---

## Fichiers à Modifier

| Fichier | Modifications |
|---------|---------------|
| `agents/apex-executor.md` | **NOUVEAU** - Agent Sonnet pour exécution de tâches APEX (remplace Snipper) |
| `commands/apex/1-analyze.md` | `--background` mode, Quick Summary template |
| `commands/apex/3-execute.md` | Progress dashboard, `--dry-run`, `--quick`, commit template, auto-detect parallèle, **utiliser apex-executor** |
| `commands/apex/4-examine.md` | `--background` mode (garde Snipper pour les fixes simples) |
| `commands/apex/next.md` | **NOUVEAU** - Commande qui lance apex-executor |
| `commands/apex/status.md` | **NOUVEAU** - Vue d'ensemble du dossier task |

---

## Conclusion

**14 améliorations proposées**, réparties en 4 catégories :

1. **Agent apex-executor** : Remplace Snipper (Haiku) par un agent Sonnet capable d'exécuter des tâches complexes avec validation intégrée. C'est la fondation des autres améliorations.

2. **Background agents** (Claude Code 2.0.60+) : Permettent à Claude de continuer à travailler (poser des questions, affiner les specs) pendant que l'exploration ou la validation tourne en arrière-plan.

3. **Visibilité** : Progress dashboard, Quick Summary, et `/apex:status` permettent de savoir où on en est en un coup d'œil.

4. **Réduction de friction** : `/apex:next`, `--dry-run`, `--quick` réduisent la verbosité et les étapes manuelles.

**Distinction importante** :
- **apex-executor** (Sonnet) → Tâches complexes (implémentation, tests)
- **Snipper** (Haiku) → Reste pour `/apex:4-examine` (fixes simples)

**Note** : La limite actuelle des background agents (pas d'écriture de fichiers) empêche leur usage pour `/apex:3-execute`, mais c'est parfait pour les phases de lecture/analyse.

**Prochaine étape** : `/apex:2-plan 01-apex-workflow-improvements` pour créer le plan d'implémentation détaillé.
