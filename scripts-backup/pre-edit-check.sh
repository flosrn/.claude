#!/bin/bash

# 🛡️ Claude Code - Validation Pré-Édition
# Vérifie l'état des fichiers avant modification

set -euo pipefail

CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CLAUDE_FILE_PATHS="${CLAUDE_FILE_PATHS:-}"

# Couleurs
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}🔍 [Pre-Edit]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️  [Pre-Edit]${NC} $1"
}

log_error() {
    echo -e "${RED}🚫 [Pre-Edit]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ [Pre-Edit]${NC} $1"
}

# Vérification de l'état Git
check_git_status() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        if [[ -n "$(git status --porcelain)" ]]; then
            log_warning "Repository Git non-clean - des changements non-committés existent"
        else
            log_success "Repository Git propre"
        fi
    fi
}

# Vérification TypeScript globale
check_project_typescript() {
    local project_dir="$1"
    
    if [[ -f "$project_dir/tsconfig.json" ]]; then
        log_info "Vérification TypeScript globale du projet"
        
        if command -v tsc &> /dev/null; then
            if ! tsc --noEmit --skipLibCheck 2>/dev/null; then
                log_error "Le projet contient des erreurs TypeScript globales"
                return 1
            else
                log_success "Aucune erreur TypeScript globale détectée"
            fi
        fi
    fi
    
    return 0
}

# Vérification de la syntaxe des fichiers
check_file_syntax() {
    local file_path="$1"
    
    if [[ "$file_path" =~ \.(ts|tsx)$ ]]; then
        # Vérification syntaxe TypeScript
        if command -v tsc &> /dev/null; then
            if ! tsc --noEmit --allowJs false "$file_path" 2>/dev/null; then
                log_error "Erreur de syntaxe TypeScript dans: $file_path"
                return 1
            fi
        fi
    elif [[ "$file_path" =~ \.(js|jsx)$ ]]; then
        # Vérification syntaxe JavaScript
        if command -v node &> /dev/null; then
            if ! node -c "$file_path" 2>/dev/null; then
                log_error "Erreur de syntaxe JavaScript dans: $file_path"
                return 1
            fi
        fi
    elif [[ "$file_path" =~ \.json$ ]]; then
        # Vérification syntaxe JSON
        if command -v jq &> /dev/null; then
            if ! jq empty "$file_path" 2>/dev/null; then
                log_error "JSON invalide dans: $file_path"
                return 1
            fi
        elif command -v node &> /dev/null; then
            if ! node -e "JSON.parse(require('fs').readFileSync('$file_path', 'utf8'))" 2>/dev/null; then
                log_error "JSON invalide dans: $file_path"
                return 1
            fi
        fi
    fi
    
    return 0
}

# Fonction principale
main() {
    log_info "Validation pré-édition démarrée"
    
    # Vérification de l'état Git
    check_git_status
    
    # Vérification TypeScript globale
    if ! check_project_typescript "$CLAUDE_PROJECT_DIR"; then
        log_error "❌ Le projet contient des erreurs TypeScript - édition bloquée"
        return 1
    fi
    
    # Vérification des fichiers individuels
    if [[ -n "$CLAUDE_FILE_PATHS" ]]; then
        local exit_code=0
        while IFS= read -r file_path; do
            if [[ -n "$file_path" && -f "$file_path" ]]; then
                if ! check_file_syntax "$file_path"; then
                    exit_code=1
                fi
            fi
        done <<< "$CLAUDE_FILE_PATHS"
        
        if [[ $exit_code -ne 0 ]]; then
            log_error "❌ Des erreurs de syntaxe ont été détectées - édition bloquée"
            return 1
        fi
    fi
    
    log_success "✅ Validation pré-édition réussie - édition autorisée"
    return 0
}

main "$@"