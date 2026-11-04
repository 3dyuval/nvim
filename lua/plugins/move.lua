-- [nfnl] fnl/plugins/move.fnl
return {
  "fedepujol/move.nvim",
  keys = {
    { "<leader>wf", ":MoveWord(1)<CR>", mode = { "n" }, desc = "Move Word Forward" },
    { "<leader>wb", ":MoveWord(-1)<CR>", mode = { "n" }, desc = "Move Word Backward" },
  },
  opts = {
    line = { enable = true, indent = true },
    block = { enable = true, indent = true },
    word = { enable = true },
    char = { enable = true },
  },
}
