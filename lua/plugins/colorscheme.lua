return {
  -- Cyberdream - High-contrast, futuristic & vibrant
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        transparent = true,
        italic_comments = true,
        hide_fillchars = true,
      })
    end,
  },
  {
    "ficcdaf/ashen.nvim",
    lazy = false,
    priority = 1000,
  },
  -- Oxocarbon - Minimal dark theme inspired by IBM Carbon
  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = false,
    priority = 1000,
  },

  -- Bamboo - Warm green theme
  {
    "ribru17/bamboo.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("bamboo").setup({
        transparent = false,
        term_colors = true,
      })
    end,
  },

  -- Nordic - Nord-inspired but darker
  {
    "AlexvZyl/nordic.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nordic").setup({
        transparent = false,
        reduced_blue = true,
      })
    end,
  },

  -- Moonfly - Dark theme with vibrant colors
  {
    "bluz71/vim-moonfly-colors",
    lazy = false,
    priority = 1000,
    name = "moonfly",
  },

  -- Everforest - Comfortable green theme
  {
    "neanias/everforest-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("everforest").setup({
        background = "hard",
        transparent_background_level = 0,
      })
    end,
  },

  -- Tundra - Clean dark theme
  {
    "sam4llis/nvim-tundra",
    lazy = false,
    priority = 1000,
    config = function()
      require("nvim-tundra").setup({
        transparent_background = false,
        editor = {
          search = {},
          substitute = {},
        },
      })
    end,
  },

  -- Melange - Warm dark theme
  {
    "savq/melange-nvim",
    lazy = false,
    priority = 1000,
  },

  -- Modus themes - High accessibility with WCAG AAA compliance
  {
    "miikanissi/modus-themes.nvim",
    lazy = false,
    priority = 1000,
  },

  -- Jellybeans - Classic vim colorscheme ported
  {
    "metalelf0/jellybeans-nvim",
    lazy = false,
    priority = 1000,
    dependencies = { "rktjmp/lush.nvim" },
  },

  -- Material themes - Multiple material design variants
  {
    "marko-cerovac/material.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("material").setup({
        contrast = {
          terminal = false,
          sidebars = false,
          floating_windows = false,
          cursor_line = false,
          non_current_windows = false,
          filetypes = {},
        },
        styles = {
          comments = { italic = true },
          strings = {},
          keywords = {},
          functions = {},
          variables = {},
          operators = {},
          types = {},
        },
        plugins = {
          "dap",
          "dashboard",
          "gitsigns",
          "hop",
          "indent-blankline",
          "lspsaga",
          "mini",
          "neogit",
          "neorg",
          "nvim-cmp",
          "nvim-navic",
          "nvim-tree",
          "nvim-web-devicons",
          "sneak",
          "telescope",
          "trouble",
          "which-key",
        },
        disable = {
          colored_cursor = false,
          borders = false,
          background = false,
          term_colors = false,
          eob_lines = false,
        },
        high_visibility = {
          lighter = false,
          darker = false,
        },
        lualine_style = "default",
        async_loading = true,
        custom_colors = nil,
        custom_highlights = {},
      })
    end,
  },
}
