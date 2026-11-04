-- [nfnl] fnl/plugins/fff-snacks.fnl
local find_at_git_root
local function _1_()
  local file = vim.api.nvim_buf_get_name(0)
  local buf_dir
  if file ~= "" then
    buf_dir = vim.fn.fnamemodify(file, ":p:h")
  else
    buf_dir = vim.fn.getcwd()
  end
  local root = (Snacks.git.get_root(buf_dir) or buf_dir)
  require("fff").change_indexing_directory(root)
  return require("fff-snacks").find_files({ cwd = root })
end
find_at_git_root = _1_
return {
  "madmaxieee/fff-snacks.nvim",
  dependencies = { "dmtrKovalenko/fff.nvim", "folke/snacks.nvim" },
  keys = {
    { "<leader>ff", find_at_git_root, desc = "Find files (git root)" },
    { "<C-f>", find_at_git_root, desc = "Find files (git root)" },
  },
  opts = { find_files = {}, live_grep = {} },
}
