# 🔄 Évaluer l'intégration cclsp dans APEX - Seed

## 🎯 Objectif

Évaluer si l'intégration explicite de cclsp (LSP MCP) dans le workflow APEX améliorerait son utilisation par Claude, étant donné que les instructions dans CLAUDE.md ne sont pas suivies.

**Questions à répondre:**
1. Pourquoi Claude ignore-t-il les instructions cclsp dans CLAUDE.md ?
2. Est-ce qu'ajouter des instructions cclsp directement dans les phases APEX forcerait leur utilisation ?
3. Quelles phases APEX bénéficieraient le plus de cclsp ?

## 📂 Point de départ

**Instructions cclsp existantes:**
- `CLAUDE.md:5-52` - Section "LSP Tools (cclsp) - MANDATORY" déjà présente avec tables, triggers, exemples

**Phases APEX potentiellement concernées:**
- `commands/apex/1-analyze.md` - Exploration : `find_definition`, `find_references`
- `commands/apex/3-execute.md` - Implémentation : `rename_symbol`, `get_diagnostics`
- `commands/apex/4-examine.md` - Validation : `get_diagnostics`

**Configuration cclsp:**
- Vérifier `settings.json` ou `.mcp.json` pour la config MCP

## ⚠️ Pièges à éviter

- **Ne pas dupliquer** : Si les instructions CLAUDE.md suffisent avec un meilleur prompting, éviter la redondance
- **Contexte limité** : Les instructions CLAUDE.md peuvent être tronquées si le contexte est long - les phases APEX sont chargées à la demande
- **Spécificité TypeScript** : cclsp fonctionne principalement pour TS/JS - pas pertinent pour tous les projets

## 📋 Spécifications

**Critères d'évaluation:**
1. **Impact** : Est-ce que l'intégration dans APEX garantirait l'utilisation de cclsp ?
2. **Pertinence** : Quelles opérations APEX bénéficient réellement de LSP vs Grep ?
3. **Coût** : Complexité ajoutée vs bénéfice réel

**Décisions à prendre:**
- Intégrer dans APEX : Oui/Non/Partiel
- Si oui : Quelles phases ? Quels triggers ?

## 🔍 Contexte technique

**Pourquoi cclsp > Grep pour APEX:**
| Phase | Opération | cclsp | Grep |
|-------|-----------|-------|------|
| 1-analyze | Trouver définitions | ✅ Précis | ⚠️ Faux positifs |
| 1-analyze | Trouver usages | ✅ Sémantique | ⚠️ Matches strings/comments |
| 3-execute | Renommer symbole | ✅ Atomic refactor | ❌ Risqué |
| 4-examine | Vérifier types | ✅ Diagnostics LSP | ⚠️ Doit run tsc |

**Hypothèse:** Les instructions CLAUDE.md sont lues au début de session mais "oubliées" pendant l'exécution des phases APEX car le contexte est saturé par les prompts des phases.

## 📚 Artifacts source

> **Lazy Load**: Ces fichiers sont disponibles pour référence. Ne les lire que si nécessaire.

| Artifact | Path | Quand lire |
|----------|------|------------|
| Instructions cclsp | `CLAUDE.md:5-52` | Pour voir le format actuel |
| Phase Analyze | `commands/apex/1-analyze.md` | Pour identifier où insérer cclsp |
| Phase Execute | `commands/apex/3-execute.md` | Pour identifier où insérer cclsp |
| Phase Examine | `commands/apex/4-examine.md` | Pour identifier où insérer cclsp |
