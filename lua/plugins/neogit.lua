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
        ["<leader>q"] = "Close", -- Close Neogit
        -- Git conflict resolution keybindings (matching keymaps.lua)
        ["grO"] = function() require("git-resolve-conflict").resolve_ours() end,
        ["grP"] = function() require("git-resolve-conflict").resolve_theirs() end,
        ["grU"] = function() require("git-resolve-conflict").resolve_union() end,
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
