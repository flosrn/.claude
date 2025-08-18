# Stop Multi-Agent Observability

Arrête le système d'observabilité et libère les ports 4000 et 5173.

## Usage
Exécute cette commande pour arrêter le dashboard de monitoring.

## Instructions pour Claude

1. **Arrêter le système d'observabilité** :
```bash
cd ~/.claude/observability && ./stop.sh
```

2. **Vérifier l'arrêt** :
```bash
# Vérifier que les ports sont libérés
lsof -i :4000 && echo "Port 4000 still in use" || echo "Port 4000 free"
lsof -i :5173 && echo "Port 5173 still in use" || echo "Port 5173 free"
```

3. **Informer l'utilisateur** :
```
✅ Observability system stopped!

🔌 Port 4000: Released
🖥️  Port 5173: Released  

The hooks will continue to send events, but they'll be ignored when the server is not running.
Your existing hooks (validation, quality, notifications) continue working normally.
```

Note : L'arrêt du système d'observabilité n'affecte pas les autres hooks qui continuent à fonctionner normalement.