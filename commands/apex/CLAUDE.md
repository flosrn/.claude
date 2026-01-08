# APEX Workflow System

Multi-session workflow orchestrator: **A**nalyze → **P**lan → **E**xecute → e**X**amine

> See [overview.md](./overview.md) for detailed phase walkthroughs and comprehensive examples.

## Quick Reference

| Command | Purpose | Key Flags |
|---------|---------|-----------|
| `/apex:0-brainstorm` | Adaptive research with smart agent routing | `<topic>` or `<folder>` |
| `/apex:1-analyze` | Gather context & research | `--yolo` |
| `/apex:2-plan` | Design implementation strategy | `--yolo` |
| `/apex:tasks` | Divide plan into task files | `--yolo` |
| `/apex:3-execute` | Implement changes | `--parallel`, `--continue`, `--validate`, `--quick`, `--dry-run`, `--force-sonnet`, `--force-opus` |
| `/apex:4-examine` | Two-phase validation (technical + logical) | `--foreground`, `--global`, `--skip-patterns` |
| `/apex:5-browser-test` | Browser testing with GIF | `--url=`, `--no-gif`, `--parallel` |
| `/apex:next` | Run next pending task | - |
| `/apex:status` | Show progress tree | - |
| `/apex:handoff` | Transfer context to new workflow | `-` |

## Task Folder Structure

```
.claude/tasks/NN-kebab-name/
├── seed.md              # Context from /apex:handoff (optional)
├── analyze.md           # Phase 1: research findings
├── plan.md              # Phase 2: file-centric changes
├── implementation.md    # Phase 3/4: session log
└── tasks/               # From /apex:tasks (optional)
    ├── index.md         # Task list with dependencies
    ├── task-01.md       # Individual task
    └── ...
```

**Path**: `./.claude/tasks/<folder>/`

> ⚠️ **CRITICAL**: This path is INTENTIONALLY `.claude/.claude/tasks/` when working dir is `~/.claude`.
> This is NOT a typo. The project root IS the `.claude` config folder, and tasks go in a NESTED `.claude/tasks/` subfolder.
> **NEVER "simplify" or "correct" this path.** Always use `./.claude/tasks/` exactly as written.

## Mode Flags

**YOLO Mode** (`--yolo`): Auto-continues to next phase via hooks. Creates `.yolo` marker file. Stops at execute phase for safety.

**Background Mode**: Agents run asynchronously while asking clarifying questions. Default on analyze and examine phases.
- Use `--foreground` on examine phase to disable background execution

**Parallel Mode** (`3,4` or `--parallel`): Execute multiple tasks concurrently. Verify tasks don't depend on each other before using.

**Continue Mode** (`--continue`): Resume execution from last session state. Reads progress from `implementation.md` and continues where interrupted.

**Validation Mode**: Execute phase skips validation by default. Use these flags to opt-in:
- `--validate`: Run typecheck/lint after task, attempt fixes
- `--quick`: Run validation but stop immediately on first error

**Global Scope** (`--global`): For examine phase, analyze ALL feature files instead of just modified ones. More comprehensive but slower.

## Adaptive Agent Routing (Brainstorm)

The `/apex:0-brainstorm` command uses a **scoring system** to select optimal research agents:

| Dimension | Scores | Agent Selection |
|-----------|--------|-----------------|
| **Code Relevance** | 0-2: Skip | 3-4: 1x explore-codebase | 5+: 2x explore-codebase |
| **Web Research** | 0-1: Skip | 2-3: websearch (3 angles) | 4+: intelligent-search |
| **Documentation** | 0-1: Skip | 2+: explore-docs |

**intelligent-search** auto-routes to best provider:
- Tavily: Factual queries with citations
- Exa: Semantic/deep search
- Perplexity: Complex reasoning (API key required)

**Signal examples** that increase scores:
- Code: "améliorer src/auth/*" (+3), "optimiser le cache actuel" (+2)
- Web: "React 19 features" (+3), "Redis vs alternatives" (+2)
- Docs: "Stripe webhooks" (+3), "connect Drizzle with Supabase" (+2)

## Seed Mode (Brainstorm from Handoff)

Brainstorm auto-detects when argument is an existing task folder and enters **Seed Mode**:

```
/apex:0-brainstorm 27-my-feature    ← Seed Mode (enriches existing seed.md)
/apex:0-brainstorm "new topic"      ← Fresh Mode (creates new folder)
```

**Seed Mode workflow:**
1. Detects folder pattern (`^\d+-`)
2. Reads existing `seed.md` from `/apex:handoff`
3. Pre-loads context (Mission, Specs, Files)
4. Skips interview phase (specs already defined)
5. Runs Research Loop with pre-loaded context
6. **ENRICHES** existing seed.md (preserves + adds research sections)

**Sections preserved:** 🎯 Mission, ✅ Critères, 📋 Spécifications
**Sections added:** 🔍 Brainstorm Summary, 📊 Strategy Scores, 🧭 Decision Journey

