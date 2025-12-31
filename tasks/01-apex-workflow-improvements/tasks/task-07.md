# Task: Add Quick Summary Template to 1-analyze

## Problem

The analyze.md output requires reading through detailed findings to understand key takeaways. There's no TL;DR for quick orientation.

## Proposed Solution

Add a "Quick Summary (TL;DR)" section at the TOP of the analyze.md template with:
- Key files to modify (bulleted list)
- Patterns to follow (1-2 examples with file:line)
- Dependencies (blocking or none)
- Estimation (task count, time range)

## Dependencies

- None (independent template enhancement)

## Context

- File: `commands/apex/1-analyze.md`
- Location: Step 5 (template definition)
- Section goes at TOP of analyze.md, before detailed findings
- Should be concise: 5-10 lines maximum

## Success Criteria

- analyze.md template has "Quick Summary (TL;DR)" section at top
- Summary includes key files, patterns, dependencies, estimation
- Summary is concise and scannable
- Detailed findings remain intact below summary
