return {
  "cbochs/grapple.nvim",
  opts = {
    scope = "git", -- also try out "git_branch"
    statusline = {
      icon = "",
    },
    win_opts = {
      width = 80,
      height = 12,
      row = 0.5,
      col = 0.5,
      relative = "editor",
      border = "rounded",
      style = "minimal",
      title = " Grapple ",
      title_pos = "center",
      footer_pos = "center",
    },
  },
  event = { "BufReadPost", "BufNewFile" },
  cmd = "Grapple",
  keys = {
    -- { "<C-G>", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
    { "<C-;>", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
    { "<leader><", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
    { "<leader>>", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
  },
}
