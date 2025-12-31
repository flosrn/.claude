# 🔄 APEX System Overview & Audit - Seed

## 🎯 Objectif

Créer une **overview complète et parfaite** du système APEX avec:
1. Visualisation de ce que fait chaque commande
2. Diagramme du workflow complet
3. Vérification que tout fonctionne correctement
4. Identification des améliorations potentielles

**Livrable attendu**: Documentation visuelle (mermaid diagrams?) + rapport d'audit

## 📂 Point de départ

**Fichiers critiques à lire:**
- `commands/apex/1-analyze.md` - Phase d'analyse
- `commands/apex/2-plan.md` - Phase de planification
- `commands/apex/3-execute.md` - Phase d'exécution
- `commands/apex/4-examine.md` - Phase de validation
- `commands/apex/5-tasks.md` - Génération des tâches
- `commands/apex/handoff.md` - Transfert de contexte entre sessions
- `commands/apex/next.md` - Shortcut pour continuer
- `commands/apex/status.md` - Affichage du statut
- `commands/apex/test-live.md` - Tests en live
- `agents/apex-executor.md` - Agent d'exécution

## ⚠️ Pièges à éviter

- **Commandes bash non-portables**: On vient de corriger `grep -E` → `/usr/bin/grep -E` pour bypasser rg, `sort -V` → `sort -t- -k1 -n`, `$(())` → `expr`. Vérifier qu'il n'y a pas d'autres patterns problématiques.
- **Ne pas oublier les flags**: `--yolo`, `--background`, `--parallel`, `--dry-run`, `--quick` - documenter leur comportement
- **BLUF pattern**: Le seed.md a été restructuré pour mettre l'objectif FIRST - vérifier que c'est cohérent partout

## 📋 Spécifications

- **Format de visualisation**: Mermaid diagrams (supportés par GitHub/Claude)
- **Scope**: Tous les fichiers dans `commands/apex/` + `agents/apex-executor.md`
- **Outputs attendus**:
  1. Diagramme du workflow APEX (1→2→3→4→5)
  2. Description de chaque commande (inputs/outputs/flags)
  3. Liste des améliorations suggérées
  4. Vérification de cohérence entre les fichiers

## 🔍 Contexte technique (optionnel)

> **Note**: Section optionnelle. Lire uniquement si besoin de comprendre l'historique.

Le système APEX suit la méthodologie **Analyze-Plan-Execute-eXamine**:
- Chaque phase produit un artifact (`analyze.md`, `plan.md`, `implementation.md`)
- Les tâches peuvent être divisées en sous-tâches (`tasks/task-01.md`, etc.)
- Le `seed.md` permet de transférer le contexte entre sessions

Récemment modifié:
- Structure BLUF pour seed.md (objectif en premier)
- Lazy loading des artifacts (références au lieu de copier le contenu)
- Commandes bash portables (bypass de rg avec /usr/bin/grep)

## 📚 Artifacts source

> **Lazy Load**: Ces fichiers sont disponibles pour référence. Ne les lire que si nécessaire.

| Artifact | Path | Quand lire |
|----------|------|------------|
| Restructure BLUF | `tasks/07-optimize-apex-seed-structure/analyze.md` | Pour comprendre pourquoi BLUF |
| Implémentation BLUF | `tasks/07-optimize-apex-seed-structure/implementation.md` | Pour les détails techniques |
