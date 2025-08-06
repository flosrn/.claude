---
description: "Smart omniscient analysis of GitHub repositories - prioritized deep understanding with intelligent filtering and progressive comprehension"
allowed-tools:
  [
    "WebFetch(*)",
    "Task(*)",
    "Write(*)",
    "Read(*)",
    "Glob(*)",
    "Grep(*)",
    "mcp__context7__resolve-library-id",
    "mcp__context7__get-library-docs",
  ]
---

# Claude Command: GitHub Repository Smart Omniscient Analysis

Expert-level technical deep dive using intelligent prioritization and UIThub advanced filtering to achieve comprehensive understanding of any GitHub repository. Employs smart token management and progressive analysis to maximize comprehension within context limits.

## Usage

```
/github-repo-deep-analysis https://github.com/owner/repo
```

## Arguments

- `$ARGUMENTS`: Complete GitHub repository URL for omniscient technical analysis

## Smart Omniscient Analysis Methodology

### Phase 1: Repository Assessment & Smart Strategy

**Objective: Determine optimal analysis strategy based on repository size and complexity**

1. **Repository Parsing**: Extract owner/repo from `$ARGUMENTS`
2. **Initial Reconnaissance**: `https://uithub.com/{owner}/{repo}?maxFileSize=1000` - Quick overview
3. **Size Assessment**: Determine if repository is small (< 50 files), medium (50-500), or large (500+)
4. **Priority Strategy**: Choose analysis depth based on repository size and context limits

#### Smart Analysis Strategies

**Small Repository (< 50 files): Complete Omniscience**
- **Full Analysis**: `https://uithub.com/{owner}/{repo}` - Absorb everything
- **Documentation**: `https://uithub.com/{owner}/{repo}?fileExtensions=.md,.txt,.rst` - All docs
- **Code Complete**: Full code understanding with every function and algorithm

**Medium Repository (50-500 files): Prioritized Deep Dive**
- **Documentation First**: `https://uithub.com/{owner}/{repo}?fileExtensions=.md,.txt,.rst` - 100% docs
- **Core Code**: `https://uithub.com/{owner}/{repo}?excludeDirs=tests,docs,examples&maxFileSize=10000`
- **Main Entry Points**: Focus on main.*, index.*, cli.*, app.* files
- **Key Modules**: Identify and analyze critical business logic files

**Large Repository (500+ files): Strategic Focus**
- **Documentation Complete**: `https://uithub.com/{owner}/{repo}?fileExtensions=.md,.txt,.rst` - 100% docs
- **Architecture Core**: `https://uithub.com/{owner}/{repo}?maxFileSize=5000&excludeDirs=tests,examples,docs,vendor`
- **Main Interfaces**: Focus on public APIs, main entry points, core modules
- **Configuration**: All config files (*.json, *.yaml, *.toml, Dockerfile, etc.)

### Phase 2: Progressive Documentation Mastery (ALWAYS 100%)

**Objective: Complete absorption of ALL documentation regardless of repository size**

#### Documentation Complete Analysis
**UIThub Query**: `https://uithub.com/{owner}/{repo}?fileExtensions=.md,.txt,.rst,.adoc,.org`

**Documentation Deep Dive:**
- **README Analysis**: Complete understanding of project purpose, setup, usage
- **API Documentation**: Every endpoint, parameter, response format
- **Configuration Docs**: Every config option, environment variable, setting
- **Tutorials & Guides**: Step-by-step understanding of all workflows
- **Architectural Docs**: System design, patterns, decision rationales
- **Contributing Guidelines**: Development process, coding standards, workflow
- **Changelog/Release Notes**: Evolution, breaking changes, feature additions

#### Documentation Knowledge Integration
- **Command References**: Every CLI command, option, flag, and behavior
- **Configuration Matrix**: All possible configuration combinations and effects
- **Troubleshooting Knowledge**: Every known issue, solution, and debugging approach
- **Integration Patterns**: How to integrate, extend, and customize the system

### Phase 3: Smart Code Analysis (Priority-Based)

**Objective: Maximum code understanding within context constraints**

#### UIThub Advanced Filtering Strategies

**Priority 1: Core Architecture** 
```
https://uithub.com/{owner}/{repo}?excludeDirs=tests,examples,docs,node_modules,vendor,.git&maxFileSize=15000
```
- Main entry points and application structure
- Core business logic and algorithms
- Key modules and their interactions

