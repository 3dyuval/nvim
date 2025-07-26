#!/usr/bin/env lua

-- Neovim Runner for Kitty Remote Control
-- This script uses kitty's remote control to test Neovim functionality
--
-- PREREQUISITES:
-- 1. Kitty terminal with remote control enabled
-- 2. Add to kitty.conf: allow_remote_control yes
-- 3. Optional: remote_control_password your_password_here
-- 4. Neovim installed at /home/yuval/.local/bin/nvim
-- 5. The interactive test script at ~/.config/nvim/lua/config/tests/test_keymaps_interactive.lua
--
-- USAGE:
-- Basic keymap conflict testing:
--   lua neovim_runner_kitty.lua test-conflicts
--   lua neovim_runner_kitty.lua test-conflicts --keep-open
--
-- Test specific keymap:
--   lua neovim_runner_kitty.lua test-single n "<leader>ff" ":Telescope find_files<CR>" "Find files"
--
-- Run arbitrary Neovim command:
--   lua neovim_runner_kitty.lua run-command ":checkhealth"
--   lua neovim_runner_kitty.lua run-command ":TestLeaderCP"
--
-- Test with JSON output:
--   lua neovim_runner_kitty.lua test-output /tmp/results.json
--
-- KITTY CONFIGURATION ADDITIONS:
-- Add these lines to your kitty.conf:
--   # Enable remote control
--   allow_remote_control yes
--
--   # Optional: Set password for security
--   # remote_control_password your_password_here
--
--   # Optional: Listen on socket (if not using default)
--   # listen_on unix:/tmp/kitty
--
-- HOW IT WORKS:
-- 1. Launches Neovim in a new kitty pane with a test file (bypasses LazyVim dashboard)
-- 2. Loads the interactive test script via require()
-- 3. Executes keymap conflict tests and captures results
-- 4. Saves output to JSON and summary files
-- 5. Displays formatted results and optionally closes the pane
-- 6. Uses kitty's remote control protocol to send commands and text

-- Import kitty-mcp module
local kitty = require("kitty-mcp")

local M = {}

-- Launch Neovim in a new pane
local function launch_nvim_pane(title, test_file)
	title = title or "Neovim Test"
	test_file = test_file or "scripts/tmp/test_file.txt"

	-- Ensure scripts/tmp directory exists
	os.execute("mkdir -p scripts/tmp")

	-- Create test file if it doesn't exist
	local file = io.open(test_file, "w")
	if file then
		file:write(
			"# Neovim Test File\n\nThis is a test file for neovim runner.\nYou can edit this content for testing purposes.\n"
		)
		file:close()
	end

	-- Use nvim from PATH and launch in new pane
	local nvim_path = "nvim"
	local cmd = string.format('launch --type=window --title="%s" %s %s', title, nvim_path, test_file)
	print("Debug: Running command: " .. cmd)
	local result, success = kitty_command(cmd)
	print("Debug: Command result: " .. (result or "nil"))
	print("Debug: Command success: " .. tostring(success))
	return result, success, test_file
end

-- Wait for Neovim to fully load
local function wait_for_nvim(seconds)
	seconds = seconds or 3
	print(string.format("Waiting %d seconds for Neovim to load...", seconds))
	os.execute(string.format("sleep %d", seconds))
end

