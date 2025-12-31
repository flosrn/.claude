# Analysis: APEX Vision Agent avec Claude Opus 4.5

**Analyzed**: 2025-12-31
**Status**: Complete

## Quick Summary (TL;DR)

> Implémenter un agent vision dans APEX qui utilise **Claude Opus 4.5** pour analyser les screenshots et images drag & drop. **Usage principal** : enrichir le contexte pour le debugging (screenshot de l'état actuel d'une page Gapila), secondairement pour l'inspiration ou nouvelles features.

**Key files to modify:**
- `agents/vision-analyzer.md` - **Nouveau** agent dédié avec `model: opus`
- `commands/apex/1-analyze.md` - Ajouter détection d'images et lancement agent vision

**Patterns to follow:**
- Format frontmatter agent : `agents/apex-executor.md:1-7` (model: sonnet → model: opus)
- Lancement parallèle agents : `commands/apex/1-analyze.md:94-108`

**⚠️ Gotchas discovered:**
- Le skill `ai-multimodal` utilise **Gemini**, pas Claude - ne pas réutiliser
- Claude Code lit déjà les images nativement via le tool `Read`
- Les images drag & drop arrivent comme fichiers temporaires ou inline dans le message
- **L'usage principal n'est PAS design-to-code mais debugging visuel et contexte**

**Dependencies:** Aucun bloquant - Claude Opus 4.5 supporte la vision nativement

**Estimation:** ~2 tasks, ~1h total

---

## Cas d'usage prioritaires

| Priorité | Cas | Exemple | Output attendu |
|----------|-----|---------|----------------|
| 🥇 **Principal** | Bug visuel / Debugging | "Le bouton est coupé" + screenshot | Description de l'état visible, élément problématique, hypothèses de cause |
| 🥈 **Fréquent** | Contexte page | "Sur cette page..." + screenshot | Description complète de la page, composants visibles, état actuel |
| 🥉 **Occasionnel** | Inspiration design | "Je veux un style comme ça" | Patterns, couleurs, layout à reproduire |
| 4 | Nouvelle feature | "Implémente ce mockup" | Design-to-code structuré |

---

## Architecture Proposée

### Option retenue : Agent dédié avec model: opus

```
User drag & drop image dans Ghostty
         │
         ▼
/apex:1-analyze détecte l'image
         │
         ├── Lancement parallèle ───────────────────────┐
         │                                              │
         ▼                                              ▼
┌─────────────────────┐                    ┌─────────────────────┐
│ vision-analyzer     │                    │ explore-codebase    │
│ model: opus         │                    │ explore-docs        │
│ Analyse l'image     │                    │ websearch           │
└─────────────────────┘                    └─────────────────────┘
         │                                              │
         ▼                                              │
image-analysis.md                                       │
         │                                              │
         └──────────────────┬───────────────────────────┘
                            ▼
                     analyze.md
                (inclut résumé vision)
```

### Composants à créer

#### 1. `agents/vision-analyzer.md`

```yaml
---
name: vision-analyzer
description: Analyze UI screenshots and design mockups using Claude Opus 4.5 vision. Extracts components, layout, colors, and implementation guidance.
color: pink
model: opus
permissionMode: default
---
```

**Prompt** :
- Analyser screenshots UI : composants, layout, hiérarchie
- Analyser mockups design : couleurs, typography, spacing
- Produire output structuré pour implémentation

#### 2. Modification `commands/apex/1-analyze.md`

Ajouter après Step 2 (ULTRA THINK) :

```markdown
### Vision Detection (if images in conversation)

**Step 2b**: Check for images in current context
- Detect image file paths mentioned in user message
- Detect inline images (base64 or temp files from drag & drop)

**If images detected:**
Launch vision-analyzer agent in parallel:
```
Task(
  subagent_type="vision-analyzer",
  model="opus",
  prompt="Analyze these UI/design images: [paths]. Extract: components, layout, colors, implementation notes.",
  run_in_background=true
)
```
```

---

## Codebase Context

### Agent Definition Format

Découvert dans `agents/apex-executor.md:1-7` :

```yaml
---
name: apex-executor
description: Dedicated APEX task executor...
color: purple
model: sonnet          # ← Clé pour spécifier le modèle
permissionMode: acceptEdits
---
```

**Modèles disponibles** (via Task tool) : `sonnet`, `opus`, `haiku`

### Skill ai-multimodal (Gemini) - À NE PAS utiliser

