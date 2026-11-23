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
    keymaps = {
      ["?"] = { "actions.show_help", mode = "n" },
      ["g?"] = { "actions.show_help", mode = "n" },
      h = { "actions.parent", mode = "n" },
      i = { "actions.select", mode = "n" },
      ["<CR>"] = "actions.select",
      ["<C-s>"] = { "actions.select", opts = { vertical = true } },
      ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
      ["<C-t>"] = { "actions.select", opts = { tab = true } },
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = { "actions.close", mode = "n" },
      ["<C-l>"] = "actions.refresh",
      ["-"] = { "actions.parent", mode = "n" },
      _ = { "actions.open_cwd", mode = "n" },
      ["`"] = { "actions.cd", mode = "n" },
      gs = { "actions.change_sort", mode = "n" },
      gx = "actions.open_external",
      ["g."] = { "actions.toggle_hidden", mode = "n" },
      ["g\\"] = { "actions.toggle_trash", mode = "n" },
    },
    skip_confirm_for_simple_edits = false,
    use_default_keymaps = false,
  },
  lazy = false,
}
