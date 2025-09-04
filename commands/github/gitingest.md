---
description: "Smart GitIngest integration for intelligent repository analysis with automatic mode detection"
allowed-tools:
  [
    "Bash(*)",
    "Write(*)", 
    "Read(*)",
    "LS(*)",
  ]
---

# Smart GitIngest Repository Analysis

Intelligent repository analysis using GitIngest CLI with automatic mode detection and smart filtering strategies.

## Usage

```bash
# Simple usage - auto-detects optimal strategy
/github/gitingest https://github.com/owner/repo

# With specific mode
/github/gitingest https://github.com/owner/repo --mode=docs
/github/gitingest https://github.com/owner/repo --mode=code  
/github/gitingest https://github.com/owner/repo --mode=config
/github/gitingest https://github.com/owner/repo --mode=full
```

## Arguments

- `$ARGUMENTS`: GitHub repository URL (required) + optional `--mode=<mode>` parameter

## Smart Analysis Modes

### 🎯 Auto-Detection (Default)
**Automatically selects optimal strategy based on repository characteristics**

- **Small repos** (< 100 files) → Full analysis with size limits
- **Medium repos** (100-1000 files) → Code + docs focus  
- **Large repos** (1000+ files) → Documentation priority
- **Config repos** (detected patterns) → Configuration files only

### 📚 Documentation Mode (`--mode=docs`)
**Perfect for understanding project structure and usage**
```bash
gitingest $URL -i "*.md" -i "*.rst" -i "*.txt" -i "docs/*" -s 102400
```
- All markdown, reStructured text, and documentation directories
- 100KB max per file (handles large docs)
- Excludes code to focus on project understanding

### 💻 Code Mode (`--mode=code`)
**Focuses on source code implementation**
```bash  
gitingest $URL -i "*.py" -i "*.js" -i "*.ts" -i "*.go" -i "*.rs" -i "*.java" -i "*.cpp" -i "*.c" -s 51200 -e "tests/*" -e "node_modules/*" -e "dist/*" -e "build/*"
```
- Major programming languages
- 50KB max per file (optimal for code analysis)
- Excludes tests, dependencies, and build artifacts

### ⚙️ Configuration Mode (`--mode=config`)  
**Analyzes project setup and deployment**
```bash
gitingest $URL -i "*.json" -i "*.yml" -i "*.yaml" -i "*.toml" -i "*.ini" -i "Dockerfile*" -i "*.env*" -i "Makefile" -i "package.json" -i "pyproject.toml" -i "Cargo.toml"
```
- All configuration and build files
- Docker, CI/CD, package managers
- Environment and deployment settings

### 🌍 Full Mode (`--mode=full`)
**Complete repository analysis (use with caution on large repos)**
```bash
gitingest $URL -s 204800 -e "node_modules/*" -e ".git/*" -e "dist/*" -e "build/*" -e "*.log" -e ".next/*" -e "__pycache__/*"
```
- All files up to 200KB each
- Standard exclusions for common bloat
- Best for smaller repositories

## Implementation Logic

### Phase 1: URL Parsing & Validation
1. **Extract Repository Info**: Parse owner/repo from GitHub URL
2. **Validate GitIngest Availability**: Ensure CLI is installed
3. **Mode Selection**: Auto-detect or use provided mode

### Phase 2: Auto-Detection Strategy (if mode not specified)
```markdown
Repository Analysis:
- Check if URL is accessible
- Estimate repository size (if possible via GitHub API patterns)
- Detect primary language from URL patterns
- Apply intelligent mode selection
```

### Phase 3: GitIngest Execution with Fallbacks
```bash
# Primary execution - save to dedicated directory
OUTPUT_DIR="$HOME/.claude/reports/gitingest"
OUTPUT_FILE="$OUTPUT_DIR/$(basename $URL)-$(date +%Y%m%d-%H%M%S).txt"
gitingest $URL [mode-specific-args] -o "$OUTPUT_FILE"

# Fallback strategies if primary fails:
# 1. Reduce file size limits by 50%
# 2. Add more restrictive exclusions  
# 3. Switch to docs-only mode
# 4. Final fallback: README only
```

### Phase 4: Analysis & Results
1. **File Processing**: Save output with timestamp
2. **Summary Generation**: Parse GitIngest output for key metrics
3. **Next Steps Suggestion**: Recommend follow-up actions
4. **Integration Options**: Offer deeper analysis with other commands

## Error Handling & Fallbacks

### Common Scenarios
- **Repository too large**: Automatic fallback to restrictive modes
- **Network timeouts**: Retry with smaller scope
- **Access denied**: Clear error message with token suggestions
- **GitIngest not installed**: Installation instructions

### Fallback Sequence
```
Primary Mode → Reduce file sizes → Add exclusions → Docs only → README only
```

## Output Format

```
🔄 GitIngest: Analyzing https://github.com/owner/repo
📊 Mode: Auto-selected 'code' (detected Python project)
⚡ Command: gitingest https://github.com/owner/repo -i "*.py" -i "*.md" -s 51200 -e "tests/*"

✅ Analysis Complete!
📁 Output: ~/.claude/reports/gitingest/repo-20250826-165430.txt
📊 Results: 744 files analyzed, ~195k tokens
🎯 Focus: Python source code + key documentation

💡 Next Steps:
   • Run /github/analyze-repo for architectural deep-dive
   • Use /research/smart-search for specific implementation questions
   • Check /refactor/refactor-code for improvement suggestions

📋 Quick Stats:
   Repository: owner/repo
   Files: 744 analyzed
   Size: 888KB output
   Estimated tokens: 195,700
   Location: ~/.claude/reports/gitingest/
```

## Integration Points

### With Existing Commands
- **Complements** `/github/analyze-repo` for external repository analysis
- **Feeds into** `/research/smart-search` for targeted research
- **Prepares for** `/refactor/refactor-code` with code understanding

### Output Management
- **Automatic timestamping** to avoid file conflicts
- **Organized storage** in `~/.claude/reports/gitingest/` (gitignored)
- **Clean naming** with repo name and timestamp
- **Easy access** via dedicated directory

## Best Practices

### For Small Repos (< 100 files)
- Use full mode for comprehensive understanding
- Perfect for learning new libraries or tools

### For Medium Repos (100-1000 files)  
- Start with docs mode for context
- Follow with code mode for implementation
- Use config mode for deployment understanding

### For Large Repos (1000+ files)
- Begin with docs-only for overview
- Target specific areas with code mode
- Avoid full mode unless absolutely necessary

### Performance Tips
- **File size limits** prevent token overflow
- **Smart exclusions** focus on relevant content
- **Mode selection** optimizes for use case

## Command Requirements

- **GitIngest CLI** must be installed (`pipx install gitingest`)
- **Network access** for GitHub repository cloning
- **Disk space** for temporary clones (cleaned automatically)
- **Write permissions** for output file creation

This command bridges the gap between external repository discovery and deep Claude Code analysis, providing the perfect entry point for understanding any GitHub project efficiently.