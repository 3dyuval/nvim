-- Universal test runner for utils/tests directory
-- Discovers and runs all test modules automatically

local M = {}

-- Test discovery configuration
local TEST_PATTERNS = {
	"test_*.lua", -- test_picker_extensions.lua
	"*_test.lua", -- actual_keymaps_test.lua
	"test*.lua", -- test_actual_keymaps.lua
}

local EXCLUDE_PATTERNS = {
	"run_all.lua", -- this file
	"%.md$", -- markdown files
	"%.sh$", -- shell scripts
}

-- Helper function to check if a file matches exclusion patterns
local function should_exclude(filename)
	for _, pattern in ipairs(EXCLUDE_PATTERNS) do
		if filename:match(pattern) then
			return true
		end
	end
	return false
end

-- Helper function to check if a file matches test patterns
local function is_test_file(filename)
	for _, pattern in ipairs(TEST_PATTERNS) do
		local lua_pattern = pattern:gsub("%*", ".*")
		if filename:match("^" .. lua_pattern .. "$") then
			return true
		end
	end
	return false
end

-- Discover test files in a directory
local function discover_tests(dir_path, module_prefix)
	local tests = {}
	local full_path = vim.fn.expand(dir_path)

	if vim.fn.isdirectory(full_path) == 0 then
		return tests
	end

	local files = vim.fn.readdir(full_path)

	for _, item in ipairs(files) do
		local item_path = full_path .. "/" .. item

		if vim.fn.isdirectory(item_path) == 1 then
			-- Recursively discover tests in subdirectories
			local subdir_prefix = module_prefix .. "." .. item
			local subdir_tests = discover_tests(item_path, subdir_prefix)
			vim.list_extend(tests, subdir_tests)
		elseif item:match("%.lua$") and is_test_file(item) and not should_exclude(item) then
			-- It's a Lua test file
			local module_name = item:gsub("%.lua$", "")
			local full_module = module_prefix .. "." .. module_name

			table.insert(tests, {
				file = item,
				path = item_path,
				module = full_module,
				name = module_name,
			})
		end
	end

	return tests
end

-- Run a single test module
local function run_test_module(test_info)
	print("Running: " .. test_info.name)

	local success, test_module = pcall(require, test_info.module)
	if not success then
		print("  ✗ Failed to load module: " .. test_module)
		return false
	end

	-- Try different test runner function names
	local runner_functions = {
		"run_all_tests", -- most common
		"run_tests", -- alternative
		"run", -- simple
		"test", -- minimal
	}

	for _, func_name in ipairs(runner_functions) do
		if type(test_module[func_name]) == "function" then
			local run_success, err = pcall(test_module[func_name])
			if run_success then
				print("  ✓ Tests completed")
				return true
			else
				print("  ✗ Test execution failed: " .. (err or "unknown error"))
				return false
			end
		end
	end

	-- If no runner function found, check if it's a direct function module
	if type(test_module) == "function" then
		local run_success, err = pcall(test_module)
		if run_success then
			print("  ✓ Tests completed")
			return true
		else
			print("  ✗ Test execution failed: " .. (err or "unknown error"))
			return false
		end
	end

	print("  ⚠ No test runner function found (tried: " .. table.concat(runner_functions, ", ") .. ")")
	return false
end

-- Main test runner function
function M.run_all_tests()
	print("=== Utils Tests Runner ===")

	local base_dir = vim.fn.expand("~/.config/nvim/lua/utils/tests")
	local tests = discover_tests(base_dir, "utils.tests")

	if #tests == 0 then
		print("No test files found in " .. base_dir)
		return false
	end

	print("Discovered " .. #tests .. " test modules:")
	for _, test in ipairs(tests) do
		print("  - " .. test.name .. " (" .. test.file .. ")")
	end
	print("")

	local passed = 0
	local failed = 0

	for _, test in ipairs(tests) do
		if run_test_module(test) then
			passed = passed + 1
		else
			failed = failed + 1
		end
		print("") -- separator between tests
	end

	print("=== Test Summary ===")
	print("Total: " .. #tests)
	print("Passed: " .. passed)
	print("Failed: " .. failed)

	if failed == 0 then
		print("✅ All utils tests passed!")
		return true
	else
		print("❌ Some utils tests failed")
		return false
	end
end

-- Convenience function for running from command line
function M.run()
	return M.run_all_tests()
end

return M

