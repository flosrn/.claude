#!/bin/bash
# Test suite for fix-drizzle-imports.sh
#
# Usage: ./test_fix_drizzle_imports.sh
#
# Runs tests to verify the Drizzle import fixer works correctly

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIX_SCRIPT="$SCRIPT_DIR/../fix-drizzle-imports.sh"
TEST_DIR=$(mktemp -d)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

assert_contains() {
    local file="$1"
    local pattern="$2"
    local message="$3"

    if grep -q "$pattern" "$file"; then
        echo -e "${GREEN}✓ $message${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ $message${NC}"
        echo "  Expected pattern: $pattern"
        echo "  File contents:"
        head -20 "$file"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_not_contains() {
    local file="$1"
    local pattern="$2"
    local message="$3"

    if ! grep -q "$pattern" "$file"; then
        echo -e "${GREEN}✓ $message${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ $message${NC}"
        echo "  Did not expect pattern: $pattern"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 1: Adds eslint-disable to schema.ts
test_adds_eslint_disable() {
    echo "Test 1: Adds eslint-disable to schema.ts"
    local test_path="$TEST_DIR/test1"
    mkdir -p "$test_path"

    # Create mock schema.ts without eslint-disable
    cat > "$test_path/schema.ts" << 'EOF'
import { pgTable, text, uuid } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: uuid('id').primaryKey(),
});
EOF

    # Create mock relations.ts
    cat > "$test_path/relations.ts" << 'EOF'
import { users } from './schema';
export const usersRelations = {};
EOF

    # Run the script
    bash "$FIX_SCRIPT" "$test_path" > /dev/null 2>&1

    assert_contains "$test_path/schema.ts" "eslint-disable" "eslint-disable added to schema.ts"
}

# Test 2: Adds usersInAuth import to schema.ts
test_adds_users_import() {
    echo "Test 2: Adds usersInAuth import to schema.ts"
    local test_path="$TEST_DIR/test2"
    mkdir -p "$test_path"

    cat > "$test_path/schema.ts" << 'EOF'
import { pgTable, text, uuid } from 'drizzle-orm/pg-core';

export const profiles = pgTable('profiles', {
  id: uuid('id').primaryKey(),
});
EOF

    cat > "$test_path/relations.ts" << 'EOF'
import { profiles } from './schema';
export const profilesRelations = {};
EOF

    bash "$FIX_SCRIPT" "$test_path" > /dev/null 2>&1

    assert_contains "$test_path/schema.ts" "usersInAuth as users" "usersInAuth import added to schema.ts"
}

# Test 3: Adds usersInAuth to relations.ts
test_adds_relations_import() {
    echo "Test 3: Adds usersInAuth import to relations.ts"
    local test_path="$TEST_DIR/test3"
    mkdir -p "$test_path"

    cat > "$test_path/schema.ts" << 'EOF'
import { pgTable, uuid } from 'drizzle-orm/pg-core';
export const profiles = pgTable('profiles', { id: uuid('id') });
EOF

    cat > "$test_path/relations.ts" << 'EOF'
import { profiles } from './schema';
export const profilesRelations = {};
EOF

    bash "$FIX_SCRIPT" "$test_path" > /dev/null 2>&1

    assert_contains "$test_path/relations.ts" "from './auth.users'" "usersInAuth import added to relations.ts"
}

# Test 4: Idempotent - doesn't duplicate imports
test_idempotent() {
    echo "Test 4: Script is idempotent (doesn't duplicate)"
    local test_path="$TEST_DIR/test4"
    mkdir -p "$test_path"

    cat > "$test_path/schema.ts" << 'EOF'
/* eslint-disable */
import { pgTable, uuid } from 'drizzle-orm/pg-core';
import { usersInAuth as users } from './auth.users';
export const profiles = pgTable('profiles', { id: uuid('id') });
EOF

    cat > "$test_path/relations.ts" << 'EOF'
import { profiles } from './schema';
import { usersInAuth } from './auth.users';
export const profilesRelations = {};
EOF

    # Run twice
    bash "$FIX_SCRIPT" "$test_path" > /dev/null 2>&1
    bash "$FIX_SCRIPT" "$test_path" > /dev/null 2>&1

    # Count occurrences - should be exactly 1
    local count=$(grep -c "eslint-disable" "$test_path/schema.ts" || echo "0")
    if [ "$count" -eq 1 ]; then
        echo -e "${GREEN}✓ eslint-disable appears exactly once${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ eslint-disable appears $count times (expected 1)${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 5: Fails gracefully when files don't exist
test_missing_files() {
    echo "Test 5: Fails gracefully when files don't exist"
    local test_path="$TEST_DIR/test5"
    mkdir -p "$test_path"

    if bash "$FIX_SCRIPT" "$test_path" > /dev/null 2>&1; then
        echo -e "${RED}✗ Should have failed with missing files${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        echo -e "${GREEN}✓ Correctly fails when files are missing${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
}

# Run all tests
echo "========================================"
echo "Running fix-drizzle-imports.sh tests"
echo "========================================"
echo ""

test_adds_eslint_disable
echo ""
test_adds_users_import
echo ""
test_adds_relations_import
echo ""
test_idempotent
echo ""
test_missing_files

echo ""
echo "========================================"
echo -e "Results: ${GREEN}$TESTS_PASSED passed${NC}, ${RED}$TESTS_FAILED failed${NC}"
echo "========================================"

if [ "$TESTS_FAILED" -gt 0 ]; then
    exit 1
fi
