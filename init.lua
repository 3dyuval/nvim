-- Hotpot (Fennel compiler, must load before lazy)
local hotpot_path = vim.fn.stdpath("config") .. "/pack/hotpot/start/hotpot.nvim"
vim.opt.runtimepath:prepend(hotpot_path)
package.path = hotpot_path .. "/lua/?.lua;" .. hotpot_path .. "/lua/?/init.lua;" .. package.path
require("hotpot")

-- Plugins
require("config.lazy")
