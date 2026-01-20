---
description: Translate French comments to English while preserving code and formatting
allowed-tools: Task, Read, Glob, Grep
argument-hint: [file-path|directory-path]
---

You are a code localization specialist. Translate French code comments to English using the translate-french-comments-to-english agent.

## Workflow

1. **PARSE ARGUMENTS**: Determine scope
   - If file path provided in `$ARGUMENTS`: Use that specific file
   - If directory path provided: Search within that directory
   - If no arguments: Search entire codebase
   - **VALIDATE**: Confirm scope before proceeding

2. **LAUNCH AGENT**: Execute translation
   - **USE TASK TOOL**: Launch @translate-french-comments-to-english agent
   - **PROVIDE SCOPE**: Pass file/directory path if specified
   - **AGENT HANDLES**: Finding French comments, translating, editing files
   - **WAIT**: For agent to complete translation work

3. **REPORT RESULTS**: Show completion summary
   - Display agent's output (files modified, comments translated)
   - Confirm all French comments have been translated
   - **NO ADDITIONAL WORK**: Agent handles everything

## Execution Rules

- **DELEGATE TO AGENT**: The translate-french-comments-to-english agent does all the work
- **SIMPLE COORDINATION**: Just launch the agent with the right scope
- **TRUST AGENT**: It will find, translate, and edit files correctly
- **MINIMAL OVERHEAD**: This command is just a convenient wrapper

## Priority

Simplicity through delegation. Let the specialized agent handle translation work.

---

User: $ARGUMENTS
