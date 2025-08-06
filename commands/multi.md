---
description: "Meta-command orchestrator for executing multiple slash commands with combined context and intelligent workflow coordination"
allowed-tools:
  [
    "Read(*)",
    "Glob(*)",
    "LS(*)",
    "Bash(git:*)",
    "Bash(gh:*)",
    "TodoWrite(*)",
  ]
---

# Claude Command: Multi-Command Orchestrator (multi)

Universal meta-command that enables execution of multiple slash commands simultaneously, combining their contexts and capabilities for comprehensive workflow orchestration.

## Usage

```
/multi <command1> <command2> [command3...]    # Execute multiple commands with combined context
/multi <command1> + <command2>               # Alternative syntax with explicit separator  
/multi --sequential <cmd1> <cmd2>            # Execute commands in sequence (explicit)
/multi --parallel <cmd1> <cmd2>              # Execute with parallel context loading
/multi --list                                # Show all available commands
/multi --help <command>                      # Show help for specific command
```

## CRITICAL: Auto-Loading Implementation

**FIRST ACTION**: When `/multi` command starts, it MUST:
1. Execute `Glob("/Users/flo/.claude/commands/*.md")` to find all commands
2. Execute `Read()` for EACH command file mentioned in the user request
3. Parse and understand the full capabilities of each command
4. Only then proceed with the integrated workflow

**Example for `/multi commit pr merge`:**
```
Step 1: Glob("/Users/flo/.claude/commands/*.md") 
Step 2: Read("/Users/flo/.claude/commands/commit.md")
Step 3: Read("/Users/flo/.claude/commands/pr.md") 
Step 4: Read("/Users/flo/.claude/commands/merge.md")
Step 5: Integrate and execute workflow
```

## Syntax Patterns

### Basic Multi-Command Execution
```
/multi work commit pr
→ LOADS: work.md + commit.md + pr.md files  
→ EXECUTES: Smart branch creation → Commits → Creates PR
→ RESULT: Complete workflow for any change type (feat/fix/chore/etc)

/multi branch commit pr merge  
→ LOADS: branch.md + commit.md + pr.md + merge.md files
→ EXECUTES: Branch creation → Commit → PR → Merge
→ RESULT: Complete workflow from branch creation to merged PR

/multi commit review
→ LOADS: commit.md + review.md files  
→ EXECUTES: Creates quality commit with review insights
→ RESULT: High-quality, reviewed commit

/multi branch sync pr
→ LOADS: branch.md + sync.md + pr.md files
→ EXECUTES: Branch management + sync + PR creation
→ RESULT: Complete Git workflow with upstream sync
```

### Advanced Combinations
```
/multi deep-research release
→ Research capabilities + release management
→ Research-driven release planning and documentation

/multi mcp-mgmt context7 shadcn-ui
→ MCP management + Context7 docs + Shadcn component knowledge
→ Complete development toolchain setup with documentation access

/multi review security performance  
→ Code review + security analysis + performance optimization
→ Comprehensive code quality assessment
```

## Orchestration Intelligence

### Context Consolidation
When multiple commands are specified, I will:

1. **Auto-discover Commands**: Automatically scan `/Users/flo/.claude/commands/` directory
2. **Load All Command Contexts**: Read and internalize all specified slash command documents
3. **Identify Synergies**: Find complementary capabilities between commands
4. **Resolve Conflicts**: Handle overlapping functionality intelligently  
5. **Create Unified Workflow**: Combine commands into coherent execution plan

### Implementation Process
```
Multi-Command Execution Workflow:
1. Use Glob tool to discover all *.md files in commands/
2. Use Read tool to load content of each specified command
3. Parse command capabilities, tools, and workflows
4. Create integrated execution plan
5. Execute workflow with combined context
```

### Smart Integration Patterns

**Development Workflow Integration:**
```
Command Combinations → Integrated Capabilities
├── mcp-mgmt + github-repo-deep-analysis → Contextual MCP recommendations
├── commit + review → Quality-assured commits with review insights
├── branch + sync + pr → Complete Git workflow orchestration
├── deep-research + release → Research-driven release management
└── review + security + performance → Comprehensive quality gates
```

