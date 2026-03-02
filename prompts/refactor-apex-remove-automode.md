# Refactor APEX: Supprimer auto_mode et simplifier AskUserQuestion

<context>
Le workflow APEX (`~/.claude/skills/workflow-apex/`) est un système d'implémentation en steps progressifs.
Chaque step s'exécute dans sa propre session Claude Code, avec resume via `/apex -r {task_id}`.

Le flag `-a` (auto_mode) contrôle actuellement DEUX comportements distincts :
1. **Chaînage des steps** : tous les steps dans une seule session (jamais utilisé)
2. **Skip des AskUserQuestion** : pas de questions posées à l'utilisateur

Le chaînage de steps n'est JAMAIS utilisé — le workflow DOIT toujours être step-by-step
pour que chaque step bénéficie d'un contexte frais (200k tokens).

Les AskUserQuestion sont classés en 3 catégories :
- **A. Flagstamps** : la réponse est déjà déterminée par les flags → SUPPRIMER
- **B. Rubber-stamps** : l'utilisateur répond toujours la même chose → SUPPRIMER
- **C. Questions utiles** : réponse contextuelle → SMART DEFAULTS (auto-choisir l'option recommandée, logger le choix)

Ce refactoring supprime `-a` et rend le workflow entièrement autonome sans jamais bloquer.
</context>

<objective>
Refactorer le workflow APEX pour :
1. Supprimer complètement le flag `-a` / `auto_mode` de tous les fichiers
2. Supprimer les AskUserQuestion inutiles (catégories A et B)
3. Remplacer les AskUserQuestion utiles (catégorie C) par des smart defaults non-bloquants
4. Simplifier les session boundaries (toujours STOP, plus de condition)
5. Rendre `save_mode` toujours activé par défaut (plus besoin de `-s`)
6. Mettre à jour code-process (`~/clawd/skills/code-process/`) pour refléter les changements
</objective>

<instructions>

## Phase 1 : Lecture et compréhension

Lire ces fichiers pour comprendre l'état actuel :

```
~/.claude/skills/workflow-apex/SKILL.md
~/.claude/skills/workflow-apex/steps/step-00-init.md
~/.claude/skills/workflow-apex/scripts/session-boundary.sh
~/.claude/skills/workflow-apex/templates/00-context.md
```

## Phase 2 : SKILL.md — Point d'entrée

Modifier `~/.claude/skills/workflow-apex/SKILL.md` :

1. **Flags** : Retirer `-a`/`--auto`/`-A`/`--no-auto` des tables enable/disable
2. **Flags** : Retirer `-s`/`--save`/`-S`/`--no-save` (save_mode toujours true)
3. **Examples** : Retirer tous les exemples utilisant `-a` ou `-s`
4. **Quick start** : Supprimer la section "Autonomous mode" et ses exemples
5. **State variables** : Retirer `{auto_mode}` et `{save_mode}` de la table
6. **Workflow** : Supprimer les mentions de "auto_mode=true chains all steps"
7. **Session behavior** : Simplifier — toujours step-by-step, toujours save
8. **Execution rules** : Retirer les mentions de `auto_mode`

## Phase 3 : step-00-init.md — Initialisation

Modifier `~/.claude/skills/workflow-apex/steps/step-00-init.md` :

1. **Defaults** : Retirer `auto_mode` et mettre `save_mode: true` (toujours)
2. **Parsing** : Retirer `-a`/`-A` du flag parsing (Step 1b)
3. **Step 1c** : Supprimer la logique "Auto-enable save_mode" (toujours true)
4. **Config table** : Retirer `auto_mode` et `save_mode` du résumé
5. **Resume (Step 2b)** : Ne plus restaurer `auto_mode`/`save_mode` (pas besoin)
6. **Setup-templates call** : Retirer le paramètre `auto_mode`, adapter `save_mode` = toujours true

## Phase 4 : Session boundaries — Simplification globale

Chaque step file a une section "Session Boundary" avec deux branches :
```
IF auto_mode = true:
    → Load next step immediately (chain)

IF auto_mode = false:
    → Run session-boundary.sh
    → STOP
```

**Transformer en :**
```
→ Run session-boundary.sh
→ STOP
```

Appliquer ce pattern à TOUS les step files :
- `step-01-analyze.md`
- `step-01b-team-analyze.md`
- `step-02-plan.md`
- `step-03-execute.md`
- `step-03b-team-execute.md`
- `step-04-validate.md`
- `step-05-examine.md`
- `step-05b-team-examine.md`
- `step-06-resolve.md`
- `step-06b-team-resolve.md`
- `step-07-tests.md`
- `step-08-run-tests.md`
- `step-09-finish.md`

Pour chaque fichier :
1. Lire le fichier complet
2. Chercher toutes les occurrences de `auto_mode`
3. Supprimer les branches conditionnelles `IF auto_mode = true` / `IF auto_mode = false`
4. Garder uniquement le comportement "STOP après chaque step"
5. Retirer `auto_mode` de la table des variables disponibles
6. Retirer `save_mode` de la table des variables (toujours true, pas besoin de le tracker)

## Phase 5 : Catégorie A — Supprimer les Flagstamps

### step-00b-branch.md
Lire le fichier. Supprimer le AskUserQuestion "Create branch?".
Remplacer par : auto-créer `feat/{task_id}` directement (le flag `-b` a déjà décidé).
Le block `IF auto_mode = true` devient le seul comportement.

### step-04-validate.md
Lire le fichier. Supprimer le AskUserQuestion "What next?".
Remplacer par : détermination automatique basée sur les flags :
```
IF test_mode AND tests not completed → next = 07-tests
ELSE IF examine_mode → next = 05-examine
ELSE IF pr_mode → next = 09-finish
ELSE → workflow complete
```

### step-05-examine.md et step-05b-team-examine.md
Lire les fichiers. Supprimer le AskUserQuestion "What next after review?".
Remplacer par : toujours résoudre les findings (passer à step-06-resolve).

### step-08-run-tests.md
Lire le fichier. Supprimer le AskUserQuestion "What next after tests?".
Remplacer par : détermination automatique :
```
IF examine_mode AND examine not completed → next = 05-examine
ELSE IF pr_mode → next = 09-finish
ELSE → workflow complete
```

### step-09-finish.md
Lire le fichier. Supprimer le AskUserQuestion "Push and create PR?".
Remplacer par : push et créer la PR directement (le flag `-pr` a décidé).

## Phase 6 : Catégorie B — Supprimer les Rubber-stamps

### step-02-plan.md
Lire le fichier. Supprimer le AskUserQuestion "Approve plan?".
Le plan est automatiquement approuvé. Si le plan est mauvais, step-04 (validate)
et step-05 (examine) rattraperont.

### step-03-execute.md
Lire le fichier. Supprimer le AskUserQuestion "Looks good?" post-implémentation.
L'implémentation est automatiquement confirmée.

### step-07-tests.md
Lire le fichier. Supprimer le AskUserQuestion "Create tests?".
Les tests sont automatiquement créés (le flag `-t` a décidé).

## Phase 7 : Catégorie C — Smart Defaults

Pour chaque question utile, remplacer par :
1. Choisir automatiquement l'option recommandée
2. Logger le choix dans le fichier de step (si save_mode, ce qui est toujours le cas)

### step-02-plan.md — "Multiple approaches?"
Remplacer le AskUserQuestion par :
```
Choisir l'approche recommandée automatiquement.
Logger dans le fichier de step :
  ℹ️ Auto-selected approach: {approach_name}
  Reason: {why this approach was recommended}
```

### step-06-resolve.md et step-06b-team-resolve.md — "Resolution strategy?"
Remplacer par : auto-fix Real findings, skip Noise/Uncertain.
Logger : `ℹ️ Auto-resolution: fixing Real findings, skipping Noise/Uncertain`

### step-03-execute.md — "Blocker encountered"
Remplacer par : utiliser l'alternative recommandée automatiquement.
Logger : `ℹ️ Auto-unblocked: {description of alternative used}`

### step-08-run-tests.md — "Test fails 3x"
Remplacer par : skip le test après 3 échecs.
Logger : `⚠️ Auto-skipped test after 3 failures: {test_name} — {error_summary}`

### step-08-run-tests.md — "Services needed"
Remplacer par : tenter le démarrage automatique.
Logger : `ℹ️ Auto-started services: {service_names}`

### step-08-run-tests.md — "Config issue"
Remplacer par : tenter le fix automatique.
Logger : `ℹ️ Auto-fixed config: {description}`

## Phase 8 : Scripts et templates

### scripts/session-boundary.sh
Pas de changement structurel nécessaire — le script STOP déjà toujours.
Vérifier qu'il n'y a pas de condition `auto_mode`.

### scripts/setup-templates.sh
Retirer le paramètre `auto_mode` des arguments.
Adapter pour que `save_mode` soit implicitement true.

### templates/00-context.md
Retirer `auto_mode` et `save_mode` de la table Configuration.
Retirer `{{auto_mode}}` et `{{save_mode}}` des placeholders.

## Phase 9 : step-00b-interactive.md

Retirer l'option "Auto mode" du AskUserQuestion de configuration interactive.
Retirer l'option "Save mode" (toujours activé, pas configurable).

## Phase 10 : code-process (~/clawd/skills/code-process/)

Mettre à jour pour refléter les changements APEX :

### SKILL.md
- Retirer la règle "NEVER use -a" des critical_rules (le flag n'existe plus)
- Mettre à jour l'architecture pour refléter le nouveau comportement

### CLAUDE.md
- Retirer les mentions de `-a` et `auto mode` dans les anti-patterns
- Mettre à jour la section Critical Variables si nécessaire

### steps/step-00-init.md
- Retirer le commentaire "Important: NEVER use -a (auto mode) with apex"

### steps/step-03-launch.md
- Retirer les mentions de `-a` dans les règles et commentaires

### steps/step-04-orchestrator.md
- Retirer les mentions de `-a` dans le prompt de l'orchestrateur

## Phase 11 : Vérification finale

Après toutes les modifications :

```bash
# Vérifier qu'il ne reste aucune mention de auto_mode dans le workflow
grep -r "auto_mode" ~/.claude/skills/workflow-apex/
# Doit retourner 0 résultats

# Vérifier qu'il ne reste aucune mention de -a/--auto dans le workflow
grep -rE "\-a\b|--auto\b|--no-auto" ~/.claude/skills/workflow-apex/
# Doit retourner 0 résultats (attention aux faux positifs comme -ax dans d'autres contextes)

# Vérifier que save_mode n'est plus dans les flags/defaults (mais peut rester comme concept interne)
grep -r "save_mode.*false" ~/.claude/skills/workflow-apex/
# Doit retourner 0 résultats

# Vérifier qu'il ne reste aucun AskUserQuestion de catégorie A ou B
# Les seuls AskUserQuestion restants devraient être dans step-00b-interactive.md
grep -r "AskUserQuestion" ~/.claude/skills/workflow-apex/steps/
# Ne devrait apparaître QUE dans step-00b-interactive.md

# Vérifier code-process
grep -ri "auto.mode\|never.*-a\b" ~/clawd/skills/code-process/
# Doit retourner 0 résultats
```

</instructions>

<constraints>
- JAMAIS supprimer un fichier step — modifier les fichiers existants
- JAMAIS toucher aux steps/scripts qui ne sont pas listés
- TOUJOURS lire un fichier AVANT de le modifier
- TOUJOURS préserver les sections qui ne concernent pas auto_mode/AskUserQuestion
- TOUJOURS garder la structure YAML frontmatter de chaque step
- Les smart defaults (catégorie C) doivent LOGGER leur décision, pas juste procéder silencieusement
- Le format de log pour les smart defaults est : `ℹ️ Auto-{action}: {details}` ou `⚠️ Auto-{action}: {details}`
- NE PAS ajouter de nouveau flag (le flag `-i` interactif est prévu pour une future session)
- NE PAS modifier la logique métier des steps (analyse, plan, execute, validate, etc.)
- NE PAS modifier les scripts generate-task-id.sh ou update-state-snapshot.sh
</constraints>

<examples>

<example name="session_boundary_before_after">
**AVANT (avec auto_mode) :**
```markdown
## Session Boundary

IF auto_mode = true:
    → Run per-step git commit (if branch_mode)
    → Update progress: `bash {skill_dir}/scripts/update-progress.sh ...`
    → Update state snapshot: `bash {skill_dir}/scripts/update-state-snapshot.sh ...`
    → Load next step immediately: `./step-03-execute.md`

IF auto_mode = false:
    → Run session boundary:
    ```bash
    bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "02" "plan" \
      "{summary}" "03-execute" "Execute (Implementation)" \
      "{step_context}" "{gotcha}" "{branch_mode}" "skip"
    ```
    → STOP — session ends here
```

**APRÈS (simplifié) :**
```markdown
## Session Boundary

Run session boundary:
```bash
bash {skill_dir}/scripts/session-boundary.sh "{task_id}" "02" "plan" \
  "{summary}" "03-execute" "Execute (Implementation)" \
  "{step_context}" "{gotcha}" "{branch_mode}" "skip"
```
→ STOP — session ends here
```
</example>

<example name="flagstamp_removal">
**AVANT (step-09-finish.md) :**
```markdown
### 3. Confirm Push (if not auto_mode)

**If `{auto_mode}` = true:**
→ Skip confirmation, push directly

**If `{auto_mode}` = false:**
Use AskUserQuestion:
  - "Push and create PR (Recommended)"
  - "Push only"
  - "Review commits first"
  - "Cancel"
```

**APRÈS :**
```markdown
### 3. Push Changes

Push directly — the user chose `-pr` which implies push consent:
```bash
git push -u origin {branch_name}
```
```
</example>

<example name="smart_default">
**AVANT (step-06-resolve.md) :**
```markdown
**If `{auto_mode}` = true:**
→ Auto-fix Real findings, skip noise/uncertain

**If `{auto_mode}` = false:**
Use AskUserQuestion:
  - "Auto-fix Real issues (Recommended)"
  - "Walk through each finding"
  - "Fix only critical"
  - "Skip all"
```

**APRÈS :**
```markdown
**Resolution strategy:** Auto-fix Real findings, skip Noise/Uncertain.

Log decision (if save_mode):
```
ℹ️ Auto-resolution: fixing {N} Real findings, skipping {M} Noise/Uncertain
```

For each Real finding:
1. Read the file
2. Apply the fix
3. Verify the fix
4. Log: `✓ Fixed F{id}: {description}`
```
</example>

<example name="variable_table_cleanup">
**AVANT :**
```markdown
| `{auto_mode}` | Skip confirmations |
| `{save_mode}` | Save outputs to .claude/output/apex/ |
| `{examine_mode}` | Auto-proceed to adversarial review |
```

**APRÈS :**
```markdown
| `{examine_mode}` | Include adversarial review |
```
(auto_mode et save_mode retirés — save est toujours actif, auto n'existe plus)
</example>

</examples>

<success_criteria>
1. `grep -r "auto_mode" ~/.claude/skills/workflow-apex/` retourne 0 résultats
2. `grep -r "AskUserQuestion" ~/.claude/skills/workflow-apex/steps/` ne retourne que `step-00b-interactive.md`
3. `grep -r "save_mode.*false" ~/.claude/skills/workflow-apex/` retourne 0 résultats
4. `grep -ri "auto.mode\|never.*-a\b" ~/clawd/skills/code-process/` retourne 0 résultats
5. Le workflow step-by-step fonctionne toujours : init → analyze → STOP → resume → plan → STOP → ...
6. Les smart defaults loggent leurs décisions dans les fichiers de step
7. Aucun AskUserQuestion ne peut bloquer le workflow
8. Le SKILL.md ne contient plus `-a`/`-s` dans la table des flags
9. Le templates/00-context.md ne contient plus `{{auto_mode}}` ni `{{save_mode}}`
10. Tous les fichiers step conservent leur structure (frontmatter YAML, sections MANDATORY EXECUTION RULES, etc.)
</success_criteria>
