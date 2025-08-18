# TypeScript Quality Hooks (Strict)

## Vue d'ensemble

Hook PostToolUse strict inspiré de `bartolli/claude-code-typescript-hooks` mais adapté aux exigences spécifiques de Florian :

- **Interdiction totale** de `any` et `unknown`
- TypeScript compilation stricte 
- ESLint avec `--max-warnings=0`
- Prettier auto-formatting
- Cache intelligent pour performance
- Traitement ciblé des fichiers modifiés uniquement

## Fonctionnement

### Déclenchement
Le hook s'exécute automatiquement sur `Edit|Write` pour fichiers `.ts/.tsx`

### Pipeline de validation

1. **Prettier** - Formatage automatique silencieux
2. **ESLint** - Lint + auto-fix, zéro warning toléré
3. **TypeScript** - Compilation avec `tsc --noEmit`
4. **Règles strictes** - Scan pour `any`/`unknown`/`@ts-ignore`

### Exit codes
- **Exit 0** : Toutes validations passées (silencieux)
- **Exit 2** : Erreurs détectées → **Claude BLOQUÉ** jusqu'à correction

## Configuration requise

### Settings.json
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "bun $HOME/.claude/hooks/ts/run-ts-quality.js",
        "timeout": 15000
      }
    ]
  }
}
```

### Variables d'environnement
- `CLAUDE_FILE_PATHS` - Liste des fichiers modifiés (auto-fournie par Claude Code)
- `CLAUDE_HOOKS_DEBUG=true` - Mode debug détaillé

## Optimisations performance

### Cache intelligent
- SHA256 des configs TypeScript pour détection changements
- Mappings fichiers → configs mis en cache
- Première exécution ~100-200ms, suivantes <5ms

### Ciblage fichiers
- Traite uniquement `$CLAUDE_FILE_PATHS` (fichiers modifiés)
- Évite scan complet du repo à chaque édition
- TypeScript en mode `--noEmit` (type-check uniquement)

## Règles strictes appliquées

### Interdictions BLOQUANTES
```typescript
// ❌ BLOQUÉ - Hook exit 2
const data: any = fetchData();
const result: unknown = parseResponse();

// ❌ BLOQUÉ - Hook exit 2  
// @ts-ignore
const value = dangerousOperation();
```

### Pratiques recommandées
```typescript
// ✅ AUTORISÉ
interface UserData {
  id: string;
  name: string;
}

const data: UserData = fetchData();
const result: UserData | null = parseResponse();
```

## Dépannage

### Hook ne s'exécute pas
```bash
# Vérifier permissions
ls -la ~/.claude/hooks/ts/run-ts-quality.js

# Tester manuellement
echo '{"tool_name":"Edit","tool_input":{"file_path":"test.ts"}}' | \
  bun ~/.claude/hooks/ts/run-ts-quality.js
```

### Erreurs de cache
```bash
# Supprimer cache corrompu
rm ~/.claude/hooks/ts/quality-cache.json
```

### Mode debug
```bash
export CLAUDE_HOOKS_DEBUG=true
# Les prochaines éditions afficheront logs détaillés
```

## Désactivation temporaire

### Pour une session
```bash
export CLAUDE_DISABLE_PROJECT_HOOKS=true
```

### Modification settings.json temporaire
Commenter le hook dans `.claude/settings.json`

## Intégration avec l'écosystème

Ce hook s'intègre parfaitement avec :
- **Validator sécurité** (PreToolUse) - Double protection
- **Memory bank pattern** (centminmod) - Cohérence documentation
- **Flashbacker** - Traçage des corrections de qualité
- **Commands core** - Workflow de refactoring

Le combo forme un système de qualité robuste et non-négociable.