-- [nfnl] fnl/plugins/oil.fnl
local function _1_()
  return require("oil").open()
end
local function _2_()
  return require("oil").open_float()
end
return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>o-", _1_, desc = "Oil: open parent dir (editable)" },
    { "<leader>oo", _2_, desc = "Oil: open float (editable)" },
  },
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    view_options = { show_hidden = true },
    float = { padding = 4, max_width = 100, max_height = 30 },
    skip_confirm_for_simple_edits = false,
  },
  lazy = false,
}
