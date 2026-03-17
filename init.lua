-- lazy.nvim resets packpath, so your pack/git/start/vim-fugitive never gets picked up. The
-- fix is to add performance.rtp.reset = false to your lazy setup - but that may break
-- lazy's own optimizations.(Fennel compiler, must load before lazy)
--
-- This wont work:
-- vim.opt.packpath:append(vim.fn.stdpath("config"))
--
--

local hotpot_path = vim.fn.stdpath("config") .. "/pack/hotpot/start/hotpot.nvim"
vim.opt.runtimepath:prepend(hotpot_path)
package.path = hotpot_path .. "/lua/?.lua;" .. hotpot_path .. "/lua/?/init.lua;" .. package.path
require("hotpot")
-- Plugins
require("config.lazy")
