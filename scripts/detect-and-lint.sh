#!/bin/bash

# 🔍 Claude Code - Détection et Linting Intelligent
# Détecte automatiquement les outils de chaque projet et exécute les checks appropriés

set -euo pipefail

# Configuration
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CLAUDE_FILE_PATHS="${CLAUDE_FILE_PATHS:-}"
CLAUDE_STRICT_MODE="${CLAUDE_STRICT_MODE:-true}"
CLAUDE_NO_ANY="${CLAUDE_NO_ANY:-true}"

# Couleurs pour output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction de logging
log_info() {
    echo -e "${BLUE}ℹ️  [Claude Code]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ [Claude Code]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️  [Claude Code]${NC} $1"
}

log_error() {
    echo -e "${RED}❌ [Claude Code]${NC} $1"
}

# Détection des outils disponibles dans le projet
detect_project_tools() {
    local project_dir="$1"
    local tools=""
    
    # Package managers
    if [[ -f "$project_dir/package.json" ]]; then
        if [[ -f "$project_dir/pnpm-lock.yaml" ]]; then
            tools+="pnpm "
        elif [[ -f "$project_dir/bun.lockb" ]]; then
            tools+="bun "
        elif [[ -f "$project_dir/yarn.lock" ]]; then
            tools+="yarn "
        else
            tools+="npm "
        fi
    fi
    
    # TypeScript
    if [[ -f "$project_dir/tsconfig.json" ]] || [[ -f "$project_dir/tsconfig.*.json" ]]; then
        tools+="typescript "
    fi
    
    # Linting tools
    if [[ -f "$project_dir/eslint.config.js" ]] || [[ -f "$project_dir/eslint.config.mjs" ]] || [[ -f "$project_dir/.eslintrc.json" ]] || [[ -f "$project_dir/.eslintrc.js" ]]; then
        tools+="eslint "
    fi
    
    # Formatting tools
    if [[ -f "$project_dir/.prettierrc" ]] || [[ -f "$project_dir/.prettierrc.json" ]] || [[ -f "$project_dir/prettier.config.js" ]]; then
        tools+="prettier "
    fi
    
    # Build tools
    if [[ -f "$project_dir/turbo.json" ]]; then
        tools+="turbo "
    fi
    
    if [[ -f "$project_dir/vite.config.ts" ]] || [[ -f "$project_dir/vite.config.js" ]]; then
        tools+="vite "
    fi
    
    if [[ -f "$project_dir/next.config.js" ]] || [[ -f "$project_dir/next.config.ts" ]]; then
        tools+="next "
    fi
    
    echo "$tools"
}

# Validation TypeScript spécifique
validate_typescript() {
    local file_path="$1"
    local project_dir="$2"
    
    if [[ "$file_path" =~ \.(ts|tsx)$ ]]; then
        log_info "Vérification TypeScript pour: $(basename "$file_path")"
        
        # Type checking
        if command -v tsc &> /dev/null; then
            if ! tsc --noEmit --skipLibCheck "$file_path" 2>/dev/null; then
                log_error "Erreurs TypeScript détectées dans $file_path"
                return 1
            fi
        fi
        
        # Détection d'usage de 'any' si CLAUDE_NO_ANY est activé
        if [[ "$CLAUDE_NO_ANY" == "true" ]]; then
            if grep -n ": any\|<any>\|any\[\]\|= any\|any |" "$file_path" | grep -v "// @ts-ignore\|// eslint-disable" > /dev/null; then
                log_error "Usage de 'any' détecté dans $file_path"
                log_warning "Lignes concernées:"
                grep -n ": any\|<any>\|any\[\]\|= any\|any |" "$file_path" | grep -v "// @ts-ignore\|// eslint-disable" | while read -r line; do
                    echo "  $line"
                done
                return 1
            fi
        fi
    fi
    
    return 0
}

# Exécution du linting adaptatif
run_adaptive_linting() {
    local file_path="$1"
    local project_dir="$2"
    local tools="$3"
    local package_manager=""
    
    # Détermine le package manager
    if [[ "$tools" =~ pnpm ]]; then
        package_manager="pnpm"
    elif [[ "$tools" =~ bun ]]; then
        package_manager="bun"
    elif [[ "$tools" =~ yarn ]]; then
        package_manager="yarn"
    elif [[ "$tools" =~ npm ]]; then
        package_manager="npm"
    fi
    
    # Prettier - Formatage automatique
    if [[ "$tools" =~ prettier ]]; then
        log_info "Formatage avec Prettier: $(basename "$file_path")"
        if command -v prettier &> /dev/null; then
            prettier --write "$file_path" 2>/dev/null || log_warning "Prettier n'a pas pu formatter $file_path"
        elif [[ -n "$package_manager" ]]; then
            $package_manager exec prettier --write "$file_path" 2>/dev/null || log_warning "Prettier n'a pas pu formatter $file_path"
        fi
    fi
    
    # ESLint - Linting et fix automatique
    if [[ "$tools" =~ eslint ]]; then
        log_info "Linting ESLint pour: $(basename "$file_path")"
        if command -v eslint &> /dev/null; then
            if ! eslint --fix "$file_path" 2>/dev/null; then
                log_error "Erreurs ESLint détectées dans $file_path"
                eslint "$file_path" 2>&1 | head -20 || true
                return 1
            fi
        elif [[ -n "$package_manager" ]]; then
            if ! $package_manager exec eslint --fix "$file_path" 2>/dev/null; then
                log_error "Erreurs ESLint détectées dans $file_path"
                $package_manager exec eslint "$file_path" 2>&1 | head -20 || true
                return 1
            fi
        fi
    fi
    
    return 0
}

# Fonction principale
main() {
    log_info "Démarrage du processus de linting intelligent"
    
    # Vérifier les variables d'environnement
    if [[ -z "$CLAUDE_FILE_PATHS" ]]; then
        log_warning "Aucun fichier spécifié dans CLAUDE_FILE_PATHS"
        return 0
    fi
    
    # Détecter les outils du projet
    local tools
    tools=$(detect_project_tools "$CLAUDE_PROJECT_DIR")
    log_info "Outils détectés: $tools"
    
    # Traiter chaque fichier
    local exit_code=0
    while IFS= read -r file_path; do
        if [[ -n "$file_path" && -f "$file_path" ]]; then
            log_info "Traitement de: $file_path"
            
            # Validation TypeScript
            if ! validate_typescript "$file_path" "$CLAUDE_PROJECT_DIR"; then
                exit_code=1
                continue
            fi
            
            # Linting adaptatif
            if ! run_adaptive_linting "$file_path" "$CLAUDE_PROJECT_DIR" "$tools"; then
                exit_code=1
                continue
            fi
            
            log_success "✨ Traitement terminé pour: $(basename "$file_path")"
        fi
    done <<< "$CLAUDE_FILE_PATHS"
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "🎉 Tous les fichiers sont conformes aux standards"
    else
        log_error "🚨 Des erreurs ont été détectées - vérifiez les fichiers ci-dessus"
    fi
    
    return $exit_code
}

# Exécution
main "$@"