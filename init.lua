-- nfnl handles Fennel compilation via ftplugin (no bootstrap needed)
-- It activates when you open .fnl files and compiles them to .lua on save
-- Plugins
require("config.lazy")
vim.secure.trust({ action = "allow", path = vim.fn.stdpath("config") .. "/.nfnl.fnl" })
