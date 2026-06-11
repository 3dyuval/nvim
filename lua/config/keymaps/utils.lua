-- [nfnl] fnl/config/keymaps/utils.fnl
local lset = vim.keymap.set
lset("n", "<leader>gs", ":DiffviewOpen %", {desc = "File DiffviewOpen history", noremap = true})
local function _1_()
  return require("hover").open()
end
return lset("n", "P", _1_, {desc = "Hover"})
