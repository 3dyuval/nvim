local function _1_()
  local actions = require("diffview.actions")
  local function _2_()
    if vim.opt_local.diff:get() then
      return vim.cmd("diffget")
    else
      return actions.conflict_choose("theirs")
    end
  end
  local function _4_()
    if vim.opt_local.diff:get() then
      return vim.cmd("diffget //2")
    else
      return actions.conflict_choose("ours")
    end
  end
  local function _6_()
    if (vim.fn.search("^<<<<<<< ", "nw") ~= 0) then
      return actions.next_conflict()
    else
      return vim.cmd("normal! ]c")
    end
  end
  local function _8_()
    if (vim.fn.search("^<<<<<<< ", "nw") ~= 0) then
      return actions.prev_conflict()
    else
      return vim.cmd("normal! [c")
    end
  end
  local function _10_()
    if (vim.fn.search("^<<<<<<< ", "nw") ~= 0) then
      return actions.next_conflict()
    else
      return vim.cmd("normal! ]c")
    end
  end
  local function _12_()
    if (vim.fn.search("^<<<<<<< ", "nw") ~= 0) then
      return actions.prev_conflict()
    else
      return vim.cmd("normal! [c")
    end
  end
  local function _14_()
    return actions.toggle_stage_entry()
  end
  local _15_
  do
    local gitgraph = require("integration.gitgraph-diffview")
    local function _16_(bufnr)
      vim.opt_local.foldenable = false
      vim.b[bufnr]["snacks_indent"] = false
      vim.b[bufnr]["snacks_scope"] = false
      return nil
    end
    local function _17_(view)
      vim.g.diffview_active = true
      return gitgraph["on-view-opened"](view)
    end
    local function _18_(view)
      vim.g.diffview_active = false
      return gitgraph["on-view-closed"](view)
    end
    local function _19_(view)
      return gitgraph["on-selection-changed"](view)
    end
    local function _20_(view)
      return gitgraph["on-files-staged"](view)
    end
    _15_ = {diff_buf_read = _16_, view_opened = _17_, view_closed = _18_, selection_changed = _19_, files_staged = _20_}
  end
  return {enhanced_diff_hl = true, use_icons = true, show_help_hints = true, default_args = {DiffviewOpen = {"--imply-local"}, DiffviewFileHistory = {}}, view = {default = {layout = "diff2_horizontal", winbar_info = true, win_config = {position = "bottom"}}, merge_tool = {layout = "diff3_horizontal", winbar_info = true, disable_diagnostics = false}, file_history = {layout = "diff2_horizontal", winbar_info = true, pin_local = true, win_config = {position = "bottom"}}}, graph_panel = {win_config = {position = "bottom", height = 16}}, file_panel = {listing_style = "tree", tree_options = {folder_statuses = "only_folded", flatten_dirs = false}}, keymaps = {disable_defaults = true, view = {{"n", "dr", _2_, {desc = "Get from right"}}, {"n", "dl", _4_, {desc = "Get from left (ours)"}}, {"n", "Dr", "<Cmd>%diffget //3<CR>", {desc = "Get all from right (theirs)"}}, {"n", "Dl", "<Cmd>%diffget //2<CR>", {desc = "Get all from left (ours)"}}, {"n", "A", _6_, {desc = "Next conflict or hunk"}}, {"n", "E", _8_, {desc = "Prev conflict or hunk"}}, {"n", "<C-PageDown>", _10_, {desc = "Next conflict or hunk"}}, {"n", "<C-PageUp>", _12_, {desc = "Prev conflict or hunk"}}, {"n", "<leader>.", actions.cycle_layout, {desc = "Cycle layout"}}, {"n", "q", actions.close, {desc = "Close diffview"}}, {"n", "<C-S-A>", actions.select_next_entry, {desc = "Open diff for next file"}}, {"n", "<C-S-E>", actions.select_prev_entry, {desc = "Open diff for previous file"}}, {"n", "gf", actions.goto_file_edit, {desc = "Go to file"}}, {"n", "<C-s>", actions.stage_all, {desc = "Stage all"}}, {"n", "?", actions.help("view"), {desc = "Help"}}}, diff1_inline = {{"n", "A", actions.next_inline_hunk, {desc = "Next inline hunk"}}, {"n", "E", actions.prev_inline_hunk, {desc = "Prev inline hunk"}}}, file_panel = {{"n", "dr", actions.restore_entry, {desc = "Restore file"}}, {"n", "dl", _14_, {desc = "Stage file"}}, {"n", "<C-R>", actions.refresh_files, {desc = "Refresh files"}}, {"n", "A", actions.select_next_entry, {desc = "Next file"}}, {"n", "E", actions.select_prev_entry, {desc = "Prev file"}}, {"n", "<C-S-A>", actions.select_next_entry, {desc = "Next file"}}, {"n", "<C-S-E>", actions.select_prev_entry, {desc = "Prev file"}}, {"n", "<C-PageDown>", actions.select_next_entry, {desc = "Next file"}}, {"n", "<C-PageUp>", actions.select_prev_entry, {desc = "Prev file"}}, {"n", "<cr>", actions.select_entry, {desc = "Open diff"}}, {"n", "o", actions.select_entry, {desc = "Open diff"}}, {"n", "q", "<Cmd>DiffviewClose<CR>", {desc = "Close diffview"}}, {"n", "?", actions.help("file_panel"), {desc = "Help"}}}, file_history_panel = {{"n", "A", actions.select_next_commit, {desc = "Next commit"}}, {"n", "E", actions.select_prev_commit, {desc = "Prev commit"}}, {"n", "<C-M-A>", actions.select_next_entry, {desc = "Next file"}}, {"n", "<C-M-E>", actions.select_prev_entry, {desc = "Prev file"}}, {"n", "<cr>", actions.select_entry, {desc = "Open diff"}}, {"n", "o", actions.select_entry, {desc = "Open diff"}}, {"n", "q", "<Cmd>DiffviewClose<CR>", {desc = "Close diffview"}}, {"n", "?", actions.help("file_history_panel"), {desc = "Help"}}}, help_panel = {{"n", "q", actions.close, {desc = "Close help menu"}}, {"n", "<esc>", actions.close, {desc = "Close help menu"}}}}, hooks = _15_, diff_binaries = false, watch_index = false}
end
return {"dlyongemallo/diffview-plus.nvim", dev = true, dependencies = {"nvim-tree/nvim-web-devicons", "isakbm/gitgraph.nvim"}, cmd = {"DiffviewOpen", "DiffviewToggle", "DiffviewFileHistory", "DiffviewGraph", "DiffviewDiffFiles", "DiffviewMergeFiles", "DiffviewDiffDirs"}, opts = _1_}
