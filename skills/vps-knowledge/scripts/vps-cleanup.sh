#!/bin/bash
# Nettoyage Docker (images, build cache) et affiche l'espace récupéré
set -euo pipefail

BEFORE=$(df / | tail -1 | awk '{print $3}')

echo "=== Nettoyage images Docker ==="
docker image prune -f

echo ""
echo "=== Nettoyage build cache ==="
docker builder prune -f

AFTER=$(df / | tail -1 | awk '{print $3}')
FREED_KB=$((BEFORE - AFTER))
FREED_MB=$((FREED_KB / 1024))

echo ""
echo "=== Résultat ==="
echo "Espace libéré: ~${FREED_MB} MB"
df -h / | tail -1
