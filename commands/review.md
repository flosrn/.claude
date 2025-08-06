---
description: "Intelligent code review assistant with automated analysis, quality checks, and collaborative review workflows"
allowed-tools:
  [
    "Bash(gh pr review:*)",
    "Bash(gh pr diff:*)",
    "Bash(git diff:*)",
    "Bash(git log:*)",
    "Bash(gh pr view:*)",
    "Bash(gh pr comment:*)",
  ]
---

# Claude Command: Review

Intelligent code review assistant providing automated code analysis, quality validation, security scanning, and collaborative review workflows.

## Usage

```
/review                       # Start interactive review session
/review pr <number>           # Review specific pull request
/review diff                  # Review uncommitted changes
/review security              # Run security-focused review
/review performance           # Analyze performance implications
/review checklist             # Generate review checklist
/review submit                # Submit review with recommendations
```

## Automated Code Analysis

### Code Quality Assessment

- **Complexity analysis**: Cyclomatic complexity, cognitive load
- **Maintainability**: Code duplication, coupling, cohesion
- **Readability**: Naming conventions, documentation coverage
- **Test coverage**: Missing tests, test quality evaluation

### Pattern Recognition

```
Code Patterns Detected:
├── Anti-patterns: God objects, circular dependencies
├── Design patterns: Proper implementation verification
├── Architecture violations: Layer boundary breaches
└── Best practices: Framework-specific recommendations
```

### Language-Specific Analysis

- **TypeScript**: Type safety, interface design, generics usage
- **JavaScript**: Modern syntax adoption, async/await patterns
- **Python**: PEP compliance, type hints, performance patterns
- **Java**: Design patterns, memory management, concurrency
- **Go**: Idiomatic Go, error handling, goroutine usage

## Security Review

### Vulnerability Detection

- **OWASP Top 10**: SQL injection, XSS, authentication flaws
- **Dependency scanning**: Known vulnerabilities in packages
- **Secrets detection**: API keys, passwords in code
- **Permission issues**: Overprivileged operations

### Security Checklist

```
Security Review Points:
□ Input validation and sanitization
□ Authentication and authorization
□ Secure data transmission (HTTPS/TLS)
□ Proper error handling (no info leakage)
□ SQL injection prevention
□ XSS protection mechanisms
□ CSRF token implementation
□ Secure session management
□ Password hashing and storage
□ API rate limiting
```

### Compliance Validation

- GDPR data handling requirements
- SOC 2 compliance checks
- Industry-specific regulations
- Internal security policies

## Performance Analysis

### Performance Impact Assessment

- **Memory usage**: Heap allocation, memory leaks
- **CPU utilization**: Algorithmic complexity, optimization opportunities
- **I/O efficiency**: Database queries, file operations
- **Network calls**: API usage patterns, caching strategies

### Optimization Recommendations

```
Performance Optimizations:
├── Database: Query optimization, indexing suggestions
├── Frontend: Bundle size, lazy loading, caching
├── Backend: Algorithm improvements, async patterns
└── Infrastructure: Scaling recommendations
```

### Benchmarking Integration

- Performance regression detection
- Load testing recommendations
- Monitoring and observability
- Performance budget validation

## Quality Gates

### Code Standards Enforcement

- **Formatting**: ESLint, Prettier, language-specific linters
- **Documentation**: JSDoc, docstrings, README updates
- **Naming conventions**: Variables, functions, classes
- **File organization**: Structure and module boundaries

### Test Quality Assessment

```
Test Review Criteria:
├── Coverage: Line, branch, and condition coverage
├── Quality: Unit, integration, and e2e tests
├── Maintainability: Test readability and reliability
└── Performance: Test execution time and efficiency
```

### Breaking Change Detection

- API contract modifications
- Database schema changes
- Configuration requirement changes
- Backward compatibility assessment

## Collaborative Review

### Reviewer Assignment

- **Expertise matching**: Code area specialists
- **Workload balancing**: Review distribution
- **Learning opportunities**: Junior-senior pairings
- **Cross-team collaboration**: External stakeholder involvement

### Review Workflow Management

```
Review Process:
1. Automated pre-review analysis
2. Reviewer assignment and notification
3. Collaborative review with comments
4. Issue resolution and re-review
5. Approval and merge preparation
6. Post-merge feedback collection
```

### Communication Tools

- Contextual code comments
- Review summary generation
- Progress tracking dashboards
- Notification management

## Review Types

### Quick Review

