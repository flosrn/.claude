# Intégration centminmod/my-claude-code-setup

## Éléments importés

### Commandes utiles (namespace `core/`)

- **cleanup/cleanup-context.md** - Optimisation memory bank (15-25% réduction tokens)
- **refactor/refactor-code.md** - Plans de refactoring sans modification de code  
- **documentation/create-readme-section.md** - Génération sections README

### Pattern Memory Bank

- Système de fichiers CLAUDE-*.md pour maintenir contexte
- Règles d'exclusion des commits pour fichiers mémoire
- Continuité de session via activeContext.md

### Notifications macOS (optionnel)

- Script `scripts/notify-macos.sh` 
- Utilise terminal-notifier si disponible (brew install terminal-notifier)
- Fallback vers afplay si fichier audio présent

## Non importé (par choix minimaliste)

- Agents complexes (memory-bank-synchronizer, code-searcher, etc.)
- Commandes anthropic/, security/, architecture/ (redondantes avec notre setup)
- Configuration MCP spécifique centminmod
- Settings complets (nous gardons notre approche minimale)

## Intégration avec notre setup

Les éléments importés s'intègrent parfaitement avec :
- Notre validator de sécurité (PreToolUse)
- Les hooks TypeScript à venir
- Le système Flashbacker pour tracing
- Notre approche settings.json minimale

## Usage recommandé

1. Utiliser `/cleanup-context` régulièrement pour optimiser la mémoire
2. Employer `/refactor-code` pour analyses sans modification
3. Créer sections README avec `/create-readme-section`
4. Adopter le pattern memory bank pour projets complexes