-- [nfnl] fnl/plugins/fff-snacks.fnl
local function _1_()
  return require("fff-snacks").find_files()
end
local function _2_()
  local file = vim.api.nvim_buf_get_name(0)
  local dir
  if (file ~= "") then
    dir = vim.fn.fnamemodify(file, ":p:h")
  else
    dir = vim.fn.getcwd()
  end
  return require("fff-snacks").find_files({cwd = dir})
end
return {"madmaxieee/fff-snacks.nvim", dependencies = {"dmtrKovalenko/fff.nvim", "folke/snacks.nvim"}, keys = {{"<leader>ff", _1_, desc = "Find files (cwd)"}, {"<C-f>", _2_, desc = "Find files (buffer dir)"}}, opts = {}}
