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
-- 1. Launches Neovim in a new kitty tab with a temp file (bypasses LazyVim dashboard)
-- 2. Loads the interactive test script via require()
-- 3. Executes keymap conflict tests and captures results
-- 4. Displays formatted results and optionally closes the tab
-- 5. Uses kitty's remote control protocol to send commands and text

local M = {}

-- Helper function to execute shell commands
local function execute_command(cmd)
    local handle = io.popen(cmd .. " 2>&1")
    local result = handle:read("*a")
    local success = handle:close()
    return result, success
end

-- Helper function to execute kitty remote control commands
local function kitty_command(cmd)
    local full_cmd = string.format('kitten @ %s', cmd)
    return execute_command(full_cmd)
end

-- Send text to a specific kitty window
local function send_text(match_criteria, text)
    local cmd = string.format('send-text --match \'%s\' "%s"', match_criteria, text:gsub('"', '\\"'))
    return kitty_command(cmd)
end

-- Launch Neovim in a new tab
local function launch_nvim_tab(title)
    title = title or "Neovim Test"
    local nvim_path = "/home/yuval/.local/bin/nvim"  -- Use full path to avoid conflicts
    -- Create a temp file to bypass dashboard - LazyVim doesn't show dashboard when opening a file
    local temp_file = "/tmp/nvim_keymap_test_temp.lua"
    local cmd = string.format('launch --type=tab --tab-title="%s" %s %s', title, nvim_path, temp_file)
    print("Debug: Running command: " .. cmd)
    local result, success = kitty_command(cmd)
    print("Debug: Command result: " .. (result or "nil"))
    print("Debug: Command success: " .. tostring(success))
    return result, success
end

-- Wait for Neovim to fully load
local function wait_for_nvim(seconds)
    seconds = seconds or 3
    print(string.format("Waiting %d seconds for Neovim to load...", seconds))
    os.execute(string.format("sleep %d", seconds))
end