-- Test keymap conflicts in Neovim
function M.test_keymap_conflicts(keymaps, keep_open, output_file)
	local pane_title = "Keymap Conflict Test"
	output_file = output_file or "scripts/tmp/nvim_keymap_test_results.json"
	local test_file = "scripts/tmp/nvim_test_keymaps.txt"

	print("=== Testing Neovim Keymap Conflicts ===")

	-- Launch Neovim in new pane with test file
	print("Launching Neovim in new pane...")
	local window_id, success, created_file = kitty.launch_nvim_test(pane_title, test_file, true, false)
	if not success then
		print("Failed to launch neovim pane")
		return false
	end

	print(string.format("✅ Launched Neovim in window ID: %s", window_id))
	local window_match = string.format("id:%s", window_id)

	wait_for_nvim(4) -- Wait a bit longer for full load

	-- Load the interactive test script using require
	print("Loading keymap conflict test script...")
	kitty.send_nvim_require(window_match, "config.tests.test_keymaps_interactive", false)

	-- First, let's check if the mapping exists
	print("Checking existing <leader>cp mapping...")
	kitty.send_nvim_command(window_match, "nmap <leader>cp", false)
	os.execute("sleep 0.5")
	kitty.send_text(window_match, "") -- Press Enter
	os.execute("sleep 1")

	-- Write results to file for reading
	local test_cmd
	-- Write conflicts results to readable text file with proper syntax
	local text_report_file = "/tmp/vm_conflicts_report.txt"
	if keymaps then
		local keymaps_str = serialize_keymaps(keymaps)
		test_cmd = string.format(
			':lua local keymaps = %s local existing = require("config.tests.test_keymaps_interactive").capture_existing_keymaps() local conflicts = require("config.tests.test_keymaps_interactive").test_keymap_conflicts(keymaps, existing) local file = io.open("%s", "w") file:write("VM Keymaps Conflicts Analysis") file:write("\\n============================\\n\\n") file:write("Test Date: " .. os.date()) file:write("\\n\\nTested Keymaps:\\n") for i, km in ipairs(keymaps) do file:write("  " .. i .. ". " .. km.lhs .. " (" .. km.mode .. ") -> " .. (km.desc or km.rhs)) file:write("\\n") end file:write("\\nConflicts Found: " .. #conflicts) file:write("\\n\\n") if #conflicts > 0 then for i, conflict in ipairs(conflicts) do file:write("CONFLICT " .. i .. ":\\n") file:write("  Key: " .. conflict.key) file:write("\\n  Existing: " .. (conflict.existing_rhs or "unknown") .. " (" .. (conflict.existing_desc or "no description") .. ")") file:write("\\n  New: " .. (conflict.new_rhs or "unknown") .. " (" .. (conflict.new_desc or "no description") .. ")") file:write("\\n  Type: " .. (conflict.conflict_type or "unknown")) file:write("\\n  Severity: " .. (conflict.severity or "unknown")) file:write("\\n\\n") end else file:write("SUCCESS: No conflicts detected! Your VM keymaps are safe to use.") end file:close() print("VM conflicts report written to %s")',
			keymaps_str,
			text_report_file
		)
	else
		-- Test default <leader>cp
		print("Testing <leader>cp conflict...")
		test_cmd = string.format(
			':lua local keymaps = {{ mode = "n", lhs = "<leader>cp", rhs = "test", desc = "Test conflicting keymap" }} local existing = require("config.tests.test_keymaps_interactive").capture_existing_keymaps() local conflicts = require("config.tests.test_keymaps_interactive").test_keymap_conflicts(keymaps, existing) local file = io.open("%s", "w") file:write("Leader CP Conflict Test") file:write("\\n======================\\n\\n") file:write("Conflicts Found: " .. #conflicts) file:write("\\n\\n") if #conflicts > 0 then for i, conflict in ipairs(conflicts) do file:write("CONFLICT: " .. conflict.key .. " -> " .. (conflict.existing_desc or "unknown")) file:write("\\n") end else file:write("No conflicts found.") end file:close() print("Conflict report written to %s")',
			text_report_file
		)
	end

	kitty.send_text(window_match, test_cmd)
	os.execute("sleep 0.5")
	kitty.send_text(window_match, "") -- Press Enter
	os.execute("sleep 2") -- Wait for results to be written

	-- Open the results in a new buffer
	kitty.send_nvim_command(window_match, string.format("new %s", text_report_file), false)
	os.execute("sleep 1")
	os.execute("sleep 0.5")

	-- Read and display results
	local file = io.open(output_file, "r")
	if file then
		local content = file:read("*a")
		file:close()

		-- Parse JSON manually for display
		local ok, data = pcall(function()
			-- Simple JSON parsing for display
			return load("return " .. content:gsub("(%w+):", '["%1"]='))()
		end)

		if ok and type(data) == "table" then
			print("\n" .. string.rep("=", 60))
			print("KEYMAP CONFLICT TEST RESULTS")
			print(string.rep("=", 60))
			print("Test Date: " .. (data.timestamp or "unknown"))
			print("")

			if data.summary then
				print("SUMMARY:")
				print(string.format("  Total Conflicts: %d", data.summary.total_conflicts or 0))
				if data.summary.errors > 0 then
					print(string.format("  🚨 Errors: %d (Explicit keymap conflicts)", data.summary.errors))
				end
				if data.summary.warnings > 0 then
					print(string.format("  ⚠️  Warnings: %d (Important built-in overrides)", data.summary.warnings))
				end
				if data.summary.info > 0 then
					print(string.format("  ℹ️  Info: %d (Less critical overrides)", data.summary.info))
				end
			end

			if data.conflicts and #data.conflicts > 0 then
				print("\nCONFLICTS FOUND:")
				for i, conflict in ipairs(data.conflicts) do
					print(string.format("\n%d. Mode: %s, Key: %s [%s]", i, conflict.mode, conflict.key, conflict.severity))
					print(string.format("   Existing: %s - %s", conflict.existing_rhs, conflict.existing_desc))
					print(string.format("   New: %s - %s", conflict.new_rhs, conflict.new_desc))
				end
			else
				print("\n✅ NO CONFLICTS FOUND!")
			end

			print("\n" .. string.rep("=", 60))
		else
			-- Fallback: just print the JSON
			print("\nRaw results:")
			print(content)
		end

		-- Clean up
		os.remove(output_file)
	else
		print("\n❌ Could not read results. Check the Neovim tab for visual results.")
	end

	-- Close the pane unless keep_open is true
	if not keep_open then
		os.execute("sleep 1")
		print("\nClosing test pane...")
		kitty_command(string.format('close-window --match title:"%s"', pane_title))
	else
		print("\n✅ Test pane kept open. Check the '" .. pane_title .. "' pane for visual results.")
	end

	-- Save summary to additional output file
	local summary_file = output_file:gsub("%.json$", "_summary.txt")
	local summary_handle = io.open(summary_file, "w")
	if summary_handle then
		summary_handle:write("Neovim Keymap Test Results\n")
		summary_handle:write("==========================\n")
		summary_handle:write("Test File: " .. test_file .. "\n")
		summary_handle:write("Output File: " .. output_file .. "\n")
		summary_handle:write("Pane Title: " .. pane_title .. "\n")
		summary_handle:write("Keep Open: " .. tostring(keep_open) .. "\n")
		summary_handle:close()
		print("📄 Test summary written to: " .. summary_file)
	end

	return true, output_file, summary_file
