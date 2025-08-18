# Start Multi-Agent Observability

Démarre le système d'observabilité pour visualiser en temps réel l'activité des agents Claude Code.

## Usage
Exécute cette commande pour lancer le dashboard de monitoring.

## Instructions pour Claude

1. **Démarrer le système d'observabilité** :
```bash
cd ~/.claude/observability && ./start.sh
```

2. **Vérifier que le système fonctionne** :
- Serveur : http://localhost:4000/events/filter-options
- Client : http://localhost:5173

3. **Informer l'utilisateur** :
```
✅ Observability system started!

🖥️  Dashboard URL: http://localhost:5173
🔌 Server API: http://localhost:4000  
📡 WebSocket: ws://localhost:4000/stream

Use Claude Code normally - all actions will be visible in real-time on the dashboard.

To stop: cd ~/.claude/observability && ./stop.sh
```

Le dashboard affichera en temps réel :
- 🔧 PreToolUse - Avant chaque action
- ✅ PostToolUse - Après chaque action  
- 💬 UserPromptSubmit - Chaque prompt utilisateur
- 🛑 Stop - Fin de réponse
- 🔔 Notification - Interactions