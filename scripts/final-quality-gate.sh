#!/bin/bash

# 🎯 Claude Code - Final Quality Gate
# Comprehensive final check after Claude completes work

set -euo pipefail

CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CLAUDE_STRICT_MODE="${CLAUDE_STRICT_MODE:-true}"
CLAUDE_NO_ANY="${CLAUDE_NO_ANY:-true}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}🎯 [Quality Gate]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ [Quality Gate]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️  [Quality Gate]${NC} $1"
}

log_error() {
    echo -e "${RED}❌ [Quality Gate]${NC} $1"
}

log_header() {
    echo -e "${PURPLE}🚀 [Quality Gate]${NC} $1"
}

# Detect available package manager
detect_package_manager() {
    local project_dir="$1"
    
    if [[ -f "$project_dir/pnpm-lock.yaml" ]]; then
        echo "pnpm"
    elif [[ -f "$project_dir/bun.lockb" ]]; then
        echo "bun"
    elif [[ -f "$project_dir/yarn.lock" ]]; then
        echo "yarn"
    elif [[ -f "$project_dir/package.json" ]]; then
        echo "npm"
    else
        echo ""
    fi
}

# Run comprehensive TypeScript check
run_typescript_check() {
    local project_dir="$1"
    
    if [[ -f "$project_dir/tsconfig.json" ]]; then
        log_info "Running comprehensive TypeScript check"
        
        if command -v tsc &> /dev/null; then
            if ! tsc --noEmit --skipLibCheck; then
                log_error "TypeScript compilation errors detected"
                return 1
            else
                log_success "TypeScript check passed"
            fi
        else
            log_warning "TypeScript compiler not found - skipping type check"
        fi
    fi
    
    return 0
}

# Run linting with available tools
run_project_linting() {
    local project_dir="$1"
    local package_manager="$2"
    
    # ESLint check
    if [[ -f "$project_dir/eslint.config.js" ]] || [[ -f "$project_dir/eslint.config.mjs" ]] || [[ -f "$project_dir/.eslintrc.json" ]] || [[ -f "$project_dir/.eslintrc.js" ]]; then
        log_info "Running ESLint validation"
        
        local lint_cmd=""
        if command -v eslint &> /dev/null; then
            lint_cmd="eslint ."
        elif [[ -n "$package_manager" ]]; then
            lint_cmd="$package_manager exec eslint ."
        fi
        
        if [[ -n "$lint_cmd" ]]; then
            if ! $lint_cmd 2>/dev/null; then
                log_error "ESLint validation failed"
                return 1
            else
                log_success "ESLint validation passed"
            fi
        fi
    fi
    
    return 0
}

# Check for 'any' usage in TypeScript files
check_any_usage() {
    local project_dir="$1"
    
    if [[ "$CLAUDE_NO_ANY" != "true" ]]; then
        return 0
    fi
    
    log_info "Scanning for 'any' usage in TypeScript files"
    
    local any_files
    any_files=$(find "$project_dir" -name "*.ts" -o -name "*.tsx" | grep -v node_modules | xargs grep -l ": any\|<any>\|any\[\]\|= any\|any |" 2>/dev/null || true)
    
    if [[ -n "$any_files" ]]; then
        log_error "Found 'any' usage in the following files:"
        while IFS= read -r file; do
            echo "  📁 $file"
            grep -n ": any\|<any>\|any\[\]\|= any\|any |" "$file" | head -3 | while IFS= read -r line; do
                echo "    └─ $line"
            done
        done <<< "$any_files"
        return 1
    else
        log_success "No 'any' usage detected"
    fi
    
    return 0
}

# Run available build/test commands
run_build_validation() {
    local project_dir="$1"
    local package_manager="$2"
    
    if [[ -z "$package_manager" ]]; then
        return 0
    fi
    
    # Check package.json for available scripts
    if [[ -f "$project_dir/package.json" ]]; then
        local scripts
        scripts=$(cat "$project_dir/package.json" | jq -r '.scripts | keys[]' 2>/dev/null || true)
        
        # Run typecheck if available
        if echo "$scripts" | grep -q "typecheck"; then
            log_info "Running typecheck script"
            if ! $package_manager run typecheck; then
                log_error "Typecheck failed"
                return 1
            else
                log_success "Typecheck passed"
            fi
        fi
        
        # Run lint if available
        if echo "$scripts" | grep -q "^lint$"; then
            log_info "Running lint script"
            if ! $package_manager run lint; then
                log_error "Lint script failed"
                return 1
            else
                log_success "Lint script passed"
            fi
        fi
        
        # Run build check if available (but don't keep artifacts)
        if echo "$scripts" | grep -q "build"; then
            log_info "Running build validation"
            if ! $package_manager run build; then
                log_error "Build failed"
                return 1
            else
                log_success "Build validation passed"
            fi
        fi
    fi
    
    return 0
}

# Main execution
main() {
    log_header "🚀 Final Quality Gate Started"
    
    local project_dir="$CLAUDE_PROJECT_DIR"
    local package_manager
    package_manager=$(detect_package_manager "$project_dir")
    
    if [[ -n "$package_manager" ]]; then
        log_info "Detected package manager: $package_manager"
    else
        log_warning "No package manager detected"
    fi
    
    local exit_code=0
    
    # 1. TypeScript Check
    if ! run_typescript_check "$project_dir"; then
        exit_code=1
    fi
    
    # 2. Linting Check
    if ! run_project_linting "$project_dir" "$package_manager"; then
        exit_code=1
    fi
    
    # 3. Any Usage Check
    if ! check_any_usage "$project_dir"; then
        exit_code=1
    fi
    
    # 4. Build Validation (only if strict mode)
    if [[ "$CLAUDE_STRICT_MODE" == "true" ]]; then
        if ! run_build_validation "$project_dir" "$package_manager"; then
            exit_code=1
        fi
    fi
    
    # Final result
    if [[ $exit_code -eq 0 ]]; then
        log_header "🎉 QUALITY GATE PASSED - All checks successful!"
    else
        log_header "🚨 QUALITY GATE FAILED - Fix issues above before proceeding"
    fi
    
    return $exit_code
}

main "$@"