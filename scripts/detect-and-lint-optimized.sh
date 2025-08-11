#!/bin/bash

# 🚀 Claude Code - Linting Optimisé avec Cache et Throttling
# Version haute performance avec gestion intelligente des ressources

set -euo pipefail

# Configuration optimisée
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CLAUDE_FILE_PATHS="${CLAUDE_FILE_PATHS:-}"
CLAUDE_NO_ANY="${CLAUDE_NO_ANY:-true}"

# Cache et throttling
CACHE_DIR="/tmp/claude-lint-cache"
LOCK_FILE="/tmp/claude-lint.lock"
MIN_INTERVAL=3  # secondes minimum entre exécutions
CACHE_TTL=300   # 5 minutes de cache

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}⚡ [Claude Fast]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ [Claude Fast]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️  [Claude Fast]${NC} $1"
}

# Throttling - éviter l'exécution trop fréquente
check_throttle() {
    if [[ -f "$LOCK_FILE" ]]; then
        local last_run=$(stat -f %m "$LOCK_FILE" 2>/dev/null || echo "0")
        local now=$(date +%s)
        local elapsed=$((now - last_run))
        
        if [[ $elapsed -lt $MIN_INTERVAL ]]; then
            log_info "⏳ Throttled - dernière exécution il y a ${elapsed}s"
            exit 0
        fi
    fi
    
    mkdir -p "$(dirname "$LOCK_FILE")"
    touch "$LOCK_FILE"
}

# Cache basé sur hash du fichier
get_file_cache_key() {
    local file_path="$1"
    local file_hash=$(md5 -q "$file_path" 2>/dev/null || echo "no-hash")
    local file_mtime=$(stat -f %m "$file_path" 2>/dev/null || echo "0")
    echo "${file_hash}_${file_mtime}"
}

is_cached_and_valid() {
    local cache_key="$1"
    local cache_file="$CACHE_DIR/$cache_key"
    
    if [[ -f "$cache_file" ]]; then
        local cache_age=$(stat -f %m "$cache_file" 2>/dev/null || echo "0")
        local now=$(date +%s)
        local age=$((now - cache_age))
        
        if [[ $age -lt $CACHE_TTL ]]; then
            return 0
        fi
    fi
    return 1
}

mark_cached() {
    local cache_key="$1"
    mkdir -p "$CACHE_DIR"
    touch "$CACHE_DIR/$cache_key"
}

# Détection rapide des outils projet (cache dans variable)
detect_tools_cached() {
    if [[ -n "${CLAUDE_PROJECT_TOOLS:-}" ]]; then
        echo "$CLAUDE_PROJECT_TOOLS"
        return
    fi
    
    local tools=""
    local project_dir="$1"
    
    # Package manager rapide
    [[ -f "$project_dir/pnpm-lock.yaml" ]] && tools+="pnpm "
    [[ -f "$project_dir/bun.lockb" ]] && tools+="bun "
    [[ -f "$project_dir/package.json" ]] && tools+="npm "
    
    # Outils essentiels seulement
    [[ -f "$project_dir/tsconfig.json" ]] && tools+="typescript "
    [[ -f "$project_dir/.eslintrc"* ]] || [[ -f "$project_dir/eslint.config"* ]] && tools+="eslint "
    [[ -f "$project_dir/.prettier"* ]] && tools+="prettier "
    
    # Cache pour la session
    export CLAUDE_PROJECT_TOOLS="$tools"
    echo "$tools"
}

# Validation TypeScript ultra rapide (fichier unique)
fast_typescript_check() {
    local file_path="$1"
    
    if [[ ! "$file_path" =~ \.(ts|tsx)$ ]]; then
        return 0
    fi
    
    # Check syntaxe basique seulement
    if command -v tsc &> /dev/null; then
        if ! tsc --noEmit --skipLibCheck --isolatedModules "$file_path" 2>/dev/null; then
            log_warning "⚠️  TypeScript: erreurs dans $(basename "$file_path")"
            return 1
        fi
    fi
    
    # Détection any rapide si activé
    if [[ "$CLAUDE_NO_ANY" == "true" ]]; then
        if grep -q ": any\|<any>\|any\[\]" "$file_path" 2>/dev/null; then
            log_warning "⚠️  'any' détecté dans $(basename "$file_path")"
            return 1
        fi
    fi
    
    return 0
}

# Linting ultra rapide
fast_lint() {
    local file_path="$1"
    local tools="$2"
    
    # Prettier en premier (le plus rapide)
    if [[ "$tools" =~ prettier ]] && command -v prettier &> /dev/null; then
        prettier --write "$file_path" &>/dev/null || true
    fi
    
    # ESLint avec --fix seulement si nécessaire
    if [[ "$tools" =~ eslint ]]; then
        if command -v eslint &> /dev/null; then
            eslint --fix --quiet "$file_path" &>/dev/null || true
        elif [[ "$tools" =~ npm ]] && [[ -f "$(pwd)/node_modules/.bin/eslint" ]]; then
            "$(pwd)/node_modules/.bin/eslint" --fix --quiet "$file_path" &>/dev/null || true
        fi
    fi
}

# Fonction principale optimisée
main() {
    # Throttling global
    check_throttle
    
    if [[ -z "$CLAUDE_FILE_PATHS" ]]; then
        log_info "Aucun fichier à traiter"
        exit 0
    fi
    
    # Détection tools cachée
    local tools
    tools=$(detect_tools_cached "$CLAUDE_PROJECT_DIR")
    
    # Traitement fichier par fichier avec cache
    local processed_count=0
    while IFS= read -r file_path; do
        if [[ -n "$file_path" && -f "$file_path" ]]; then
            local cache_key
            cache_key=$(get_file_cache_key "$file_path")
            
            # Check cache
            if is_cached_and_valid "$cache_key"; then
                log_info "📄 $(basename "$file_path") (cached)"
                continue
            fi
            
            log_info "📄 Processing $(basename "$file_path")"
            
            # TypeScript check rapide
            if ! fast_typescript_check "$file_path"; then
                continue  # Skip linting si erreur TS
            fi
            
            # Linting rapide
            fast_lint "$file_path" "$tools"
            
            # Marquer comme traité
            mark_cached "$cache_key"
            ((processed_count++))
        fi
    done <<< "$CLAUDE_FILE_PATHS"
    
    if [[ $processed_count -gt 0 ]]; then
        log_success "⚡ $processed_count fichier(s) traité(s)"
    else
        log_info "✨ Tous les fichiers déjà optimisés"
    fi
}

# Cleanup automatique du cache (périodique)
cleanup_cache() {
    if [[ -d "$CACHE_DIR" ]]; then
        find "$CACHE_DIR" -type f -mtime +1 -delete 2>/dev/null || true
    fi
}

# Exécution avec cleanup
cleanup_cache &
main "$@"