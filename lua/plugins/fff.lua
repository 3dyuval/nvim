-- [nfnl] fnl/plugins/fff.fnl
local function _1_()
  return require("fff.download").download_or_build_binary()
end
local function _2_(_, opts)
  return require("fff").setup(opts)
end
return {"dmtrKovalenko/fff.nvim", enabled = true, version = "v0.9.6", build = _1_, opts = {version = "v0.9.6", base_path = vim.fn.getcwd(), max_results = 100, max_threads = 6, prompt = "FFF ", title = "Find Files", layout = {width = 0.8, height = 0.8, preview_size = 0.5, prompt_position = "bottom"}, preview = {enabled = true, max_lines = 5000, max_size = (10 * 1024 * 1024), show_file_info = true, binary_file_threshold = 1024, line_numbers = false, wrap_lines = false}, keymaps = {close = "<Esc>", select = "<CR>", select_split = "<C-s>", select_vsplit = "<C-v>", select_tab = "<C-CR>", move_up = {"<Up>", "<C-p>"}, move_down = {"<Down>", "<C-n>"}, preview_scroll_up = "<C-u>", preview_scroll_down = "<C-d>", toggle_debug = "<F2>"}, frecency = {enabled = true, db_path = (vim.fn.stdpath("cache") .. "/fff_nvim")}, logging = {log_level = "info", enabled = false}, icons = {enabled = true}, respect_gitignore = true, follow_symlinks = false, show_hidden = false, ui_enabled = false}, config = _2_}
