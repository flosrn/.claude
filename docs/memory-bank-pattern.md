# Memory Bank Pattern (from centminmod)

## Pattern d'utilisation

Le système de memory bank utilise des fichiers spécialisés pour maintenir le contexte entre les sessions :

### Fichiers core du contexte

- **CLAUDE-activeContext.md** - État actuel de la session, objectifs et progrès
- **CLAUDE-patterns.md** - Patterns de code établis et conventions  
- **CLAUDE-decisions.md** - Décisions d'architecture et rationale
- **CLAUDE-troubleshooting.md** - Problèmes courants et solutions éprouvées
- **CLAUDE-config-variables.md** - Référence des variables de configuration
- **CLAUDE-temp.md** - Scratch pad temporaire

## Règles d'utilisation

1. Toujours référencer le fichier de contexte actif en premier
2. Maintenir la continuité de session
3. Exclure les fichiers CLAUDE-*.md des commits (sauf demande explicite)
4. Préférer éditer plutôt que créer de nouveaux fichiers
5. Jamais de création proactive de documentation

## Intégration avec notre setup

Ce pattern s'intègre naturellement avec :
- Notre validator de sécurité  
- Les hooks TypeScript
- Le système de tracing Flashbacker
- Les commandes core importées

## Commandes utiles importées

- `/cleanup-context` - Optimisation des fichiers de mémoire
- `/refactor-code` - Plans de refactoring sans modification
- `/create-readme-section` - Sections README professionnelles