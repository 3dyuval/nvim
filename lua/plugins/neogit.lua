return {
  "NeogitOrg/neogit",
  opts = {
    kind = "vsplit",
    -- floating = {
    -- relative = "editor",
    -- width = 0.95,
    -- height = 0.90,
    -- style = "minimal",
    -- border = "rounded",
    -- },
    integrations = {
      diffview = true,
    },
    keymaps = {},
    autoinstall = true,
  },
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "sindrets/diffview.nvim", -- optional - Diff integration

    -- Only one of these is needed.
    "nvim-telescope/telescope.nvim", -- optional
    "ibhagwan/fzf-lua", -- optional
    "echasnovski/mini.pick", -- optional
    "folke/snacks.nvim", -- optional
  },
}
