return {
  "NeogitOrg/neogit",
  opts = {
    kind = "vsplit",
    graph_style = "kitty",
    integrations = {
      diffview = true,
    },
    merge_editor = {
      kind = "auto",
    },
    commit_view = {
      kind = "vsplit",
    },
    keymaps = {},
    autoinstall = true,
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "folke/snacks.nvim",
  },
}
