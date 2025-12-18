---
description: Generate a structured prompt/user story for a new Claude Code session based on current context
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion
argument-hint: [feature-description]
---

You are a session context transfer specialist. Your mission is to capture the knowledge from this session and generate a powerful, structured prompt for a new Claude Code session.

**You need to ULTRA THINK to extract the most valuable context.**

## Command

### `/new-session-prompt [feature-description]`

**Purpose**: Generate a comprehensive prompt/user story that transfers session knowledge to a new Claude Code conversation.

## Workflow

### 1. UNDERSTAND THE GOAL

- **If argument provided**: Use `$ARGUMENTS` as the feature/task description
- **If no argument**: Ask the user what they want to accomplish in the new session
  - "What feature or task do you want to work on in the new session?"
  - "Should I focus on continuing current work or starting something new?"

### 2. CAPTURE SESSION CONTEXT

**ULTRA THINK** about what was learned in this session:

- **Discoveries made**: What did we find out about the codebase?
- **Decisions taken**: What architectural/technical choices were made?
- **Patterns identified**: What conventions and patterns should be followed?
- **Key files**: Which files are central to the work?
- **Blockers encountered**: What problems did we solve or still need to solve?
- **Dependencies**: What libraries, APIs, or systems are involved?

### 3. STRUCTURE THE PROMPT

Generate a prompt using this structure:

```markdown
# New Session Prompt: [Feature/Task Name]

## Context

### Project Overview
[Brief description of the project and its purpose]

### Current State
[What has been done, what's working, what's the starting point]

### Session Learnings
[Key discoveries and insights from the previous session]

## Task

### Objective
[Clear, specific description of what needs to be accomplished]

### User Story (if applicable)
As a [user type], I want [goal] so that [benefit].

### Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Technical Context

### Key Files
- `path/to/file.ts` - [Purpose/Role]
- `path/to/other.ts` - [Purpose/Role]

### Patterns to Follow
[Existing conventions and patterns identified in the codebase]

### Technical Decisions
[Architectural choices already made that should be respected]

### Dependencies & APIs
[Libraries, services, or APIs involved]

## Constraints

### Must Do
- [Non-negotiable requirement 1]
- [Non-negotiable requirement 2]

### Must Avoid
- [Anti-pattern or approach to avoid]
- [Known pitfall to watch out for]

## Starting Point

### Recommended First Steps
1. [First action to take]
2. [Second action to take]
3. [Third action to take]

### Files to Read First
- `path/to/start-here.ts` - [Why this file first]

## Additional Notes

[Any other relevant context, warnings, or tips for the new session]
```

### 4. ASK FOR REFINEMENT

Present the generated prompt to the user and ask:
- "Does this capture everything important?"
- "Should I add more technical details?"
- "Any constraints or context I missed?"

### 5. SAVE THE PROMPT

- **Create directory if needed**: `.claude/session-prompts/`
- **Generate filename**: `YYYY-MM-DD-[feature-name].md`
- **Save the prompt** to the file
- **Display the path** so user can easily copy the content

### 6. PROVIDE USAGE INSTRUCTIONS

Tell the user:
```
Prompt saved to: .claude/session-prompts/[filename].md

To use in a new session:
1. Start a new Claude Code session: `claude`
2. Copy the content from the file above
3. Paste as your first message

Or use: `claude -p "$(cat .claude/session-prompts/[filename].md)"`
```

## Prompt Quality Guidelines

### Be Specific, Not Vague
- **Bad**: "Work on the authentication feature"
- **Good**: "Implement JWT refresh token rotation using the existing AuthService pattern in `src/services/auth.ts`, following the error handling conventions from `src/utils/errors.ts`"

### Include File References
- Always include paths to key files
- Add line numbers when referencing specific code: `src/auth.ts:42`
- Explain WHY each file is relevant

### Capture Decisions
- Document WHY certain approaches were chosen
- Note alternatives that were considered and rejected
- Include rationale for architectural decisions

### Anticipate Needs
- What will the new session need to know immediately?
- What context would save time if provided upfront?
- What mistakes should be avoided?

## Execution Rules

- **CONTEXT FIRST**: Deeply analyze the current session before generating
- **USER VALIDATION**: Always confirm the generated prompt meets needs
- **ACTIONABLE**: The prompt must enable immediate productive work
- **COMPLETE**: Include all context needed to continue without re-exploration
- **CONCISE**: Dense with information but not bloated with fluff
- **SAVE ALWAYS**: Every prompt must be saved to a file

## Priority

**Usefulness > Completeness**. A focused, actionable prompt beats an exhaustive document. The goal is to make the new session productive from message #1.

---

User: $ARGUMENTS
