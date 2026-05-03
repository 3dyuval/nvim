return {
  {
    "folke/flash.nvim",
    enabled = false, -- Completely disable Flash
  },
  {
    "LazyVim/LazyVim",
    init = function()
      -- Override the default wrap_spell autocmd to disable spell checking
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("override_wrap_spell", { clear = true }),
        pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.spell = true
        end,
      })
    end,
  },

  -- Opt out of LazyVim keymaps - bind explicitly in keymaps.lua
  {
    "MagicDuck/grug-far.nvim",
    keys = {},
    config = function(_, opts)
      require("grug-far").setup(opts)
      pcall(vim.keymap.del, { "n", "x" }, "<leader>sr")
    end,
  },
  { "folke/trouble.nvim", keys = {} },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function() end, -- Disable default keymaps, defined in keymaps.lua
    },
  },
  -- Note: LSP keymaps are now consolidated in lua/plugins/lsp-keymaps.lua
}
