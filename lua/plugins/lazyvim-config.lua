return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- Disable the default <leader>cr code action binding
      keys[#keys + 1] = { "<leader>cr", false }
    end,
  },
}
