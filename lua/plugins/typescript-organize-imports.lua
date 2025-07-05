return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
    },
    opts = {
      servers = {
        -- Keep vtsls enabled but add typescript.nvim for organize imports
        vtsls = {
          -- Keep existing vtsls config
        },
      },
      setup = {
        vtsls = function(_, opts)
          -- Keep existing vtsls setup
          LazyVim.lsp.on_attach(function(client, buffer)
            -- Add TypeScript organize imports command
            if client.name == "vtsls" then
              vim.keymap.set("n", "<leader>co", function()
                vim.cmd("TypescriptOrganizeImports")
              end, { buffer = buffer, desc = "Organize Imports" })
              
              vim.keymap.set("n", "<leader>cR", function()
                vim.cmd("TypescriptRenameFile")
              end, { buffer = buffer, desc = "Rename File" })
            end
          end, "vtsls")
          
          -- Setup typescript.nvim
          require("typescript").setup({
            server = opts,
          })
        end,
      },
    },
  },
}