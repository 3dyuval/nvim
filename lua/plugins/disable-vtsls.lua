-- Explicitly disable vtsls to prevent conflicts with typescript-tools
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable vtsls explicitly
        vtsls = false,
        -- Also disable ts_ls if it's configured
        ts_ls = false,
        tsserver = false,
      },
    },
  },
}