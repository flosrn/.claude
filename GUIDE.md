# 🚀 Guide Complet Claude Code Setup

> Configuration personnalisée avec gestion de sessions, commandes utilitaires et validation de qualité

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Status Line Intelligente](#status-line-intelligente)
3. [Système de Notifications](#système-de-notifications)
4. [Commandes Disponibles](#commandes-disponibles)
5. [Hooks de Sécurité et Qualité](#hooks-de-sécurité-et-qualité)
6. [Workflows Recommandés](#workflows-recommandés)

---

## 🎯 Vue d'ensemble

### Structure du projet
```
~/.claude/
├── commands/           # Commandes slash personnalisées
│   ├── core/          # Commandes utilitaires
│   ├── git/           # Workflows Git
│   └── observability/ # Commandes monitoring
├── observability/     # Système d'observabilité
│   ├── apps/server/   # Serveur événements (port 4000)
│   ├── apps/client/   # Dashboard UI (port 5173)
│   └── statusline-ccusage.sh  # Status line avancée
├── ccnotify/          # Notifications Ghostty
├── hooks/             # Hooks de validation
│   ├── ts/           # Validation TypeScript
│   └── observability/ # Tracking événements
├── scripts/          # Scripts utilitaires et sécurité
├── logs/             # Logs de sécurité
└── settings.json     # Configuration Claude Code
```

---

## 🔋 Status Line Intelligente

### Fonctionnalités
La status line affiche en temps réel toutes les informations importantes :

#### Éléments Affichés
- **🌿 Branch Git** : Branche courante avec modifications (+/-) colorées
- **📁 Répertoire** : Nom du dossier courant
- **🤖 Modèle** : Modèle Claude actuel (Sonnet 4, Opus 4.1, etc.)
- **💰 Coûts** : Session (vert), journée (violet), block (gris)
- **⏱ Temps restant** : Temps restant du block actuel
- **🔋 Progress Bar** : Barre de progression colorée du block
- **🧩 Tokens** : Comptage intelligent des tokens

#### Format d'Affichage
```
🌿 main* (+3 -8) | 📁 .claude | 🤖 Sonnet 4 | 💰 $20.25 / 📅 $30.10 / 🧊 $13.48 (4h 24m left) | 🔋 ██░░░░░░░░ 11% | 🧩 16.5K tokens
```

#### Codes Couleur Progress Bar
- **🟢 Vert** : 0-59% d'utilisation (sécurisé)
- **🟡 Jaune** : 60-79% d'utilisation (attention)
- **🔴 Rouge** : 80-100% d'utilisation (critique)

---

## 🔔 Système de Notifications

### ccnotify - Notifications Intelligentes

#### Fonctionnalités
- **Tracking automatique** : Suivi des tâches Claude Code
- **Calcul de durée** : Temps d'exécution précis
- **Base de données** : SQLite pour historique complet
- **Integration Ghostty** : Clic pour retourner à votre session

#### Types de Notifications
1. **Task Complete** : Tâche terminée avec durée
2. **Waiting for Input** : Claude attend votre réponse

#### Fonctionnement
- **Déclenchement** : Hooks Stop et Notification
- **Affichage** : `terminal-notifier` avec titre/durée
- **Action clic** : Active Ghostty et revient à votre session


## 📚 Commandes Disponibles

### Commandes Git (`/git:*`)

| Commande | Description | Usage |
|----------|-------------|-------|
| `/workflow "description"` | Workflow complet branch→commit→PR | Nouvelle feature ou fix |
| `/branch "nom-feature"` | Créer branche depuis main | Début développement feature |
| `/commit` | Commit intelligent avec message auto | Après modifications complètes |
| `/pr` | Créer pull request avec description | Prêt pour review |
| `/sync-upstream` | Synchroniser avec upstream (sécurisé) | Mise à jour depuis fork original |

### Commandes TypeScript (`/typescript:*`)

| Commande | Description | Usage |
|----------|-------------|-------|
| `/disable-ts-check` | Désactive validation TypeScript | Debug temporaire |
| `/enable-ts-check` | Réactive validation TypeScript | Retour mode strict |

### Commandes Observabilité (`/observability:*`)

| Commande | Description | Usage |
|----------|-------------|-------|
| `/start-monitoring` | Lance dashboard observabilité | Monitoring session |
| `/stop-monitoring` | Arrête système monitoring | Fin session |

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