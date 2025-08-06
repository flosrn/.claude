---
description: "Comprehensive MCP (Model Context Protocol) server management with intelligent installation, scope management, and troubleshooting workflows"
allowed-tools:
  [
    "Bash(claude mcp:*)",
    "Bash(npx:*)",
    "Bash(uvx:*)",
    "Bash(pip install:*)",
    "Bash(npm install:*)",
    "Read(*)",
    "Write(*)",
    "Edit(*)",
    "WebSearch(*)",
    "WebFetch(*)",
    "LS(*)",
  ]
---

# Claude Command: MCP Management (mcp-mgmt)

Comprehensive MCP (Model Context Protocol) server management system providing intelligent installation, scope management, troubleshooting, and best practices enforcement for Claude Code integrations.

## Usage

```
/mcp-mgmt                      # Interactive MCP management wizard
/mcp-mgmt install <server>     # Smart server installation with scope detection
/mcp-mgmt list                 # List all configured servers with status
/mcp-mgmt remove <server>      # Remove server with cleanup
/mcp-mgmt status               # Health check and diagnostic report
/mcp-mgmt troubleshoot        # Comprehensive troubleshooting assistant
/mcp-mgmt authenticate <server># Handle server authentication
/mcp-mgmt update <server>     # Update server to latest version
/mcp-mgmt config              # Manage MCP configurations
```

## MCP Installation Mastery

### Scope Intelligence System

**Automatic Scope Detection:**
- **Project context analysis**: Detects if you're in a team project vs personal workspace
- **Server type classification**: Categorizes servers by use case and sharing needs
- **Permission analysis**: Evaluates security requirements and access patterns
- **Recommendation engine**: Suggests optimal scope based on context

### Scope Hierarchy Understanding

```
Scope Precedence (Highest to Lowest):
├── Local Scope (Project-specific)
│   ├── Stored in: .claude/mcp.json
│   ├── Use for: Personal dev servers, sensitive credentials
│   ├── Command: claude mcp add <server> --scope local
│   └── Isolation: Complete project isolation
│
├── Project Scope (Team collaboration)  
│   ├── Stored in: .mcp.json (version controlled)
│   ├── Use for: Shared team tools, standardized workflows
│   ├── Command: claude mcp add <server> --scope project
│   └── Approval: Requires user consent for security
│
└── User Scope (Cross-project)
    ├── Stored in: ~/.claude.json
    ├── Use for: Personal utilities, development tools
    ├── Command: claude mcp add <server> --scope user
    └── Availability: All projects on machine
```

### Smart Installation Process

**Pre-Installation Analysis:**
1. **Server verification**: Validates server existence and authenticity
2. **Dependency check**: Ensures required runtimes (Node.js, Python, etc.)
3. **Scope recommendation**: Suggests optimal installation scope
4. **Conflict detection**: Identifies potential conflicts with existing servers
5. **Security assessment**: Evaluates server permissions and risks

**Installation Execution:**
```
Smart Installation Workflow:
1. Server Discovery & Validation
   ├── GitHub repository verification
   ├── Package registry confirmation  
   ├── Documentation completeness check
   └── Security reputation analysis

2. Environment Preparation
   ├── Runtime dependency verification
   ├── Installation path setup
   ├── Permission configuration
   └── Backup creation for rollback

3. Intelligent Installation
   ├── Optimal installation method selection
   ├── Scope-appropriate configuration
   ├── Integration testing
   └── Health verification

4. Post-Installation Validation
   ├── Connection testing
   ├── Functionality verification
   ├── Performance baseline
   └── Documentation generation
```

## Installation Methods Mastery

### Package Manager Integration

**NPM/Node.js Servers:**
```bash
# Standard NPM installation
claude mcp add youtube-transcript npx --scope user -- -y @jkawamoto/mcp-youtube-transcript

# With environment variables
claude mcp add api-server npx --scope local -e API_KEY=value -- server.js

# With custom arguments
claude mcp add custom-server node --scope project -- /path/to/server.js --port 3000
```

**Python/UV Servers:**
```bash
# UV installation from GitHub
claude mcp add git-server uvx --scope user -- --from git+https://github.com/user/repo server

# UV with specific Python version
claude mcp add py-server uvx --scope project -- --python 3.11 package-name

# Pip installation
claude mcp add local-server python --scope local -- -m pip install package && python -m package
```

