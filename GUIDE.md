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

### SessionStart - Notification Démarrage
- **Déclencheur** : Nouvelle session Claude
- **Action** : Notification de démarrage de session

### Stop - Notification
- **Action** : Son de notification fin de tâche
- **Fichier** : `songs/finish.mp3`

---

## 🎮 Workflows Recommandés

### 🚀 Démarrage de Projet

1. **Nouvelle session** :
   - Le système d'observabilité track automatiquement vos actions
   - Utilisez les MCP servers pour la persistence (Pieces notamment)

### 💾 Gestion du Contexte

**Surveillez le % de contexte utilisé via la status line**

1. **Contexte critique** :
   - Utilisez les MCP servers pour sauvegarder le contexte important
   - Redémarrez une nouvelle session si nécessaire

### 🔄 Cycle de Développement

1. **Début de feature** :
   - Utilisez les agents spécialisés pour la planification
   - Documentez dans les MCP servers pour persistence

2. **Découverte importante** :
   - Utilisez Pieces MCP pour sauvegarder les insights
   - Le système d'observabilité track automatiquement

3. **Fin de session** :
   - L'audio notification confirme la fin des tâches
   - Contexte important sauvé via MCP

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
- `hooks/ts/quality-cache.json` - Cache de validation
- `observability/` - Données de monitoring locales

### Debugging

**Vérifier l'installation** :
```bash
# Tester les MCP servers
claude mcp list

# Vérifier l'observabilité
cd ~/.claude/observability && ./status.sh
```

**Logs de sécurité** :
```bash
tail ~/.claude/logs/security.log
```

---

## 🆘 Troubleshooting

### Gestion du contexte
1. Utilisez les MCP servers pour la persistence
2. Le système d'observabilité track vos sessions automatiquement

### Commande bloquée par sécurité
- Vérifiez `logs/security.log` pour la raison
- Les commandes doivent rester dans `~/.claude`

### Validation TypeScript échoue
- Vérifiez le cache : `hooks/ts/quality-cache.json`
- Relancez pour voir les erreurs détaillées

---

## 📚 Ressources

- **Centminmod** : https://github.com/centminmod/my-claude-code-setup
- **Scopecraft** : https://github.com/scopecraft/command
- **Claude Code Docs** : https://docs.anthropic.com/en/docs/claude-code

---

*Configuration mise à jour le 2025-08-19 - Setup avec observabilité avancée et MCP integrations*