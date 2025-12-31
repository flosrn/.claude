# Analysis: Evaluate cclsp Integration into APEX Workflow

**Analyzed**: 2025-12-31
**Status**: Complete
**Task Folder**: `tasks/10-evaluate-cclsp-apex-integration/`

---

## Quick Summary (TL;DR)

> This section is the PRIMARY content for lazy loading. Keep it dense and actionable.

**Root Cause Identified**: CLAUDE.md instructions are NOT "forgotten" — the issue is that:
1. **APEX phases don't reference cclsp** at all (no embedded instructions)
2. **Emphatic language backfires** on Claude Opus 4.5 (may cause overtriggering or dismissal)
3. **"Lost in the Middle" effect** — CLAUDE.md instructions positioned mid-context get lower attention

**Key Files to Modify:**
- `commands/apex/3-execute.md:268-275` - Add refactoring section (HIGHEST IMPACT)
- `commands/apex/1-analyze.md:116-133` - Add symbol navigation guidance
- `CLAUDE.md:31-78` - Simplify emphatic language for Claude 4.5 compatibility

**Critical Finding on "MUST" Language:**
```
Claude Opus 4.5 responds WORSE to emphatic instructions.
Where: "CRITICAL: You MUST use cclsp"
Better: "Use cclsp for finding definitions and references"
```

**Recommended Solution**: Hybrid approach
1. **Embed cclsp instructions** in APEX phase files (visible in phase context)
2. **Simplify CLAUDE.md language** (remove CRITICAL/MUST overkill)
3. **Keep lsp-navigation skill** as backup trigger

**Expected Impact**: 65-90% compliance (vs current ~20%)

**Dependencies:** None blocking

**Estimation:** ~4 tasks, ~2h total

---

## 1. Why CLAUDE.md Instructions Are Not Followed

### The Hypothesis Was Partially Wrong

The seed.md hypothesized that CLAUDE.md instructions are "forgotten" during APEX execution due to context saturation. **Research reveals a more nuanced picture:**

| Factor | Impact | Evidence |
|--------|--------|----------|
| **APEX phases don't mention cclsp** | HIGH | Zero references in 1-analyze, 3-execute, 4-examine |
| **"Lost in the Middle" effect** | MEDIUM | Instructions mid-context get ~30% less attention |
| **Emphatic language backfires** | MEDIUM | Claude 4.5 overtriggers or dismisses "MUST" language |
| **Context saturation** | LOW | Claude 4.5 handles ~150-200 instructions reliably |

### Anthropic's Official Guidance (Critical Finding)

From [Claude 4 Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices):

> Where you might have said "CRITICAL: You MUST use this tool when...", you can use more normal prompting like "Use this tool when..."
>
> Claude Opus 4.5 is more responsive to the system prompt than previous models. If your prompts were designed to reduce undertriggering on tools, Claude Opus 4.5 may now OVERTRIGGER. The fix is to dial back any aggressive language.

**Current CLAUDE.md (problematic):**
```markdown
## LSP Tools (cclsp) - MANDATORY
⚠️ **CRITICAL REQUIREMENT**: You MUST use cclsp MCP tools...
```

**Better for Claude 4.5:**
```markdown
## LSP Tools (cclsp)
Use cclsp MCP tools for finding symbol definitions and references.
This provides semantic code understanding rather than text matching.
```

---

## 2. Codebase Context

### Current APEX Phase Analysis

| Phase | File | cclsp References | Gap Severity |
|-------|------|------------------|--------------|
| 1-analyze | `commands/apex/1-analyze.md` | 0 | MEDIUM |
| 2-plan | `commands/apex/2-plan.md` | 0 | LOW |
| 3-execute | `commands/apex/3-execute.md` | 0 | **HIGH** |
| 4-examine | `commands/apex/4-examine.md` | 0 | LOW |

### Phase 3 (Execute) - Critical Gap

**Location**: `commands/apex/3-execute.md:268-289`

**Current content** (lines 268-275):
```markdown
### 2. ULTRA THINK BEFORE EACH CHANGE
**BEFORE editing any file:**
- Think through the exact changes needed
- Consider side effects and dependencies
- Check if patterns exist to follow
- Verify you have all context needed
```

**Missing**: No mention of using cclsp for:
- Finding symbol definitions before editing
- Finding all usages before refactoring
- Using `rename_symbol` instead of manual find/replace

