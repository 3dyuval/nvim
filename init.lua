-- lazy.nvim resets packpath, so your pack/git/start/vim-fugitive never gets picked up. The
-- fix is to add performance.rtp.reset = false to your lazy setup - but that may break
-- lazy's own optimizations.(Fennel compiler, must load before lazy)
--
-- This wont work:
-- vim.opt.packpath:append(vim.fn.stdpath("config"))
--
--

local hotpot_path = vim.fn.stdpath("data") .. "/pack/start/hotpot.nvim"
if not vim.uv.fs_stat(hotpot_path) then
  vim.system({ "git", "clone", "--depth", "1", "https://github.com/rktjmp/hotpot.nvim", hotpot_path }):wait()
end
vim.opt.runtimepath:prepend(hotpot_path)
package.path = hotpot_path .. "/lua/?.lua;" .. hotpot_path .. "/lua/?/init.lua;" .. package.path
require("hotpot")
-- Plugins
require("config.lazy")
