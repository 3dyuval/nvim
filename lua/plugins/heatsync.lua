-- [nfnl] fnl/plugins/heatsync.fnl
local function _1_(item)
  vim.fn.setreg("+", item.date)
  return vim.notify(("Copied: " .. item.date))
end
return {"3dyuval/heatsync.nvim", dev = true, build = "make hooks server", dependencies = {"nvzone/volt", "nvzone/menu"}, opts = {actions = {{label = "Copy date", key = "y", action = _1_}}}, enabled = false}
