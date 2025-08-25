return {
  "dmtrKovalenko/fff.nvim",
  enabled = true,
  build = "cargo +nightly build --release",
  opts = {
    base_path = vim.fn.getcwd(),
    max_results = 100,
    max_threads = 4,
    prompt = "🪿 ",
    title = "FFF Files",
    ui_enabled = true,

    layout = {
      width = 0.8,
      height = 0.8,
      preview_size = 0.5,
    },

    preview = {
      enabled = true,
      max_lines = 5000,
      max_size = 10 * 1024 * 1024,
      line_numbers = false,
      wrap_lines = false,
      show_file_info = true,
      binary_file_threshold = 1024,
    },

    keymaps = {
      open = "<leader>F",
      close = "<Esc>",
      select = "<CR>",
      select_split = "<C-s>",
      select_vsplit = "<C-v>",
      select_tab = "<C-t>",
      move_up = { "<Up>", "<C-p>" },
      move_down = { "<Down>", "<C-n>" },
      preview_scroll_up = "<C-u>",
      preview_scroll_down = "<C-d>",
      toggle_debug = "<F2>",
    },

    frecency = {
      enabled = true,
      db_path = vim.fn.stdpath("cache") .. "/fff_nvim",
    },

    logging = {
      enabled = false,
      log_level = "info",
    },

    icons = {
      enabled = true,
    },

    -- Directory display options
    show_hidden = false, -- Show hidden files/folders
    respect_gitignore = true, -- Respect .gitignore rules
    follow_symlinks = false, -- Follow symbolic links
  },
  config = function(_, opts)
    -- Setup fff.nvim with options
    require("fff").setup(opts)

    -- Also make the snacks picker integration available
    _G.fff_snacks_picker = require("utils.fff").fff
  end,
}