**Use case:** `/apex:handoff` → `/apex:0-brainstorm <folder>` → `/apex:1-analyze <folder>`

## Smart Skip (Post-Brainstorm)

When `/apex:1-analyze` detects a seed.md from `/apex:0-brainstorm`, it enters **ultra-light mode**:

| Agent | Full Mode | Post-Brainstorm (code≥3) | Post-Brainstorm (code<3) |
|-------|-----------|--------------------------|--------------------------|
| `explore-codebase` | Adaptive | ⏭️ Skip | ✅ Light scan |
| `explore-docs` | Adaptive | ⏭️ Skip | ⏭️ Skip |
| `websearch` | Adaptive | ⏭️ Skip | ⏭️ Skip |
| `vision-analyzer` | If image | If image | If image |

**Score inheritance**: Analyze reads `### 📊 Strategy Scores` from seed.md to determine if brainstorm already did comprehensive codebase exploration (code_score ≥ 3).

**Detection**: Looks for `## 🔍 Brainstorm Summary` or `### Brainstorm Summary` in seed.md.

**Why?** Research Loop already performed comprehensive research. Ultra-light mode avoids redundant exploration.

## Adaptive Routing (Analyze Mode B)

When `/apex:1-analyze` runs WITHOUT prior brainstorm, it calculates its own strategy scores:

| Dimension | 0-2 | 3-4 | 5+ |
|-----------|-----|-----|-----|
| **Code** | Skip | 1 agent | 2 agents |
| **Web** | Skip | websearch | intelligent-search |
| **Docs** | Skip | explore-docs | explore-docs |

This matches brainstorm's adaptive routing, ensuring consistent behavior whether user starts with brainstorm or analyze.

## Two-Phase Validation (Examine)

The examine phase runs two sequential validations:

| Phase | Purpose | Behavior |
|-------|---------|----------|
| **Phase 1: Technical** | Build, typecheck, lint | Fast, runs in background by default |
| **Phase 2: Logical** | Coherence, edge cases, patterns | Deep analysis, only if Phase 1 passes |

**Scope modes**:
- Standard (default): Modified files + direct dependencies
- Global (`--global`): All files in feature directory

## Smart Model Selection

Execute phase automatically selects the optimal model (Sonnet vs Opus) per task based on complexity scoring:

| Criterion | Points |
|-----------|--------|
| Modifies existing files | +2 |
| Modifies 3+ existing files | +1 |
| Contains "integration/integrate" | +2 |
| Contains "API/SDK/callback" | +1 |
| Contains "refactor/migration" | +1 |
| Has 3+ dependencies | +1 |
| Mentions gotchas/risks | +1 |

**Thresholds**: 0-2 = Sonnet, 3+ = Opus

**Override flags**:
- `--force-sonnet`: Always use Sonnet (faster, cheaper)
- `--force-opus`: Always use Opus (complex tasks)

## File Artifacts

| File | Created By | Purpose |
|------|------------|---------|
| `seed.md` | `/apex:handoff`, `/apex:0-brainstorm`, or both | Prior context (handoff) + research (brainstorm) |
| `analyze.md` | `/apex:1-analyze` | Research findings, patterns, gotchas (includes Strategy Scores) |
| `plan.md` | `/apex:2-plan` | File-by-file change plan (no code snippets) |
| `tasks/` | `/apex:tasks` | Granular task breakdown with dependencies |
| `implementation.md` | `/apex:3-execute` | Session log, changes made, test results |

## Conventions

**Naming**: Use KEBAB-CASE for task folders (`08-auth-feature`, not `08_auth_feature`)

**Planning style**: File-centric (organized by file, not feature):
```markdown
### `src/auth/middleware.ts`
- Create JWT validation function
- Add error handling for expired tokens
```

**Parallel notation**: Use arrows for dependencies, pipes for parallel:
`Task 1 → [Task 2 ‖ Task 3] → Task 4`

**Directive template** (for seed.md): Objectif first, supporting context second, technical details last.

## Bash Portability

The system uses portable constructs to avoid alias and shell compatibility issues:
- `/usr/bin/grep -E` instead of `grep -E` (bypasses rg alias)
- `/bin/ls -1t` instead of `ls -1t` (bypasses eza alias)
- `sort -t- -k1 -n` instead of `sort -V` (portable numeric sort)
- `VAR="$(cmd | pipe)"` instead of `VAR=$(cmd | pipe)` (zsh requires quotes around `$()` with pipes)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| File not found errors | Use `./.claude/tasks/<folder>/file.md` (NOT `tasks/<folder>/...`) |
| YOLO doesn't continue | Verify `.yolo` file exists in task folder |
| Parallel tasks conflict | Check `index.md` for dependency violations |
| Hook not triggering | Verify hook registration in settings.json |
| Phase 2 not running | Phase 2 requires Phase 1 to pass (or user to skip) |
| Skill not invoked | Ensure `Skill` is in allowed-tools and skill description matches |
| Background too slow | Use `--foreground` for synchronous execution |
