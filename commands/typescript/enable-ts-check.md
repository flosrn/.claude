# Enable TypeScript Check

Réactive la vérification TypeScript stricte avec validation de qualité.

## Usage
Utilisez cette commande quand vous voulez réactiver la validation TypeScript complète.

## Instructions pour Claude

1. **Modifier la variable d'environnement** :
```json
# Dans settings.json, changer :
"CLAUDE_NO_TS_CHECK": "true"
# vers :
"CLAUDE_NO_TS_CHECK": "false"
```

2. **Informer l'utilisateur** :
```
✅ TypeScript checking enabled!

📝 La vérification TypeScript stricte est maintenant active.
🛡️ Claude Code sera bloqué si il y a des erreurs TS.
⚠️  Utilisez /disable-ts-check si le contexte sature à nouveau.

Votre pipeline complet est maintenant actif :
- ✅ Validation sécurité (Bash)
- ✅ Prettier (formatage)
- ✅ ESLint (si présent)
- ✅ TypeScript compilation (activé)
- ✅ Strict rules (any/unknown) (activé)
```

La vérification TypeScript reprendra dès le prochain Edit/Write sur fichier .ts/.tsx.