**Cross-Command Knowledge Sharing:**
- **Configuration awareness**: MCP settings inform repository analysis
- **Context preservation**: Previous command outputs influence subsequent actions
- **Workflow optimization**: Commands coordinate to avoid redundant operations
- **Error prevention**: Commands validate each other's prerequisites

## Execution Modes

### Default: Intelligent Parallel Context
```
/multi mcp-mgmt github-repo-deep-analysis https://github.com/user/repo

Execution Process:
1. Simultaneously load both command contexts
2. Analyze the GitHub repository with full technical depth
3. Apply MCP management knowledge to suggest optimal servers
4. Provide integrated recommendations combining both expertises
5. Offer coordinated next steps and workflow suggestions
```

### Sequential Mode: Step-by-Step Execution
```
/multi --sequential commit review pr

Execution Process:
1. Execute commit workflow with quality checks
2. Apply review process to created commit
3. Use review insights to create optimized pull request
4. Each step builds on previous step's output
```

### Parallel Mode: Maximum Context Loading
```
/multi --parallel deep-research mcp-mgmt github-repo-deep-analysis

Execution Process:
1. Load all three command contexts simultaneously
2. Provide comprehensive capabilities from all commands
3. Enable complex multi-faceted analysis and recommendations
4. Maintain awareness of all command capabilities throughout session
```

## Intelligent Command Discovery

### Auto-Detection of Available Commands
The orchestrator automatically:
- **Scans command directory**: Uses Glob to discover all *.md files in `/Users/flo/.claude/commands/`
- **Loads command metadata**: Reads frontmatter and description from each command file
- **Validates command existence**: Ensures specified commands exist before execution
- **Suggests alternatives**: Recommends similar commands if typos detected
- **Provides completion hints**: Shows available commands for combination

### Active Command Discovery Process
```bash
# Step 1: Discover all available commands
Glob: /Users/flo/.claude/commands/*.md

# Step 2: Read each specified command file
Read: /Users/flo/.claude/commands/commit.md
Read: /Users/flo/.claude/commands/pr.md
Read: /Users/flo/.claude/commands/review.md

# Step 3: Parse and integrate capabilities
```

### Command Compatibility Analysis
```
Compatibility Assessment:
├── Complementary: Commands that enhance each other
├── Independent: Commands that can work in parallel  
├── Sequential: Commands that should execute in order
└── Conflicting: Commands with overlapping functionality
```

## Error Handling and Fallbacks

### Missing Command Handling
```
/multi nonexistent-command github-repo-deep-analysis

Response:
⚠️  Command 'nonexistent-command' not found
📋 Available commands: mcp-mgmt, commit, review, branch, sync, pr, release, deep-research, github-repo-deep-analysis
🤔 Did you mean: 'mcp-mgmt'?
✅ Proceeding with: github-repo-deep-analysis
```

### Partial Execution Recovery
- **Continue with available commands**: Execute valid commands even if some fail
- **Provide partial capabilities**: Offer reduced functionality when commands unavailable
- **Suggest alternatives**: Recommend similar command combinations
- **Graceful degradation**: Maintain useful functionality despite errors

## Advanced Features

### Command Argument Distribution
```
/multi mcp-mgmt github-repo-deep-analysis https://github.com/user/repo --scope user

Intelligent Argument Parsing:
- URL goes to github-repo-deep-analysis
- --scope flag goes to mcp-mgmt  
- Shared arguments distributed appropriately
- Context-aware parameter routing
```

### Dynamic Workflow Creation
- **Adaptive execution plans**: Adjust workflow based on command combination
- **Conditional branching**: Execute different paths based on initial results
- **Feedback loops**: Later commands influence earlier command parameters
- **Optimization opportunities**: Combine redundant operations between commands

### Session Memory Integration
- **Command history awareness**: Remember previously executed command combinations
- **Performance learning**: Optimize future executions based on usage patterns
- **Preference adaptation**: Learn user's preferred command combinations
- **Context persistence**: Maintain combined context across multiple interactions

## Usage Examples

