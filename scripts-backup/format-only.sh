#!/bin/bash

# 🎨 Claude Code - Formatage Rapide Seul
# Formatage ultra-léger pour fichiers config/docs sans linting lourd

set -euo pipefail

CLAUDE_FILE_PATHS="${CLAUDE_FILE_PATHS:-}"
CACHE_DIR="/tmp/claude-format-cache"

# Couleurs
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}🎨 [Format]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✨ [Format]${NC} $1"
}

# Cache simple pour éviter reformatage répétitif
get_cache_key() {
    local file_path="$1"
    echo "$(md5 -q "$file_path" 2>/dev/null || echo "no-hash")"
}

is_recently_formatted() {
    local file_path="$1"
    local cache_key=$(get_cache_key "$file_path")
    local cache_file="$CACHE_DIR/$cache_key"
    
    if [[ -f "$cache_file" ]]; then
        local cache_age=$(stat -f %m "$cache_file" 2>/dev/null || echo "0")
        local now=$(date +%s)
        if [[ $((now - cache_age)) -lt 60 ]]; then  # Cache 1 minute
            return 0
        fi
    fi
    return 1
}

mark_formatted() {
    local file_path="$1"
    local cache_key=$(get_cache_key "$file_path")
    mkdir -p "$CACHE_DIR"
    touch "$CACHE_DIR/$cache_key"
}

# Formatage rapide par type
format_file() {
    local file_path="$1"
    local ext="${file_path##*.}"
    
    case "$ext" in
        "json")
            if command -v jq &> /dev/null; then
                jq '.' "$file_path" > "${file_path}.tmp" && mv "${file_path}.tmp" "$file_path"
            elif command -v prettier &> /dev/null; then
                prettier --write "$file_path" &>/dev/null
            fi
            ;;
        "md"|"mdx")
            if command -v prettier &> /dev/null; then
                prettier --write --prose-wrap always "$file_path" &>/dev/null
            fi
            ;;
        "yml"|"yaml")
            if command -v prettier &> /dev/null; then
                prettier --write "$file_path" &>/dev/null
            fi
            ;;
    esac
}

# Main
main() {
    if [[ -z "$CLAUDE_FILE_PATHS" ]]; then
        exit 0
    fi
    
    local count=0
    while IFS= read -r file_path; do
        if [[ -n "$file_path" && -f "$file_path" ]]; then
            if is_recently_formatted "$file_path"; then
                continue
            fi
            
            log_info "Formatage $(basename "$file_path")"
            format_file "$file_path"
            mark_formatted "$file_path"
            ((count++))
        fi
    done <<< "$CLAUDE_FILE_PATHS"
    
    if [[ $count -gt 0 ]]; then
        log_success "$count fichier(s) formaté(s)"
    fi
}

main "$@"