# Guide Anti-Over-Engineering pour Claude Code

## Principes Fondamentaux

### 1. Approche "Chirurgicale"
- **Modifications minimales = risque minimal**
- Examiner le code existant avant de proposer une solution
- Réutiliser les composants et patterns déjà présents
- Ne toucher QUE ce qui est nécessaire

### 2. Instructions Claires et Spécifiques
Au lieu de : "Ajoute une fonctionnalité de login"
Préférer : "Ajoute un champ email_verified: bool = False dans User class de models/user.py"

### 3. Décomposer les Tâches Complexes
- Ne jamais demander tout d'un coup
- Diviser en sous-étapes bien définies
- Une tâche = une modification ciblée

## Techniques Pratiques

### Dans CLAUDE.md

```markdown
# Instructions Anti-Over-Engineering

## Code Style
- KISS (Keep It Simple, Stupid)
- Modifications minimales uniquement
- Réutiliser l'existant avant de créer du nouveau
- Une fonction = une responsabilité
- Pas d'abstraction prématurée

## Workflow
- Lire le code existant AVANT de proposer
- Suivre les patterns déjà en place
- Ne PAS créer de nouveaux fichiers sauf si absolument nécessaire
- Préférer éditer plutôt que réécrire

## Interdictions
- JAMAIS de refactoring non demandé
- JAMAIS de création de framework pour une simple feature
- JAMAIS plus de 3 niveaux d'abstraction
- JAMAIS de patterns enterprise pour un projet solo
```

### Commandes Utiles

1. **Clear fréquent** : `/clear` entre chaque nouvelle tâche
2. **Context minimal** : Ne donner que les fichiers pertinents
3. **Instructions explicites** : "Modifie UNIQUEMENT la ligne X"

## Exemples de Prompts Efficaces

### ❌ MAUVAIS
"Améliore l'architecture de mon app"
"Ajoute un système d'authentification"
"Refactorise ce code"

### ✅ BON
"Ajoute validation email dans loginRoute() ligne 45"
"Corrige l'erreur TypeScript ligne 23 de user.service.ts"
"Ajoute un try/catch autour de l'appel API ligne 89"

## Red Flags à Éviter

Si Claude propose :
- Plus de 3 nouveaux fichiers pour une feature simple
- Un système de middleware pour un besoin basique
- Des interfaces/abstractions pour un code utilisé une fois
- Une refonte architecturale non demandée

**STOP** et reformuler plus spécifiquement.

## Philosophie

> "Le meilleur code n'est pas celui qui impressionne les autres développeurs. C'est celui qui résout le problème et disparaît dans l'architecture existante."

## Checklist Avant Chaque Demande

- [ ] Ma demande est-elle spécifique ?
- [ ] Ai-je indiqué le fichier et les lignes concernées ?
- [ ] Ai-je précisé "modification minimale" ?
- [ ] Ai-je fourni un exemple du pattern existant à suivre ?

## Mots Clés Magiques

Utiliser ces mots dans vos prompts :
- "minimal"
- "simple"
- "uniquement"
- "sans refactoring"
- "garde l'architecture actuelle"
- "modification chirurgicale"
- "comme l'existant"

## Retour d'Expérience Communauté

D'après Reddit et les forums de développeurs :
- Claude est entraîné sur du code "production-ready" enterprise
- Il pattern-match vers des solutions complexes par défaut
- Les développeurs solo n'ont PAS besoin de cette complexité
- Traiter Claude comme un stagiaire rapide, pas un architecte senior

## Solution Finale

**Arrêter de planifier des vaisseaux spatiaux et commencer à shipper des features.**