### Development Workflow
```
/multi mcp-mgmt github-repo-deep-analysis https://github.com/user/nextjs-app
→ Analyzes Next.js repository architecture
→ Recommends MCP servers: shadcn-ui for components, context7 for docs
→ Suggests optimal installation scopes based on project structure
→ Provides integrated development workflow recommendations
```

### Quality Assurance Pipeline
```
/multi review security performance commit
→ Comprehensive code quality analysis
→ Security vulnerability assessment  
→ Performance optimization recommendations
→ Creates quality-assured commit with all insights
```

### Release Management
```
/multi deep-research release pr sync
→ Research-driven release planning
→ Automated release preparation
→ Pull request creation with research context
→ Repository synchronization for release
```

### Team Onboarding
```
/multi mcp-mgmt branch sync
→ Complete MCP setup guidance
→ Branch management best practices
→ Repository synchronization workflows
→ New team member onboarding checklist
```

## Implementation Strategy

### Command Loading Implementation
**CRITICAL**: Multi-command MUST actually load other commands' content:

1. **First Action**: Use `Glob("/Users/flo/.claude/commands/*.md")` to discover commands
2. **Second Action**: Use `Read()` tool for each specified command file  
3. **Third Action**: Parse command metadata, tools, and workflow descriptions
4. **Fourth Action**: Create integrated execution plan with full command knowledge

### Command Context Preservation
All existing slash commands remain fully functional and unchanged:
- **Individual execution**: `/commit`, `/review`, `/mcp-mgmt` work exactly as before
- **Full feature access**: Complete command capabilities preserved
- **No interference**: Multi-command execution doesn't affect individual command behavior
- **Backward compatibility**: Existing workflows continue to work
- **Active loading**: Multi-command actually reads and integrates other command files

### Enhanced Capabilities
When combined via `/multi`, commands gain:
- **Cross-command awareness**: Commands can reference each other's capabilities
- **Shared context**: Information flows between command contexts
- **Workflow optimization**: Reduced redundancy and improved efficiency
- **Intelligent coordination**: Commands work together rather than in isolation

## Best Practices

### Effective Command Combinations
```
Recommended Patterns:
├── Analysis + Management: github-repo-deep-analysis + mcp-mgmt
├── Quality + Delivery: review + commit + pr
├── Research + Planning: deep-research + release
├── Setup + Sync: mcp-mgmt + sync + branch
└── Complete Workflow: branch + commit + review + pr + sync
```

### Performance Considerations
- **Context loading time**: More commands = longer initial loading
- **Memory usage**: Combined contexts require more memory
- **Execution complexity**: More commands = more complex decision trees
- **Optimal combinations**: 2-4 commands typically provide best balance

### Security and Safety
- **Command validation**: All commands verified before execution
- **Permission inheritance**: Most restrictive permissions apply
- **Safe fallbacks**: Graceful degradation when commands unavailable
- **Audit trail**: Complete logging of multi-command executions

## Options and Flags

### Execution Control
- `--sequential`: Force sequential execution order
- `--parallel`: Maximize parallel context loading  
- `--dry-run`: Preview combined capabilities without execution
- `--verbose`: Show detailed orchestration process
- `--optimize`: Enable workflow optimization between commands

### Context Management  
- `--context-limit <n>`: Limit combined context size
- `--priority <command>`: Give priority to specific command's context
- `--exclude-conflicts`: Skip commands with conflicting functionality
- `--force-compatibility`: Override compatibility warnings

### Debug and Analysis
- `--show-combinations`: Display all possible command combinations
- `--analyze-compatibility`: Show compatibility matrix for commands
- `--performance-profile`: Profile execution time and resource usage
- `--suggest-optimizations`: Recommend better command combinations

## Notes

- **Universal compatibility**: Works with any existing or future slash commands
- **Zero configuration**: Automatically discovers and orchestrates available commands
- **Intelligent integration**: Combines command capabilities rather than just executing sequentially
- **Performance optimized**: Efficient context loading and execution coordination
- **Future-proof**: Scales with new commands and capabilities
- **Maintains simplicity**: Complex orchestration with simple syntax
- **Preserves individual commands**: All existing commands remain fully functional

This meta-command transforms Claude Code into a true workflow orchestration platform, enabling complex multi-faceted analysis and development workflows through simple command combinations.