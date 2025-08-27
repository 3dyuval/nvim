local maps = require("keymaps.maps")
local map = maps.map
local func = maps.func
local desc = maps.desc
local which = maps.which

local find_files
local save_file
local save_and_stage_file

map({
  [func] = which,
  ["<leader>"] = {
    [" "] = desc("Find files", find_files),
    f = {
      s = desc("Save file", save_file),
      S = desc("Save and stage file", save_and_stage_file),
    },
  },
})

find_files = function()
  require("fff").find_files()
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