**Priority 2: Configuration & Infrastructure**
```
https://uithub.com/{owner}/{repo}?fileExtensions=.json,.yaml,.yml,.toml,.ini,.env,.dockerfile,.sh,.py,.js&maxFileSize=5000&excludeDirs=node_modules,vendor
```
- Build and deployment configuration
- Environment setup and requirements
- Infrastructure as code patterns

**Priority 3: Critical Interfaces**
```
https://uithub.com/{owner}/{repo}?filePatterns=*api*,*interface*,*contract*,*schema*&excludeDirs=tests,examples
```
- Public APIs and interfaces
- Data schemas and contracts
- Plugin/extension points

#### Intelligent Code Deep Dive
- **Entry Point Mastery**: Complete understanding of application startup and main flows
- **Data Flow Tracing**: How data moves through the system from input to output
- **Algorithm Expertise**: Core algorithms, optimizations, and computational patterns
- **State Management**: How application state is managed, stored, and synchronized
- **Error Handling**: Complete error handling strategy and failure recovery patterns

### Phase 4: Technology Stack Mastery

**Objective: Master every technology, framework, and tool used**

#### Dependency Analysis & Context7 Integration
**UIThub Query**: `https://uithub.com/{owner}/{repo}?filePatterns=package.json,requirements.txt,Cargo.toml,go.mod,composer.json,pom.xml,build.gradle,Gemfile`

**Context7 Documentation Integration Process:**
```
For each detected technology/library:
1. Parse dependency files to identify all libraries and frameworks
2. Use mcp__context7__resolve-library-id to identify available documentation
3. Use mcp__context7__get-library-docs to fetch expert-level, version-specific documentation
4. Cross-reference actual implementation with official best practices
5. Understand version-specific features, limitations, and breaking changes
```

#### Technology Stack Deep Understanding
- **Language Mastery**: Deep understanding of language-specific idioms, patterns, and best practices
- **Framework Architecture**: Complete understanding of framework usage, patterns, and architectural decisions
- **Build System Expertise**: Master build processes, compilation, bundling, testing, and deployment
- **Database Integration**: Understand data persistence, queries, migrations, schema evolution
- **Infrastructure Tools**: Docker, CI/CD, deployment platforms, monitoring tools

### Phase 5: Advanced Analysis (Context Permitting)

**Objective: Deep dive into specialized areas when context allows**

#### Performance & Security Analysis
**UIThub Query**: `https://uithub.com/{owner}/{repo}?filePatterns=*test*,*spec*,*bench*,*security*,*auth*&excludeDirs=node_modules,vendor`

- **Performance Patterns**: Identify bottlenecks, caching strategies, optimization techniques
- **Security Implementation**: Authentication, authorization, input validation, security headers
- **Testing Strategy**: Test coverage, testing patterns, quality assurance approaches
- **Monitoring & Observability**: Logging, metrics, tracing, debugging capabilities

#### Advanced Integration Analysis
- **Plugin Architecture**: Extension points, hooks, middleware patterns
- **API Design**: RESTful patterns, GraphQL schemas, RPC interfaces
- **Data Processing**: Stream processing, batch operations, data transformation
- **Concurrency Patterns**: Threading, async patterns, race condition handling

### Phase 6: Omniscient Knowledge Synthesis

**Objective: Achieve author-level understanding and expertise**

#### Expert-Level Integration
I will synthesize all analysis into comprehensive understanding:

**Technical Omniscience:**
- **Complete Architecture**: Every component, interaction, design decision, and trade-off
- **Implementation Mastery**: Every algorithm, optimization, pattern, and edge case
- **Operational Expertise**: Deployment, configuration, monitoring, troubleshooting
- **Extension Knowledge**: How to extend, modify, integrate, and customize

**Practical Mastery:**
- **Command-Line Expertise**: Every CLI option, flag, behavior, and combination
- **Configuration Mastery**: Every setting, environment variable, and configuration pattern  
- **Debugging Proficiency**: Systematic approach to any issue or unexpected behavior
- **Integration Capability**: How to integrate with other systems, APIs, and workflows

#### Smart Context Management
- **Token Optimization**: Prioritize most critical information within context limits
- **Progressive Disclosure**: Build understanding incrementally with follow-up queries
- **Knowledge Persistence**: Save comprehensive analysis for future reference
- **Query Preparation**: Anticipate follow-up questions and prepare contextual responses

