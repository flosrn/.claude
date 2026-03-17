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

### 3. Extract Search Keywords

From task_description + issue body:

```
Examples:
  "Add authentication to API" → ["authentication", "API", "middleware", "JWT"]
  "Fix layout bug on mobile" → ["responsive", "mobile", "layout", "CSS", "breakpoint"]
```

Store as {search_keywords} array.

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
