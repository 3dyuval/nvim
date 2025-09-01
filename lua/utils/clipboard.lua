-- Clipboard operations utilities
local M = {}

M.copy_file_path = function()
  local file_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
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

return M