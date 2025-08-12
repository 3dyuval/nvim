local lil = require("lil")
local extern, _ = lil.extern, lil._

local leader = lil.key "Leader"

lil.map({
  [leader + " "] = function()
    require("fff").find_files()
  end,
})