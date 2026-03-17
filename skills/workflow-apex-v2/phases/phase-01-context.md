---
name: phase-01-context
description: Context gathering - explore codebase, research, infer acceptance criteria
prev_phase: ./phase-00-init.md
next_phase: ./phase-02-plan.md
---

# Phase 1: Context

Explorer (read-only, no planning, no implementation)

---

## EXECUTION SEQUENCE

### 1. Initialize

```bash
source {output_dir}/.env.local
bash {skill_dir}/scripts/update-progress.sh "{TASK_ID}" "01" "context" "in_progress"
```

Mark phase in progress.

### 2. Read Reference Documents

**If {REFERENCE_FILES} set:**

- Read each file
- Extract key information (requirements, specs, acceptance criteria)
- Scan for patterns, examples, existing implementations
- Save to `{output_dir}/01-context.md` section: "Reference Documents"

**If ISSUE_URL set:**

- Read `{output_dir}/issue-context.md` (created in phase-00)
- Extract labels, assignee, description
- Parse acceptance criteria from issue body (look for "Acceptance Criteria", "Requirements", checkboxes)

### 2b. Similar Issue Search (optional)

**IF {ISSUE_NUMBER} is set:**

Search for similar resolved issues to avoid regressions and learn from past fixes:

```bash
# Extract 2-3 key terms from issue title
KEYWORDS=$(echo "{task_description}" | tr ' ' '\n' | grep -vE '^(the|a|an|in|on|to|for|and|or|is|it|of|with)$' | head -3 | tr '\n' ' ')
gh issue list --search "$KEYWORDS" --state closed --limit 5 --json number,title,labels
```

For each similar closed issue:
- Note how it was resolved (linked PR, closing comment)
- Flag potential regression if same area of code is involved
- Add to `{output_dir}/01-context.md` section: "Similar Issues"

If no similar issues found, skip silently.

### 3. Extract Search Keywords

From task_description + issue body:

```
Examples:
  "Add authentication to API" → ["authentication", "API", "middleware", "JWT"]
  "Fix layout bug on mobile" → ["responsive", "mobile", "layout", "CSS", "breakpoint"]
```

Store as {search_keywords} array.

### 3b. Save-Every-2 Rule (applies to ALL exploration below)

**CRITICAL: Context is RAM, files are disk.**

After every 2 research/exploration operations (Read, Grep, Glob, agent results), immediately append key findings to `{output_dir}/01-context.md`. Do NOT accumulate findings only in conversation context.

```
Pattern:
  Operation 1 (e.g., Glob for *.ts files)
  Operation 2 (e.g., Read main entry point)
  → SAVE: append discovered file list + patterns to 01-context.md

  Operation 3 (e.g., Grep for auth patterns)
  Operation 4 (e.g., Read utility file)
  → SAVE: append auth patterns + utilities to 01-context.md
```

This prevents information loss if context compaction occurs mid-phase. Each save is an incremental append, not a full rewrite.

### 4. Explore Codebase

**Complexity assessment:**

- Small (1-5 files touched): 1-2 agents
- Medium (5-15 files): 3-5 agents
- Large (15+ files): 6-10 agents

**Exploration strategy (1 agent per area):**

1. File structure & conventions
2. Relevant entry points (main.ts, router, index.ts)
3. Utility/helper patterns
4. State management (store, context, reducers)
5. Testing patterns
6. Type definitions
7. Dependencies & external libraries
8. Configuration & environment
9. Documentation & examples
10. API/service integrations

**IF team_mode = true:**

```
Use Agent Teams:
  1. Create team: `TeamCreate` with name = {TASK_ID}
  2. For each area:
     - TaskCreate with subject, description
     - Agent assigns self via TaskUpdate (owner)
  3. Wait for agents to complete (auto-delivered messages)
  4. Collect findings from TaskList
  5. Synthesize in step 5 below
```

**IF team_mode = false (default):**

```
Use 1 Explore agent:
  - Query: "Explore codebase for {TASK_DESCRIPTION}"
  - Focus on {search_keywords}
  - Collect: file list, key files, patterns, utilities
```

Model hints (inline):
```yaml
- Explore agents: model "haiku" (fast, read-only)
- explore-docs agents: model "sonnet" (research, synthesis)
```

### 5. Synthesize Findings

**Structure into sections (save to `{output_dir}/01-context.md`):**

```markdown
# Phase 1: Context

## Task Requirements
- Feature to implement
- Success criteria (inferred from issue + description)
- Non-functional requirements

## Codebase Context
### File Structure
- List of relevant files with line numbers
- Folder organization

### Key Patterns
- Style patterns (naming, structure)
- Common utilities and helpers
- Architecture layer examples

### Existing Implementations
- Similar features already in codebase
- Patterns to follow/avoid

## Documentation Insights
- README sections relevant to task
- API docs, type definitions
- Configuration examples

## Research Findings
- External library patterns (if applicable)
- Best practices for this domain
- Performance considerations

## Acceptance Criteria (Inferred)
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3
```

### 6. Infer Acceptance Criteria

If not explicitly listed in issue/description:

```
Common patterns:
  Feature implementation:
    ✓ Functionality works as specified
    ✓ Follows existing code style
    ✓ Type-safe (no 'any')
    ✓ Tests pass (if test_mode)

  Bug fix:
    ✓ Reproduces original issue
    ✓ Fix resolves issue
    ✓ No regressions
    ✓ Tests added

  Refactor:
    ✓ Behavior unchanged
    ✓ All tests pass
    ✓ Code duplication reduced
    ✓ Performance maintained or improved
```

Add inferred criteria to context file.

### 7. Mark Complete

```bash
bash {skill_dir}/scripts/update-progress.sh "{TASK_ID}" "01" "context" "complete"
```

### 8. Handle Phase Boundary

**IF pause_mode = true:**

```bash
bash {skill_dir}/scripts/session-boundary.sh "{TASK_ID}"
echo "ℹ️ Session paused. Resume with: /apex -r {TASK_ID}"
```

STOP execution. User resumes next session.

**IF pause_mode = false (default):**

Proceed directly to phase-02-plan.
