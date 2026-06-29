-- [nfnl] fnl/plugins/diffview-plus.fnl
local function _1_()
  local actions = require("diffview.actions")
  local function _2_()
    if (vim.fn.search("^<<<<<<< ", "nw") ~= 0) then
      return actions.conflict_choose("theirs")
    else
      return vim.cmd("diffget")
    end
  end
  local function _4_()
    if (vim.fn.search("^<<<<<<< ", "nw") ~= 0) then
      return actions.conflict_choose("ours")
    else
      return vim.cmd("diffget")
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
    return actions.toggle_stage_entry()
  end
  local function _11_(bufnr)
    vim.opt_local.foldenable = false
    vim.b[bufnr]["snacks_indent"] = false
    vim.b[bufnr]["snacks_scope"] = false
    return nil
  end
  local function _12_()
    vim.g.diffview_active = true
    return nil
  end
  local function _13_()
    vim.g.diffview_active = false
    return nil
  end
  return {enhanced_diff_hl = true, use_icons = true, show_help_hints = true, default_args = {DiffviewOpen = {"--imply-local"}, DiffviewFileHistory = {}}, view = {default = {layout = "diff2_horizontal", winbar_info = true, win_config = {position = "bottom"}}, merge_tool = {layout = "diff1_plain", winbar_info = true, disable_diagnostics = false}, file_history = {layout = "diff2_horizontal", winbar_info = true, pin_local = true, win_config = {position = "bottom"}}}, file_panel = {listing_style = "tree", tree_options = {folder_statuses = "only_folded", flatten_dirs = false}}, keymaps = {disable_defaults = true, view = {{"n", "dr", _2_, {desc = "Get from right (THEIRS)"}}, {"n", "dl", _4_, {desc = "Get from left (OURS)"}}, {"n", "Dr", "<Cmd>%diffget<CR>", {desc = "Get all from right (THEIRS)"}}, {"n", "Dl", "<Cmd>diffget<CR>", {desc = "Get all from left (OURS)"}}, {"n", "dp", "<Cmd>diffput<CR>", {desc = "Put hunk to other (OURS)"}}, {"n", "A", _6_, {desc = "Next conflict or hunk"}}, {"n", "E", _8_, {desc = "Prev conflict or hunk"}}, {"n", "<leader>.", actions.cycle_layout, {desc = "Cycle layout"}}, {"n", "q", actions.close, {desc = "Close diffview"}}, {"n", "<C-S-A>", actions.select_next_entry, {desc = "Open diff for next file"}}, {"n", "<C-S-E>", actions.select_prev_entry, {desc = "Open diff for previous file"}}, {"n", "gf", actions.goto_file_edit, {desc = "Go to file"}}, {"n", "<C-s>", actions.stage_all, {desc = "Stage all"}}, {"n", "?", actions.help("view"), {desc = "Help"}}}, diff1_inline = {{"n", "A", actions.next_inline_hunk, {desc = "Next inline hunk"}}, {"n", "E", actions.prev_inline_hunk, {desc = "Prev inline hunk"}}}, file_panel = {{"n", "dr", actions.restore_entry, {desc = "Restore file"}}, {"n", "dl", _10_, {desc = "Stage file"}}, {"n", "<C-R>", actions.refresh_files, {desc = "Refresh files"}}, {"n", "A", actions.select_next_entry, {desc = "Next file"}}, {"n", "E", actions.select_prev_entry, {desc = "Prev file"}}, {"n", "<C-S-A>", actions.select_next_entry, {desc = "Next file"}}, {"n", "<C-S-E>", actions.select_prev_entry, {desc = "Prev file"}}, {"n", "<cr>", actions.select_entry, {desc = "Open diff"}}, {"n", "o", actions.select_entry, {desc = "Open diff"}}, {"n", "q", "<Cmd>DiffviewClose<CR>", {desc = "Close diffview"}}, {"n", "?", actions.help("file_panel"), {desc = "Help"}}}, file_history_panel = {{"n", "A", actions.select_next_entry, {desc = "Next file"}}, {"n", "E", actions.select_prev_entry, {desc = "Prev file"}}, {"n", "<C-M-A>", actions.select_next_entry, {desc = "Next file"}}, {"n", "<C-M-E>", actions.select_prev_entry, {desc = "Prev file"}}, {"n", "<cr>", actions.select_entry, {desc = "Open diff"}}, {"n", "o", actions.select_entry, {desc = "Open diff"}}, {"n", "q", "<Cmd>DiffviewClose<CR>", {desc = "Close diffview"}}, {"n", "?", actions.help("file_history_panel"), {desc = "Help"}}}, help_panel = {{"n", "q", actions.close, {desc = "Close help menu"}}, {"n", "<esc>", actions.close, {desc = "Close help menu"}}}}, hooks = {diff_buf_read = _11_, view_opened = _12_, view_closed = _13_}, diff_binaries = false, watch_index = false}
end
return {"dlyongemallo/diffview-plus.nvim", dev = true, dependencies = {"nvim-tree/nvim-web-devicons"}, cmd = {"DiffviewOpen", "DiffviewFileHistory"}, opts = _1_}
