# Task: Enhance Parallel Auto-Detect and Use apex-executor

## Problem

1. Current parallel auto-detect only looks for explicit `[Task X ‖ Task Y]` notation, missing tasks that could run in parallel based on dependency analysis
2. Parallel execution uses Snipper (Haiku) which lacks capability for complex tasks

## Proposed Solution

1. Enhance parallel auto-detection to also analyze the dependency table in `index.md` - find all incomplete tasks whose dependencies are ALL complete
2. Replace Snipper with apex-executor for parallel task execution

## Dependencies

- Task 1: apex-executor agent must exist (for replacement)

## Context

- File: `commands/apex/3-execute.md`
- Location for auto-detect: "Parallel Auto-Detect Mode" section in Step 2
- Location for agent swap: Step 3B, substep "Step 2: Launch Parallel Agents"
- Current: `subagent_type: "Snipper"` → Change to: `subagent_type: "apex-executor"`

## Success Criteria

- Parallel auto-detect parses dependency table from `index.md`
- Finds tasks where all dependencies are marked complete
- Multiple qualifying tasks are treated as parallel candidates
- Agent type changed from Snipper to apex-executor for parallel execution
- Description updated to reflect apex-executor capabilities