Le skill existant `skills/ai-multimodal/SKILL.md` utilise :
- **Gemini 2.5 Flash/Pro** via Google API
- Scripts Python custom (`gemini_batch_process.py`)
- N'est PAS compatible avec notre besoin Claude Opus

### Image Reading in Claude Code

Claude Code peut lire les images nativement :
- Tool `Read` supporte PNG, JPG, WEBP, HEIC, HEIF
- Les images sont présentées visuellement à Claude (multimodal LLM)
- Fonctionne avec chemins de fichiers absolus

---

## Documentation Insights

### Claude Opus 4.5 Vision Capabilities

D'après la recherche web :
- **Meilleure compréhension sémantique UI** parmi les modèles frontier
- **Design-to-code supérieur** : produit du HTML/React clean
- **Contexte** : 200K tokens standard, 1M beta
- **Pricing** : $5 input / $25 output per 1M tokens

### Input Formats Supportés

- Base64 inline dans le message
- Chemins de fichiers (via tool Read)
- URLs publiques

---

## Implementation Plan Preview

### Task 1: Créer l'agent vision-analyzer

**Fichier** : `agents/vision-analyzer.md`

**Contenu** :
- Frontmatter avec `model: opus`
- Prompt spécialisé pour UI/UX analysis
- Output format structuré (markdown)
- Instructions pour différents types d'images

### Task 2: Intégrer dans 1-analyze.md

**Modifications** :
1. Ajouter section "Vision Detection"
2. Pattern de détection d'images dans conversation
3. Lancement agent vision en parallèle
4. Merge des résultats vision dans analyze.md

---

## Output Format: image-analysis.md

Le format s'adapte au cas d'usage détecté :

### Format Debugging (cas principal)

```markdown
# Image Analysis: Debugging Context

**Analyzed by**: Claude Opus 4.5
**Date**: [timestamp]
**Type**: Bug / Visual Issue

## Screenshot Description

**Page**: [URL or page name if identifiable]
**Viewport**: ~[estimated width]px

### What I See
- Header with logo "Gapila" and navigation
- Main content area showing a campaign card
- Modal overlay partially visible
- [etc.]

### Potential Issues Detected
1. **Button alignment**: The "Submit" button appears cut off on the right edge
2. **Overflow**: Content seems to overflow its container
3. **Z-index**: Modal appears behind the header

### Likely Causes (hypotheses)
- Missing `overflow-hidden` on parent container
- Fixed positioning conflict with flex layout
- Z-index stacking context issue

### Relevant Components to Check
- `components/CampaignCard.tsx` - card container styles
- `components/Modal.tsx` - positioning and z-index
- `app/[account]/campaigns/page.tsx` - layout wrapper
```

### Format Context (enrichissement)

```markdown
# Image Analysis: Page Context

**Analyzed by**: Claude Opus 4.5
**Date**: [timestamp]
**Type**: Context / Reference

## Current Page State

**Page**: Campaign Editor
**User State**: Logged in, editing campaign "Noël 2024"

### Visible Elements
- Sidebar: campaign settings (name, dates, status)
- Main: wheel preview with 6 segments
- Header: breadcrumb showing Campaigns > Noël 2024 > Edit

### Data Displayed
- Campaign name: "Noël 2024"
- Status: Draft
- Segments: 6 visible (Café offert, Menu -10%, ...)

### UI State
- No modals open
- Sidebar collapsed on mobile
- Form appears unsaved (no checkmark)
```

### Format Inspiration (design-to-code)

```markdown
# Image Analysis: Design Reference

**Analyzed by**: Claude Opus 4.5
**Date**: [timestamp]
**Type**: Inspiration / New Feature

## Design Patterns to Extract

### Layout
- 2-column grid with sticky sidebar
- Card-based content with hover states

### Colors
- Primary: #3B82F6 (blue)
- Background: #F9FAFB

### Components to Implement
- `ProductCard` with image, title, price
- `StickyFilters` sidebar component
```

---

## Questions Ouvertes

1. **Détection des images** : Comment détecter quand l'utilisateur a drag & drop une image ?
   - Option A : Regex sur le message pour détecter les chemins `/tmp/` ou `/var/`
   - Option B : Nouveau paramètre `--image <path>` explicite
   - Option C : L'utilisateur mentionne "j'ai partagé une image"

2. **Stockage des images** : Copier les images dans le dossier task ?
   - Avantage : référence persistante dans seed.md
   - Inconvénient : duplication de données

---

## Next Steps

Run `/apex:2-plan 09-apex-vision-agent` to create the implementation plan.
