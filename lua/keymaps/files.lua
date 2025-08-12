local lil = require("lil")
local extern, _ = lil.extern, lil._

lil.map({
  ["<leader>"] = {
    [" "] = function()
      require("fff").find_files()
    end,
  },
})
