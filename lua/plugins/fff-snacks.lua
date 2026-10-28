-- [nfnl] fnl/plugins/fff-snacks.fnl
local function _1_()
  return require("fff-snacks").find_files()
end
local function _2_()
  local file = vim.api.nvim_buf_get_name(0)
  local buf_dir
  if (file ~= "") then
    buf_dir = vim.fn.fnamemodify(file, ":p:h")
  else
    buf_dir = vim.fn.getcwd()
  end
  local root = (Snacks.git.get_root(buf_dir) or buf_dir)
  require("fff").change_indexing_directory(root)
  return require("fff-snacks").find_files({cwd = root})
end
return {"madmaxieee/fff-snacks.nvim", dependencies = {"dmtrKovalenko/fff.nvim", "folke/snacks.nvim"}, keys = {{"<leader>ff", _1_, desc = "Find files (cwd)"}, {"<C-f>", _2_, desc = "Find files (git root)"}}, opts = {find_files = {}, live_grep = {}}}
