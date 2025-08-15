#!/bin/bash

# 🎯 Claude Code - Filtre Intelligent de Fichiers
# Ne traite que les fichiers pertinents pour éviter surcharge CPU

set -euo pipefail

CLAUDE_FILE_PATHS="${CLAUDE_FILE_PATHS:-}"

# Extensions supportées par catégorie
TYPESCRIPT_EXTS="ts|tsx"
JAVASCRIPT_EXTS="js|jsx|mjs|cjs"
STYLE_EXTS="css|scss|sass|less"
CONFIG_EXTS="json|yml|yaml|toml"
DOC_EXTS="md|mdx|txt"
WEB_EXTS="html|htm|vue|svelte"

# Fonction de filtrage
filter_relevant_files() {
    local mode="${1:-web}"  # web, backend, docs, config
    
    while IFS= read -r file_path; do
        if [[ -n "$file_path" && -f "$file_path" ]]; then
            local basename_file=$(basename "$file_path")
            local ext="${basename_file##*.}"
            
            case "$mode" in
                "web")
                    if [[ "$file_path" =~ \.(${TYPESCRIPT_EXTS}|${JAVASCRIPT_EXTS}|${STYLE_EXTS})$ ]]; then
                        echo "$file_path"
                    fi
                    ;;
                "config")
                    if [[ "$file_path" =~ \.(${CONFIG_EXTS})$ ]]; then
                        echo "$file_path"
                    fi
                    ;;
                "docs")
                    if [[ "$file_path" =~ \.(${DOC_EXTS})$ ]]; then
                        echo "$file_path"
                    fi
                    ;;
                "all")
                    if [[ "$file_path" =~ \.(${TYPESCRIPT_EXTS}|${JAVASCRIPT_EXTS}|${STYLE_EXTS}|${CONFIG_EXTS}|${DOC_EXTS}|${WEB_EXTS})$ ]]; then
                        echo "$file_path"
                    fi
                    ;;
            esac
        fi
    done <<< "$CLAUDE_FILE_PATHS"
}

# Auto-détection du mode basé sur les fichiers
detect_project_mode() {
    local has_ts=false
    local has_config=false
    local has_docs=false
    
    while IFS= read -r file_path; do
        if [[ "$file_path" =~ \.(ts|tsx)$ ]]; then
            has_ts=true
        elif [[ "$file_path" =~ \.(json|yml|yaml)$ ]]; then
            has_config=true
        elif [[ "$file_path" =~ \.(md|txt)$ ]]; then
            has_docs=true
        fi
    done <<< "$CLAUDE_FILE_PATHS"
    
    if [[ "$has_ts" == "true" ]]; then
        echo "web"
    elif [[ "$has_config" == "true" ]]; then
        echo "config"
    elif [[ "$has_docs" == "true" ]]; then
        echo "docs"
    else
        echo "all"
    fi
}

# Exécution
mode=$(detect_project_mode)
filter_relevant_files "$mode"