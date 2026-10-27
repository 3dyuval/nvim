-- [nfnl] fnl/plugins/harpoon.fnl
local function add()
  local h = require("harpoon")
  return h:list():add()
end
local function menu()
  local h = require("harpoon")
  return h.ui:toggle_quick_menu(h:list())
end
local function jump(n)
  local function _1_()
    local h = require("harpoon")
    return h:list():select(n)
  end
  return _1_
end
local function _2_()
  return require("harpoon").setup({})
end
return {"ThePrimeagen/harpoon", branch = "harpoon2", dependencies = {"nvim-lua/plenary.nvim"}, keys = {{"<leader>ha", add, desc = "Harpoon: add file"}, {"<leader>he", menu, desc = "Harpoon: menu"}, {"<leader>h1", jump(1), desc = "Harpoon: file 1"}, {"<leader>h2", jump(2), desc = "Harpoon: file 2"}, {"<leader>h3", jump(3), desc = "Harpoon: file 3"}, {"<leader>h4", jump(4), desc = "Harpoon: file 4"}}, config = _2_}
