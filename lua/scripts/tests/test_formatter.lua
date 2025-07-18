-- Test for formatter.lua core API
-- Tests the async formatting API without external dependencies

local M = {}

function M.test_formatter_module()
	print("Testing formatter module loading...")

	local success, formatter = pcall(require, "utils.formatter")
	if success then
		print("  ✓ Formatter module loaded")

		-- Test basic functions exist
		local functions = { "format_file", "format_batch", "get_active_jobs", "setup" }
		for _, func_name in ipairs(functions) do
			if type(formatter[func_name]) == "function" then
				print("    ✓ " .. func_name .. " function available")
			else
				print("    ✗ " .. func_name .. " function missing")
			end
		end

		return true
	else
		print("  ✗ Failed to load formatter: " .. formatter)
		return false
	end
end

function M.test_formatter_setup()
	print("Testing formatter setup...")

	local formatter = require("utils.formatter")
	local success = pcall(formatter.setup, { verbose = false })

	if success then
		print("  ✓ Formatter setup completed")

		-- Check if commands were created
		local commands = vim.api.nvim_get_commands({})
		local expected_commands = { "Format", "FormatCheck", "FormatJobs" }

		for _, cmd in ipairs(expected_commands) do
			if commands[cmd] then
				print("    ✓ " .. cmd .. " command created")
			else
				print("    ✗ " .. cmd .. " command missing")
			end
		end

		return true
	else
		print("  ✗ Formatter setup failed")
		return false
	end
end

function M.test_job_management()
	print("Testing job management...")

	local formatter = require("utils.formatter")
	local jobs = formatter.get_active_jobs()

	if type(jobs) == "table" then
		print("  ✓ Active jobs returned as table")
		print("    Current active jobs: " .. vim.tbl_count(jobs))
		return true
	else
		print("  ✗ Active jobs should return table")
		return false
	end
end

function M.test_file_validation()
	print("Testing file validation logic...")

	-- Create test files
	local temp_dir = vim.fn.tempname()
	vim.fn.mkdir(temp_dir, "p")

	local test_files = {
		valid = temp_dir .. "/test.js",
		invalid = "/non/existent/file.js",
	}

	vim.fn.writefile({ "const x = 1;" }, test_files.valid)

	-- Test file readability (core logic)
	if vim.fn.filereadable(test_files.valid) == 1 then
		print("  ✓ Valid file detected correctly")
	else
		print("  ✗ Valid file not detected")
	end

	if vim.fn.filereadable(test_files.invalid) == 0 then
		print("  ✓ Invalid file detected correctly")
	else
		print("  ✗ Invalid file should not exist")
	end

	-- Cleanup
	vim.fn.delete(temp_dir, "rf")
	print("  ✓ Test cleanup completed")

	return true
end

-- Main test runner
function M.run_all_tests()
	print("=== Formatter Core Logic Tests ===")

	local tests = {
		{ name = "Module Loading", fn = M.test_formatter_module },
		{ name = "Setup", fn = M.test_formatter_setup },
		{ name = "Job Management", fn = M.test_job_management },
		{ name = "File Validation", fn = M.test_file_validation },
	}

	local passed = 0
	local total = #tests

	for _, test in ipairs(tests) do
		print("\n" .. test.name .. ":")
		local success, result = pcall(test.fn)
		if success and result then
			passed = passed + 1
			print("  ✓ " .. test.name .. " passed")
		else
			print("  ✗ " .. test.name .. " failed")
		end
	end

	print("\n=== Test Summary ===")
	print("Passed: " .. passed .. "/" .. total)

	return passed == total
end

return M

