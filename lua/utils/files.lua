-- File operations utilities
local M = {}

-- Standard fff.nvim file picker with override
M.find_files = function()
  require("fff").find_files()
end

-- Snacks picker with fff.nvim backend
M.find_files_snacks = function()
  if _G.fff_snacks_picker then
    _G.fff_snacks_picker()
  else
    vim.notify("FFF Snacks picker not available", vim.log.levels.WARN)
    Snacks.picker.files()
  end
end

M.save_file = ":w<CR>"

M.save_and_stage_file = function()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  if file ~= "" then
    vim.fn.system("git add " .. vim.fn.shellescape(file))
    vim.notify("Saved and staged: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
  end
end

return M
