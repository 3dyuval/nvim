return {
  "bngarren/checkmate.nvim",
  ft = "markdown",
  opts = {
    files = {
      "*.md",
      "*.ts",
    },
    keys = {
      ["<leader>tr"] = { rhs = "<cmd>Checkmate toggle<CR>" },
      ["<leader>tn"] = { rhs = "<cmd>Checkmate create<CR>" },
      ["<leader>ta"] = { rhs = "<cmd>Checkmate archive<CR>" },
    },
  },
}