**Pre-built Binary Servers:**
```bash
# Direct executable
claude mcp add binary-server /path/to/binary --scope user

# With configuration file
claude mcp add config-server /usr/local/bin/server --scope project -- --config config.json
```

### Transport Protocol Mastery

**STDIO Transport (Default):**
- Direct process communication
- Lowest latency and overhead
- Best for local development
- Standard for most MCP servers

**SSE (Server-Sent Events):**
```bash
# Cloud-based MCP server
claude mcp add cloud-server https://api.example.com/mcp/sse --transport sse --scope user

# With authentication headers
claude mcp add auth-server https://api.example.com/mcp/sse --transport sse -H "Authorization: Bearer token"
```

**HTTP Transport:**
```bash
# REST-based MCP server
claude mcp add rest-server https://api.example.com/mcp --transport http --scope project

# With custom headers
claude mcp add api-server https://api.example.com/mcp --transport http -H "X-API-Key: key" -H "Content-Type: application/json"
```

## Server Management Excellence

### Comprehensive Status Monitoring

**Health Check System:**
```
MCP Server Status Dashboard:
┌─────────────────────────────────────────────────────────────┐
│ 🟢 context7         │ SSE     │ Connected    │ v1.2.0     │
│ 🟡 youtube-transcript│ STDIO   │ Slow response│ v2.1.0     │
│ 🔴 custom-server     │ STDIO   │ Failed       │ v1.0.0     │
│ 🔄 updating-server   │ HTTP    │ Updating...  │ v1.1.0→1.2 │
└─────────────────────────────────────────────────────────────┘

Status Indicators:
🟢 Connected and healthy
🟡 Connected with issues  
🔴 Connection failed
🔄 Operation in progress
⚠️  Authentication needed
🔒 Permission denied
```

**Diagnostic Information:**
- Connection latency and response times
- Resource usage (memory, CPU)
- Error rates and failure patterns  
- Authentication status and token validity
- Version information and update availability

### Intelligent Troubleshooting

**Automatic Problem Detection:**
```
Common Issues & Auto-Resolution:
├── Connection Failures
│   ├── Port conflicts → Auto port reassignment
│   ├── Permission issues → Sudo/admin guidance
│   ├── Network problems → Connectivity verification
│   └── Service crashes → Restart and logging
│
├── Authentication Problems
│   ├── Expired tokens → Auto-refresh attempt
│   ├── Invalid credentials → Re-authentication flow
│   ├── Permission changes → Scope validation
│   └── OAuth issues → Complete re-authorization
│
├── Configuration Errors
│   ├── Invalid JSON → Syntax correction assistance
│   ├── Missing dependencies → Installation guidance
│   ├── Path issues → Path resolution and validation
│   └── Environment variables → Configuration assistance
│
└── Performance Issues
    ├── High latency → Connection optimization
    ├── Memory leaks → Resource monitoring setup
    ├── CPU overuse → Performance profiling
    └── Timeouts → Timeout configuration tuning
```

**Interactive Troubleshooting:**
1. **Symptom analysis**: Describes observed problems
2. **Diagnostic execution**: Runs comprehensive system checks
3. **Root cause identification**: Pinpoints specific issues
4. **Solution recommendation**: Provides step-by-step fixes
5. **Resolution verification**: Confirms problems are resolved
6. **Prevention guidance**: Suggests measures to prevent recurrence

## Configuration Management

### Multi-Environment Support

**Configuration File Locations:**
```
Configuration Hierarchy:
├── ~/.claude.json (User scope)
│   ├── Personal servers across all projects
│   ├── Development utilities
│   └── Cross-project tools
│
├── .claude/mcp.json (Local scope)  
│   ├── Project-specific servers
│   ├── Sensitive credentials
│   └── Development overrides
│
└── .mcp.json (Project scope)
    ├── Team-shared configurations
    ├── Standardized toolsets
    └── Version-controlled settings
```

**Environment Variable Integration:**
```json
{
  "mcpServers": {
    "api-server": {
      "command": "node",
      "args": ["server.js"],
      "env": {
        "API_KEY": "${API_KEY}",
        "DATABASE_URL": "${DATABASE_URL}",
        "PORT": "${MCP_PORT:-3000}"
      }
    }
  }
}
```