end

-- Test a single keymap
function M.test_single_keymap(mode, lhs, rhs, desc, keep_open)
	local keymaps = { { mode = mode, lhs = lhs, rhs = rhs, desc = desc } }
	return M.test_keymap_conflicts(keymaps, keep_open)
end

-- Test with results written to file
function M.test_with_output(keymaps, output_file)
	output_file = output_file or "scripts/tmp/keymap_conflict_results.json"
	local pane_title = "Keymap Test Output"
	local test_file = "scripts/tmp/nvim_test_output.txt"

	print("=== Testing with JSON Output ===")

	-- Launch Neovim in pane
	local result, success, created_file = kitty.launch_nvim_test(pane_title, test_file, true, false)
	if not success then
		print("Failed to launch neovim pane")
		return nil
	end
	wait_for_nvim()

	-- Source the test script
	kitty.send_text(
		string.format("title:%s", pane_title),
		":source ~/.config/nvim/lua/config/tests/test_keymaps_interactive.lua"
	)
	os.execute("sleep 0.5")
	kitty.send_text(string.format("title:%s", pane_title), "")

	-- Run test and write results
	os.execute("sleep 0.5")
	local keymaps_str = keymaps and serialize_keymaps(keymaps) or "{}"
	local cmd = string.format(
		':lua require("config.tests.test_keymaps_interactive").write_results(%s, "%s")',
		keymaps_str,
		output_file
	)
	kitty.send_text(string.format("title:%s", pane_title), cmd)
	os.execute("sleep 0.5")
	kitty.send_text(string.format("title:%s", pane_title), "")

	-- Wait for file to be written
	os.execute("sleep 1")

	-- Try to read the results
	local file = io.open(output_file, "r")
	if file then
		local content = file:read("*a")
		file:close()
		print("\n📄 Results written to: " .. output_file)
		print("JSON Output:")
		print(content)
		return content
	else
		print("\n❌ Could not read results file: " .. output_file)
		return nil
	end
end

