return {
  dir = "/home/yuval/snacks-dash",
  name = "snacks-dash",
  dev = true,
  dependencies = { "snacks.nvim", "octo.nvim" },
  init = function()
    -- Add plugin directory to runtimepath before requiring
    vim.opt.runtimepath:prepend("/home/yuval")
  end,
  config = function()
    local m = require("snacks-dash")

    m.setup({})
    vim.keymap.set("n", "<leader>gi", m.issues, { desc = "GitHub Issues" })
    vim.keymap.set("n", "<leader>gp", m.prs, { desc = "GitHub PRs" })
  end,
}
