# Seed: Convert APEX Commands to CLAUDE.md

## 🎯 Objectif

Analyser TOUS les fichiers dans `commands/apex/` et créer un fichier `CLAUDE.md` consolidé qui documente le workflow APEX complet. Ce fichier sera placé dans `commands/apex/CLAUDE.md`.

## 📂 Point de départ

**Dossier source:** `commands/apex/`

**Fichiers à analyser (10 fichiers, ~100KB total):**

| Fichier | Taille | Description |
|---------|--------|-------------|
| `overview.md` | 18KB | Documentation complète du système |
| `1-analyze.md` | 10KB | Phase d'analyse |
| `2-plan.md` | 5KB | Phase de planification |
| `3-execute.md` | 20KB | Phase d'exécution |
| `4-examine.md` | 12KB | Phase de validation |
| `5-demo.md` | 12KB | Phase de démonstration |
| `handoff.md` | 7KB | Transfert de contexte entre sessions |
| `next.md` | 2KB | Exécution automatique de la prochaine tâche |
| `status.md` | 3KB | Affichage du statut |
| `tasks.md` | 8KB | Création de tâches |

**Cible:** `commands/apex/CLAUDE.md`

## ⚠️ Pièges à éviter

1. **Langage emphatique = backfire sur Claude 4.5** - Supprimer "CRITICAL", "MANDATORY", "MUST", "NEVER". Utiliser des déclarations neutres.

2. **Ne pas copier-coller** - Les fichiers sources sont des références détaillées. CLAUDE.md doit être des instructions actionnables et concises.

3. **Garder concis** - CLAUDE.md est lu à chaque démarrage de conversation. Instructions verbeuses = tokens gaspillés.

## 📋 Spécifications

**À inclure:**
- Vue d'ensemble du workflow APEX (Analyze → Plan → Execute → Examine → Demo)
- Structure des dossiers de tâches
- Conventions de nommage
- Modes spéciaux (YOLO, background)
- Quand utiliser chaque phase
- Commandes disponibles et leur usage

**À exclure:**
- Détails d'implémentation de chaque phase
- Syntaxe complète des slash commands
- Explications verbeuses

**Format:**
- Tables pour référence rapide
- Bullet points pour les règles
- Explications en 1-2 phrases max

## 🔍 Contexte technique

APEX = Analyze-Plan-Execute-eXamine (+ Demo optionnel)

Workflow systématique pour implémenter des features de manière fiable avec validation continue.

## 📚 Artifacts source

Tous les fichiers dans `commands/apex/`:
- `overview.md`
- `1-analyze.md`
- `2-plan.md`
- `3-execute.md`
- `4-examine.md`
- `5-demo.md`
- `handoff.md`
- `next.md`
- `status.md`
- `tasks.md`