-- Test keymap conflicts in Neovim
function M.test_keymap_conflicts(keymaps, keep_open)
    local tab_title = "Keymap Conflict Test"
    local output_file = "/tmp/nvim_keymap_test_results.json"
    
    print("=== Testing Neovim Keymap Conflicts ===")
    
    -- Launch Neovim with minimal UI to avoid GPU errors
    print("Launching Neovim...")
    launch_nvim_tab(tab_title)
    wait_for_nvim(4)  -- Wait a bit longer for full load
    
    -- Dashboard bypassed by opening a temp file
    
    -- Load the interactive test script using require
    print("Loading keymap conflict test script...")
    send_text(string.format('title:%s', tab_title), ':lua require("config.tests.test_keymaps_interactive")')
    os.execute("sleep 0.5")
    send_text(string.format('title:%s', tab_title), '')  -- Press Enter
    os.execute("sleep 1")
    
    -- First, let's check if the mapping exists
    print("Checking existing <leader>cp mapping...")
    send_text(string.format('title:%s', tab_title), ':nmap <leader>cp')
    os.execute("sleep 0.5")
    send_text(string.format('title:%s', tab_title), '')  -- Press Enter
    os.execute("sleep 1")
    
    -- Write results to file for reading
    local test_cmd
    if keymaps then
        local keymaps_str = serialize_keymaps(keymaps)
        test_cmd = string.format(':lua require("config.tests.test_keymaps_interactive").write_results(%s, "%s")', 
            keymaps_str, output_file)
    else
        -- Test default <leader>cp
        print("Testing <leader>cp conflict...")
        test_cmd = string.format(':lua require("config.tests.test_keymaps_interactive").write_results({{ mode = "n", lhs = "<leader>cp", rhs = "test", desc = "Test conflicting keymap" }}, "%s")', 
            output_file)
    end
    
    send_text(string.format('title:%s', tab_title), test_cmd)
    os.execute("sleep 0.5")
    send_text(string.format('title:%s', tab_title), '')  -- Press Enter
    os.execute("sleep 2")  -- Wait for results to be written
    
    -- Read and display results
    local file = io.open(output_file, "r")
    if file then
        local content = file:read("*a")
        file:close()
        
        -- Parse JSON manually for display
        local ok, data = pcall(function()
            -- Simple JSON parsing for display
            return load("return " .. content:gsub('(%w+):', '[\"%1\"]='))()
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
                    print(string.format("\n%d. Mode: %s, Key: %s [%s]", 
                        i, conflict.mode, conflict.key, conflict.severity))
                    print(string.format("   Existing: %s - %s", 
                        conflict.existing_rhs, conflict.existing_desc))
                    print(string.format("   New: %s - %s", 
                        conflict.new_rhs, conflict.new_desc))
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
    
    -- Close the tab unless keep_open is true
    if not keep_open then
        os.execute("sleep 1")
        print("\nClosing test tab...")
        kitty_command(string.format('close-tab --match title:"%s"', tab_title))
    else
        print("\n✅ Test tab kept open. Check the '" .. tab_title .. "' tab for visual results.")
    end
    
    return true
end

-- Test a single keymap
function M.test_single_keymap(mode, lhs, rhs, desc, keep_open)
    local keymaps = {{ mode = mode, lhs = lhs, rhs = rhs, desc = desc }}
    return M.test_keymap_conflicts(keymaps, keep_open)
end

-- Test with results written to file
function M.test_with_output(keymaps, output_file)
    output_file = output_file or "/tmp/keymap_conflict_results.json"
    local tab_title = "Keymap Test Output"
    
    print("=== Testing with JSON Output ===")
    
    -- Launch Neovim
    launch_nvim_tab(tab_title)
    wait_for_nvim()
    
    -- Source the test script
    send_text(string.format('title:%s', tab_title), ':source ~/.config/nvim/lua/config/tests/test_keymaps_interactive.lua')
    os.execute("sleep 0.5")
    send_text(string.format('title:%s', tab_title), '')
    
    -- Run test and write results
    os.execute("sleep 0.5")
    local keymaps_str = keymaps and serialize_keymaps(keymaps) or '{}'
    local cmd = string.format(
        ':lua require("config.tests.test_keymaps_interactive").write_results(%s, "%s")',
        keymaps_str, output_file
    )
    send_text(string.format('title:%s', tab_title), cmd)
    os.execute("sleep 0.5")
    send_text(string.format('title:%s', tab_title), '')
    
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
        table.insert(parts, string.format('mode="%s",', km.mode or 'n'))
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
function M.run_nvim_command(command, tab_title)
    tab_title = tab_title or "Neovim Command"
    
    print(string.format("=== Running Neovim Command: %s ===", command))
    
    -- Launch Neovim
    launch_nvim_tab(tab_title)
    wait_for_nvim()
    
    -- Run the command
    send_text(string.format('title:%s', tab_title), command)
    os.execute("sleep 0.5")
    send_text(string.format('title:%s', tab_title), '')
    
    print("\n✅ Command executed in '" .. tab_title .. "' tab.")
    
    return true
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
    test-single MODE LHS RHS    Test a single keymap
    test-output [FILE]          Test and write JSON results to file
    run-command "COMMAND"       Run arbitrary Neovim command

Options:
    --keep-open                 Keep the Neovim tab open after testing

Examples:
    lua neovim_runner_kitty.lua test-conflicts
    lua neovim_runner_kitty.lua test-single n "<leader>ff" ":Telescope find_files<CR>"
    lua neovim_runner_kitty.lua test-conflicts --keep-open
    lua neovim_runner_kitty.lua test-output /tmp/results.json
    lua neovim_runner_kitty.lua run-command ":checkhealth"
]])
    elseif args[1] == "test-conflicts" then
        M.test_keymap_conflicts(nil, keep_open)
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