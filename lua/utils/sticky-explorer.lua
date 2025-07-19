-- Explorer Session Persistence for Snacks.nvim
-- This module persists the sidebar explorer state across sessions

local M = {}

-- Simple flag to track if user wants the explorer open
-- This gets saved/restored by persistence.nvim automatically
local function get_explorer_enabled()
	return vim.g.StickyExplorer_isOpen == 1
end

local function set_explorer_enabled(enabled)
	vim.g.StickyExplorer_isOpen = enabled and 1 or 0
end

-- Check if a window is the explorer window (left sidebar)
local function is_explorer_window(win)
	if not win or not vim.api.nvim_win_is_valid(win) then
		return false
	end

	local buf = vim.api.nvim_win_get_buf(win)
	local ft = vim.api.nvim_buf_get_option(buf, "filetype")

	-- Must be a snacks picker/explorer
	if not (ft == "snacks_picker" or ft == "snacks_explorer") then
		return false
	end

	-- Check if it's positioned like a sidebar (left side, fixed width)
	local config = vim.api.nvim_win_get_config(win)

	-- Floating windows have 'relative' field, splits don't
	if config.relative and config.relative ~= "" then
		return false -- This is a floating window, not our sidebar
	end

	-- Check if it's on the left side by comparing with other windows
	local win_col = vim.api.nvim_win_get_position(win)[2]
	return win_col == 0 -- Left-most position
end

-- Find the explorer window
local function find_explorer_window()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if is_explorer_window(win) then
			return win
		end
	end
	return nil
end

-- Open the sidebar explorer
local function open_explorer()
	if find_explorer_window() then
		return -- Already open
	end

	-- Store current window to return focus
	local current_win = vim.api.nvim_get_current_win()

	-- Create simple explorer without any special close handling
	local picker = require("snacks").picker.explorer({
		root = false,
		auto_close = false,
		layout = {
			preset = "left",
			preview = false,
		},
	})

	-- Return focus to original window
	vim.schedule(function()
		if vim.api.nvim_win_is_valid(current_win) then
			vim.api.nvim_set_current_win(current_win)
		end
	end)

	return picker
end

-- Close the sidebar explorer
local function close_explorer()
	local win = find_explorer_window()
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
end

-- Public API
function M.toggle()
	local currently_enabled = get_explorer_enabled()
	local new_state = not currently_enabled

	set_explorer_enabled(new_state)

	if new_state then
		-- Opening: create explorer
		open_explorer()
	else
		-- Closing: close explorer
		close_explorer()
	end
end

function M.focus_or_open()
	set_explorer_enabled(true)
	local win = find_explorer_window()
	if win then
		vim.api.nvim_set_current_win(win)
	else
		open_explorer()
	end
end

-- Restore explorer if enabled (DRY helper)
local function restore_explorer_if_enabled()
	if get_explorer_enabled() then
		open_explorer()
	end
end

-- Setup session restoration only
function M.setup()
	local group = vim.api.nvim_create_augroup("ExplorerPersistence", { clear = true })

	-- Restore explorer state after session load
	vim.api.nvim_create_autocmd("User", {
		pattern = "PersistenceLoadPost",
		group = group,
		callback = function()
			vim.defer_fn(restore_explorer_if_enabled, 100)
		end,
	})

	-- Also check on VimEnter in case session was loaded before our autocmd
	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		once = true,
		callback = function()
			vim.defer_fn(restore_explorer_if_enabled, 100)
		end,
	})
end

return M

