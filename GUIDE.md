# 🚀 Guide Complet Claude Code Setup

> Configuration personnalisée avec gestion de sessions, commandes utilitaires et validation de qualité

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Gestion des Sessions (Flashbacker)](#gestion-des-sessions-flashbacker)
3. [Commandes Disponibles](#commandes-disponibles)
4. [Hooks de Sécurité et Qualité](#hooks-de-sécurité-et-qualité)
5. [Workflows Recommandés](#workflows-recommandés)

---

## 🎯 Vue d'ensemble

### Structure du projet
```
~/.claude/
├── commands/           # Commandes slash personnalisées
│   ├── core/          # Commandes utilitaires (centminmod)
│   └── fb/            # Commandes session (flashbacker)
├── flashback/         # Système de mémoire persistante
│   ├── memory/        # Fichiers REMEMBER.md, WORKING_PLAN.md
│   ├── scripts/       # Scripts hooks
│   └── prompts/       # Templates AI
├── hooks/             # Hooks de validation
│   └── ts/           # Validation TypeScript
├── scripts/          # Scripts utilitaires
├── logs/             # Logs de sécurité
└── settings.json     # Configuration Claude Code
```

---

## 🧠 Gestion des Sessions (Flashbacker)

### Concept Clé
Flashbacker maintient votre contexte de travail entre les sessions Claude, même après compaction du contexte.

### Fichiers de Mémoire

#### `REMEMBER.md`
- **Rôle** : Mémoire long-terme du projet
- **Contenu** : Architecture, décisions importantes, conventions, pièges à éviter
- **Persistance** : Permanent, survit aux compactions

#### `WORKING_PLAN.md`
- **Rôle** : Plan de développement actuel
- **Contenu** : Tâches en cours, priorités, blocages
- **Mise à jour** : À chaque session importante

#### `CURRENT_SESSION.md`
- **Rôle** : Snapshot de la session courante
- **Contenu** : Résumé des accomplissements, décisions, problèmes résolus
- **Archivage** : Automatique (garde 10 dernières sessions)

### 🔄 Workflow Session Management

#### Avant Compaction (Context ~90% plein)

1. **Sauvegarder la session** :
```
/fb:save-session
```
- Crée un résumé formaté de la session
- Archive automatiquement l'ancienne session
- Sauvegarde dans `CURRENT_SESSION.md`

2. **OU Mettre à jour le plan** :
```
/fb:working-plan
```
- Analyse la conversation
- Met à jour les priorités dans `WORKING_PLAN.md`
- Déplace les tâches complétées

#### Après Compaction

Le hook `SessionStart` s'exécute automatiquement et charge :
- REMEMBER.md (mémoire projet)
- WORKING_PLAN.md (priorités actuelles)  
- Historique de conversation précédente

Si le hook ne se déclenche pas, exécutez manuellement :
```
/fb:session-start
```

#### Ajouter à la Mémoire Permanente

Pour sauvegarder une information critique :
```
/fb:remember "Ne jamais utiliser l'API v1, toujours v2 pour l'auth"
```

### 📊 Format du Session Summary

Le `/fb:save-session` génère automatiquement :
```markdown
# 📋 Session Summary - [Date]

## 🎯 Session Overview
[Résumé principal]

## 📁 Files Modified
- **`path/file.ts`** - Description détaillée

## ⚒️ Tool Calls & Operations
- **Edit**: `file:lines` - Changement effectué
- **Bash**: `command` - Résultat

## ✅ Key Accomplishments
- Feature implémentée avec détails

## 🔧 Problems Solved
- Issue → Solution → Vérification

## 💡 Technical Decisions
- Décision prise avec justification

## 🔄 Next Steps
- Prochaines priorités
```

---

## 📚 Commandes Disponibles

### Commandes Session (`/fb:*`)

| Commande | Description | Quand l'utiliser |
|----------|-------------|------------------|
| `/fb:session-start` | Restaure le contexte après compaction | Début de session ou après compaction |
| `/fb:save-session` | Capture et formate le résumé de session | Avant compaction (90% contexte) |
| `/fb:working-plan` | Met à jour le plan de développement | Après avancement significatif |
| `/fb:remember "info"` | Ajoute à la mémoire permanente | Information critique découverte |

### Commandes Utilitaires (`/core/*`)

| Commande | Description | Usage |
|----------|-------------|-------|
| `/cleanup-context` | Optimise les tokens en consolidant la doc | Quand le contexte devient trop large |
| `/refactor-code` | Analyse approfondie pour refactoring | Avant refactoring majeur |
| `/check-best-practices` | Vérifie standards TS/React/Next.js | Review de qualité code |
| `/create-readme-section` | Génère sections README professionnelles | Documentation projet |
| `/update-memory-bank` | Met à jour CLAUDE.md | Sync mémoire projet |

### Meta-Commande

| Commande | Description | Usage |
|----------|-------------|-------|
| `/create-command` | Crée de nouvelles commandes Claude | Automatisation de workflows |

---

## 🔒 Hooks de Sécurité et Qualité

### PreToolUse - Validation Sécurité
- **Script** : `scripts/validate-command.js`
- **Cible** : Commandes Bash
- **Actions** :
  - Bloque commandes dangereuses (rm -rf, sudo, etc.)
  - Bloque accès hors ~/.claude
  - Log dans `logs/security.log`
- **Exit 2** = Bloque l'exécution

### PostToolUse - Qualité TypeScript
- **Script** : `hooks/ts/run-ts-quality.js`
- **Cible** : Edit/Write de fichiers .ts/.tsx
- **Pipeline** :
  1. Prettier (formatage)
  2. ESLint (règles strictes)
  3. TypeScript Compiler (vérification types)
- **Exit 2** = Bloque si erreurs

### SessionStart - Restauration Contexte
- **Script** : `flashback/scripts/session-start.sh`
- **Déclencheur** : Nouvelle session Claude
- **Action** : Charge automatiquement la mémoire projet

### Stop - Notification
- **Action** : Son de notification fin de tâche
- **Fichier** : `songs/finish.mp3`

---

## 🎮 Workflows Recommandés

### 🚀 Démarrage de Projet

1. **Première session** :
   ```
   /fb:remember "Architecture: Next.js 14 avec App Router"
   /fb:remember "Base de données: PostgreSQL avec Prisma"
   /fb:working-plan
   ```

2. **Sessions suivantes** :
   - Le hook SessionStart charge automatiquement le contexte
   - Sinon : `/fb:session-start`

### 💾 Gestion du Contexte

**Surveillez le % de contexte utilisé**

1. **À 85-90%** :
   ```
   /fb:save-session
   ```
   
2. **Après compaction automatique** :
   - Vérifiez que le contexte est restauré
   - Sinon : `/fb:session-start`

### 🔄 Cycle de Développement

1. **Début de feature** :
   ```
   /fb:working-plan
   # Met à jour avec nouvelle feature
   ```

2. **Découverte importante** :
   ```
   /fb:remember "L'API rate limit est 100 req/min"
   ```

3. **Fin de session** :
   ```
   /fb:save-session
   # Ou
   /fb:working-plan
   ```

### 🧹 Maintenance

1. **Contexte trop gros** :
   ```
   /cleanup-context
   ```

2. **Review code** :
   ```
   /check-best-practices
   ```

3. **Planification refactoring** :
   ```
   /refactor-code
   ```

---

## 📝 Notes Importantes

### Limitations
- **Pas de hooks automatiques** pour pre/post-compaction
- Gestion manuelle des sessions requise
- SessionStart hook ne fonctionne que pour nouveau démarrage

### Fichiers à ne pas commiter
- `logs/security.log` - Logs de sécurité temporaires
- `flashback/memory/CURRENT_SESSION.md` - Session temporaire
- `hooks/ts/quality-cache.json` - Cache de validation

### Debugging

**Vérifier l'installation** :
```bash
flashback status
flashback doctor
```

**Voir la mémoire actuelle** :
```bash
cat ~/.claude/flashback/memory/REMEMBER.md
cat ~/.claude/flashback/memory/WORKING_PLAN.md
```

**Logs de sécurité** :
```bash
tail ~/.claude/logs/security.log
```

---

## 🆘 Troubleshooting

### Le contexte n'est pas restauré
1. Vérifiez que SessionStart hook est configuré
2. Exécutez manuellement : `/fb:session-start`

### Commande bloquée par sécurité
- Vérifiez `logs/security.log` pour la raison
- Les commandes doivent rester dans `~/.claude`

### Validation TypeScript échoue
- Vérifiez le cache : `hooks/ts/quality-cache.json`
- Relancez pour voir les erreurs détaillées

---

## 📚 Ressources

- **Flashbacker** : https://github.com/agentsea/flashbacker
- **Centminmod** : https://github.com/centminmod/my-claude-code-setup
- **Scopecraft** : https://github.com/scopecraft/command

---

*Configuration créée le 2025-08-16 - Version avec Flashbacker 2.3.5*