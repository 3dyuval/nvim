return {
  "mattn/emmet-vim",
  ft = { "html", "css", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
  config = function()
    -- Use standard Ctrl+y, key binding (community convention)
    vim.g.user_emmet_leader_key = "<C-y>"
    vim.g.user_emmet_mode = "i"
    
    -- Enable emmet for JSX/TSX
    vim.g.user_emmet_settings = {
      javascript = {
        extends = "jsx",
      },
      typescript = {
        extends = "jsx",
      },
    }
  end,
}