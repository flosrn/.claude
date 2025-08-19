# Multi-Agent Observability System

**Source**: https://github.com/disler/claude-code-hooks-multi-agent-observability  
**Purpose**: Real-time monitoring and visualization of Claude Code agent activities

## Installation

✅ **Installé de manière non-intrusive** - Préserve tout votre setup existant

### Structure
```
~/.claude/
├── observability/           # Système d'observabilité isolé
│   ├── apps/               # Server Bun + Client Vue
│   ├── start.sh           # Démarrage système
│   └── stop.sh            # Arrêt système
├── hooks/observability/    # Scripts de monitoring
│   ├── send_event.py      # Envoi événements au serveur
│   └── utils/             # Utilitaires
└── settings.json          # Hooks ajoutés aux existants
```

## Fonctionnalités

### 🎯 **Monitoring en Temps Réel**
- **Tous les tool calls** (Bash, Edit, Write, Read)
- **Modifications de fichiers** avec détails
- **Sessions multi-agents** avec codes couleur
- **Timeline complète** des actions
- **WebSocket live updates**

### 📊 **Dashboard Web**
- **URL** : http://localhost:5173
- **Filtrage** par app, session, type d'événement
- **Live Pulse Chart** avec barres colorées par session
- **Chat Transcript** viewer intégré
- **Auto-scroll** avec contrôle manuel

### 🔧 **Types d'Événements**

| Événement | Emoji | Description | Données Capturées |
|-----------|-------|-------------|-------------------|
| PreToolUse | 🔧 | Avant exécution outil | Tool name, inputs, validation |
| PostToolUse | ✅ | Après exécution outil | Tool name, outputs, results |
| UserPromptSubmit | 💬 | Soumission prompt | Contenu prompt (tronqué 100 chars) |
| Stop | 🛑 | Fin de réponse | Résumé + chat transcript |
| Notification | 🔔 | Interactions utilisateur | Messages notifications |

## Usage

### Démarrage
```bash
cd ~/.claude/observability
./start.sh
```
- Démarre serveur sur port **4000**
- Démarre client sur port **5173**
- Ouvre automatiquement le dashboard

### Arrêt
```bash
cd ~/.claude/observability
./stop.sh
```

### Accès Dashboard
1. Ouvrir http://localhost:5173
2. Exécuter des commandes Claude Code
3. Voir les événements en temps réel

## Intégration avec votre Setup

### ✅ **Préservation Complète**
- **Validation sécurité** : Maintenue
- **Pipeline qualité TS** : Maintenu
- **CCNotify** : Maintenu
- **MCP Servers** : Maintenu

### 🔗 **Hooks Ajoutés**
L'observability a été ajoutée comme **hooks supplémentaires** non-bloquants :

```json
{
  "type": "command",
  "command": "uv run $HOME/.claude/hooks/observability/send_event.py --source-app claude-setup --event-type [TYPE]",
  "run_in_background": true,
  "timeout": 2000
}
```

### 📡 **Communication**
- **HTTP POST** → http://localhost:4000/events
- **WebSocket** → ws://localhost:4000/stream
- **Données** stockées en SQLite local

## Configuration

### Variables d'Environnement
- `ANTHROPIC_API_KEY` - Requis pour résumés AI (optionnel)
- `ENGINEER_NAME` - Nom pour identification (optionnel)

### Ports Utilisés
- **4000** : Serveur observability (HTTP/WebSocket)
- **5173** : Dashboard client (Vue dev server)

## Données Visualisées

### Timeline des Événements
- **Timestamp** précis de chaque action
- **Tool utilisé** avec paramètres
- **Fichiers modifiés** avec chemins
- **Session ID** pour grouper les actions
- **Durée d'exécution** des outils

### Live Pulse Chart
- **Barres colorées** par session
- **Emojis** par type d'événement
- **Animation** en temps réel
- **Filtrage** dynamique

### Chat Transcript
- **Conversations complètes** avec Claude
- **Syntax highlighting** pour le code
- **Modal viewer** pour détails
- **Intégration** avec événements Stop

## Sécurité & Performance

### 🛡️ **Sécurité**
- **Non-bloquant** : N'interrompt jamais vos hooks existants
- **Local only** : Toutes données restent sur votre machine
- **Background** : Exécution en arrière-plan
- **Timeout** : 2s max par événement

### ⚡ **Performance**
- **SQLite** avec mode WAL pour accès concurrent
- **WebSocket** pour updates temps réel
- **Limite d'événements** configurable (défaut: 100)
- **Rotation automatique** des anciens événements

## Troubleshooting

### Observability ne fonctionne pas
```bash
# Vérifier que le serveur tourne
curl http://localhost:4000/events/filter-options

# Tester l'envoi d'événement
uv run ~/.claude/hooks/observability/send_event.py --source-app test --event-type PreToolUse

# Vérifier les logs
cd ~/.claude/observability && ./stop.sh && ./start.sh
```

### Ports déjà utilisés
```bash
# Arrêter les processus
cd ~/.claude/observability && ./stop.sh

# Vérifier les ports
lsof -i :4000
lsof -i :5173
```

### Hooks ne s'exécutent pas
- Vérifier que `uv` est installé
- Vérifier les chemins absolus dans settings.json
- Vérifier les permissions d'exécution

## Dépendances

### Système
- **Bun** : Serveur et client
- **uv** : Exécution scripts Python
- **Python 3.8+** : Scripts hooks

### Packages
- **Serveur** : TypeScript, SQLite, WebSocket
- **Client** : Vue 3, Vite, Tailwind CSS
- **Hooks** : anthropic, python-dotenv (auto-installées par uv)

## Commandes Utiles

```bash
# Status système
cd ~/.claude/observability && ./start.sh
curl http://localhost:4000/events/filter-options

# Test manuel
curl -X POST http://localhost:4000/events \
  -H "Content-Type: application/json" \
  -d '{"source_app":"test","session_id":"test-123","hook_event_type":"PreToolUse","payload":{"tool_name":"Bash","tool_input":{"command":"ls"}}}'

# Nettoyage complet
cd ~/.claude/observability && ./stop.sh
rm -f apps/server/events.db
```

## Exemple d'Utilisation

1. **Démarrer l'observability** : `./start.sh`
2. **Ouvrir dashboard** : http://localhost:5173
3. **Exécuter dans Claude** : "Run `ls -la` to see files"
4. **Observer dans dashboard** :
   - PreToolUse 🔧 : `Bash` command "ls -la"
   - PostToolUse ✅ : Results with file list
   - Live chart mise à jour

Vous avez maintenant une **visibilité complète** sur toutes les actions de vos agents Claude en temps réel ! 🎉