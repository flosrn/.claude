# Claude Code Setup

Structure propre et robuste pour Claude Code avec intégrations de qualité.

## Structure

- `commands/` - Commandes Claude disponibles
- `hooks/` - Hooks pour validation et contrôle qualité
- `scripts/` - Scripts utilitaires et validation
- `agents/` - Configuration des agents spécialisés
- `flashback/` - Système de mémoire et trace (Flashbacker)
- `logs/` - Logs de sécurité et activité
- `docs/` - Documentation du setup

## Composants intégrés

- Security validator (PreToolUse avec Bun)
- TypeScript quality hooks (strict rules)
- Command creation tools (Scopecraft)
- Memory/trace system (Flashbacker)
- Selected tools from centminmod

## Usage

Voir `docs/USAGE.md` pour les détails d'utilisation.