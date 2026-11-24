-- [nfnl] fnl/workspace/folds.fnl
local function _1_()
  local function _2_()
    if (vim.wo.foldlevel < 99) and (vim.bo.filetype ~= "gitcommit") then
      vim.wo.foldlevel = 99
      return nil
    else
      return nil
    end
  end
  return vim.defer_fn(_2_, 100)
end
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "TabEnter" }, { callback = _1_ })
return {}
