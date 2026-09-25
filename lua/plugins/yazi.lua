-- [nfnl] fnl/plugins/yazi.fnl
local function _1_()
  vim.g.loaded_netrwPlugin = 1
  return nil
end
return {"mikavilpas/yazi.nvim", dependencies = {{"nvim-lua/plenary.nvim", lazy = true}}, event = "VeryLazy", keys = {{"<leader>-", "<cmd>Yazi<cr>", mode = {"n", "v"}, desc = "Yazi at current file"}, {"<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Yazi in working dir"}}, opts = {open_for_directories = true, change_neovim_cwd_on_close = true, floating_window_scaling_factor = 0.9, keymaps = {show_help = "<f1>"}, integrations = {grep_in_directory = "snacks.picker", grep_in_selected_files = "snacks.picker"}}, init = _1_}
