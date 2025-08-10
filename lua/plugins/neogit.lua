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
    mappings = {
      popup = {
        ["m"] = false,
        ["M"] = "MergePopup",
      },
      status = {
        ["C"] = "YankSelected",
        ["m"] = false, -- disable merge to use your custom binding
      },
    },
    autoinstall = true,
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "folke/snacks.nvim",
  },
}
