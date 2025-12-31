# Task: Add Background Mode to 1-analyze

## Problem

The analyze phase blocks while exploration agents run. Users wait idly instead of being able to answer clarifying questions that would improve the analysis.

## Proposed Solution

Add `--background` flag that:
1. Launches exploration agents with `run_in_background: true`
2. Immediately asks clarifying questions while agents run
3. Synthesizes agent findings with user answers when agents complete
4. Adds "User Clarifications" section to analyze.md

## Dependencies

- None (independent of other tasks)

## Context

- File: `commands/apex/1-analyze.md`
- Modify Step 3 (LAUNCH PARALLEL ANALYSIS) for background mode
- Add interactive clarification loop using `AskUserQuestion`
- Modify Step 4 (SYNTHESIZE FINDINGS) to include user clarifications
- Uses `TaskOutput` to check agent status periodically

## Success Criteria

- `--background` flag is detected in argument parsing
- Agents launch with `run_in_background: true` when flag present
- Clarifying questions appear while agents run in background
- User answers are stored and included in synthesis
- analyze.md template includes "User Clarifications" section
