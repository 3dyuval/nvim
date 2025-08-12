return {
  "dmtrKovalenko/fff.nvim",
  enabled = true, -- Disable until Rust backend is built
  build = "cargo +nightly build --release",
  opts = {
    base_path = vim.fn.getcwd(),
    max_results = 100,
    max_threads = 4,
    prompt = "🪿 ",
    title = "FFF Files",
    ui_enabled = true,

    width = 0.8,
    height = 0.8,

    preview = {
      enabled = true,
      width = 0.5,
      max_lines = 5000,
      max_size = 10 * 1024 * 1024,
      line_numbers = false,
      wrap_lines = false,
      show_file_info = true,
      binary_file_threshold = 1024,
    },

    keymaps = {
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
  },
}

