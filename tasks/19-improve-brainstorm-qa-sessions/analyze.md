# Analysis: Improve /brainstorm with Interactive Q&A Sessions

**Analyzed**: 2026-01-06
**Status**: Complete

## Quick Summary (TL;DR)

> **Deux améliorations complémentaires :**
> 1. Améliorer `/brainstorm` avec un flux Q&A progressif **avant** la phase de recherche (pattern de `handoff.md:107-188`)
> 2. Ajouter un **Step 0 Clarity Check** dans `/apex:1-analyze` qui détecte les tâches vagues et suggère `/brainstorm` d'abord
>
> Best practices : **Flipped Interaction Pattern** (LLM pose les questions), détection de satisfaction utilisateur, synthèse avant action.

**Key files to modify:**
- `commands/brainstorm.md` - Commande principale à enrichir avec Q&A
- `commands/apex/1-analyze.md` - Ajouter Step 0 détection de clarté + suggestion brainstorm

**Patterns to follow:**
- `commands/apex/handoff.md:107-188` - Multi-round interview flow
- `plugins/marketplaces/claude-code-plugins/plugins/plugin-dev/skills/command-development/references/interactive-commands.md` - Reference complète AskUserQuestion

**⚠️ Gotchas discovered:**
- AskUserQuestion ne fonctionne PAS dans les subagents (Task tool)
- Max 1-4 questions par appel, 2-4 options par question
- Header max 12 caractères

**Dependencies:** Aucun bloquant

**Estimation:** ~2 fichiers, ~1.5h total

---

## Codebase Context

### Commande `/brainstorm` actuelle (`commands/brainstorm.md`)

**Structure actuelle (146 lignes):**
- Lines 1-5: YAML frontmatter (`model: opus`)
- Lines 18-25: Persona du chercheur rigoureux
- Lines 27-96: **4 rounds de recherche** sans interaction utilisateur :
  1. **ROUND 1** (30-48): Initial Exploration - agents parallèles
  2. **ROUND 2** (52-68): Skeptical Challenge - devil's advocate
  3. **ROUND 3** (72-82): Multi-Perspective Analysis (5 personas)
  4. **ROUND 4** (86-95): Synthesis & Conclusion
- Lines 98-107: Règles d'exécution
- Lines 109-145: Format de sortie et critères de succès

**Problème identifié:** Aucune phase de collecte de contexte utilisateur avant la recherche. Le brainstorming démarre immédiatement sur `$ARGUMENTS` sans clarification.

### Pattern Q&A de référence (`commands/apex/handoff.md:107-188`)

**Workflow CLARIFICATIONS GATHERING:**

```markdown
1. ULTRA THINK - Identifier ce qui nécessite clarification :
   - Adjectifs vagues → Demander des métriques spécifiques
   - Aspects multiples → Demander lequel est critique
   - Scope manquant → Demander ce qui est exclu
   - Audience manquante → Demander qui en bénéficie
   - Approche floue → Demander les préférences de style
   - Gaps techniques → Demander sur error handling, edge cases
   - Implications UX → Demander sur le comportement et feedback
   - Tradeoffs → Demander sur les approches concurrentes

2. INTERVIEW LOOP avec AskUserQuestion :
   - 2-3 questions focalisées par round
   - Attendre les réponses
   - Détecter signal de satisfaction ("c'est bon", "let's proceed", "that's all")
   - Si pas satisfait → poser 2-3 questions supplémentaires
   - Utiliser framing "What/How" (collaboratif, pas accusatoire "Why")

3. SYNTHESIZE & CONFIRM :
   - Synthèse détaillée avec interprétation, exemples concrets, implications
   - Demander confirmation : "Est-ce bien ça ?"
   - Corriger si nécessaire
```

**Questions INTERDITES (handoff.md:141-148):**
- Priorité, deadline, ordering (gestion automatique)
- Questions de project management qui font perdre du temps

### Autres patterns AskUserQuestion existants

| Pattern | Fichier | Lignes | Use Case |
|---------|---------|--------|----------|
| Single Decision | `git/commitizen.md` | 98-135 | Sélection d'option avec variantes |
| Conditional Intake | `create-meta-prompts/SKILL.md` | 63-87 | Détection de purpose |
| Location Selection | `create-context-docs.md` | 17-26 | Choix binaire simple |
| Intake + Refinement | `new-session-prompt.md` | 21-113 | Q&A en deux phases |

### Reference complète (`interactive-commands.md`)

**Patterns documentés:**
- Pattern 1: Simple interactive setup (3 questions)
- Pattern 2: Multi-stage workflow adaptatif
- Pattern 3: Simple Yes/No Decision
- Pattern 4: Multiple Configuration Questions
- Pattern 5: Conditional Question Flow (4 stages)
- Iterative Collection Pattern (loop pour N items)
- Validation Loop (Ask → Validate → Ask follow-up)
- Dynamic Options Based on Context

---

## Documentation Insights

