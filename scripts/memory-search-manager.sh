#!/bin/bash
# Memory Search Manager - Central control for CORE Memory search operations
# Usage: memory-search-manager.sh [enable|disable|status|search "query"]

SCRIPT_DIR="$(dirname "$0")"
SETTINGS_FILE="$HOME/.claude/settings.json"

case "$1" in
    "enable")
        echo "🧠 Enabling automatic memory search..."
        # Update settings.json to enable auto memory search
        if command -v jq >/dev/null 2>&1; then
            jq '.env.CLAUDE_MEMORY_SEARCH_AUTO = "true"' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        else
            sed -i '' 's/"CLAUDE_MEMORY_SEARCH_AUTO": "false"/"CLAUDE_MEMORY_SEARCH_AUTO": "true"/g' "$SETTINGS_FILE"
        fi
        echo "✅ Automatic memory search enabled"
        ;;
    
    "disable")
        echo "🚫 Disabling automatic memory search..."
        # Update settings.json to disable auto memory search
        if command -v jq >/dev/null 2>&1; then
            jq '.env.CLAUDE_MEMORY_SEARCH_AUTO = "false"' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        else
            sed -i '' 's/"CLAUDE_MEMORY_SEARCH_AUTO": "true"/"CLAUDE_MEMORY_SEARCH_AUTO": "false"/g' "$SETTINGS_FILE"
        fi
        echo "✅ Automatic memory search disabled"
        ;;
    
    "status")
        if grep -q '"CLAUDE_MEMORY_SEARCH_AUTO": "true"' "$SETTINGS_FILE"; then
            echo "🧠 Memory search: ENABLED (automatic)"
        else
            echo "🚫 Memory search: DISABLED (manual only)"
        fi
        ;;
    
    "search")
        if [[ -n "$2" ]]; then
            echo "🔍 MANUAL MEMORY SEARCH: Use memory-search to search for: $2"
        else
            echo "❌ Usage: memory-search-manager.sh search \"your query\""
            exit 1
        fi
        ;;
    
    *)
        echo "🧠 Memory Search Manager"
        echo "Usage: $0 [enable|disable|status|search \"query\"]"
        echo ""
        echo "Commands:"
        echo "  enable   - Enable automatic memory search on all interactions"
        echo "  disable  - Disable automatic memory search (manual only)"
        echo "  status   - Show current memory search status"
        echo "  search   - Trigger manual memory search with specific query"
        exit 1
        ;;
esac