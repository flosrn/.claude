# 🔄 Handoff Brainstorm Flag - Seed

## 🎯 Objectif

Ajouter un flag `--brainstorm` à la commande `/apex:handoff` qui permet à Claude de poser des questions de clarification AVANT de générer le seed.

**Comportement souhaité** :
```bash
/apex:handoff "tâche complexe et vague" --brainstorm
```
→ Claude pose 2-3 questions ciblées via `AskUserQuestion`
→ Intègre les réponses dans le seed généré

## 📂 Point de départ

**Fichier à modifier** :
- `commands/apex/handoff.md` - Ajouter le flag et la logique de brainstorm

**Pattern existant à suivre** :
- `--vision` flag déjà implémenté (step 3b conditionnel)
- `AskUserQuestion` tool pour les questions interactives

## 📋 Spécifications

**Questions types à poser** (adapter selon la description) :
1. **Priorité** : Quel aspect est le plus important ?
2. **Audience/Scope** : Pour qui ? Quelle portée ?
3. **Mode** : Analyser d'abord ou implémenter directement ?

**Contraintes** :
- Max 3-4 questions (pas surcharger l'utilisateur)
- Questions adaptées au contexte de la description
- Si description déjà claire → moins de questions

## ⚠️ Pièges à éviter

- Ne pas poser de questions génériques inutiles
- Éviter de transformer handoff en interrogatoire
- Les questions doivent apporter de la valeur (clarifier, prioriser, challenger)

## 🔍 Contexte technique

**Cas d'usage démontré** (cette session) :
- Description vague : "améliorer le suivi de l'IA créateur, visualiser le contexte, analyse de l'interface"
- Questions posées : Priorité (3 aspects liés), Audience (utilisateur final), Mode (analyser d'abord)
- Résultat : Clarification qui enrichit le seed

**Valeur ajoutée du brainstorm** :
- Tâches complexes → décomposition
- Demandes floues → précision
- Multi-aspects → priorisation

## 📚 Artifacts source

> **Lazy Load**: Lire si besoin de comprendre la structure actuelle de handoff.

| Artifact | Path | Quand lire |
|----------|------|------------|
| Handoff actuel | `commands/apex/handoff.md` | Pour voir la structure des flags existants |
| Implémentation task 11 | `tasks/11-convert-apex-overview-to-claudemd/implementation.md` | Pour voir comment --vision a été ajouté |
