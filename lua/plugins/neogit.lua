return {
  "NeogitOrg/neogit",
  opts = {
    auto_refresh = true,
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
      rebase_editor = {
        ["E"] = "MoveUp", -- move commit up
        ["A"] = "MoveDown", -- move commit down
      },
      popup = {
        ["m"] = false,
        ["M"] = "MergePopup",
      },
      status = {
        ["C"] = "YankSelected",
        ["m"] = false, -- disable merge to use your custom binding
        ["<leader>q"] = "Close", -- Close Neogit
        -- Git conflict resolution keybindings (matching keymaps.lua)
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