### AskUserQuestion Tool Constraints

```typescript
{
  questions: [                    // 1-4 questions per call
    {
      question: string,           // What to ask
      header: string,             // Max 12 chars
      multiSelect: boolean,       // Optional
      options: [                  // 2-4 options
        { label: string, description: string }
      ]
    }
  ]
}
```

**Limitations critiques:**
- Ne fonctionne PAS dans les subagents (Task tool) - session principale only
- "Other" option ajoutée automatiquement
- Keyboard navigation: arrows, space/number, Enter

---

## Research Findings (Best Practices Communautaires)

### 1. Flipped Interaction Pattern (Vanderbilt University)

**Concept:** Inverser les rôles - le LLM pose des questions clarificatrices au lieu que l'utilisateur fournisse tout le contexte.

**Structure:**
> "Ask me questions until you have enough information to [objective]. Ask me one question at a time."

**Avantages:**
- Meilleure collecte de contexte
- Utilisateur n'a pas à deviner ce qui est pertinent
- Flow conversationnel naturel

### 2. Hourglass Ideation Framework (Research)

**7 étapes:**
1. Scope Definition
2. Foundational Materials Collection
3. Foundational Materials Structuring
4. Idea Generation
5. Idea Refinement
6. Idea Evaluation
7. Multi-idea Evaluation & Selection

**Insight clé:** La collecte de contexte (étapes 1-3) doit précéder la génération (étape 4).

### 3. Multi-Agent Discussion Framework

**Structure:**
- 4 agents avec personas diverses
- 5 rounds de discussion
- 3 phases: Diverge → Exchange → Converge

**Personas suggérées:**
- Visionary Millionaire
- Futurist
- Critic
- Six Thinking Hats perspectives

**Research finding:** Surpasse les approches single-agent en originalité et élaboration.

### 4. BSHR Loop (Brainstorm, Search, Hypothesize, Refine)

**Flow:**
1. Brainstorm - Générer des questions de recherche
2. Search - Collecter l'information
3. Hypothesize - Former des hypothèses
4. Refine - Itérer jusqu'à satisfaction

**Avantage:** Modèle le comportement humain de "information foraging".

### 5. Menu Actions Pattern

**Concept:** Définir des commandes custom pour l'utilisateur pendant le brainstorming.

```
/diverge - Générer plus d'idées variées
/converge - Évaluer et sélectionner
/critique - Challenger les idées
/deepen - Approfondir une idée spécifique
```

**Avantage:** Donne le contrôle à l'utilisateur sur le flow.

---

## User Clarifications

- **Q: Structure Q&A ?**
  **A: Progressif** - Une question à la fois, les suivantes dépendent des réponses précédentes

- **Q: Type de brainstorming ?**
  **A: Multi-purpose** - Adapter dynamiquement selon le contexte détecté

- **Q: Intégration brainstorm × APEX ?**
  **A: Solution A - Détection + Suggestion** - Ajouter Step 0 dans analyze qui détecte les tâches vagues et suggère /brainstorm (simple, non-bloquant)

---

## Découverte Clé : handoff.md a déjà --brainstorm

**Le flag `--brainstorm` existe déjà** dans `/apex:handoff` (`commands/apex/handoff.md:4,18,107-188`) !

Il fait exactement :
- Q&A interactif avant de générer le seed
- Multi-round interview avec détection de satisfaction
- Synthèse et confirmation avant action

**Mais il est sous-utilisé** car :
1. Pas de lien direct avec `/brainstorm`
2. `/apex:1-analyze` ne suggère pas son utilisation
3. Pas de détection automatique de tâches vagues

---

## Architecture APEX Integration (Solution A)

### Pourquoi NE PAS fusionner brainstorm dans analyze

| Aspect | `/brainstorm` | `/apex:1-analyze` |
|--------|---------------|-------------------|
| **But** | Explorer les APPROCHES possibles | Collecter le CONTEXTE pour implémenter |
| **Output** | Recommandations, trade-offs | Fichiers à modifier, patterns |
| **Quand** | Tâche vague, décision stratégique | Tâche définie, prêt à coder |

**Conclusion** : Ce sont deux outils complémentaires, pas redondants.

### Step 0 : Clarity Check (à ajouter dans 1-analyze.md)

```markdown
### 0. CLARITY CHECK (before everything)

**Analyze "$ARGUMENTS" for vagueness indicators:**

Vague patterns to detect:
- Vague adjectives: "améliorer", "optimiser", "mieux", "better", "improve"
- Missing specifics: no file paths, no concrete outcome mentioned
- Exploratory language: "explorer", "réfléchir", "brainstorm", "explore"
- Question framing: "comment faire", "quelle approche", "how to"

**If 2+ indicators detected:**

Use AskUserQuestion:
- Question: "Cette tâche semble exploratoire. Veux-tu clarifier l'approche d'abord ?"
- Options:
  1. "Lancer /brainstorm d'abord" → Display command and stop
  2. "Continuer avec Q&A rapide" → Ask 2-3 clarifying questions inline
  3. "Continuer directement" → Proceed to Step 1

**If task is clear:** Skip to Step 1 (SETUP TASK FOLDER)
```

