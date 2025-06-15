return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- Ensure JSX/TSX parsers are installed
    opts.ensure_installed = opts.ensure_installed or {}
    vim.list_extend(opts.ensure_installed, {
      "javascript",
      "typescript", 
      "tsx",
      "html",
      "css"
    })
    
    -- Enable autotag integration (Takuya's way)
    opts.autotag = {
      enable = true,
    }
    
    return opts
  end,
}