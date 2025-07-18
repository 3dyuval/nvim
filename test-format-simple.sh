#!/usr/bin/env bash

# Simple test suite for the batch formatter
set -euo pipefail

echo "=== Testing batch formatter ==="

# Test 1: Basic functionality
echo "Test 1: Basic JavaScript formatting"
echo "const x=1;const y=2;" > test-configs/basic.js
./format test-configs/basic.js >/dev/null 2>&1
if grep -q "const x = 1;" test-configs/basic.js; then
    echo "✓ JavaScript formatting works"
else
    echo "✗ JavaScript formatting failed"
fi

# Test 2: Import organization
echo "Test 2: Import organization"
cat > test-configs/imports.ts <<'EOF'
import { z } from 'zod';
import { Component } from '@angular/core';
import { myFunc } from '@/utils';
import React from 'react';
EOF

./format test-configs/imports.ts >/dev/null 2>&1
if head -1 test-configs/imports.ts | grep -q "import React"; then
    echo "✓ Import organization works"
else
    echo "✗ Import organization failed"
fi

# Test 3: Lua formatting
echo "Test 3: Lua formatting"
echo "local x=1;local y=2" > test-configs/basic.lua
./format test-configs/basic.lua >/dev/null 2>&1
if grep -q "local x = 1" test-configs/basic.lua; then
    echo "✓ Lua formatting works"
else
    echo "✗ Lua formatting failed"
fi

# Test 4: Check mode
echo "Test 4: Check mode"
echo "const x=1;" > test-configs/check.js
if ./format --check test-configs/check.js >/dev/null 2>&1; then
    echo "✗ Check mode should fail for unformatted file"
else
    echo "✓ Check mode correctly identifies unformatted file"
fi

# Test 5: Dry run
echo "Test 5: Dry run mode"
echo "const x=1;" > test-configs/dryrun.js
original=$(cat test-configs/dryrun.js)
./format --dry-run test-configs/dryrun.js >/dev/null 2>&1
new=$(cat test-configs/dryrun.js)
if [[ "$original" == "$new" ]]; then
    echo "✓ Dry run mode doesn't modify files"
else
    echo "✗ Dry run mode modified file"
fi

# Cleanup
rm -f test-configs/basic.js test-configs/imports.ts test-configs/basic.lua test-configs/check.js test-configs/dryrun.js test-configs/simple.js

echo "=== Tests completed ==="