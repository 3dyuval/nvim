-- [nfnl] fnl/workspace/kitty-padding.fnl
local function _1_()
  if vim.env.KITTY_WINDOW_ID and vim.env.KITTY_LISTEN_ON then
    return vim.fn.system(
      string.format(
        "kitten @ --to %s set-spacing --match id:%s padding=0",
        vim.env.KITTY_LISTEN_ON,
        vim.env.KITTY_WINDOW_ID
      )
    )
  else
    return nil
  end
end
vim.defer_fn(_1_, 100)
local function _3_()
  if vim.env.KITTY_WINDOW_ID and vim.env.KITTY_LISTEN_ON then
    return vim.fn.system(
      string.format(
        "kitten @ --to %s set-spacing --match id:%s padding=12",
        vim.env.KITTY_LISTEN_ON,
        vim.env.KITTY_WINDOW_ID
      )
    )
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("VimLeavePre", { callback = _3_ })
return {}
