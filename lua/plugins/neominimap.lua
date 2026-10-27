-- [nfnl] fnl/plugins/neominimap.fnl
local function _1_()
  vim.opt.wrap = false
  vim.opt.sidescrolloff = 36
  vim.g.neominimap = {auto_enable = true, layout = "float", float = {minimap_width = 10, max_minimap_height = 12, window_border = "rounded", margin = {right = 1, top = 1}}}
  return nil
end
return {"Isrothy/neominimap.nvim", version = "v3.*.*", init = _1_, lazy = false}
