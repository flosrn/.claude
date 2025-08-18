# CCNotify - Système de Déduplication des Notifications

## 📋 Vue d'ensemble

Le système CCNotify implémente un mécanisme de déduplication pour résoudre le problème de **double notification** causé par le bug Claude Code #3465, où les hooks Stop et Notification se déclenchent en séquence rapide.

## 🐛 Problème résolu

**Symptôme** : Réception de 2 notifications consécutives
1. 🎉 "Task completed" (hook Stop)
2. 🤔 "Waiting for input" (hook Notification) - 10-15 secondes après

**Cause** : Bug documenté Claude Code #3465 - événements de hooks dupliqués depuis le répertoire home

## 🛠 Solution implémentée

### Architecture

```
NotificationDeduplicator
├── Verrouillage de fichier (fcntl.flock)
├── Système de cooldown configurable  
├── Priorité des événements (Stop > Notification)
└── Auto-nettoyage des fichiers temporaires
```

### Composants

**1. Classe `NotificationDeduplicator`**
- **Localisation** : `/Users/flo/.claude/ccnotify/ccnotify.py`
- **Cooldown** : 8 secondes par défaut
- **Fichiers temporaires** : `/tmp/claude_notify_{session_id}.*`

**2. Logique de déduplication**
```python
def should_send_notification(self, session_id, event_type):
    # 1. Verrouillage non-bloquant
    # 2. Vérification cooldown
    # 3. Application priorité
    # 4. Enregistrement notification
```

## 🎯 Règles de priorité

| Séquence | Résultat | Logique |
|----------|----------|---------|
| Stop → Notification (< 8s) | Stop SEUL | Notification supprimée |
| Stop → Stop (< 8s) | Stop SEUL | Duplicate supprimé |
| Notification → Stop (< 8s) | DEUX notifications | Stop override |
| Stop → Notification (> 8s) | DEUX notifications | Cooldown expiré |

## 📁 Fichiers impliqués

```
/Users/flo/.claude/ccnotify/
├── ccnotify.py              # Script principal avec déduplication
├── ccnotify.db             # Base SQLite des sessions
├── ccnotify.log           # Logs avec détails déduplication
└── ccnotify.log.YYYY-MM-DD # Archives quotidiennes

/tmp/
├── claude_notify_{session_id}.lock     # Verrouillage
└── claude_notify_info_{session_id}.json # Métadonnées
```

## 🔧 Configuration

### Paramètres modifiables

**Cooldown** (dans `ccnotify.py:129`)
```python
self.deduplicator = NotificationDeduplicator(cooldown_seconds=8)
```

**Hooks actifs** (dans `settings.json`)
```json
{
  "hooks": {
    "Stop": ["python3 $HOME/.claude/ccnotify/ccnotify.py Stop"],
    "Notification": ["python3 $HOME/.claude/ccnotify/ccnotify.py Notification"]
  }
}
```

## 📊 Monitoring

### Logs de déduplication

**Vérification des logs**
```bash
tail -f /Users/flo/.claude/ccnotify/ccnotify.log
```

**Exemples de logs**
```
2025-08-18 18:43:19 - INFO - Stop notification check for session abc123: Notification approved for Stop
2025-08-18 18:43:30 - INFO - Notification check for session abc123: Suppressed Notification - Stop notification sent 11.0s ago
```

### Indicateurs de bon fonctionnement

- ✅ `Notification approved for Stop`
- ✅ `Suppressed Notification - Stop notification sent X.Xs ago`  
- ✅ `Stop overrides previous Notification`
- ❌ `Deduplication check failed` (erreur système)

## 🚨 Troubleshooting

### Problèmes courants

**1. Double notifications persistent**
- **Cause** : Cooldown insuffisant (< temps entre Stop/Notification)
- **Solution** : Augmenter `cooldown_seconds` à 12-15s

**2. Pas de notification du tout**
- **Cause** : Problème de verrouillage ou permissions
- **Diagnostic** : Vérifier `/tmp/claude_notify_*` et logs
- **Solution** : Redémarrer terminal ou nettoyer `/tmp/`

**3. Logs "Deduplication failed"**
- **Cause** : Erreur système (permissions, espace disque)
- **Comportement** : Notifications envoyées quand même (mode dégradé)

### Diagnostic

**Test manuel**
```bash
cd /Users/flo/.claude/ccnotify
echo '{"session_id":"test","hook_event_name":"Stop","cwd":"/tmp"}' | python3 ccnotify.py Stop
echo '{"session_id":"test","hook_event_name":"Notification","message":"waiting for your input","cwd":"/tmp"}' | python3 ccnotify.py Notification
```

**Nettoyage temporaire**
```bash
rm -f /tmp/claude_notify_*
```

## 🔄 Maintenance

### Auto-nettoyage
- **Fréquence** : À chaque initialisation CCNotify  
- **Critère** : Fichiers temporaires > 1 heure
- **Emplacement** : `/tmp/claude_notify_*`

### Mises à jour

**Modifier le cooldown**
```python
# Dans ccnotify.py ligne 129
self.deduplicator = NotificationDeduplicator(cooldown_seconds=12)
```

**Relancer Claude Code** après modifications de `ccnotify.py`

## 📈 Métriques

D'après les logs, le système traite :
- ~2-3 sessions simultanées  
- ~10-20 événements/heure
- Taux suppression : ~50% des notifications Notification

## 🔗 Références

- **Issue Claude Code #3465** : Duplicate hook events from home directory
- **Documentation hooks** : https://docs.anthropic.com/en/docs/claude-code/hooks
- **terminal-notifier** : Système de notifications macOS utilisé