**Dynamic Configuration:**
- Machine-specific path resolution
- Environment-based server selection
- Conditional server loading
- Runtime parameter injection

### Security Best Practices

**Server Validation Framework:**
```
Security Validation Checklist:
□ Source code repository verification
□ Package signature validation
□ Dependency security scanning
□ Permission requirement analysis
□ Network access pattern review
□ Data handling practices evaluation
□ Authentication mechanism verification
□ Update and maintenance status check
```

**Risk Assessment Matrix:**
```
Risk Levels:
├── Low Risk (Green)
│   ├── Official Anthropic servers
│   ├── Well-known open source projects
│   ├── Read-only functionality
│   └── No network access required
│
├── Medium Risk (Yellow)
│   ├── Community-developed servers
│   ├── Limited file system access
│   ├── Outbound network connections
│   └── Minimal credential requirements
│
└── High Risk (Red)
    ├── Unknown or unverified sources
    ├── Extensive system access
    ├── Credential management
    └── Code execution capabilities
```

## Advanced MCP Operations

### Batch Management

**Workspace-wide Operations:**
```bash
# Install standard development stack across workspace
/mcp-mgmt install-stack development
# → Installs: GitHub, Context7, YouTube Transcript, Shadcn-UI

# Update all servers to latest versions
/mcp-mgmt update-all --scope user

# Health check entire MCP ecosystem
/mcp-mgmt health-check --comprehensive

# Backup all MCP configurations
/mcp-mgmt backup --include-credentials
```

**Template-based Installation:**
```yaml
# ~/.claude/mcp-templates.yml
templates:
  web-development:
    - server: "@jkawamoto/mcp-youtube-transcript"
      scope: "user"
    - server: "context7"
      scope: "user"  
    - server: "shadcn-ui"
      scope: "project"
      
  data-analysis:
    - server: "jupyter-mcp"
      scope: "local"
    - server: "pandas-helper"
      scope: "user"
```

### Version Management

**Semantic Version Control:**
- Track server versions and compatibility
- Automatic update notifications
- Rollback capabilities for failed updates
- Dependency version conflict resolution

**Update Strategies:**
```
Update Approaches:
├── Conservative: Manual updates with approval
├── Balanced: Auto-patch, manual minor/major
├── Aggressive: All updates automated
└── Custom: Per-server update policies
```

## Error Handling and Recovery

### Comprehensive Error Classification

**Connection Errors:**
- Network connectivity issues
- Port binding conflicts
- Protocol mismatch problems
- Timeout and latency issues

**Authentication Failures:**
- Token expiration and refresh
- Permission and scope changes
- OAuth flow interruptions
- Credential corruption

**Configuration Problems:**
- Syntax errors in JSON files
- Missing or invalid environment variables
- Path resolution failures
- Dependency conflicts

**Runtime Failures:**
- Server crashes and restarts
- Resource exhaustion
- Performance degradation
- Integration conflicts

### Recovery Procedures

**Automatic Recovery:**
```
Self-Healing Actions:
├── Connection retry with exponential backoff
├── Token refresh and re-authentication  
├── Configuration validation and repair
├── Dependency reinstallation
├── Cache clearing and reset
└── Service restart and monitoring
```

**Manual Recovery Guidance:**
1. **Problem identification**: Clear error categorization
2. **Step-by-step resolution**: Detailed fix procedures
3. **Verification testing**: Confirm resolution success
4. **Prevention measures**: Avoid future occurrences
5. **Escalation options**: When to seek additional help

## Performance Optimization

### Resource Management

**Memory Optimization:**
- Server memory usage monitoring
- Automatic cleanup of idle servers
- Resource limit configuration
- Memory leak detection

**Network Efficiency:**
- Connection pooling and reuse
- Request batching and caching
- Compression and optimization
- Bandwidth usage monitoring

**CPU Management:**
- Process priority optimization
- Concurrent operation limiting
- CPU usage threshold alerts
- Performance profiling tools

### Monitoring and Analytics

