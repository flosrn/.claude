#!/bin/bash

# 🧪 Claude Code - Test Performance Hooks
# Script de validation des optimisations

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_header() {
    echo -e "${PURPLE}🧪 [Performance Test]${NC} $1"
}

log_info() {
    echo -e "${BLUE}ℹ️  [Performance Test]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ [Performance Test]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️  [Performance Test]${NC} $1"
}

log_error() {
    echo -e "${RED}❌ [Performance Test]${NC} $1"
}

# Test la vitesse du script optimisé
test_script_speed() {
    log_header "Test de vitesse des scripts"
    
    # Créer fichier test temporaire
    local test_file="/tmp/test-claude-file.ts"
    cat > "$test_file" << 'EOF'
interface User {
    id: number;
    name: string;
    email: string;
}

export const getUser = (id: number): User | null => {
    // Test function
    return null;
};
EOF
    
    # Test script optimisé
    log_info "Test script optimisé..."
    export CLAUDE_FILE_PATHS="$test_file"
    
    local start_time=$(date +%s)
    bash /Users/flo/.claude/scripts/detect-and-lint-optimized.sh &>/dev/null || true
    local end_time=$(date +%s)
    local optimized_duration=$((end_time - start_time))
    
    # Test script original (si existe)
    local original_duration="N/A"
    if [[ -f "/Users/flo/.claude/scripts/detect-and-lint.sh" ]]; then
        log_info "Test script original..."
        start_time=$(date +%s)
        timeout 10s bash /Users/flo/.claude/scripts/detect-and-lint.sh &>/dev/null || true
        end_time=$(date +%s)
        original_duration=$((end_time - start_time))
    fi
    
    # Résultats
    log_success "Script optimisé: ${optimized_duration}s"
    if [[ "$original_duration" != "N/A" && "$original_duration" != "0" ]]; then
        log_info "Script original: ${original_duration}s"
        if [[ $original_duration -gt 0 ]]; then
            local improvement=$(( (original_duration - optimized_duration) * 100 / original_duration ))
            log_success "Amélioration: ${improvement}%"
        fi
    elif [[ "$original_duration" = "0" ]]; then
        log_info "Script original: très rapide ou timeout"
    fi
    
    # Nettoyage
    rm -f "$test_file"
}

# Test cache et throttling
test_cache_throttling() {
    log_header "Test cache et throttling"
    
    local test_file="/tmp/test-claude-cache.js"
    echo 'console.log("test");' > "$test_file"
    export CLAUDE_FILE_PATHS="$test_file"
    
    # Premier appel
    log_info "Premier appel (pas de cache)..."
    local start1=$(date +%s)
    bash /Users/flo/.claude/scripts/detect-and-lint-optimized.sh &>/dev/null || true
    local end1=$(date +%s)
    local duration1=$((end1 - start1))
    
    # Deuxième appel immédiat (throttled)
    log_info "Deuxième appel immédiat (throttling)..."
    local start2=$(date +%s)
    bash /Users/flo/.claude/scripts/detect-and-lint-optimized.sh &>/dev/null || true
    local end2=$(date +%s)
    local duration2=$((end2 - start2))
    
    # Attente et troisième appel (avec cache)
    sleep 4
    log_info "Troisième appel après attente (avec cache)..."
    local start3=$(date +%s)
    bash /Users/flo/.claude/scripts/detect-and-lint-optimized.sh &>/dev/null || true
    local end3=$(date +%s)
    local duration3=$((end3 - start3))
    
    log_success "Premier appel: ${duration1}s"
    log_success "Throttled: ${duration2}s (devrait être <1s)"
    log_success "Avec cache: ${duration3}s"
    
    # Validation
    if [[ $duration2 -lt 1 ]]; then
        log_success "✅ Throttling fonctionne"
    else
        log_warning "⚠️  Throttling pourrait être amélioré"
    fi
    
    rm -f "$test_file"
}

