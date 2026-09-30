-- [nfnl] fnl/plugins/platformio.fnl
local function _1_()
  vim.g.pioConfig = { picker_backend = "snacks", menu_key = "<leader>\\", debug = false, lsp = false }
  local ok, platformio = pcall(require, "platformio")
  if ok then
    return platformio.setup(vim.g.pioConfig)
  else
    return nil
  end
end
return {
  "anurag3301/nvim-platformio.lua",
  dependencies = { "akinsho/toggleterm.nvim" },
  cmd = { "Pioinit", "Piorun", "Piocmdf", "Piocmdh", "Piolib", "Piomon", "Piodebug", "PioTermList", "PioLSP" },
  config = _1_,
}
