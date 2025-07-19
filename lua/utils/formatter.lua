local M = {}

-- ============================================================================
-- DIRECT CONFORM INTEGRATION
-- ============================================================================

-- Format using conform directly (no external scripts needed)
function M.format_file(filepath, options)
	options = options or {}

	if not filepath or filepath == "" then
		vim.notify("No filepath provided", vim.log.levels.WARN)
		return false
	end

	if vim.fn.filereadable(filepath) == 0 then
		vim.notify("File not found: " .. filepath, vim.log.levels.WARN)
		return false
	end

	local conform = require("conform")
	local bufnr = vim.fn.bufnr(filepath, true)

	-- Load the buffer if not already loaded
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		vim.fn.bufload(bufnr)
	end

	-- Set appropriate filetype
	local ext = filepath:match("%.(%w+)$")
	if ext then
		local ft_map = {
			js = "javascript",
			jsx = "javascriptreact",
			ts = "typescript",
			tsx = "typescriptreact",
			json = "json",
			lua = "lua",
			html = "html",
			vue = "vue",
			css = "css",
			scss = "scss",
		}
		if ft_map[ext] then
			vim.api.nvim_buf_set_option(bufnr, "filetype", ft_map[ext])
		end
	end

	-- Format the buffer
	local success = conform.format({
		bufnr = bufnr,
		timeout_ms = options.timeout_ms or 5000,
		dry_run = options.dry_run or false,
		quiet = options.quiet or false,
	})

	if success then
		-- Save the buffer if formatting succeeded
		vim.api.nvim_buf_call(bufnr, function()
			vim.cmd("silent! write!")
		end)

		if not options.quiet then
			vim.notify("Formatted: " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.INFO)
		end
		return true
	else
		if not options.quiet then
			vim.notify("Failed to format: " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.ERROR)
		end
		return false
	end
end

-- Format multiple files
function M.format_batch(paths, options)
	options = options or {}

	if not paths or #paths == 0 then
		vim.notify("No paths provided for formatting", vim.log.levels.WARN)
		return
	end

	local files = {}

	-- Collect all files to format
	for _, path in ipairs(paths) do
		if vim.fn.isdirectory(path) == 1 then
			-- Find supported files in directory
			local cmd = string.format(
				"find %s -type f \\( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' -o -name '*.json' -o -name '*.lua' -o -name '*.html' -o -name '*.vue' -o -name '*.css' -o -name '*.scss' \\)",
				vim.fn.shellescape(path)
			)
			local result = vim.fn.systemlist(cmd)
			for _, file in ipairs(result) do
				table.insert(files, file)
			end
		elseif vim.fn.filereadable(path) == 1 then
			table.insert(files, path)
		end
	end

	if #files == 0 then
		vim.notify("No files found to format", vim.log.levels.WARN)
		return
	end

	-- Format each file
	local success_count = 0
	local total_count = #files

	if not options.quiet then
		vim.notify(string.format("Formatting %d files...", total_count), vim.log.levels.INFO)
	end

	for _, filepath in ipairs(files) do
		if M.format_file(filepath, { quiet = true, timeout_ms = options.timeout_ms }) then
			success_count = success_count + 1
		end
	end

	-- Show summary
	if not options.quiet then
		local message = string.format("Formatted %d/%d files", success_count, total_count)
		local level = success_count == total_count and vim.log.levels.INFO or vim.log.levels.WARN
		vim.notify(message, level)
	end

	return success_count
end

-- Format current buffer
function M.format_current_buffer(options)
	local filepath = vim.api.nvim_buf_get_name(0)
	if filepath == "" then
		vim.notify("Current buffer has no associated file", vim.log.levels.WARN)
		return false
	end

	return M.format_file(filepath, options)
end

-- Format selected files in picker
function M.format_picker_selection(picker, options)
	if not picker then
		vim.notify("No picker provided", vim.log.levels.WARN)
		return
	end

	local picker_extensions = require("utils.picker-extensions")
	local items = {}

	-- Get selected or current items
	if picker.selected and #picker.selected > 0 then
		items = picker.selected
	else
		local current_item, err = picker_extensions.get_current_item(picker)
		if current_item and not err then
			items = { current_item }
		end
	end

	if #items == 0 then
		vim.notify("No files selected for formatting", vim.log.levels.WARN)
		return
	end

	-- Extract file paths
	local paths = {}
	for _, item in ipairs(items) do
		if item.file then
			table.insert(paths, item.file)
		end
	end

	if #paths == 0 then
		vim.notify("No valid file paths found in selection", vim.log.levels.WARN)
		return
	end

	return M.format_batch(paths, options)
end

-- ============================================================================
-- SANDBOXED BATCH FORMATTER (uses external script for complex scenarios)
-- ============================================================================

-- For complex batch operations that need isolated environment
function M.format_batch_sandboxed(paths, _options)
	if not paths or #paths == 0 then
		vim.notify("No paths provided for formatting", vim.log.levels.WARN)
		return
	end

	local script_path = vim.fn.expand("~/.config/nvim/scripts/batch-formatter")

	if vim.fn.executable(script_path) ~= 1 then
		vim.notify("Batch formatter script not found: " .. script_path, vim.log.levels.ERROR)
		return
	end

	-- Build command
	local cmd = { script_path }
	vim.list_extend(cmd, paths)

	-- Execute the batch formatter
	local result = vim.fn.system(cmd)
	local exit_code = vim.v.shell_error

	if exit_code == 0 then
		vim.notify("Batch formatting completed successfully", vim.log.levels.INFO)
	else
		vim.notify("Batch formatting failed: " .. result, vim.log.levels.ERROR)
	end

	return exit_code == 0
end

-- ============================================================================
-- SETUP AND CONFIGURATION
-- ============================================================================

function M.setup(_opts)
	-- Create user commands
	vim.api.nvim_create_user_command("Format", function(args)
		local paths = #args.fargs > 0 and args.fargs or { vim.fn.expand("%") }
		M.format_batch(paths, { timeout_ms = args.bang and 10000 or 5000 })
	end, {
		desc = "Format files using conform.nvim",
		nargs = "*",
		bang = true,
		complete = "file",
	})

	vim.api.nvim_create_user_command("FormatSandboxed", function(args)
		local paths = #args.fargs > 0 and args.fargs or { vim.fn.expand("%") }
		M.format_batch_sandboxed(paths)
	end, {
		desc = "Format files using sandboxed batch formatter",
		nargs = "*",
		complete = "file",
	})

	vim.notify("Formatter API initialized (conform.nvim)", vim.log.levels.INFO)
end

return M
