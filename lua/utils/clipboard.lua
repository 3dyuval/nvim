-- Clipboard operations utilities
local M = {}

M.copy_file_path = function()
  local file_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  vim.fn.setreg("+", file_path)
  vim.notify("Copied path: " .. file_path)
end

M.copy_file_path_claude_style = function()
  local claude_prefix = "@"
  local file_path = claude_prefix .. vim.fn.fnamemodify(vim.fn.expand("%"), ":~")
  vim.fn.setreg("+", file_path)
  vim.notify("Copied path: " .. file_path)
end

M.copy_code_path = function()
  local result = require("utils/code").get_code_path()
  if result then
    vim.fn.setreg("+", result)
    vim.notify("Copied: " .. result)
  end
end

M.copy_file_path_from_home = function()
  local file_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~")
  vim.fn.setreg("+", file_path)
  vim.notify("Copied path: " .. file_path)
end

M.copy_file_contents = function()
  local file_path = vim.fn.expand("%:p")
  if vim.fn.filereadable(file_path) == 0 then
    vim.notify("File not readable: " .. file_path, vim.log.levels.ERROR)
    return
  end
  local content = vim.fn.readfile(file_path)
  local content_str = table.concat(content, "\n")
  vim.fn.setreg("+", content_str)
  vim.notify("Copied file contents (" .. #content .. " lines)")
end

M.copy_file_path_with_line = function()
  local file_path = vim.fn.expand("%:p")
  local line_number = vim.fn.line(".")
  local path_with_line = file_path .. ":" .. line_number
  vim.fn.setreg("+", path_with_line)
  vim.notify("Copied: " .. path_with_line)
end

M.copy_file_name = function()
  local file_name = vim.fn.fnamemodify(vim.fn.expand("%"), ":t")
  vim.fn.setreg("+", file_name)
  vim.notify("Copied name: " .. file_name)
end

return M