-- Simple keymap serializer (fallback if vim.inspect not available)
function serialize_keymaps(keymaps)
	local parts = {}
	table.insert(parts, "{")

	for i, km in ipairs(keymaps) do
		table.insert(parts, "{")
		table.insert(parts, string.format('mode="%s",', km.mode or "n"))
		table.insert(parts, string.format('lhs="%s",', km.lhs:gsub('"', '\\"')))
		table.insert(parts, string.format('rhs="%s",', km.rhs:gsub('"', '\\"')))
		if km.desc then
			table.insert(parts, string.format('desc="%s",', km.desc:gsub('"', '\\"')))
		end
		table.insert(parts, "}")
		if i < #keymaps then
			table.insert(parts, ",")
		end
	end

	table.insert(parts, "}")
	return table.concat(parts)
end

-- Run Neovim command
function M.run_nvim_command(command, pane_title, test_file)
	pane_title = pane_title or "Neovim Command"
	test_file = test_file or "scripts/tmp/nvim_command_test.txt"

	print(string.format("=== Running Neovim Command: %s ===", command))

	-- Launch Neovim in pane
	local result, success, created_file = kitty.launch_nvim_test(pane_title, test_file, true, false)
	if not success then
		print("Failed to launch neovim pane")
		return false
	end
	wait_for_nvim()

	-- Run the command
	kitty.send_text(string.format("title:%s", pane_title), command)
	os.execute("sleep 0.5")
	kitty.send_text(string.format("title:%s", pane_title), "")

	print("\n✅ Command executed in '" .. pane_title .. "' pane.")
	print("📁 Test file: " .. test_file)

	return true, test_file
end

-- Command line interface
local function main(args)
	local keep_open = false

	-- Check for --keep-open flag
	for i = #args, 1, -1 do
		if args[i] == "--keep-open" then
			keep_open = true
			table.remove(args, i)
			break
		end
	end

	if #args == 0 then
		print([[
Neovim Runner for Kitty - Test Neovim functionality via remote control

Usage: lua neovim_runner_kitty.lua [command] [options] [--keep-open]

Commands:
    test-conflicts              Test default <leader>cp conflict
    test-conflicts vm           Test VM (Visual Multi) keymaps conflicts
    test-single MODE LHS RHS    Test a single keymap
    test-output [FILE]          Test and write JSON results to file
    run-command "COMMAND"       Run arbitrary Neovim command

Options:
    --keep-open                 Keep the Neovim pane open after testing

Examples:
    lua neovim_runner_kitty.lua test-conflicts
    lua neovim_runner_kitty.lua test-single n "<leader>ff" ":Telescope find_files<CR>"
    lua neovim_runner_kitty.lua test-conflicts --keep-open
    lua neovim_runner_kitty.lua test-output /tmp/results.json
    lua neovim_runner_kitty.lua run-command ":checkhealth"

Output Files:
    - JSON results: scripts/tmp/nvim_keymap_test_results.json
    - Summary: scripts/tmp/nvim_keymap_test_results_summary.txt
    - Test files: scripts/tmp/nvim_test_*.txt
]])
	elseif args[1] == "test-conflicts" then
		if args[2] == "vm" then
			-- Test VM keymaps specifically
			local vm_keymaps = {
				{ mode = "n", lhs = "<leader>k", rhs = "VM toggle", desc = "VM leader key" },
				{ mode = "n", lhs = "<leader>kh", rhs = "VM move left", desc = "VM left (h mapped)" },
				{ mode = "n", lhs = "<leader>ka", rhs = "VM move down", desc = "VM down (a->j mapped)" },
				{ mode = "n", lhs = "<leader>ke", rhs = "VM move up", desc = "VM up (e->k mapped)" },
				{ mode = "n", lhs = "<leader>ki", rhs = "VM move right", desc = "VM right (i->l mapped)" },
				{ mode = "n", lhs = "<leader>kr", rhs = "VM insert", desc = "VM insert (r->i mapped)" },
				{ mode = "n", lhs = "<leader>kt", rhs = "VM append", desc = "VM append (t->a mapped)" },
			}
			M.test_keymap_conflicts(vm_keymaps, keep_open)
		else
			M.test_keymap_conflicts(nil, keep_open)
		end
	elseif args[1] == "test-single" and #args >= 4 then
		M.test_single_keymap(args[2], args[3], args[4], args[5], keep_open)
	elseif args[1] == "test-output" then
		M.test_with_output(nil, args[2])
	elseif args[1] == "run-command" and args[2] then
		M.run_nvim_command(args[2])
	else
		print("Invalid command. Run without arguments for help.")
	end
end

-- Run if executed directly
if arg and arg[0]:match("neovim_runner_kitty.lua$") then
	main(arg)
end

return M
