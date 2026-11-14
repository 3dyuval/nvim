-- [nfnl] fnl/workspace/lsp-autosave.fnl
do
  local orig = vim.lsp.util.apply_workspace_edit
  local function _1_(workspace_edit, offset_encoding)
    local pre_loaded = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        pre_loaded[bufnr] = true
      else
      end
    end
    local result = orig(workspace_edit, offset_encoding)
    local function _3_()
      local to_save = {}
      local to_cleanup = {}
      local function process_uri(uri)
        local bufnr = vim.uri_to_bufnr(uri)
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified then
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
          if change.textDocument and change.textDocument.uri then
            process_uri(change.textDocument.uri)
          else
          end
        end
      else
      end
      local saved_eventignore = vim.o.eventignore
      vim.o.eventignore = "all"
      for bufnr, _ in pairs(to_save) do
        local function _9_()
          return vim.cmd("silent! noautocmd write")
        end
        vim.api.nvim_buf_call(bufnr, _9_)
      end
      for bufnr, _ in pairs(to_cleanup) do
        local function _10_()
          return vim.cmd("silent! noautocmd write")
        end
        vim.api.nvim_buf_call(bufnr, _10_)
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
      vim.o.eventignore = saved_eventignore
      return vim.cmd("redraw")
    end
    vim.schedule(_3_)
    return result
  end
  vim.lsp.util.apply_workspace_edit = _1_
end
return {}
