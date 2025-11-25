local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out =
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  spec = {
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      init = function()
        -- Override the default wrap_spell autocmd to disable spell checking
        vim.api.nvim_create_autocmd("FileType", {
          group = vim.api.nvim_create_augroup("override_wrap_spell", { clear = true }),
          pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
          callback = function()
            vim.opt_local.wrap = true
            vim.opt_local.spell = false -- disable spell by default
          end,
        })
      end,
    },
    -- { import = "lazyvim.plugins.extras.lang.typescript" }, -- Disabled to prevent conflicts with custom vtsls config
    { import = "lazyvim.plugins.extras.lang.vue" },
    { import = "plugins" },
    -- All theme plugins
    { "catppuccin/nvim", name = "catppuccin", lazy = true },
    { "neanias/everforest-nvim", lazy = true },
    { "kepano/flexoki-neovim", lazy = true },
    { "ellisonleao/gruvbox.nvim", lazy = true },
    { "rebelot/kanagawa.nvim", lazy = true },
    { "marko-cerovac/material.nvim", lazy = true },
    { "rose-pine/neovim", name = "rose-pine", lazy = true },
    { "EdenEast/nightfox.nvim", lazy = true },
    { "ribru17/bamboo.nvim", lazy = true },
    { "gthelding/monokai-pro.nvim", lazy = true },
    { "folke/tokyonight.nvim", lazy = true },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
