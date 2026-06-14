-- [nfnl] fnl/config/autocmds.fnl
do
  local ai_popup = require("utils.ai_popup")
  local function _1_(opts)
    if ((opts.args == "--preview") or (opts.args == "-p")) then
      return ai_popup.run_generate((vim.g.AiCommitLastSettings or {}))
    elseif ((opts.args == "--repeat") or (opts.args == "-r")) then
      return ai_popup.repeat_last()
    else
      return ai_popup.create()
    end
  end
  vim.api.nvim_create_user_command("AiCommit", _1_, {nargs = "?", desc = "AI commit popup"})
end
local function _3_(opts)
  return require("utils.buffers").create_buffer_bug((opts.args or "X"))
end
vim.api.nvim_create_user_command("BugTemplate", _3_, {nargs = "?"})
local function _4_(opts)
  return require("utils.buffers").create_buffer_bug_snippet((opts.args or "X"))
end
vim.api.nvim_create_user_command("BugSnippet", _4_, {nargs = "?"})
do
  local orig = vim.lsp.util.apply_workspace_edit
  local function _5_(workspace_edit, offset_encoding)
    local pre_loaded = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        pre_loaded[bufnr] = true
      else
      end
    end
    local result = orig(workspace_edit, offset_encoding)
    local function _7_()
      local to_save = {}
      local to_cleanup = {}
      local function process_uri(uri)
        local bufnr = vim.uri_to_bufnr(uri)
        if (vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified) then
          if pre_loaded[bufnr] then
            to_save[bufnr] = true
            return nil
          else
            to_cleanup[bufnr] = uri
            return nil
          end
        else
          return nil
        end
      end
      if workspace_edit.changes then
        for uri, _ in pairs(workspace_edit.changes) do
          process_uri(uri)
        end
      else
      end
      if workspace_edit.documentChanges then
        for _, change in ipairs(workspace_edit.documentChanges) do
          if (change.textDocument and change.textDocument.uri) then
            process_uri(change.textDocument.uri)
          else
          end
        end
      else
      end
      local saved_eventignore = vim.o.eventignore
      vim.o.eventignore = "all"
      for bufnr, _ in pairs(to_save) do
        local function _13_()
          return vim.cmd("silent! noautocmd write")
        end
        vim.api.nvim_buf_call(bufnr, _13_)
      end
      for bufnr, _ in pairs(to_cleanup) do
        local function _14_()
          return vim.cmd("silent! noautocmd write")
        end
        vim.api.nvim_buf_call(bufnr, _14_)
        vim.api.nvim_buf_delete(bufnr, {force = true})
      end
      vim.o.eventignore = saved_eventignore
      return vim.cmd("redraw")
    end
    vim.schedule(_7_)
    return result
  end
  vim.lsp.util.apply_workspace_edit = _5_
end
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {command = "set filetype=ruby", pattern = {"Fastfile", "Appfile", "Matchfile", "Pluginfile"}})
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {command = "set filetype=elixir", pattern = {"*.ex", "*.exs"}})
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {command = "set filetype=heex", pattern = {"*.heex"}})
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {command = "set filetype=log", pattern = {"*.log"}})
local function _15_()
  if string.match((vim.fn.getline(1) or ""), "^#!.*env zsh") then
    vim.bo.filetype = "zsh"
    return nil
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("BufReadPost", {callback = _15_})
local function _17_(args)
  local mark = vim.api.nvim_buf_get_mark(args.buf, "\"")
  local lines = vim.api.nvim_buf_line_count(args.buf)
  if ((mark[1] > 0) and (mark[1] <= lines)) then
    local function _18_()
      return vim.cmd("normal! g`\"zz")
    end
    return vim.api.nvim_buf_call(args.buf, _18_)
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("BufReadPost", {callback = _17_})
local function _20_()
  vim.opt_local.swapfile = false
  return nil
end
vim.api.nvim_create_autocmd("FileType", {pattern = {"snacks_win", "snacks_picker", "snacks_explorer"}, callback = _20_})
local function _21_()
  vim.opt_local.swapfile = false
  vim.opt_local.undofile = false
  vim.opt_local.backup = false
  vim.opt_local.writebackup = false
  return nil
end
vim.api.nvim_create_autocmd("BufReadPre", {pattern = {(vim.fn.expand("~") .. "/mnt/*"), (vim.fn.expand("~") .. "/.sshfs/*")}, callback = _21_})
local function _22_()
  local function _23_()
    if (vim.wo.foldlevel < 99) then
      vim.wo.foldlevel = 99
      return nil
    else
      return nil
    end
  end
  return vim.defer_fn(_23_, 100)
end
vim.api.nvim_create_autocmd({"BufWinEnter", "WinEnter", "TabEnter"}, {callback = _22_})
local function _25_()
  if not vim.b.tailwind_checked then
    vim.b.tailwind_checked = true
    local found = false
    for _, cfg in ipairs({"tailwind.config.js", "tailwind.config.ts", "tailwind.config.cjs", "tailwind.config.mjs"}) do
      if found then break end
      if (vim.fn.filereadable(cfg) == 1) then
        local function _26_()
          return vim.cmd("LspStart tailwindcss")
        end
        vim.defer_fn(_26_, 200)
        found = true
      else
      end
    end
    return nil
  else
    return nil
  end
end
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {pattern = {"*.ts", "*.tsx", "*.js", "*.jsx"}, callback = _25_})
local function _29_()
  if (vim.env.KITTY_WINDOW_ID and vim.env.KITTY_LISTEN_ON) then
    return vim.fn.system(string.format("kitten @ --to %s set-spacing --match id:%s padding=0", vim.env.KITTY_LISTEN_ON, vim.env.KITTY_WINDOW_ID))
  else
    return nil
  end
end
vim.defer_fn(_29_, 100)
local function _31_()
  if (vim.env.KITTY_WINDOW_ID and vim.env.KITTY_LISTEN_ON) then
    return vim.fn.system(string.format("kitten @ --to %s set-spacing --match id:%s padding=12", vim.env.KITTY_LISTEN_ON, vim.env.KITTY_WINDOW_ID))
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("VimLeavePre", {callback = _31_})
local function _33_()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].claudecode_diff_tab_name then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local wbuf = vim.api.nvim_win_get_buf(win)
      if ((vim.bo[wbuf].buftype == "terminal") and string.match(vim.api.nvim_buf_get_name(wbuf), "claude")) then
        pcall(vim.api.nvim_win_close, win, false)
        return
      else
      end
    end
    return nil
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("BufWinEnter", {callback = _33_})
local function _36_()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if (name:match("claude") and (vim.bo[buf].buftype == "terminal")) then
      vim.api.nvim_set_current_win(win)
      vim.cmd("startinsert")
      return
    else
    end
  end
  return nil
end
vim.api.nvim_create_autocmd("FocusGained", {callback = _36_})
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
return vim.opt.shortmess:append("F")