# Test filtrage par extension
test_file_filtering() {
    log_header "Test filtrage par extension"
    
    # Créer fichiers test
    local ts_file="/tmp/test.ts"
    local txt_file="/tmp/test.txt"
    local log_file="/tmp/test.log"
    
    echo 'const x: number = 1;' > "$ts_file"
    echo 'Plain text file' > "$txt_file"
    echo 'Log entry' > "$log_file"
    
    # Test avec fichier TypeScript (devrait être traité)
    export CLAUDE_FILE_PATHS="$ts_file"
    log_info "Test fichier .ts (devrait être traité)..."
    if bash /Users/flo/.claude/scripts/detect-and-lint-optimized.sh 2>&1 | grep -q "Processing\|📄"; then
        log_success "✅ Fichier .ts traité"
    else
        log_warning "⚠️  Fichier .ts non traité"
    fi
    
    # Test avec fichier log (devrait être ignoré via script intelligent)
    export CLAUDE_FILE_PATHS="$log_file"
    log_info "Test fichier .log (devrait être rapide/ignoré)..."
    local start=$(date +%s)
    bash /Users/flo/.claude/scripts/detect-and-lint-optimized.sh &>/dev/null || true
    local end=$(date +%s)
    local log_duration=$((end - start))
    
    if [[ $log_duration -lt 2 ]]; then
        log_success "✅ Fichier .log traité rapidement: ${log_duration}s"
    else
        log_warning "⚠️  Fichier .log trop lent: ${log_duration}s"
    fi
    
    # Nettoyage
    rm -f "$ts_file" "$txt_file" "$log_file"
}

# Test usage CPU avec monitoring
test_cpu_usage() {
    log_header "Test usage CPU (simulation)"
    
    # Créer plusieurs fichiers test
    local test_files=()
    for i in {1..5}; do
        local file="/tmp/test-cpu-$i.ts"
        cat > "$file" << EOF
interface TestInterface$i {
    id: number;
    value: string;
}
EOF
        test_files+=("$file")
    done
    
    # Exporter tous les fichiers
    export CLAUDE_FILE_PATHS=$(IFS=$'\n'; echo "${test_files[*]}")
    
    log_info "Traitement de 5 fichiers TypeScript..."
    
    # Monitoring CPU pendant traitement
    local start=$(date +%s)
    bash /Users/flo/.claude/scripts/detect-and-lint-optimized.sh &>/dev/null || true
    local end=$(date +%s)
    local total_duration=$((end - start))
    
    log_success "Traitement 5 fichiers: ${total_duration}s"
    
    if [[ $total_duration -lt 5 ]]; then
        log_success "✅ Performance excellente"
    elif [[ $total_duration -lt 10 ]]; then
        log_success "✅ Performance bonne"
    else
        log_warning "⚠️  Performance à améliorer"
    fi
    
    # Nettoyage
    rm -f "${test_files[@]}"
}

# Validation configuration
test_config_validation() {
    log_header "Test validation configuration"
    
    # Vérifier que les timeouts sont configurés
    if grep -q '"timeout"' /Users/flo/.claude/settings.json; then
        log_success "✅ Timeouts configurés"
    else
        log_warning "⚠️  Timeouts manquants"
    fi
    
    # Vérifier mode développement
    if grep -q '"CLAUDE_MODE": "development"' /Users/flo/.claude/settings.json; then
        log_success "✅ Mode développement activé"
    else
        log_info "Mode production détecté"
    fi
    
    # Vérifier background execution
    if grep -q '"background": true' /Users/flo/.claude/settings.json; then
        log_success "✅ Exécution background configurée"
    else
        log_warning "⚠️  Pas d'exécution background"
    fi
}

# Fonction principale
main() {
    log_header "🚀 Claude Code - Test Performance Complet"
    echo
    
    test_config_validation
    echo
    
    test_script_speed
    echo
    
    test_cache_throttling
    echo
    
    test_file_filtering
    echo
    
    test_cpu_usage
    echo
    
    log_header "🎉 Tests de performance terminés!"
    log_info "Vérifiez Activity Monitor pour confirmer la réduction CPU de Ghostty"
}

main "$@"