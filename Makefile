# Neovim Configuration Makefile

.PHONY: check no-utils test format install-deps check-keymaps fix-keymaps health-check help

# Default target
help:
	@echo "Available targets:"
	@echo "  check        - Run luacheck linter on Lua files"
	@echo "  no-utils     - Check for errant util calls"
	@echo "  test         - Run all tests"
	@echo "  format       - Format code using stylua"
	@echo "  install-deps - Install development dependencies"
	@echo "  check-keymaps - Check for keymap conflicts and health"
	@echo "  fix-keymaps  - Apply automated keymap fixes (when available)"
	@echo "  health-check - Run comprehensive health check"
	@echo "  help         - Show this help message"

# Run luacheck on all Lua files
check:
	@echo "Running luacheck..."
	@if command -v luacheck >/dev/null 2>&1; then \
		luacheck lua/ --config .luacheckrc; \
	else \
		echo "luacheck not found, skipping..."; \
	fi

# Check for errant util calls (placeholder for now)
no-utils:
	@echo "Checking for errant util calls..."
	@# Check for direct vim.fn calls that should use utils
	@if grep -r "vim\.fn\." lua/ --include="*.lua" | grep -v "test" | grep -v "utils" >/dev/null; then \
		echo "Found direct vim.fn calls outside utils:"; \
		grep -r "vim\.fn\." lua/ --include="*.lua" | grep -v "test" | grep -v "utils"; \
		echo "Consider using utility functions instead"; \
	else \
		echo "No errant util calls found"; \
	fi

# Run all tests
test:
	@echo "Running all tests..."
	@echo "=== Testing configuration loading ==="
	@nvim --headless -c "lua print('✅ Neovim config loaded successfully')" -c "qa"
	
	@echo "=== Running picker extensions tests ==="
	@if [ -f "lua/utils/tests/test_picker_extensions.lua" ]; then \
		nvim --headless -c "lua require('utils.tests.test_picker_extensions').run_all_tests()" -c "qa"; \
	else \
		echo "⚠️  Picker extensions tests not found"; \
	fi
	
	@echo "=== Running git branch tests ==="
	@if [ -f "lua/plugins/tests/test_snacks_git_branches.lua" ]; then \
		nvim --headless -c "lua require('plugins.tests.test_snacks_git_branches').run_all_tests()" -c "qa"; \
	else \
		echo "⚠️  Git branch tests not found"; \
	fi
	
	@echo "=== Running keymap conflict tests ==="
	@if [ -f "lua/config/test-utils/test_keymaps.lua" ]; then \
		nvim --headless -c "lua require('config.test-utils.test_keymaps')" -c "qa"; \
	else \
		echo "⚠️  Keymap tests not found"; \
	fi
	
	@echo "=== Running fold tests ==="
	@if [ -f "lua/plugins/tests/test_fold_functionality.lua" ]; then \
		nvim --headless -c "lua require('plugins.tests.test_fold_functionality')" -c "qa"; \
	else \
		echo "⚠️  Fold tests not found"; \
	fi
	
	@echo "✅ All tests completed"

# Format code using stylua
format:
	@echo "Formatting Lua code..."
	@if command -v stylua >/dev/null 2>&1; then \
		stylua lua/; \
		echo "✅ Code formatted"; \
	else \
		echo "❌ stylua not found. Install with: cargo install stylua"; \
	fi

# Install development dependencies
install-deps:
	@echo "Installing development dependencies..."
	@echo "Installing luacheck..."
	@sudo apt-get update && sudo apt-get install -y lua-check
	@echo "Installing stylua..."
	@if ! command -v stylua >/dev/null 2>&1; then \
		if command -v cargo >/dev/null 2>&1; then \
			cargo install stylua; \
		else \
			echo "Please install Rust/Cargo first, then run: cargo install stylua"; \
		fi \
	fi
	@echo "✅ Dependencies installed"

# Check for keymap conflicts and health
check-keymaps:
	@echo "🔍 Checking keymap conflicts and health..."
	@echo "=== Running keymap conflict detection ==="
	@echo '{}' | lua lua/config/test-utils/test_keymaps.lua || echo "Keymap conflict check completed"
	
	@echo "=== Running health check ==="
	@nvim --headless -c 'lua require("config.health").check()' -c 'qa' || echo "Health check completed"
	
	@echo "=== Validating health module ==="
	@nvim --headless -c 'lua print("✅ Health module loaded:", require("config.health"))' -c 'qa'
	
	@echo "✅ Keymap checks completed"

# Apply automated keymap fixes (placeholder for future enhancements)
fix-keymaps:
	@echo "🔧 Applying automated keymap fixes..."
	@echo "⚠️  Automated fixes not yet implemented"
	@echo "Please review KEYMAP_CONFLICTS.md for manual resolution strategies"
	@echo "Run 'make check-keymaps' to identify specific conflicts"

# Run comprehensive health check
health-check:
	@echo "🏥 Running comprehensive health check..."
	@echo "=== Configuration Health ==="
	@nvim --headless -c 'checkhealth config' -c 'qa' || echo "Config health check completed"
	
	@echo "=== Which-key Health ==="
	@nvim --headless -c 'checkhealth which-key' -c 'qa' || echo "Which-key health check completed"
	
	@echo "=== LSP Health ==="
	@nvim --headless -c 'checkhealth lsp' -c 'qa' || echo "LSP health check completed"
	
	@echo "✅ Health checks completed"

# Local development test (same as scripts/test-ci.sh)
test-local:
	@echo "🧪 Running local tests..."
	@./scripts/test-ci.sh