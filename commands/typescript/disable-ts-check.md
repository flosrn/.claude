# Disable TypeScript Check

Désactive temporairement la vérification TypeScript pour éviter que les erreurs saturent le contexte.

## Usage
Utilisez cette commande quand vous voulez travailler sans être bloqué par les erreurs TypeScript.

## Instructions pour Claude

1. **Modifier la variable d'environnement** :
```json
# Dans settings.json, changer :
"CLAUDE_NO_TS_CHECK": "false"
# vers :
"CLAUDE_NO_TS_CHECK": "true"
```

2. **Informer l'utilisateur** :
```
✅ TypeScript checking disabled!

📝 La vérification TypeScript est maintenant désactivée.
🎯 Claude Code ne sera plus bloqué par les erreurs TS.
⚠️  Pensez à réactiver avec /enable-ts-check quand vous voulez vérifier la qualité.

Votre pipeline reste actif pour :
- ✅ Validation sécurité (Bash)
- ✅ Prettier (formatage)
- ✅ ESLint (si présent)
- ❌ TypeScript compilation (désactivé)
- ❌ Strict rules (any/unknown) (désactivé)
```

La vérification TypeScript sera sautée jusqu'à réactivation.