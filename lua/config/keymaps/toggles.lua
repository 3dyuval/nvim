-- [nfnl] fnl/config/keymaps/toggles.fnl
local _local_1_ = require("config.keymaps.register")
local register = _local_1_.register
local lset = vim.keymap.set
register(
  "<leader>ug",
  {
    group = "Git Signs",
    g = { cmd = "<leader>uG", desc = "Toggle Git Signs" },
    l = { cmd = ":Gitsigns toggle_linehl<CR>", desc = "Toggle line highlights" },
    n = { cmd = ":Gitsigns toggle_numhl<CR>", desc = "Toggle number highlights" },
    w = { cmd = ":Gitsigns toggle_word_diff<CR>", desc = "Toggle word diff" },
    b = { cmd = ":Gitsigns toggle_current_line_blame<CR>", desc = "Toggle current line blame" },
  }
)
local function _2_()
  return require("lensline").toggle_view()
end
lset("n", "<leader>ul", _2_, { desc = "Toggle lensline" })
lset("n", "<leader>um", ":Neominimap Toggle<CR>", { desc = "Toggle minimap" })
local function _3_()
  return require("snacks").notifier.hide()
end
register(
  "<leader>un",
  {
    group = "Notifications",
    n = { cmd = _3_, desc = "Dismiss All Notifications" },
    a = { cmd = ":NoiceAll<CR>", desc = "Show all notifications" },
    l = { cmd = ":NoiceLast<CR>", desc = "Show last notification" },
  }
)
local function _4_()
  local messages = require("noice.message.manager").get({}, { history = true, sort = true })
  local last = messages[#messages]
  if last then
    vim.fn.setreg("+", last:content())
    return vim.notify("Copied to clipboard")
  else
    return nil
  end
end
return lset("n", "<leader>unp", _4_, { desc = "Copy last notification to clipboard" })
