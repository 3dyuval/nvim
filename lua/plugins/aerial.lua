return {
  "stevearc/aerial.nvim",
  event = "BufEnter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- Show aerial in a floating window
    open_automatic = false,
    layout = {
      mirror_scroll = true,
      max_height = math.huge,
      min_width = 30,
      max_width = math.huge,
      win = {
        backdrop = 0,
        border = "single",
        winhighlight = "Normal:AerialNormal,FloatBorder:AerialBorder,NormalFloat:AerialNormal,CursorLine:AerialCursorLine",
      },
    },
    -- Use treesitter for symbols when available
    backend = { "lsp", "treesitter" },
    -- Filter symbols
    filter = nil,
    -- Lazy load
    lazy = true,
    -- Only show for buffers with LSP
    attach_mode = "global",
    -- Skip certain filetypes
    skip_builtins = true,
    -- Show indent lines
    show_indent_guides = true,
    -- Fold by default
    fold_open = false,
    fold_close = true,
    -- Icons
    icons = {
      toggle = { "🔼", "🔽" },
      indent = { "", "│" },
      treesitter = {
        Namespace = "📁",
        Text = "📄",
        Method = "🔧",
        Property = "🏷️",
        Field = "📊",
        Constructor = "🔨",
        Enum = "🔢",
        Interface = "📋",
        Function = "📝",
        Variable = "📦",
        Class = "📚",
        String = "🔗",
        Number = "🔢",
        Boolean = "🔘",
        Array = "📋",
        Object = "📦",
        Key = "🔑",
        Null = "💀",
        EnumMember = "🔢",
        Struct = "🏗️",
        Event = "⚡",
        Operator = "🔧",
        TypeParameter = "🏷️",
      },
    },
    -- Sort symbols
    sort = { "lsp", "treesitter" },
    -- Preselect first symbol
    preselect = true,
    -- Jump to symbol on enter
    jump = { scroll = "middle", border = "single" },
  },
  keys = {
    { "<leader>ao", "<Cmd>AerialToggle<CR>", desc = "Aerial (Outline)" },
    { "<leader>af", "<Cmd>AerialFocus<CR>", desc = "Aerial (Focus)" },
    { "<leader>ac", "<Cmd>AerialClose<CR>", desc = "Aerial (Close)" },
  },
}