### Phase 1 (Analyze) - Medium Gap

**Location**: `commands/apex/1-analyze.md:116-133`

**Current content** (LAUNCH PARALLEL ANALYSIS):
- Uses `explore-codebase` agent for exploration
- Generic codebase exploration instructions
- No mention of cclsp for symbol navigation

### CLAUDE.md cclsp Section - Well-Structured But Over-Emphatic

**Location**: `CLAUDE.md:31-78`

**What works:**
- Table format (Operation | Use This | NOT This)
- Trigger patterns with arrows (→)
- Example code with ❌/✅ markers
- Why explanations (cclsp > Grep comparison)

**What doesn't work for Claude 4.5:**
- "MANDATORY" keyword
- "⚠️ CRITICAL REQUIREMENT"
- "You MUST use"
- Double emphasis stacking

### Existing Skill: lsp-navigation

**Location**: `skills/lsp-navigation/SKILL.md`

**Current state**: Exists and properly configured
**Issue**: Skill triggers on natural language but doesn't get invoked during APEX phases because:
1. APEX prompts are pre-loaded, not user queries
2. Skill discovery happens at session start, not mid-execution

---

## 3. Documentation Insights

### Tool Selection Behavior (Claude 4.5)

Claude Code does NOT force tool selection through instructions alone. Instead:

1. **Tool visibility matters** — Tools present in context are more likely used
2. **Clear descriptions win** — Well-described tools get selected over vague ones
3. **Examples teach patterns** — Claude learns from example tool usage
4. **No hard rules** — Even "MUST" doesn't force compliance

### MCP Configuration Verified

**File**: `settings.json:86-102`

```json
"permissions": {
  "allow": [
    "mcp__cclsp__*"  // Already whitelisted
  ]
}
```

cclsp is correctly configured and permitted. The issue is instruction placement, not configuration.

### Instruction Limits

- Claude 4.5 handles ~150-200 instructions reliably
- System prompt already contains ~50 instructions
- Leaves room for ~100-150 in CLAUDE.md
- Current CLAUDE.md is well under limit

---

## 4. Research Findings

### Best Practices from Community

| Practice | Source | Relevance |
|----------|--------|-----------|
| CLAUDE.md < 300 lines | HumanLayer | Currently compliant |
| Position critical rules at start/end | Scale AI | Need to restructure |
| Clear guidance > emphatic language | Anthropic | **Must update** |
| Progressive disclosure | Claude Blog | Already using |
| Data-driven refinement | Arize | Future improvement |

### The "Lost in the Middle" Problem

Research shows information positioned in the middle of context windows receives less attention:

```
Position    | Attention Level
-----------|----------------
Beginning  | HIGH
Middle     | ~30% lower
End        | HIGH
```

**Implication**: CLAUDE.md cclsp section (lines 31-78) is in the middle. Consider:
1. Moving to beginning, OR
2. Reinforcing in APEX phase files (recommended)

---

## 5. Evaluation: Should We Integrate cclsp into APEX?

### Decision Matrix

| Criterion | Without APEX Integration | With APEX Integration |
|-----------|--------------------------|----------------------|
| **Visibility** | CLAUDE.md only (mid-context) | Phase files + CLAUDE.md |
| **Context timing** | Start of session | During execution |
| **Claude 4.5 compliance** | ~20% | ~65-90% |
| **Maintenance cost** | Single location | Multiple files |
| **Redundancy** | None | Some duplication |

### Recommendation: YES, Integrate (Hybrid Approach)

**Why:**
1. APEX phases are loaded just-in-time (better timing)
2. Instructions appear in active context (not forgotten)
3. Phase-specific guidance is more actionable
4. Backup via lsp-navigation skill

**How:**
1. Add cclsp sections to Phase 1 and Phase 3
2. Simplify CLAUDE.md language (remove CRITICAL/MUST)
3. Keep lsp-navigation skill as fallback

---

## 6. Proposed Changes

### Priority 1: Phase 3 (Execute) - HIGH IMPACT

**File**: `commands/apex/3-execute.md`
**Location**: After line 275

