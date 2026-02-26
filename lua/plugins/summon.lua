return {
  "salkhalil/summon.nvim",
  cmd = "Summon",
  keys = {
    { "<leader>rs", "<cmd>Summon<cr>", desc = "Summon" },
  },
  opts = {
    width = 0.85,
    height = 0.85,
    border = "rounded",
    commands = {
      btop = { command = "btop", keymap = "<leader>rb" },
      lazydocker = { command = "lazydocker", keymap = "<leader>rd" },
    },
  },
}
