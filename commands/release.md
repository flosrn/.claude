---
description: "Automated release management with semantic versioning, changelog generation, and deployment orchestration"
allowed-tools:
  [
    "Bash(gh release:*)",
    "Bash(git tag:*)",
    "Bash(git log:*)",
    "Bash(npm version:*)",
    "Bash(npm publish:*)",
    "Bash(pnpm publish:*)",
    "Bash(git push:*)",
    "Bash(git fetch:*)",
  ]
---

# Claude Command: Release

Comprehensive release automation with semantic versioning, intelligent changelog generation, asset management, and deployment orchestration.

## Usage

```
/release                       # Interactive release wizard
/release patch                 # Create patch release (1.0.0 → 1.0.1)
/release minor                 # Create minor release (1.0.0 → 1.1.0)
/release major                 # Create major release (1.0.0 → 2.0.0)
/release prerelease            # Create prerelease (1.0.0 → 1.0.1-alpha.0)
/release changelog             # Generate changelog preview
/release assets               # Manage release assets
/release rollback <version>   # Rollback to previous version
```

## Semantic Versioning

### Version Types
- **Patch (x.y.Z)**: Bug fixes, security patches, minor improvements
- **Minor (x.Y.z)**: New features, enhancements, backwards-compatible changes
- **Major (X.y.z)**: Breaking changes, major architecture updates
- **Prerelease**: Alpha, beta, RC versions for testing

### Auto-Detection
- Analyzes commit messages since last release
- Identifies breaking changes from commit footers
- Suggests appropriate version bump
- Validates version constraints and policies

### Version Calculation
```
Conventional Commits Analysis:
- feat: → Minor version bump
- fix: → Patch version bump
- BREAKING CHANGE: → Major version bump
- feat!: or fix!: → Major version bump
- chore:, docs:, style: → No version bump
```

## Intelligent Changelog Generation

### Automated Sections
- **🚀 Features**: New functionality and enhancements
- **🐛 Bug Fixes**: Resolved issues and corrections
- **💥 Breaking Changes**: API changes requiring user action
- **⚡ Performance**: Performance improvements
- **🔒 Security**: Security-related changes
- **📚 Documentation**: Documentation updates
- **🧹 Maintenance**: Dependency updates, refactoring

### Content Sources
- Commit messages with conventional format
- Pull request titles and descriptions
- Closed issues linked to commits
- Breaking change footers
- Co-authored commits and contributors

### Smart Formatting
```markdown
## [1.2.0] - 2025-01-15

### 🚀 Features
- **auth**: Add OAuth2 integration with Google and GitHub (#123)
- **api**: Implement GraphQL subscription support (#145)
- **ui**: New dashboard with real-time metrics (#167)

### 🐛 Bug Fixes
- **database**: Fix connection pool exhaustion (#189)
- **validation**: Resolve email format validation edge case (#201)

### 💥 Breaking Changes
- **api**: Remove deprecated v1 endpoints
  - MIGRATION: Update API calls from `/v1/` to `/v2/`
  - See migration guide: docs/migration-v2.md

### Contributors
Special thanks to @contributor1, @contributor2, and @contributor3
```

## Release Asset Management

### Build Artifacts
- Automatically builds distribution packages
- Generates platform-specific binaries
- Creates Docker images with version tags
- Prepares documentation bundles

### Asset Types
- **Source Code**: Automatic archive generation
- **Binaries**: Cross-platform executable builds
- **Packages**: npm, PyPI, Maven, NuGet packages
- **Documentation**: Generated docs, API references
- **Docker Images**: Multi-arch container images

### Verification
- Checksum generation for all assets
- Digital signing for security
- Virus scanning for binaries
- License compliance validation

## Deployment Orchestration

### Environment Stages
```
Release Pipeline:
1. Staging Deployment
   ├── Run integration tests
   ├── Performance benchmarks
   └── Security scans

2. Production Deployment
   ├── Blue/green deployment
   ├── Health checks
   └── Rollback readiness

3. Post-Release
   ├── Monitoring alerts
   ├── Performance tracking
   └── User feedback collection
```

### Deployment Strategies
- **Blue/Green**: Zero-downtime deployments
- **Rolling**: Gradual rollout with monitoring
- **Canary**: Controlled exposure to subset of users
- **Feature Flags**: Gradual feature activation

## Quality Gates

### Pre-Release Validation
- All CI/CD pipelines passing
- Code coverage above threshold
- Security vulnerabilities resolved
- Breaking change documentation complete
- Migration scripts tested

### Release Criteria
```
Quality Checklist:
□ All tests passing (unit, integration, e2e)
□ Code coverage ≥ 80%
□ No critical security vulnerabilities
□ Performance benchmarks met
□ Documentation updated
□ Migration guides written
□ Rollback plan documented
□ Monitoring alerts configured
```

### Post-Release Monitoring
- Application performance metrics
- Error rate monitoring
- User adoption tracking
- Feature usage analytics

## Branch Strategy Integration

### Git Flow Support
- Release branches: `release/v1.2.0`
- Automatic merge to main and develop
- Tag creation on main branch
- Hotfix branch preparation

### GitHub Flow Support
- Direct releases from main branch
- Feature branch integration
- Continuous deployment readiness

## Rollback and Recovery

### Automatic Rollback Triggers
- Critical error rate threshold exceeded
- Performance degradation detected
- Security incident identified
- Manual rollback initiation

### Rollback Process
```
Rollback Sequence:
1. Stop new deployments
2. Revert to previous version
3. Update DNS/load balancer
4. Verify system health
5. Notify stakeholders
6. Document incident
```

### Recovery Planning
- Database migration rollbacks
- API compatibility maintenance
- Feature flag management
- User communication templates

## Notification and Communication

### Stakeholder Updates
- **Developers**: Technical changelog, breaking changes
- **Product Team**: Feature summary, user impact
- **Support**: Known issues, troubleshooting guides
- **Users**: Release notes, new features announcement

### Integration Channels
- Slack/Discord release announcements
- Email notifications to subscribers
- Social media automated posts
- Documentation site updates

## Advanced Features

### Release Scheduling
- Planned release windows
- Timezone-aware scheduling
- Maintenance window coordination
- Holiday/blackout period awareness

### A/B Testing Integration
- Feature flag coordination
- Experiment version tracking
- Results correlation with releases
- Gradual feature rollouts

### Compliance and Auditing
- Release approval workflows
- Audit trail maintenance
- Regulatory compliance checks
- Change control documentation

## Options

- `--dry-run`: Preview release without executing
- `--skip-tests`: Skip test validation (not recommended)
- `--skip-build`: Use existing build artifacts
- `--prerelease`: Create pre-release version
- `--draft`: Create draft release for review
- `--auto-publish`: Auto-publish packages to registries
- `--schedule <datetime>`: Schedule release for later
- `--rollback-timeout <minutes>`: Auto-rollback timeout

## Integration Support

### Package Registries
- npm/yarn (Node.js)
- PyPI (Python)
- Maven Central (Java)
- NuGet (C#/.NET)
- Docker Hub/Registry
- Homebrew (macOS)

### CI/CD Platforms
- GitHub Actions
- GitLab CI/CD
- Jenkins
- CircleCI
- Azure DevOps
- AWS CodePipeline

### Monitoring Tools
- DataDog
- New Relic
- Sentry
- Grafana
- Prometheus
- Application Insights

## Notes

- Follows semantic versioning specification (semver.org)
- Compatible with conventional commits standard
- Supports monorepo and multi-package releases
- Integrates with existing development workflows
- Provides comprehensive audit trails for compliance
- Maintains backwards compatibility with manual processes