- Basic quality checks
- Security scan
- Test coverage verification
- Simple approval workflow

### Comprehensive Review

- In-depth code analysis
- Architecture impact assessment
- Performance implications
- Documentation completeness

### Security-Focused Review

- Vulnerability assessment
- Compliance verification
- Threat modeling
- Penetration testing readiness

### Performance Review

- Algorithmic complexity analysis
- Resource usage optimization
- Scalability assessment
- Monitoring integration

## Interactive Review Session

### Visual Code Analysis

```
Interactive Review Interface:
┌─────────────────────────────────────────┐
│ 📊 Code Metrics                        │
├─────────────────────────────────────────┤
│ Complexity: 8/10 (High)                │
│ Coverage: 87% (Good)                   │
│ Duplication: 3% (Excellent)           │
│ Maintainability: B+ (Good)            │
└─────────────────────────────────────────┘
```

### Guided Review Process

- Step-by-step review guidance
- Priority-based issue ordering
- Context-aware suggestions
- Educational explanations

### Real-time Collaboration

- Live review sessions
- Screen sharing integration
- Voice/video call coordination
- Pair programming support

## Review Templates

### Feature Review Template

```
## Feature Review Checklist

### Functionality
- [ ] Feature works as specified
- [ ] Edge cases handled appropriately
- [ ] Error handling implemented
- [ ] User experience considerations

### Code Quality
- [ ] Clean, readable code
- [ ] Appropriate abstractions
- [ ] No code duplication
- [ ] Consistent with codebase patterns

### Testing
- [ ] Comprehensive test coverage
- [ ] Tests are maintainable
- [ ] Integration tests included
- [ ] Performance tests if applicable

### Documentation
- [ ] Code comments where necessary
- [ ] API documentation updated
- [ ] User documentation updated
- [ ] Migration guides if needed
```

### Bug Fix Review Template

```
## Bug Fix Review Checklist

### Problem Understanding
- [ ] Root cause identified
- [ ] Problem scope defined
- [ ] Impact assessment complete

### Solution Quality
- [ ] Minimal, focused fix
- [ ] No unintended side effects
- [ ] Appropriate error handling
- [ ] Performance considerations

### Testing
- [ ] Regression test added
- [ ] Existing tests still pass
- [ ] Manual testing completed
- [ ] Edge cases covered

### Documentation
- [ ] Fix explained in comments
- [ ] Changelog updated
- [ ] Known issues documented
```

## AI-Powered Insights

### Smart Suggestions

- **Code improvements**: Refactoring recommendations
- **Bug predictions**: Potential issue identification
- **Best practices**: Framework-specific guidance
- **Learning resources**: Educational content suggestions

### Pattern Learning

- Team coding patterns recognition
- Historical issue correlation
- Review outcome prediction
- Continuous improvement suggestions

### Context Awareness

- Project-specific conventions
- Team skill levels and preferences
- Deadline and priority considerations
- Risk tolerance assessment

## Integration Support

### Development Tools

- **IDEs**: VS Code, IntelliJ, Vim integration
- **CI/CD**: GitHub Actions, GitLab CI, Jenkins
- **Testing**: Jest, Pytest, JUnit integration
- **Monitoring**: Sentry, DataDog, New Relic

### Communication Platforms

- Slack review notifications
- Microsoft Teams integration
- Discord bot support
- Email digest reports

### Project Management

- Jira ticket linking
- Trello card updates
- Asana task synchronization
- Linear issue tracking

## Options

- `--quick`: Fast review with basic checks only
- `--security`: Focus on security-related issues
- `--performance`: Emphasize performance analysis
- `--educational`: Include learning explanations
- `--template <type>`: Use specific review template
- `--assign <reviewers>`: Request specific reviewers
- `--priority <level>`: Set review priority level
- `--checklist`: Generate detailed review checklist

## Metrics and Analytics

### Review Quality Metrics

- Average review time
- Issue detection rate
- False positive percentage
- Reviewer satisfaction scores

### Team Performance Insights

- Review velocity trends
- Knowledge sharing patterns
- Skill development tracking
- Collaboration effectiveness

### Continuous Improvement

- Review process optimization
- Tool effectiveness measurement
- Training need identification
- Best practice evolution

## Notes

- Integrates with existing code review tools and workflows
- Supports multiple programming languages and frameworks
- Provides both automated and human-assisted review processes
- Maintains review history and learning from past reviews
- Scales from individual developers to large engineering teams
- Respects team culture and coding standards preferences
