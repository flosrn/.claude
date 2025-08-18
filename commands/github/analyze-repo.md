---
description: "Intelligent GitHub repository analysis with smart prioritization and MCP integration"
allowed-tools:
  [
    "WebFetch(*)",
    "Task(*)",
    "Write(*)",
    "Read(*)",
    "Glob(*)",
    "Grep(*)",
    "mcp__brave-search__brave_web_search",
    "mcp__context7__resolve-library-id",
    "mcp__context7__get-library-docs",
  ]
---

# Smart GitHub Repository Analysis

Intelligent analysis of GitHub repositories using smart prioritization, MCP integration, and failure handling.

## Usage

```
/analyze-repo https://github.com/owner/repo
```

## Arguments

- `$ARGUMENTS`: GitHub repository URL for comprehensive technical analysis

## Smart Analysis Strategy

### Phase 1: Repository Assessment & Strategy

**Objective: Determine optimal analysis approach with failure handling**

1. **Repository Parsing**: Extract owner/repo from `$ARGUMENTS`
2. **Initial Reconnaissance**: Use WebFetch with fallback to Brave Search
3. **Size Assessment**: Categorize repository complexity
4. **MCP Resource Planning**: Choose appropriate MCP tools with fallback

#### Analysis Strategies (Size-Based)

**Small Repository (< 100 files): Complete Analysis**
- Full code understanding with documentation
- All configuration and setup files
- Complete dependency analysis

**Medium Repository (100-1000 files): Prioritized Analysis**
- Documentation first (100% coverage)
- Core architecture and entry points
- Key modules and interfaces
- Configuration and build system

**Large Repository (1000+ files): Strategic Focus**
- Documentation complete (README, API docs, guides)
- Architecture overview and main components
- Public APIs and interfaces
- Configuration and deployment setup

### Phase 2: Smart Documentation Analysis

**Objective: Complete documentation understanding with MCP enhancement**

#### Documentation Discovery
```
Primary: WebFetch repository documentation
Fallback 1: Brave Search "site:github.com/{owner}/{repo} README OR documentation"
Fallback 2: Context7 documentation lookup (if applicable)
```

**Documentation Deep Dive:**
- **README Analysis**: Project purpose, setup, usage patterns
- **API Documentation**: Endpoints, parameters, examples
- **Configuration**: All config options, environment variables
- **Guides & Tutorials**: Setup, deployment, development
- **Contributing**: Development process, standards, workflow

### Phase 3: Technology Stack Analysis

**Objective: Master technologies with Context7 integration**

#### Dependency Analysis with MCP Integration
```
1. Parse package.json, requirements.txt, Cargo.toml, etc.
2. For each major dependency:
   - Use mcp__context7__resolve-library-id
   - Get documentation via mcp__context7__get-library-docs
   - Cross-reference with actual implementation
```

#### Smart Technology Understanding
- **Language & Framework**: Best practices, patterns, idioms
- **Build System**: Compilation, bundling, testing processes
- **Infrastructure**: Docker, CI/CD, deployment configuration
- **Database**: Schema, queries, migrations

### Phase 4: Architecture Analysis

**Objective: Understand system design with smart code sampling**

#### Core Architecture Discovery
- **Entry Points**: Main files, startup sequence
- **Data Flow**: Input → Processing → Output
- **State Management**: How state is handled
- **Integration Points**: External APIs, services
- **Error Handling**: Failure patterns, recovery

#### Smart Code Sampling (Context-Aware)
- Focus on main modules and interfaces
- Skip test files initially (analyze if context permits)
- Prioritize configuration and setup files
- Sample key business logic implementations

### Phase 5: Enhanced Analysis (Context Permitting)

**Objective: Deep dive with MCP support when resources allow**

#### Performance & Security (If Context Available)
- **Performance Patterns**: Caching, optimization, bottlenecks
- **Security Implementation**: Auth, validation, security headers
- **Testing Strategy**: Coverage, patterns, quality gates
- **Monitoring**: Logging, metrics, observability

#### MCP-Enhanced Research (Failure-Safe)
```
If context permits and MCP available:
1. Brave Search: "[repo-name] performance issues OR optimization"
2. Brave Search: "[repo-name] security best practices OR vulnerabilities"  
3. Context7: Get advanced documentation for key dependencies
```

## Failure Handling & Resource Management

### MCP Failure Strategy
- **Maximum MCP Calls**: 15 total across all phases
- **Graceful Degradation**: Continue without failed MCP services
- **Timeout Handling**: 30 seconds per MCP call, then fallback
- **Rate Limiting**: 1 second between Brave Search queries

### Context Management
- **Token Optimization**: Prioritize most critical information
- **Progressive Analysis**: Build understanding incrementally
- **Smart Truncation**: Focus on high-value content first
- **Checkpoint Saves**: Save analysis at key phases

## Analysis Report Structure

### Executive Summary
```markdown
# Repository Analysis: {repository-name}

**Analysis Strategy**: {Small/Medium/Large} | **Completeness**: {percentage}%
**Technology Stack**: {primary-technologies}
**Architecture Pattern**: {architectural-style}
**Confidence Level**: {analysis-confidence}

## Key Findings
- **Purpose**: {what-does-this-do}
- **Complexity**: {complexity-assessment}  
- **Quality**: {code-quality-indicators}
- **Maintenance**: {maintenance-status}
```

### Technical Deep Dive
```markdown
## Architecture Overview
- **Entry Points**: {main-files-startup}
- **Core Components**: {key-modules}
- **Data Flow**: {input-processing-output}
- **External Dependencies**: {key-integrations}

## Technology Analysis
- **Primary Stack**: {languages-frameworks}
- **Build System**: {build-deployment}
- **Database**: {data-persistence}
- **Infrastructure**: {deployment-hosting}

## Implementation Insights
- **Key Algorithms**: {important-logic}
- **Design Patterns**: {architectural-patterns}
- **Performance**: {optimization-approaches}
- **Security**: {security-measures}
```

### Practical Guidance
```markdown
## Getting Started
- **Setup Instructions**: {step-by-step-setup}
- **Development Environment**: {dev-requirements}
- **Common Commands**: {key-cli-commands}
- **Configuration**: {important-settings}

## Extension Points
- **Plugin Architecture**: {extensibility}
- **API Integration**: {integration-patterns}
- **Customization**: {configuration-options}
- **Contributing**: {development-process}
```

## Success Criteria

Post-analysis capabilities:
1. **Explain architecture** and design decisions
2. **Guide setup and deployment** processes
3. **Identify extension points** and customization options
4. **Troubleshoot common issues** based on documentation
5. **Suggest improvements** based on best practices
6. **Navigate codebase** efficiently for specific needs

## Quality Assurance

### Analysis Validation
- **Documentation Coverage**: All major docs analyzed
- **Architecture Understanding**: Entry points and data flow mapped  
- **Technology Mastery**: Key dependencies understood via Context7
- **Practical Applicability**: Setup and usage guidance provided

### Completeness Metrics
- **Documentation**: 100% of available docs
- **Core Code**: Main modules and interfaces
- **Configuration**: All setup and deployment files
- **Dependencies**: Major libraries understood via MCP

The goal is **practical expertise** - understanding the repository sufficiently to use, extend, deploy, and troubleshoot it effectively, with smart resource management and graceful failure handling.