## Expert Knowledge Deliverables

### Smart Omniscient Analysis Report
```markdown
# Smart Technical Analysis: {repository-name}

_Analysis Strategy: {Small/Medium/Large Repository} | Documentation: 100% | Code: {coverage-percentage}_

## Executive Technical Summary
- **Architecture Pattern**: {architectural-style}
- **Technology Stack**: {primary-technologies}
- **Complexity Level**: {complexity-assessment}
- **Analysis Depth**: {analysis-completeness}

## Documentation Mastery (100% Coverage)
### Complete Command Reference
- **CLI Commands**: {every-command-option-behavior}
- **Configuration Options**: {all-config-parameters}
- **Environment Variables**: {env-var-matrix}
- **API Endpoints**: {complete-api-reference}

### Troubleshooting Expertise
- **Common Issues**: {known-problems-solutions}
- **Debugging Approaches**: {systematic-debugging-guide}
- **Performance Tuning**: {optimization-strategies}

## Core Architecture Understanding
### Entry Points & Execution Flow
- **Application Startup**: {initialization-sequence}
- **Main Execution Paths**: {primary-workflows}
- **Data Flow**: {input-processing-output}
- **State Management**: {state-handling-patterns}

### Critical Implementation Details
- **Core Algorithms**: {key-algorithmic-patterns}
- **Business Logic**: {main-functionality-implementation}
- **Integration Points**: {external-system-interfaces}
- **Extension Mechanisms**: {plugin-hook-architecture}

## Technology Stack Deep Dive
### Framework & Library Mastery
{context7-integrated-documentation}

### Build & Deployment
- **Build Process**: {compilation-bundling-steps}
- **Dependencies**: {dependency-analysis}
- **Infrastructure**: {deployment-configuration}
- **Testing Strategy**: {test-patterns-coverage}

## Expert-Level Capabilities Acquired
### Implementation Expertise
- Can explain any code section in detail
- Can trace any execution path from input to output
- Can identify optimization opportunities and bottlenecks
- Can guide implementation changes and extensions

### Operational Mastery
- Can troubleshoot any issue systematically
- Can configure and customize for different environments
- Can integrate with other systems and APIs
- Can guide contributing and development workflows

### Advanced Understanding
- Security implications and hardening strategies
- Performance characteristics and scaling considerations
- Architecture decisions and trade-offs
- Extension and customization capabilities
```

### Interactive Expert Knowledge Base
After analysis completion, I will have **omniscient understanding** enabling:

- **Any Implementation Question**: Explain any code section, algorithm, or pattern
- **Architecture Discussions**: Discuss design decisions, trade-offs, alternatives
- **Debugging Assistance**: Help troubleshoot any issue or unexpected behavior
- **Extension Guidance**: Guide extending, modifying, or integrating the codebase
- **Performance Analysis**: Discuss bottlenecks, optimizations, scaling considerations
- **Security Assessment**: Analyze security implications and hardening options

## Quality Assurance

### Completeness Verification
- **100% Code Coverage**: Every file, function, and line understood
- **All Execution Paths**: Every possible program flow mapped and understood
- **Complete Integration**: All external dependencies and integrations mastered
- **Full Configuration**: Every configuration option and environment variable understood

### Expert-Level Validation
- **Implementation Accuracy**: Verify understanding against actual code behavior
- **Architecture Correctness**: Validate architectural understanding against implementation
- **Performance Understanding**: Confirm performance characteristics and bottlenecks
- **Security Completeness**: Ensure all security implications are understood

## Success Criteria

Post-analysis, I will demonstrate **omniscient repository understanding** by being able to:

1. **Explain any code section** in detail with context and purpose
2. **Trace any execution path** from input to output with complete accuracy
3. **Discuss architectural decisions** with rationale and alternatives
4. **Identify optimization opportunities** and performance bottlenecks
5. **Guide implementation changes** with expert-level recommendations
6. **Troubleshoot any issue** with systematic debugging approach
7. **Explain integration patterns** and extension mechanisms
8. **Discuss security implications** and hardening strategies

The goal is **complete technical omniscience** - understanding the repository as deeply as its original authors, with the ability to discuss, debug, extend, and optimize any aspect of the codebase at an expert level.