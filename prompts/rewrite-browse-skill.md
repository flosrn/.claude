Réécris le skill `/browse` (shared-skill sur le VPS à `/root/shared-skills/browse/`) pour remplacer l'approche tmux par le pattern "telephone game" acpx.

## Avant de coder quoi que ce soit

Lis et analyse en profondeur ces deux références :

1. **`/acpx-guide`** (`~/.claude/skills/acpx-guide/SKILL.md`) — le guide complet acpx basé sur notre expérience. Comprends le pattern "telephone game" (exec → acpx CLI), les bugs connus, les prérequis, le troubleshooting.

2. **`ai-qa-testing`** sur le VPS (`/root/.openclaw/workspace-gapibot/skills/ai-qa-testing/`) — le skill QA qui utilise déjà le pattern acpx avec succès. Analyse le `SKILL.md` ET le script `scripts/run-qa.sh`. C'est le modèle à suivre.

## Contexte

Le skill `/browse` actuel lance Claude Code dans tmux (`launch-browse.sh`) pour naviguer sur le web via Playwright MCP. Ça marche mais c'est fragile :
- Problèmes de PATH pour trouver `claude`
- Problèmes de quoting pour les prompts multi-lignes
- `tmux capture-pane` ne capture pas bien la sortie Ink de Claude Code
- Complexité inutile (tmux sessions, pipe-pane, log parsing)

## Ce que tu dois faire

1. **Remplacer `launch-browse.sh`** par un script `run-browse.sh` inspiré de `run-qa.sh` :
   - Source les env vars depuis le workspace `.env`
   - Écrit le prompt dans un fichier temp (`--file`)
   - Lance `acpx --approve-all --format text claude exec --file prompt.txt`
   - Stream le résultat sur stdout
   - Pas de tmux, pas de log parsing

2. **Réécrire le `SKILL.md`** :
   - L'agent appelle juste : `exec: bash .../scripts/run-browse.sh --url <URL> --task "description"`
   - Avec `yieldMs: 10000` pour backgrounder
   - Poll avec `process(poll)` pour récupérer le résultat
   - JAMAIS `sessions_spawn(runtime: "acp")` — c'est buggy
   - JAMAIS `sessions_yield` — on perd le résultat

3. **Garder le support du stealth browser** :
   - Le browse skill utilise un browser stealth sur port 9223 (pas le sandbox browser sur 9222)
   - Vérifier dans `~/.claude.json` si `playwright-stealth` est configuré
   - Le prompt doit spécifier `mcp__playwright-stealth__*` (pas `mcp__playwright__*`)

4. **Attention aux pièges** (documentés dans acpx-guide) :
   - `set -eo pipefail` (pas `-u` — les env vars peuvent être vides)
   - Sourcer le `.env` du workspace car `exec` n'hérite pas des env vars du container
   - Le chemin acpx est `/app/extensions/acpx/node_modules/.bin/acpx`
   - Après un recreate du container, il faut que `init-gateway.sh` ait tourné pour que acpx soit installé

5. **Le skill est dans shared-skills** → disponible pour TOUS les agents (Clawd, Gapibot, Shipmate). Le script doit fonctionner quel que soit l'agent qui l'appelle.

## Structure finale attendue

```
/root/shared-skills/browse/
├── SKILL.md              (~80-100 lignes, simple et direct)
└── scripts/
    └── run-browse.sh      (le script qui fait tout)
```

## Test

Après la réécriture, teste avec :
```bash
docker exec openclaw-gateway bash -c "bash /home/node/shared-skills/browse/scripts/run-browse.sh --url https://gapila.com --task 'Report the page title and count the number of links on the page.'"
```
