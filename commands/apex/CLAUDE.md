# APEX Workflow System

Multi-session workflow orchestrator: **A**nalyze → **P**lan → **E**xecute → e**X**amine

> See [overview.md](./overview.md) for detailed phase walkthroughs and comprehensive examples.

## Quick Reference

| Command | Purpose | Key Flags |
|---------|---------|-----------|
| `/apex:1-analyze` | Gather context & research | `--yolo` |
| `/apex:2-plan` | Design implementation strategy | `--yolo` |
| `/apex:tasks` | Divide plan into task files | `--yolo` |
| `/apex:3-execute` | Implement changes | `--parallel`, `--dry-run`, `--quick`, `--force-sonnet`, `--force-opus` |
| `/apex:4-examine` | Two-phase validation (technical + logical) | `--foreground`, `--global`, `--skip-patterns` |
| `/apex:5-browser-test` | Browser testing with GIF | `--url=`, `--no-gif` |
| `/apex:next` | Run next pending task | - |
| `/apex:status` | Show progress tree | - |
| `/apex:handoff` | Transfer context to new workflow | `--vision`, `--brainstorm` |

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

**Global Scope** (`--global`): For examine phase, analyze ALL feature files instead of just modified ones. More comprehensive but slower.

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
| `seed.md` | `/apex:handoff` | Prior context transfer (BLUF structure) |
| `analyze.md` | `/apex:1-analyze` | Research findings, patterns, gotchas |
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

**BLUF structure** (for seed.md): Objectif first, supporting context second, technical details last.

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
