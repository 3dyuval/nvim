# Neovim Configuration Makefile

.PHONY: lint no-utils test format install-deps help compile compile-force

# Default target
help:
	@echo "Available targets:"
	@echo "  lint                  - Run luacheck linter on Lua files"
	@echo "  no-utils              - Check for errant util calls"
	@echo "  test                  - Run all tests"
	@echo "  compile               - Compile all Fennel files using nfnl"
	@echo "  compile-force         - Force recompile all Fennel files (removes old .lua files)"
	@echo "  format                - Format code using luafmt"
	@echo "  install-deps          - Install development dependencies"
	@echo "  help                  - Show this help message"

# Run luacheck on all Lua files
lint:
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

# Run all tests (includes linting)
test: lint no-utils
	@echo "Running all tests..."
	@echo "=== Plenary Tests ==="
	@nvim --headless -c "PlenaryBustedFile lua/config/tests/keymaps.test.lua" -c "qa"
	@echo "All tests completed"

# Format code using luafmt
format:
	@echo "Formatting Lua code..."
	@if command -v luafmt >/dev/null 2>&1; then \
		find lua -name "*.lua" -exec luafmt -w replace {} \;; \
		echo "Code formatted"; \
	else \
		echo "ERROR: luafmt not found. Install with: bun install -g luafmt"; \
	fi

# Install development dependencies
install-deps:
	@echo "Installing development dependencies..."
	@echo "Installing luacheck..."
	@sudo apt-get update && sudo apt-get install -y lua-check
	@echo "Installing luafmt..."
	@if ! command -v luafmt >/dev/null 2>&1; then \
		if command -v bun >/dev/null 2>&1; then \
			bun install -g luafmt; \
		else \
			echo "Please install bun first, then run: bun install -g luafmt"; \
		fi \
	fi
	@echo "Dependencies installed"

# Compile Fennel files using nfnl
compile:
	@echo "Compiling Fennel files..."
	@./fnl/compile

# Force recompile all Fennel files (removes old .lua files first)
compile-force:
	@echo "Force recompiling Fennel files..."
	@./fnl/compile --force