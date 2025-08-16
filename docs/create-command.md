# Create Command Documentation

**Source**: https://github.com/scopecraft/command  
**Location**: `~/.claude/commands/create-command.md`  
**Purpose**: Meta-command to create new Claude commands with proper patterns

## Usage

```bash
/create-command
```

## Command Categories

1. **Planning Commands**: Feature ideation, proposals, workflows
2. **Implementation Commands**: Technical execution with modes
3. **Analysis Commands**: Review, audit, analyze
4. **Workflow Commands**: Multi-step orchestration
5. **Utility Commands**: Tools and helpers

## Examples

### Creating a React Component Generator
```
/create-command

"I need a command to generate React components with TypeScript"
→ Category: Utility command
→ Location: User command (~/.claude/commands/)
→ Pattern: Specialized with template support
```

### Creating a Code Review Helper
```
/create-command

"I want a command to review PRs against our standards"
→ Category: Analysis command
→ Location: Project command (/.claude/commands/)
→ Pattern: Similar to existing review commands
```

## Process

1. **Interview Phase**: Understand requirements
2. **Classification**: Determine category and pattern
3. **Location Decision**: Project vs User command
4. **Generation**: Create command following patterns
5. **Documentation**: Update relevant docs

## Best Practices

- Study similar existing commands first
- Use proper task/context structure
- Include human review sections for decisions
- Follow naming conventions
- Test the command after creation

## Notes

- Commands in `~/.claude/commands/` are user-global
- Commands in `/.claude/commands/` are project-specific
- Numeric prefixes indicate workflow order (01_, 02_, etc.)