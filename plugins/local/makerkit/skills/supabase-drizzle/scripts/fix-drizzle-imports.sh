#!/bin/bash
# fix-drizzle-imports.sh
# Automatically fixes Drizzle schema.ts and relations.ts after drizzle:pull
#
# Usage: ./fix-drizzle-imports.sh [path-to-packages-supabase]
#
# This script:
# 1. Adds /* eslint-disable */ to top of schema.ts
# 2. Adds usersInAuth import to schema.ts
# 3. Fixes usersInAuth import in relations.ts
#
# Cross-platform compatible (macOS and Linux)

set -e

# Default path (can be overridden by argument)
DRIZZLE_DIR="${1:-packages/supabase/src/drizzle}"

SCHEMA_FILE="$DRIZZLE_DIR/schema.ts"
RELATIONS_FILE="$DRIZZLE_DIR/relations.ts"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Fixing Drizzle imports..."
echo "Directory: $DRIZZLE_DIR"

# Check files exist
if [ ! -f "$SCHEMA_FILE" ]; then
    echo -e "${RED}Error: $SCHEMA_FILE not found${NC}"
    exit 1
fi

if [ ! -f "$RELATIONS_FILE" ]; then
    echo -e "${RED}Error: $RELATIONS_FILE not found${NC}"
    exit 1
fi

# Cross-platform sed -i
sedi() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

# Fix schema.ts
echo -e "${YELLOW}Fixing $SCHEMA_FILE...${NC}"

# Check if eslint-disable already exists
if ! grep -q "eslint-disable" "$SCHEMA_FILE"; then
    # Add eslint-disable at the top (cross-platform)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo '/* eslint-disable */' | cat - "$SCHEMA_FILE" > temp_schema && mv temp_schema "$SCHEMA_FILE"
    else
        sed -i '1i/* eslint-disable */' "$SCHEMA_FILE"
    fi
    echo -e "${GREEN}  Added /* eslint-disable */${NC}"
else
    echo "  /* eslint-disable */ already present"
fi

# Check if usersInAuth import already exists
if ! grep -q "usersInAuth as users" "$SCHEMA_FILE"; then
    # Find the line after the last drizzle import and add our import
    awk '
    /from .drizzle-orm\/pg-core.;/ {
        print
        print "import { usersInAuth as users } from '\''./auth.users'\'';"
        next
    }
    { print }
    ' "$SCHEMA_FILE" > temp_schema && mv temp_schema "$SCHEMA_FILE"
    echo -e "${GREEN}  Added usersInAuth import${NC}"
else
    echo "  usersInAuth import already present"
fi

# Fix relations.ts
echo -e "${YELLOW}Fixing $RELATIONS_FILE...${NC}"

# Remove usersInAuth from schema import if present
if grep -q "usersInAuth" "$RELATIONS_FILE"; then
    # Check if it's imported from ./schema (wrong) vs ./auth.users (correct)
    if grep -E "usersInAuth.*from.*['\"]\.\/schema['\"]" "$RELATIONS_FILE" > /dev/null 2>&1 || grep -q "usersInAuth," "$RELATIONS_FILE"; then
        # Remove usersInAuth from the schema import (cross-platform)
        sedi 's/usersInAuth,//g' "$RELATIONS_FILE"
        sedi 's/, usersInAuth//g' "$RELATIONS_FILE"
        sedi 's/usersInAuth //g' "$RELATIONS_FILE"
        echo -e "${GREEN}  Removed usersInAuth from schema import${NC}"
    fi
fi

# Add correct usersInAuth import if not present
if ! grep -q "from './auth.users'" "$RELATIONS_FILE"; then
    # Add import after the schema import
    awk '
    /from .\.\/schema.;/ {
        print
        print "import { usersInAuth } from '\''./auth.users'\'';"
        next
    }
    { print }
    ' "$RELATIONS_FILE" > temp_relations && mv temp_relations "$RELATIONS_FILE"
    echo -e "${GREEN}  Added usersInAuth import from auth.users${NC}"
else
    echo "  usersInAuth import from auth.users already present"
fi

echo -e "${GREEN}Done! Run 'pnpm typecheck' to verify.${NC}"
