#!/bin/bash
# detect-project.sh
# Detects which Makerkit project the current directory belongs to
#
# Usage: ./detect-project.sh [directory]
# Returns: gapila, lasdelaroute, or unknown

set -e

DIR="${1:-$(pwd)}"

GAPILA_PATH="/Users/flo/Code/nextjs/gapila"
LASDELAROUTE_PATH="/Users/flo/Code/nextjs/lasdelaroute"

# Check if directory is under gapila
if [[ "$DIR" == "$GAPILA_PATH"* ]]; then
    echo "gapila"
    exit 0
fi

# Check if directory is under lasdelaroute
if [[ "$DIR" == "$LASDELAROUTE_PATH"* ]]; then
    echo "lasdelaroute"
    exit 0
fi

echo "unknown"
exit 0
