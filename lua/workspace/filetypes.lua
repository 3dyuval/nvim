-- [nfnl] fnl/workspace/filetypes.fnl
local function set_ft(pattern, ft)
  return vim.api.nvim_create_autocmd(
    { "BufRead", "BufNewFile" },
    { pattern = pattern, command = ("set filetype=" .. ft) }
  )
end
set_ft({ "Fastfile", "Appfile", "Matchfile", "Pluginfile" }, "ruby")
set_ft({ "*.ex", "*.exs" }, "elixir")
set_ft({ "*.heex" }, "heex")
set_ft({ "*.log" }, "log")
local function _1_()
  if string.match((vim.fn.getline(1) or ""), "^#!.*env zsh") then
    vim.bo.filetype = "zsh"
    return nil
  else
    return nil
  end
end
vim.api.nvim_create_autocmd("BufReadPost", { callback = _1_ })
return {}
