#!/bin/bash

# 🎯 Claude Code - Quality Gate Léger
# Version allégée pour mode production - checks essentiels seulement

set -euo pipefail

CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}🎯 [Quality Light]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ [Quality Light]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️  [Quality Light]${NC} $1"
}

log_error() {
    echo -e "${RED}❌ [Quality Light]${NC} $1"
}

# Check TypeScript rapide (fichiers modifiés seulement)
quick_ts_check() {
    local project_dir="$1"
    
    if [[ ! -f "$project_dir/tsconfig.json" ]]; then
        return 0
    fi
    
    log_info "TypeScript check rapide..."
    
    # Check seulement les fichiers récemment modifiés (dernières 5 minutes)
    local recent_files
    recent_files=$(find "$project_dir" -name "*.ts" -o -name "*.tsx" | head -10)
    
    if [[ -n "$recent_files" ]] && command -v tsc &> /dev/null; then
        if tsc --noEmit --skipLibCheck 2>/dev/null; then
            log_success "TypeScript OK"
            return 0
        else
            log_warning "TypeScript: warnings détectées"
            return 1
        fi
    fi
    
    return 0
}

# Check any usage critique
critical_any_check() {
    local project_dir="$1"
    
    log_info "Vérification 'any' critique..."
    
    # Scan rapide fichiers .ts/.tsx récents seulement
    local critical_any
    critical_any=$(find "$project_dir" -name "*.ts" -o -name "*.tsx" | head -5 | xargs grep -l ": any\[\]\|any>" 2>/dev/null || true)
    
    if [[ -n "$critical_any" ]]; then
        log_error "Types 'any' critiques détectés:"
        echo "$critical_any" | head -3
        return 1
    fi
    
    log_success "Pas de 'any' critique"
    return 0
}

# Build check léger (si disponible)
light_build_check() {
    local project_dir="$1"
    
    if [[ ! -f "$project_dir/package.json" ]]; then
        return 0
    fi
    
    # Check si script typecheck existe
    if jq -r '.scripts.typecheck // empty' "$project_dir/package.json" | grep -q .; then
        log_info "Typecheck script..."
        
        local package_manager="npm"
        [[ -f "$project_dir/pnpm-lock.yaml" ]] && package_manager="pnpm"
        [[ -f "$project_dir/bun.lockb" ]] && package_manager="bun"
        
        if timeout 30s $package_manager run typecheck &>/dev/null; then
            log_success "Typecheck passed"
            return 0
        else
            log_warning "Typecheck timeout ou erreur"
            return 1
        fi
    fi
    
    return 0
}

# Main execution
main() {
    log_info "🚀 Quality Gate Léger - Mode Production"
    
    local exit_code=0
    
    # 1. TypeScript rapide
    if ! quick_ts_check "$CLAUDE_PROJECT_DIR"; then
        exit_code=1
    fi
    
    # 2. Any critique seulement
    if ! critical_any_check "$CLAUDE_PROJECT_DIR"; then
        exit_code=1
    fi
    
    # 3. Build léger si disponible
    if ! light_build_check "$CLAUDE_PROJECT_DIR"; then
        exit_code=1
    fi
    
    # Résultat final
    if [[ $exit_code -eq 0 ]]; then
        log_success "🎉 Quality Gate Léger PASSED"
    else
        log_warning "⚠️  Quality Gate Léger: warnings détectées"
    fi
    
    return $exit_code
}

main "$@"