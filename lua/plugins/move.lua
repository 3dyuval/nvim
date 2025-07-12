return {
  "fedepujol/move.nvim",
  keys = {
    -- Normal Mode (using Graphite layout: a=down, e=up)
    { "<M-a>", ":MoveLine(1)<CR>", desc = "Move Line Down" },
    { "<M-e>", ":MoveLine(-1)<CR>", desc = "Move Line Up" },
    { "<M-h>", ":MoveHChar(-1)<CR>", desc = "Move Character Left" },
    { "<M-i>", ":MoveHChar(1)<CR>", desc = "Move Character Right" },
    { "<leader>wf", ":MoveWord(1)<CR>", mode = { "n" }, desc = "Move Word Forward" },
    { "<leader>wb", ":MoveWord(-1)<CR>", mode = { "n" }, desc = "Move Word Backward" },
    -- Visual Mode
    { "<M-a>", ":MoveBlock(1)<CR>", mode = { "v" }, desc = "Move Block Down" },
    { "<M-e>", ":MoveBlock(-1)<CR>", mode = { "v" }, desc = "Move Block Up" },
    { "<M-h>", ":MoveHBlock(-1)<CR>", mode = { "v" }, desc = "Move Block Left" },
    { "<M-i>", ":MoveHBlock(1)<CR>", mode = { "v" }, desc = "Move Block Right" },
  },
  opts = {
    line = {
      enable = true,
      indent = true,
    },
    block = {
      enable = true,
      indent = true,
    },
    word = {
      enable = true,
    },
    char = {
      enable = true,
    },
  },
}
