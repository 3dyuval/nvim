local maps = require("keymaps.maps")
local map = maps.map
local func = maps.func
local desc = maps.desc
local which = maps.which
local remap = maps.remap

local find_files
local find_files_snacks
local save_file
local save_and_stage_file

map({
  [func] = which,
  ["<leader>"] = {
    [" "] = desc("Find files (fff.nvim)", find_files),
    f = {
      f = desc("Find files (snacks + fff)", find_files_snacks),
      s = desc("Save file", save_file),
      S = desc("Save and stage file", save_and_stage_file),
    },
  },
})

-- Standard fff.nvim file picker with override
find_files = function()
  require("fff").find_files()
end

-- Override the default <leader><space> mapping after lil.map
remap("n", "<leader><space>", find_files, { desc = "Find files (fff.nvim)" })

-- Snacks picker with fff.nvim backend
find_files_snacks = function()
  if _G.fff_snacks_picker then
    _G.fff_snacks_picker()
  else
    vim.notify("FFF Snacks picker not available", vim.log.levels.WARN)
    Snacks.picker.files()
  end
end

save_file = ":w<CR>"

save_and_stage_file = function()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  if file ~= "" then
    vim.fn.system("git add " .. vim.fn.shellescape(file))
    vim.notify("Saved and staged: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
  end
end
