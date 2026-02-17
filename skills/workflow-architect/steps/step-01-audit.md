---
name: step-01-audit
description: Analyze codebase structure and detect architectural smells
next_step: steps/step-02-design.md
---

# Step 1: AUDIT (Structure Analysis)

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER modify any files during this step
- ✅ ALWAYS map the full dependency graph before reporting
- ✅ ALWAYS quantify smells (file sizes, import counts, nesting depth)
- 📋 YOU ARE AN AUDITOR - observe and report only
- 🚫 FORBIDDEN to use Edit, Write, or Bash (except for analysis commands)

## CONTEXT BOUNDARIES:

- User has provided `{scope}` (target area or full codebase)
- No analysis has been done yet
- No changes approved yet

## YOUR TASK:

Perform a comprehensive architectural audit of `{scope}`, detecting structural smells and mapping dependencies.

---

## EXECUTION SEQUENCE:

### 1. Parse Arguments

Extract from `$ARGUMENTS`:

| Variable | Extraction |
|----------|-----------|
| `{scope}` | Target path or description (default: `src/`) |
| `{auto_mode}` | `-a` flag present |
| `{economy_mode}` | `-e` flag present |
| `{save_mode}` | `-s` flag present |
| `{audit_only}` | `--audit-only` flag present |
| `{dry_run}` | `--dry-run` flag present |
| `{standalone_mode}` | `--standalone` flag present (default: false) |
| `{task_id}` | Kebab-case from scope description |

### 2. Initialize Save Output (if save_mode)

**If `{save_mode}` = true:**

```bash
mkdir -p .claude/output/architect/{task_id}
```

Append findings to `.claude/output/architect/{task_id}/01-audit.md` as you work.

### 3. Load Architecture Smells Reference

Read the reference file to know what to detect:

```
Read: {skill_dir}/references/architecture-smells.md
```

### 4. Map Codebase Structure

**If `{economy_mode}` = true:**
→ Direct tools only (Read, Grep, Glob, Bash)

**If `{economy_mode}` = false:**
→ Launch 3 agents in parallel (single message):

| Agent | Type | Task |
|-------|------|------|
| 1 | Explore | Map directory tree, find large files (>300 lines), count exports per file |
| 2 | Explore | Detect circular dependencies, map import graph for `{scope}` |
| 3 | Explore | Find god modules, orphan files, misplaced code patterns |

### 4b. Frontend Smell Detection (if scope contains components or routes)

If `{scope}` includes frontend components, landing page sections, or API routes, run these additional checks:

**Route handler analysis:**
- Scan `**/route.ts` files for inline `interface`/`type` declarations → Smell #13 (Inline Types in Routes)
- Scan `**/route.ts` files > 150 lines with `.map()` or object construction → Smell #12 (Fat Route Handler)

**Component section analysis:**
- Find directories with 8+ `.ts`/`.tsx` files and no subdirectories → Smell #15 (Flat Component Section)
- Compare sibling section structures for inconsistency (some use `lib/`, others don't)

**Wrapper detection:**
- Find component files < 20 lines that import and render a single child component → Smell #14 (Unnecessary Wrapper)

Include frontend smells in the findings table alongside generic architectural smells (same Critical/Warning/Info severity tiers).

### 5. Quantify Findings

Build a structured report:

```markdown
## Architecture Audit: {scope}

### Structure Overview
| Metric | Value |
|--------|-------|
| Total files | X |
| Total lines | X |
| Average file size | X lines |
| Max file size | X lines (`path/to/file.ts`) |
| Nesting depth (max) | X levels |
| Circular dependencies | X |

### Architectural Smells Detected

#### Critical (must fix)
| Smell | Location | Details |
|-------|----------|---------|
| God Module | `src/utils/helpers.ts` (842 lines) | 23 exports, 5+ responsibilities |
| Circular Dep | `auth ↔ user` | `useAuth` imports `userService`, `userService` imports `authToken` |

#### Warning (should fix)
| Smell | Location | Details |
|-------|----------|---------|
| Feature Scatter | auth feature | 7 files across 5 directories |
| Hub Module | `src/types/index.ts` | Imported by 45% of files |

#### Info (consider)
| Smell | Location | Details |
|-------|----------|---------|
| Barrel Bloat | `src/components/index.ts` | Re-exports 32 components |
| Deep Nesting | `src/lib/api/v2/internal/` | 6 levels deep |

### Dependency Map (Key Relationships)
```
  auth → [user, api, types, store]
  dashboard → [api, types, components, auth]
  user → [api, types, auth]  ← circular with auth!
```

### Most-Imported Files (Hub Analysis)
| File | Import Count | % of Codebase |
|------|-------------|---------------|
| `src/types/index.ts` | 45 | 60% |
| `src/utils/helpers.ts` | 32 | 42% |

### Orphan Files (Dead Code)
- `src/utils/oldHelper.ts` (not imported anywhere)
- `src/components/DeprecatedBanner.tsx` (not imported anywhere)
```

### 6. Present Findings

**If `{audit_only}` = true:**
→ Present the audit report and stop. Do not load step-02.

**If `{auto_mode}` = true:**
→ Proceed directly to step-02.

**If `{auto_mode}` = false:**

```yaml
questions:
  - header: "Next Step"
    question: "Audit complete. How would you like to proceed?"
    options:
      - label: "Design restructuring plan (Recommended)"
        description: "Create a detailed plan to fix the detected smells"
      - label: "Focus on critical issues only"
        description: "Only plan fixes for critical smells"
      - label: "Stop here"
        description: "Review the audit report first, restructure later"
    multiSelect: false
```

---

## SUCCESS METRICS:

- All architectural smells quantified with file:line references
- Dependency map captures actual import relationships
- Hub modules identified with import counts
- Circular dependencies detected
- File sizes and complexity measured

## FAILURE MODES:

- Modifying any files during audit
- Reporting smells without evidence (file paths, line counts)
- Missing circular dependencies
- Not quantifying severity

---

## NEXT STEP:

After audit complete, load `./step-02-design.md`

<critical>
AUDIT ONLY - don't change anything!
</critical>
