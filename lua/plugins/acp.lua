return {
  "3dyuval/acp.nvim",
  dev = true,
  enabled = false,
  dependencies = { "nvim-lua/plenary.nvim", "paulburgess1357/nvim-mcp" },
  config = function()
    require("acp").config({
      agents = {
        opencode = {
          cmd = { "opencode", "acp" },
          mcp = { "nvim" },
        },
      },
      default_agent = "opencode",
      mcp = {
        nvim = {
          cmd = { "uvx", "nvim-mcp" },
          env = { NVIM_SOCKET_PATH = vim.v.servername },
        },
      },
    })
  end,
}
