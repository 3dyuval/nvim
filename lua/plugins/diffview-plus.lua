-- [nfnl] fnl/plugins/diffview-plus.fnl
local function _1_()
  local actions = require("diffview.actions")
  local in_diff_window
  local function _2_(f)
    local function _3_()
      if vim.wo.winfixbuf then
        local view = require("diffview.lib").get_current_view()
        if (view and view.cur_layout) then
          local main = view.cur_layout:get_main_win()
          if (main and main.id and vim.api.nvim_win_is_valid(main.id)) then
            vim.api.nvim_set_current_win(main.id)
          else
          end
        else
        end
      else
      end
      return f()
    end
    return _3_
  end
  in_diff_window = _2_
  local next_hunk
  local function _7_()
    if (vim.fn.search("^<<<<<<< ", "nw") ~= 0) then
      return actions.next_conflict()
    else
      return vim.cmd("normal! ]c")
    end
  end
  next_hunk = _7_
  local prev_hunk
  local function _9_()
    if (vim.fn.search("^<<<<<<< ", "nw") ~= 0) then
      return actions.prev_conflict()
    else
      return vim.cmd("normal! [c")
    end
  end
  prev_hunk = _9_
  local win_down
  local function _11_()
    return require("smart-splits").move_cursor_down()
  end
  win_down = _11_
  local win_up
  local function _12_()
    return require("smart-splits").move_cursor_up()
  end
  win_up = _12_
  local function _13_()
    if (vim.fn.search("^<<<<<<< ", "nw") ~= 0) then
      return actions.conflict_choose("theirs")
    else
      return vim.cmd("diffget")
    end
  end
  local function _15_()
    if (vim.fn.search("^<<<<<<< ", "nw") ~= 0) then
      return actions.conflict_choose("ours")
    else
      return vim.cmd("diffput")
    end
  end
  local function _17_()
    return actions.toggle_stage_entry()
  end
  local function _18_(bufnr)
    vim.opt_local.foldenable = false
    vim.b[bufnr]["snacks_indent"] = false
    vim.b[bufnr]["snacks_scope"] = false
    return nil
  end
  local function _19_()
    vim.g.diffview_active = true
    return nil
  end
  local function _20_()
    vim.g.diffview_active = false
    return nil
  end
  return {enhanced_diff_hl = true, use_icons = true, show_help_hints = true, default_args = {DiffviewOpen = {"--imply-local"}, DiffviewFileHistory = {}}, view = {default = {layout = "diff2_horizontal", winbar_info = true, win_config = {position = "bottom"}}, merge_tool = {layout = "diff1_plain", winbar_info = true, disable_diagnostics = false}, file_history = {layout = "diff2_horizontal", winbar_info = true, win_config = {position = "bottom"}}}, file_panel = {listing_style = "tree", tree_options = {folder_statuses = "only_folded", flatten_dirs = false}}, keymaps = {disable_defaults = true, view = {{"n", "<C-M-S-Down>", _13_, {desc = "Take THEIRS (get)"}}, {"n", "<C-M-S-Up>", _15_, {desc = "Take OURS (put)"}}, {"n", "dp", "<Cmd>diffput<CR>", {desc = "Put hunk to other (OURS)"}}, {"n", "<C-A>", win_down, {desc = "Window down"}}, {"n", "<C-E>", win_up, {desc = "Window up"}}, {"n", "<C-Down>", next_hunk, {desc = "Next conflict or hunk"}}, {"n", "<C-Up>", prev_hunk, {desc = "Prev conflict or hunk"}}, {"n", "<S-A>", actions.select_next_entry, {desc = "Next file"}}, {"n", "<S-E>", actions.select_prev_entry, {desc = "Previous file"}}, {"n", "<S-Esc>", actions.toggle_files, {desc = "Toggle files list panel"}}, {"n", "<leader>.", actions.cycle_layout, {desc = "Cycle layout"}}, {"n", "q", actions.close, {desc = "Close diffview"}}, {"n", "gf", actions.goto_file_edit, {desc = "Go to file"}}, {"n", "<C-s>", actions.stage_all, {desc = "Stage all"}}, {"n", "?", actions.help("view"), {desc = "Help"}}}, diff1_inline = {{"n", "<C-A>", win_down, {desc = "Window down"}}, {"n", "<C-E>", win_up, {desc = "Window up"}}, {"n", "<C-Down>", actions.next_inline_hunk, {desc = "Next inline hunk"}}, {"n", "<C-Up>", actions.prev_inline_hunk, {desc = "Prev inline hunk"}}}, file_panel = {{"n", "<S-A>", actions.select_next_entry, {desc = "Next file"}}, {"n", "<S-E>", actions.select_prev_entry, {desc = "Previous file"}}, {"n", "<C-A>", win_down, {desc = "Window down"}}, {"n", "<C-E>", win_up, {desc = "Window up"}}, {"n", "<C-Down>", in_diff_window(next_hunk), {desc = "Next conflict or hunk"}}, {"n", "<C-Up>", in_diff_window(prev_hunk), {desc = "Prev conflict or hunk"}}, {"n", "<S-Esc>", actions.toggle_files, {desc = "Toggle files list panel"}}, {"n", "dr", actions.restore_entry, {desc = "Restore file"}}, {"n", "dl", _17_, {desc = "Stage file"}}, {"n", "<C-R>", actions.refresh_files, {desc = "Refresh files"}}, {"n", "<cr>", actions.select_entry, {desc = "Open diff"}}, {"n", "o", actions.select_entry, {desc = "Open diff"}}, {"n", "q", "<Cmd>DiffviewClose<CR>", {desc = "Close diffview"}}, {"n", "?", actions.help("file_panel"), {desc = "Help"}}}, file_history_panel = {{"n", "<S-A>", actions.select_next_entry, {desc = "Next file"}}, {"n", "<S-E>", actions.select_prev_entry, {desc = "Previous file"}}, {"n", "<C-S-A>", actions.select_next_commit, {desc = "Next commit"}}, {"n", "<C-S-E>", actions.select_prev_commit, {desc = "Prev commit"}}, {"n", "<C-A>", win_down, {desc = "Window down"}}, {"n", "<C-E>", win_up, {desc = "Window up"}}, {"n", "<C-Down>", in_diff_window(next_hunk), {desc = "Next conflict or hunk"}}, {"n", "<C-Up>", in_diff_window(prev_hunk), {desc = "Prev conflict or hunk"}}, {"n", "<S-Esc>", actions.toggle_files, {desc = "Toggle files list panel"}}, {"n", "<cr>", actions.select_entry, {desc = "Open diff"}}, {"n", "o", actions.select_entry, {desc = "Open diff"}}, {"n", "q", "<Cmd>DiffviewClose<CR>", {desc = "Close diffview"}}, {"n", "?", actions.help("file_history_panel"), {desc = "Help"}}}, help_panel = {{"n", "q", actions.close, {desc = "Close help menu"}}, {"n", "<esc>", actions.close, {desc = "Close help menu"}}}}, hooks = {diff_buf_read = _18_, view_opened = _19_, view_closed = _20_}, diff_binaries = false, watch_index = false}
end
return {"dlyongemallo/diffview-plus.nvim", dependencies = {"nvim-tree/nvim-web-devicons"}, cmd = {"DiffviewOpen", "DiffviewFileHistory", "DiffviewDiffFiles", "DiffviewDiffDirs"}, opts = _1_, dev = false}
