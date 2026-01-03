# 🔄 Refactor /apex:4-examine - Global Logical Analysis - Seed

## 🎯 Objectif

Refonte complète de `/apex:4-examine` pour prioriser l'**analyse logique globale** du travail effectué par les agents, plutôt que simplement lint/typecheck.

**Problème actuel**: Après exécution parallèle des tâches, personne ne vérifie si le travail des agents est cohérent, s'il manque des edge cases, ou si le code pourrait être simplifié.

**Solution**: Un examine en 2 phases qui analyse vraiment le code produit.

## 📂 Point de départ

**Fichier principal à modifier:**
- `commands/apex/4-examine.md` - La commande actuelle (à lire en premier)

**Fichiers de référence pour les patterns:**
- `commands/apex/1-analyze.md` - Pattern de mode background/parallel par défaut
- `commands/apex/3-execute.md:117-175` - Pattern Smart Model Selection (pour inspiration)
- `skills/react19-patterns/SKILL.md` - Skill existant à potentiellement intégrer

## ⚠️ Pièges à éviter

- **Ne pas perdre lint/typecheck**: Ils restent utiles, juste en Phase 1 (validation rapide)
- **Ne pas hardcoder les patterns React**: Utiliser le skill existant `/react19-patterns` si possible
- **Ne pas bloquer l'utilisateur**: Mode background par défaut pour permettre la conversation

## 📋 Spécifications

### Workflow en 2 phases

```
┌─────────────────────────────────────────────────┐
│ PHASE 1: VALIDATION TECHNIQUE (rapide)          │
│ • pnpm run typecheck                            │
│ • pnpm run lint                                 │
│ Si ❌ → Arrêter et corriger                     │
│ Si ✅ → Passer à Phase 2                        │
├─────────────────────────────────────────────────┤
│ PHASE 2: ANALYSE LOGIQUE (approfondie)          │
│ • Lire analyze.md, implementation.md            │
│ • Lire fichiers modifiés + contexte             │
│ • Ultra think: cohérence, edge cases            │
│ • Appeler skill/agent React 19 patterns         │
│ • Générer rapport                               │
└─────────────────────────────────────────────────┘
```

### Modes de scope

| Mode | Flag | Comportement |
|------|------|--------------|
| Standard | (défaut) | Fichiers modifiés + leurs dépendances directes |
| Global | `--global` | Analyse toute la feature (plus complet, plus long) |

### Mode d'exécution

- **Background par défaut** (comme `/apex:1-analyze`)
- Permet à Claude Code de discuter ou travailler pendant l'analyse
- Pattern à suivre: voir `1-analyze.md` step 3

### Output: Rapport structuré

```markdown
# Examine Report: [task-folder-name]

## ✅ Technical Validation
- Typecheck: Pass/Fail
- Lint: Pass/Fail

## 🔍 Logical Analysis

### Cohérence
- [Findings about consistency]

### Edge Cases
- [Missing edge cases discovered]

### Code Quality
- [Overengineering, simplification opportunities]

## ⚛️ React 19 Patterns (if applicable)
- [Findings from react19-patterns skill/agent]

## 🚀 Next Steps / Improvements
- [ ] [Actionable improvement 1]
- [ ] [Actionable improvement 2]
```

### Question technique à creuser

**Comment appeler un skill depuis une custom slash command?**

Options à explorer (recherche web + doc Anthropic requise):
1. Appel inline dans le markdown
2. Lancer un agent qui utilise le skill
3. Référencer comme instruction
4. Autre mécanisme non documenté?

Le skill existant est: `/Users/flo/.claude/skills/react19-patterns/SKILL.md`

## 💬 Clarifications

| Question | Réponse |
|----------|---------|
| Lint/typecheck remplacé ou en plus? | En plus (Phase 1 avant analyse logique) |
| Scope de l'analyse? | Fichiers modifiés + contexte, avec flag `--global` pour analyse complète |
| Intégration React 19? | Skill existant `/react19-patterns` - explorer comment l'appeler depuis une commande |
| Output? | Rapport structuré sans corrections auto |
| Mode d'exécution? | Background/parallel par défaut |
| Section finale? | Ajouter "Next Steps / Improvements" |

## 📚 Artifacts source

> **Lazy Load**: Ces fichiers sont disponibles pour référence. Ne les lire que si nécessaire.

| Artifact | Path | Quand lire |
|----------|------|------------|
| Commande examine actuelle | `commands/apex/4-examine.md` | **Lire en premier** - pour comprendre l'existant |
| Pattern background mode | `commands/apex/1-analyze.md` | Pour copier le pattern d'exécution parallèle |
| Smart Model Selection | `commands/apex/3-execute.md` | Pour inspiration sur la structure |
| Skill React 19 | `skills/react19-patterns/SKILL.md` | Pour comprendre le skill à intégrer |
| CLAUDE.md APEX | `commands/apex/CLAUDE.md` | Pour mettre à jour la documentation |
