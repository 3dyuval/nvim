#!/bin/bash
set -e

# Simple test runner inspired by conform.nvim
# Creates isolated environment and runs tests with Plenary
echo "🧪 Running Neovim configuration tests..."

# Test 1: Basic config loading

echo "=== Testing configuration loading ==="
nvim --headless -c "lua print('✅ Neovim config loaded successfully')" -c "qa"

# Test 2: Run tests with Plenary (if available)
if command -v nvim >/dev/null 2>&1; then
  echo "=== Running Plenary-based tests ==="

  # Check if we have any plenary based tests
  if [ -d "lua/utils/tests" ]; then
    nvim --headless \
      -c "lua package.path = package.path .. ';./lua/?.lua'" \
      -c "lua if pcall(require, 'plenary.test_harness') then require('plenary.test_harness').test_directory('./lua/utils/tests', {minimal_init = './test/minimal_init.lua'}) else print('⚠️ Plenary not available, running basic tests...'); require('utils.tests.run_all').run_all_tests() end" \
      -c "qa"
  else
    echo "⚠️ No lua/utils/tests directory found"
  fi

  # Run keymap-utils tests
  if [ -d "lua/keymap-utils/tests" ]; then
    echo "=== Running keymap-utils tests ==="
    nvim --headless \
      -c "PlenaryBustedFile lua/keymap-utils/tests/keymap_utils_spec.lua" \
      -c "qa"
  fi

  # Test 3: Additional test files in test directory
  echo "=== Running additional tests ==="
  if [ -d "test" ]; then
    for test_file in test/test_*.lua; do
      if [ -f "$test_file" ]; then
        echo "Running $(basename "$test_file")"
        nvim --headless \
          -c "lua package.path = package.path .. ';./test/?.lua'; dofile('$test_file')" \
          -c "qa"
      fi
    done
  fi
else
  echo "❌ Neovim not found!!! Aborting"
  exit 1
fi

echo "✅ All tests completed"