**Performance Metrics:**
```
MCP Performance Dashboard:
┌─────────────────────────────────────────────────────────┐
│ Server Performance Metrics (Last 24h)                  │
├─────────────────────────────────────────────────────────┤
│ context7         │ 45ms avg │ 99.9% uptime │ 12MB RAM  │
│ youtube-transcript│ 120ms avg│ 98.5% uptime │ 8MB RAM   │
│ custom-server    │ 890ms avg│ 85.2% uptime │ 24MB RAM  │
└─────────────────────────────────────────────────────────┘

Alerts:
⚠️  custom-server: High latency detected
🔴 custom-server: Reliability below threshold
```

**Usage Analytics:**
- Request frequency and patterns
- Feature utilization statistics
- Error rates and trends
- User interaction patterns

## Integration Excellence

### Development Environment Integration

**IDE Support:**
- VS Code MCP extension integration
- IntelliJ plugin coordination
- Vim/Neovim setup assistance
- Editor-specific configuration

**CI/CD Integration:**
```yaml
# GitHub Actions MCP Setup
- name: Setup MCP Servers
  uses: claude-code/setup-mcp@v1
  with:
    servers: |
      context7
      youtube-transcript
    scope: project
    verify: true
```

**Docker Environment:**
```dockerfile
# MCP-enabled development container
FROM node:18-alpine
RUN npm install -g @anthropic/claude-code
COPY .mcp.json /workspace/
RUN claude mcp install-from-config /workspace/.mcp.json
```

### Team Collaboration

**Shared Configuration Management:**
- Version-controlled MCP setups
- Team-wide server standardization
- Permission and access management
- Onboarding automation

**Documentation Generation:**
- Auto-generated MCP documentation
- Server capability references
- Usage examples and guides
- Troubleshooting knowledge base

## Options and Flags

### Command Options

- `--scope <scope>`: Specify installation scope (local/project/user)
- `--transport <type>`: Set transport protocol (stdio/sse/http)
- `--dry-run`: Preview operations without executing
- `--force`: Override safety checks and warnings
- `--verbose`: Enable detailed logging and debugging
- `--config <file>`: Use custom configuration file
- `--no-verify`: Skip server verification checks
- `--backup`: Create backup before destructive operations
- `--parallel <n>`: Set parallel operation limit
- `--timeout <seconds>`: Configure operation timeouts

### Environment Variables

```bash
# MCP configuration environment variables
export CLAUDE_MCP_LOG_LEVEL=debug
export CLAUDE_MCP_CONFIG_DIR=~/.claude
export CLAUDE_MCP_CACHE_DIR=~/.claude/cache
export CLAUDE_MCP_BACKUP_DIR=~/.claude/backups
export CLAUDE_MCP_AUTO_UPDATE=false
export CLAUDE_MCP_VERIFY_SSL=true
```

## Success Metrics and Quality Assurance

### Installation Success Criteria

**Technical Validation:**
- Server connectivity established
- All required tools and dependencies present
- Configuration files properly formatted
- Authentication successfully completed
- Health checks passing consistently

**Functional Verification:**
- Core server functionality working
- Integration with Claude Code confirmed
- Performance within acceptable ranges
- Error handling working correctly
- Documentation accessible and complete

### Quality Gates

**Pre-Installation:**
- Server source verification
- Security risk assessment
- Compatibility validation
- Resource requirement check
- Network connectivity test

**Post-Installation:**
- Functionality test suite
- Performance benchmark
- Integration verification  
- Security configuration audit
- Documentation completeness

## Continuous Improvement

### Learning and Adaptation

**Usage Pattern Learning:**
- Server utilization analysis
- Performance optimization recommendations
- Configuration improvement suggestions
- Workflow enhancement opportunities

**Community Integration:**
- Server recommendation system
- Best practice sharing
- Issue reporting and resolution
- Feature request collection

**Automated Enhancement:**
- Self-optimizing configurations
- Predictive maintenance
- Proactive issue resolution
- Continuous performance tuning

## Notes

- **Claude Code Integration**: Seamlessly integrates with existing Claude Code workflows
- **Cross-Platform Support**: Works on macOS, Linux, and Windows environments
- **Scalability**: Handles single servers to large enterprise MCP ecosystems
- **Security-First**: Implements comprehensive security validation and best practices
- **Extensibility**: Supports custom server types and integration patterns
- **Reliability**: Provides robust error handling and recovery mechanisms
- **Performance**: Optimized for minimal resource usage and maximum responsiveness
- **Documentation**: Maintains comprehensive documentation and troubleshooting guides