### Workflow résultant

```
┌─────────────────────────────────────────────────┐
│  /apex:1-analyze "Améliorer le tracking"        │
│                      │                          │
│              ┌───────▼───────┐                  │
│              │ CLARITY CHECK │                  │
│              │ (Step 0)      │                  │
│              └───────┬───────┘                  │
│                      │                          │
│     ┌────────────────┼────────────────┐         │
│     │                │                │         │
│  [VAGUE]        [MODERATE]       [CLEAR]        │
│     │                │                │         │
│     ▼                ▼                ▼         │
│ "Suggère      Q&A inline        Continue        │
│ /brainstorm"  (2-3 Q's)         normally        │
│     │                │                │         │
│     │                └────────┬───────┘         │
│     │                         │                 │
│     │                 ┌───────▼───────┐         │
│     │                 │  ULTRA THINK  │         │
│     │                 │  + Agents     │         │
│     │                 └───────────────┘         │
└─────┴───────────────────────────────────────────┘
```

---

## Proposed Architecture

### Phase 0: Context Gathering (NOUVEAU)

**Avant** le Round 1 actuel, ajouter une phase de clarification :

```markdown
## PHASE 0: Context Gathering (Interactive)

1. ANALYZE the topic "$ARGUMENTS":
   - Is it vague or specific?
   - What domain? (tech, business, creative, research)
   - What type of output expected? (ideas, solutions, analysis, recommendations)

2. DETERMINE if clarification needed:
   - If topic is clear and specific → Skip to Round 1
   - If topic is vague → Enter interview loop

3. INTERVIEW LOOP (if needed):
   - Ask 2-3 focused questions per round
   - Wait for user responses
   - Detect satisfaction signal
   - Synthesize understanding before proceeding
```

### Questions adaptatives par type de brainstorming

**Feature/Product ideation:**
- "Pour qui est cette fonctionnalité ? (utilisateurs cibles)"
- "Quel problème principal doit-elle résoudre ?"
- "Y a-t-il des contraintes techniques ou business ?"

**Problem-solving:**
- "Peux-tu décrire le problème plus en détail ?"
- "Qu'as-tu déjà essayé qui n'a pas fonctionné ?"
- "Quels critères définiraient une bonne solution ?"

**Architecture/Design:**
- "Quels sont les composants ou systèmes concernés ?"
- "Y a-t-il des contraintes de performance ou scalabilité ?"
- "Quelle est la priorité : simplicité, flexibilité, ou performance ?"

**Research/Analysis:**
- "Quel est l'objectif de cette recherche ?"
- "Y a-t-il un angle ou perspective particulier à privilégier ?"
- "Quel niveau de profondeur souhaites-tu ?"

---

## Key Files to Modify

| File | Changes | Complexity |
|------|---------|------------|
| `commands/brainstorm.md` | Ajouter Phase 0 Q&A progressif, adapter YAML avec `allowed-tools: AskUserQuestion` | Medium |
| `commands/apex/1-analyze.md` | Ajouter Step 0 Clarity Check avec détection de tâches vagues | Low |

---

## Implementation Recommendations

### Pour `/brainstorm` (Phase 0 Q&A)

1. **Garder la structure existante** - Les 4 rounds actuels sont solides, juste ajouter Phase 0 avant

2. **Utiliser le pattern de handoff.md:107-188** - Multi-round interview avec détection de satisfaction

3. **Adapter les questions au contexte** - Détecter le type de brainstorming et poser des questions pertinentes

4. **Permettre le skip** - Si le topic est déjà clair, permettre de sauter Phase 0

5. **Synthèse avant action** - Confirmer la compréhension avant de lancer les agents de recherche

### Pour `/apex:1-analyze` (Clarity Check)

6. **Ajouter Step 0 avant tout** - Détection de tâches vagues avec patterns regex

7. **3 options via AskUserQuestion** :
   - "Lancer /brainstorm d'abord" → suggérer la commande
   - "Q&A rapide inline" → poser 2-3 questions
   - "Continuer directement" → skip

8. **Non-bloquant** - L'utilisateur garde le contrôle total

---

## Summary

Cette amélioration crée une **synergie entre `/brainstorm` et APEX** :

```
/brainstorm "topic vague"     →  Exploration approfondie (4 rounds)
                                      ↓
/apex:handoff --brainstorm    →  Q&A pour seed (déjà existant)
                                      ↓
/apex:1-analyze               →  Clarity Check (NOUVEAU)
                                 suggère /brainstorm si vague
```

**Résultat** : L'utilisateur est guidé vers le bon outil selon la clarté de sa tâche.

---

## Next Step

Run `/apex:plan 19-improve-brainstorm-qa-sessions` to create the implementation plan.
