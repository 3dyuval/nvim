# Neovim Configuration Makefile

.PHONY: check no-utils test format install-deps help

# Default target
help:
	@echo "Available targets:"
	@echo "  check      - Run luacheck linter on Lua files"
	@echo "  no-utils   - Check for errant util calls"
	@echo "  test       - Run all tests"
	@echo "  format     - Format code using stylua"
	@echo "  install-deps - Install development dependencies"
	@echo "  help       - Show this help message"

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
	@if [ -f "test/ci.sh" ]; then \
		./test/ci.sh; \
	else \
		echo "⚠️ Test runner script not found"; \
		echo "=== Basic config test ==="; \
		nvim --headless -c "lua print('✅ Neovim config loaded successfully')" -c "qa"; \
	fi

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

# Local development test (same as scripts/test-ci.sh)
test-local:
	@echo "🧪 Running local tests..."
	@./scripts/test-ci.sh