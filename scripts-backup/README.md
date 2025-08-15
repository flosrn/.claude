# Scripts Claude Code - Backup

Scripts de hooks sauvegardés le $(date +%Y-%m-%d).

## Configuration actuelle (simplifiée)
- `simple-lint.sh` : Linting simple avec Prettier + ESLint
- Hook PostToolUse : Format/lint automatique des fichiers JS/TS
- Hook Stop : Son de fin

## Scripts sauvegardés
- `detect-and-lint-optimized.sh` : Version optimisée avec cache
- `final-quality-gate-light.sh` : Quality gate allégé  
- `detect-any-types.js` : Détection des types 'any'
- `format-only.sh` : Formatage seul
- `pre-edit-check.sh` : Validation pre-édition
- `smart-file-filter.sh` : Filtrage intelligent
- `validate-command.js` : Validation commandes
- `hooks-config-example.json` : Ancienne configuration complète

## Pour restaurer
Copiez les scripts nécessaires depuis ce dossier vers `/Users/flo/.claude/scripts/`