#!/usr/bin/env bash

# Test suite for the batch formatter
# Tests format consistency, batch operations, and error handling

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test directory
TEST_DIR="test-configs"
FORMATTER="./format"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test functions
test_start() {
    local test_name="$1"
    echo -e "${YELLOW}Running test: ${test_name}${NC}"
    ((TESTS_RUN++))
}

test_pass() {
    echo -e "${GREEN}✓ PASSED${NC}"
    ((TESTS_PASSED++))
}

test_fail() {
    local reason="$1"
    echo -e "${RED}✗ FAILED: ${reason}${NC}"
    ((TESTS_FAILED++))
}

# Test 1: Format consistency
test_format_consistency() {
    test_start "Format consistency"
    
    # Create a temp file with bad formatting
    local temp_file="$TEST_DIR/temp_consistency.js"
    cat > "$temp_file" <<'EOF'
const   x=1;const   y=2;
function test(a,b){return a+b}
EOF
    
    # Format twice and check if output is identical
    "$FORMATTER" "$temp_file" >/dev/null 2>&1
    local content1=$(cat "$temp_file")
    
    "$FORMATTER" "$temp_file" >/dev/null 2>&1
    local content2=$(cat "$temp_file")
    
    if [[ "$content1" == "$content2" ]]; then
        test_pass
    else
        test_fail "Formatting is not idempotent"
    fi
    
    rm -f "$temp_file"
}

# Test 2: Batch operation
test_batch_operation() {
    test_start "Batch operation"
    
    # Create multiple test files
    local files=()
    for i in {1..3}; do
        local file="$TEST_DIR/batch_test_$i.js"
        echo "const x$i = $i;" > "$file"
        files+=("$file")
    done
    
    # Format all at once
    if "$FORMATTER" "${files[@]}" >/dev/null 2>&1; then
        test_pass
    else
        test_fail "Batch formatting failed"
    fi
    
    # Cleanup
    rm -f "${files[@]}"
}

# Test 3: Check mode
test_check_mode() {
    test_start "Check mode"
    
    # Create an unformatted file
    local temp_file="$TEST_DIR/temp_check.js"
    echo "const   x=1;" > "$temp_file"
    
    # Check should fail for unformatted file
    if "$FORMATTER" --check "$temp_file" >/dev/null 2>&1; then
        test_fail "Check mode should fail for unformatted file"
    else
        # Format the file
        "$FORMATTER" "$temp_file" >/dev/null 2>&1
        
        # Now check should pass
        if "$FORMATTER" --check "$temp_file" >/dev/null 2>&1; then
            test_pass
        else
            test_fail "Check mode should pass for formatted file"
        fi
    fi
    
    rm -f "$temp_file"
}

# Test 4: Import organization
test_import_organization() {
    test_start "Import organization"
    
    local temp_file="$TEST_DIR/temp_imports.ts"
    cat > "$temp_file" <<'EOF'
import { z } from 'zod';
import { Component } from '@angular/core';
import { myFunc } from '@/utils';
import React from 'react';
EOF
    
    "$FORMATTER" "$temp_file" >/dev/null 2>&1
    
    # Check if imports are reordered (React should be first based on config)
    if grep -q "^import React" "$temp_file" && grep -A1 "^import React" "$temp_file" | grep -q "import { Component }"; then
        test_pass
    else
        test_fail "Imports were not properly organized"
    fi
    
    rm -f "$temp_file"
}

# Test 5: Error handling
test_error_handling() {
    test_start "Error handling"
    
    # Try to format a non-existent file
    if "$FORMATTER" "non_existent_file.js" >/dev/null 2>&1; then
        test_fail "Should fail for non-existent file"
    else
        test_pass
    fi
}

# Test 6: Dry run mode
test_dry_run() {
    test_start "Dry run mode"
    
    local temp_file="$TEST_DIR/temp_dry_run.js"
    echo "const   x=1;" > "$temp_file"
    local original_content=$(cat "$temp_file")
    
    # Run in dry-run mode
    "$FORMATTER" --dry-run "$temp_file" >/dev/null 2>&1
    
    # Content should not change
    local new_content=$(cat "$temp_file")
    if [[ "$original_content" == "$new_content" ]]; then
        test_pass
    else
        test_fail "Dry run mode modified the file"
    fi
    
    rm -f "$temp_file"
}

# Test 7: Multiple file types
test_multiple_file_types() {
    test_start "Multiple file types"
    
    # Create files of different types
    echo "const x = 1;" > "$TEST_DIR/test.js"
    echo '{"key": "value"}' > "$TEST_DIR/test.json"
    echo "local x = 1" > "$TEST_DIR/test.lua"
    
    # Format all
    if "$FORMATTER" "$TEST_DIR/test.js" "$TEST_DIR/test.json" "$TEST_DIR/test.lua" >/dev/null 2>&1; then
        test_pass
    else
        test_fail "Failed to format multiple file types"
    fi
    
    rm -f "$TEST_DIR/test.js" "$TEST_DIR/test.json" "$TEST_DIR/test.lua"
}

# Test 8: Glob pattern support
test_glob_patterns() {
    test_start "Glob pattern support"
    
    # Create test files
    for i in {1..3}; do
        echo "const x$i = $i;" > "$TEST_DIR/glob_test_$i.js"
    done
    
    # Test directory formatting
    local file_count=$(find "$TEST_DIR" -name "glob_test_*.js" | wc -l)
    if [[ $file_count -eq 3 ]]; then
        if "$FORMATTER" "$TEST_DIR" >/dev/null 2>&1; then
            test_pass
        else
            test_fail "Directory formatting failed"
        fi
    else
        test_fail "Failed to create test files"
    fi
    
    rm -f "$TEST_DIR"/glob_test_*.js
}

# Main test runner
main() {
    echo "=== Running formatter test suite ==="
    echo
    
    # Ensure test directory exists
    mkdir -p "$TEST_DIR"
    
    # Run all tests
    test_format_consistency
    test_batch_operation
    test_check_mode
    test_import_organization
    test_error_handling
    test_dry_run
    test_multiple_file_types
    test_glob_patterns
    
    echo
    echo "=== Test Summary ==="
    echo -e "Tests run: $TESTS_RUN"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        exit 1
    fi
}

# Run tests
main "$@"