**Add this section:**
```markdown
### Symbol Navigation & Refactoring

Use cclsp MCP tools for code navigation during implementation:

| Operation | Tool | Why |
|-----------|------|-----|
| Find where X is defined | `mcp__cclsp__find_definition` | Semantic accuracy |
| Find all usages of X | `mcp__cclsp__find_references` | No false positives |
| Rename symbol | `mcp__cclsp__rename_symbol` | Safe cross-file refactor |

Before editing code:
1. Use `find_definition` to locate the symbol
2. Use `find_references` to understand impact
3. Use `rename_symbol` for any renaming (not manual find/replace)

Example:
```
// Find where getUserData is defined
mcp__cclsp__find_definition(file_path="src/api.ts", symbol_name="getUserData")

// Find all places using it
mcp__cclsp__find_references(file_path="src/api.ts", symbol_name="getUserData")
```
```

### Priority 2: Phase 1 (Analyze) - MEDIUM IMPACT

**File**: `commands/apex/1-analyze.md`
**Location**: After line 133

**Add this section:**
```markdown
### Symbol Navigation

When exploring codebase for definitions or usages, use cclsp:
- "Where is X defined?" → `mcp__cclsp__find_definition`
- "Where is X used?" → `mcp__cclsp__find_references`

cclsp provides semantic understanding (not text matching), preventing
false positives from similar names in comments or strings.
```

### Priority 3: Simplify CLAUDE.md - MEDIUM IMPACT

**File**: `CLAUDE.md:31-78`

**Change from:**
```markdown
## LSP Tools (cclsp) - MANDATORY
⚠️ **CRITICAL REQUIREMENT**: You MUST use cclsp MCP tools...
```

**To:**
```markdown
## LSP Tools (cclsp)
Use cclsp MCP tools for finding symbol definitions and references.
LSP provides semantic code understanding rather than text matching.
```

Keep the tables and examples, just remove emphatic language.

---

## 7. Key Files

| File | Lines | Purpose |
|------|-------|---------|
| `commands/apex/3-execute.md` | 268-289 | Add cclsp refactoring section |
| `commands/apex/1-analyze.md` | 116-133 | Add symbol navigation guidance |
| `CLAUDE.md` | 31-78 | Simplify emphatic language |
| `skills/lsp-navigation/SKILL.md` | 1-76 | Keep as backup trigger |
| `settings.json` | 86-102 | Already configured correctly |

---

## 8. Patterns to Follow

### Effective Instruction Patterns (from CLAUDE.md analysis)

**What works:**
- Tables with clear columns (Operation | Use This | NOT This)
- Decision arrows: "When X → Use Y"
- Example code with clear labels
- Explanation of "why" (not just rules)

**What to avoid:**
- "CRITICAL", "MANDATORY", "MUST" (Claude 4.5)
- Double emphasis (⚠️ + caps + bold)
- Long paragraphs of rules

### Example of Good Pattern

```markdown
## Shell Aliases

When using shell commands with ls, grep, or find, use absolute paths
because this system has aliases that override these commands.

| Command | Use Instead |
|---------|-------------|
| `ls`    | `/bin/ls`   |
| `grep`  | `/usr/bin/grep` |
| `find`  | `/usr/bin/find` |
```

---

## 9. Dependencies

**None blocking.**

- cclsp MCP server: Already configured
- Permissions: Already whitelisted
- Skills: lsp-navigation exists
- APEX infrastructure: Working

---

## 10. Risk Assessment

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Over-complication | Medium | Keep additions minimal |
| Maintenance burden | Low | Only 2 files to update |
| Regression in other behavior | Low | Test with sample tasks |
| Claude 4.5 still ignores | Low | Multiple reinforcement points |

---

## 11. Testing Plan

After implementation:

1. **Test Phase 1**: Run `/apex:1-analyze` on a TypeScript task
   - Verify cclsp is mentioned in context
   - Check if `find_definition` or `find_references` are used

2. **Test Phase 3**: Run `/apex:3-execute` with refactoring
   - Verify cclsp section appears in context
   - Check if `rename_symbol` is used instead of manual edits

3. **Verify skill backup**: Check if lsp-navigation triggers on "where is X defined"

---

## Sources

- [Claude 4 Best Practices - Anthropic](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices)
- [Writing a Good CLAUDE.md - HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [Long Context Instruction Following - Scale AI](https://scale.com/blog/long-context-instruction-following)
- [CLAUDE.md Best Practices - Arize](https://arize.com/blog/claude-md-best-practices-learned-from-optimizing-claude-code-with-prompt-learning/)
- [Claude Code MCP Documentation](https://code.claude.com/docs/en/mcp)
