-- [nfnl] fnl/workspace/tailwind.fnl
local function _1_()
  if not vim.b.tailwind_checked then
    vim.b.tailwind_checked = true
    local found = false
    for _, cfg in ipairs({ "tailwind.config.js", "tailwind.config.ts", "tailwind.config.cjs", "tailwind.config.mjs" }) do
      if found then
        break
      end
      if vim.fn.filereadable(cfg) == 1 then
        local function _2_()
          return vim.cmd("LspStart tailwindcss")
        end
        vim.defer_fn(_2_, 200)
        found = true
      else
      end
    end
    return nil
  else
    return nil
  end
end
vim.api.nvim_create_autocmd(
  { "BufEnter", "BufWinEnter" },
  { pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" }, callback = _1_ }
)
return {}
