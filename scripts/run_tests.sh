#!/bin/bash
set -e

# Simple test runner inspired by conform.nvim
# Creates isolated environment and runs tests with Plenary

echo "🧪 Running Neovim configuration tests..."

# Test 1: Basic config loading
echo "=== Testing configuration loading ==="
nvim --headless -c "lua print('✅ Neovim config loaded successfully')" -c "qa"

# Test 2: Run tests with Plenary if available
if command -v nvim >/dev/null 2>&1; then
  echo "=== Running Plenary-based tests ==="
  
  # Check if we have any plenary-based tests
  if [ -d "lua/utils/tests" ]; then
    nvim --headless \
      -c "lua package.path = package.path .. ';./lua/?.lua'" \
      -c "lua if pcall(require, 'plenary.test_harness') then require('plenary.test_harness').test_directory('./lua/utils/tests', {minimal_init = './tests/minimal_init.lua'}) else print('⚠️ Plenary not available, running basic tests...'); require('utils.tests.run_all').run_all_tests() end" \
      -c "qa"
  else
    echo "⚠️ No test directory found"
  fi
  
  # Test 3: Script-specific tests
  echo "=== Running script tests ==="
  if [ -d "lua/scripts/tests" ]; then
    for test_file in lua/scripts/tests/*.lua; do
      if [ -f "$test_file" ]; then
        echo "Running $(basename "$test_file")"
        nvim --headless \
          -c "lua require('$(echo "$test_file" | sed 's|lua/||' | sed 's|\.lua||' | sed 's|/|\.|g')').run_all_tests()" \
          -c "qa"
      fi
    done
  fi
else
  echo "❌ Neovim not found"
  exit 1
fi

echo "✅ All tests completed"