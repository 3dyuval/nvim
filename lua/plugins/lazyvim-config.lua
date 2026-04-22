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

  -- Enable colorschemes used by omarchy themes
  { "st-eez/osaka-jade.nvim", enabled = true },
  { "serhez/teide.nvim", enabled = true },
  { "folke/tokyonight.nvim", enabled = true },
  { "catppuccin/nvim", name = "catppuccin", enabled = true },
  { "sainnhe/gruvbox-material", enabled = true },
  { "motaz-shokry/gruvbox.nvim", enabled = true },
  { "rebelot/kanagawa.nvim", enabled = true },
  { "rose-pine/neovim", name = "rose-pine", enabled = true },
  { "sainnhe/everforest", enabled = true },
  { "alexmozaidze/palenight.nvim", enabled = true },
  { "hylophile/flatwhite.nvim", enabled = false },
  {
    "loctvl842/monokai-pro.nvim",
    enabled = true,
  },
  { "marko-cerovac/material.nvim", enabled = true },
  { "shaunsingh/nord.nvim", enabled = true, name = "nord" },
  { "AlexvZyl/nordic.nvim", enabled = false },
  { "ribru17/bamboo.nvim", enabled = true },
  { "kepano/flexoki-neovim", name = "flexoki", enabled = true },
  { "tahayvr/matteblack.nvim", enabled = true },
  { "bjarneo/aether.nvim", enabled = true },
  { "bjarneo/hackerman.nvim", enabled = true },
  { "3dyuval/flatdeep.nvim", enabled = true },

  {
    "3dyuval/retro-fallout.nvim",
  },
  { "briones-gabriel/darcula-solid.nvim", enabled = true },
  { "zenbones-theme/zenbones.nvim", dependencies = { "rktjmp/lush.nvim" }, enabled = true },
  { "navarasu/onedark.nvim", enabled = false },
  { "EdenEast/nightfox.nvim", enabled = false },

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
