#!/bin/bash

# Local CI test script to validate workflow steps
# Run this to test the CI pipeline locally before pushing

set -e

echo "🧪 Running local CI tests..."

# Check if we're in the right directory
if [ ! -f "init.lua" ]; then
    echo "❌ Error: Please run this script from the Neovim config root directory"
    exit 1
fi

echo "📁 Current directory: $(pwd)"

# Test 1: Lua formatting check
echo "🎨 Checking Lua formatting..."
if command -v stylua &> /dev/null; then
    stylua --check lua/ && echo "✅ Lua formatting check passed" || echo "❌ Lua formatting check failed"
else
    echo "⚠️  stylua not found, skipping Lua formatting check"
fi

# Test 2: JS/TS formatting check
echo "🎨 Checking JS/TS formatting..."
if command -v biome &> /dev/null; then
    if find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | grep -q .; then
        biome check . && echo "✅ JS/TS formatting check passed" || echo "❌ JS/TS formatting check failed"
    else
        echo "ℹ️  No JS/TS files found, skipping biome check"
    fi
else
    echo "⚠️  biome not found, skipping JS/TS formatting check"
fi

# Test 3: Neovim configuration loading
echo "🚀 Testing Neovim configuration loading..."
if nvim --headless -c "lua print('✅ Neovim config loaded successfully')" -c "qa"; then
    echo "✅ Configuration loading test passed"
else
    echo "❌ Configuration loading test failed"
    exit 1
fi

# Test 4: Keymap conflict tests
echo "⌨️  Running keymap conflict tests..."
if [ -f "lua/config/test-utils/test_keymaps.lua" ]; then
    if nvim --headless -c "lua require('config.test-utils.test_keymaps')" -c "qa"; then
        echo "✅ Keymap conflict tests passed"
    else
        echo "❌ Keymap conflict tests failed"
    fi
else
    echo "⚠️  Keymap tests not found, skipping"
fi

# Test 5: Picker extensions tests
echo "🔍 Running picker extensions tests..."
if [ -f "lua/utils/tests/test_picker_extensions.lua" ]; then
    if nvim --headless -c "lua require('utils.tests.test_picker_extensions').run_all_tests()" -c "qa"; then
        echo "✅ Picker extensions tests passed"
    else
        echo "❌ Picker extensions tests failed"
    fi
else
    echo "⚠️  Picker extensions tests not found, skipping"
fi

# Test 6: Git branch functionality tests
echo "🌿 Running git branch tests..."
if [ -f "lua/plugins/tests/test_snacks_git_branches.lua" ]; then
    if nvim --headless -c "lua require('plugins.tests.test_snacks_git_branches').run_all_tests()" -c "qa"; then
        echo "✅ Git branch tests passed"
    else
        echo "❌ Git branch tests failed"
    fi
else
    echo "⚠️  Git branch tests not found, skipping"
fi

# Test 7: Health check
echo "🏥 Running Neovim health check..."
if nvim --headless -c "checkhealth" -c "qa" 2>/dev/null; then
    echo "✅ Health check completed"
else
    echo "⚠️  Health check completed with warnings (this is often normal)"
fi

# Test 8: Plugin validation
echo "🔌 Validating plugin configurations..."
if nvim --headless -c "lua local lazy = require('lazy'); print('Loaded plugins:', #lazy.plugins()); for name, plugin in pairs(lazy.plugins()) do if plugin.name then print('  -', plugin.name) end end" -c "qa"; then
    echo "✅ Plugin validation passed"
else
    echo "❌ Plugin validation failed"
fi

echo ""
echo "🎉 Local CI tests completed!"
echo "💡 If all tests passed, your changes should work in the GitHub workflow"
echo "📝 To run the full CI pipeline, create a pull request or push to master/main"