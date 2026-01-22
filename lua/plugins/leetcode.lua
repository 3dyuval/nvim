return {
  "kawre/leetcode.nvim",
  cmd = "Leet",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  init = function()
    -- Auto-copy cookie from ~/.config/leetcode.cookie to cache dir
    local src = vim.fn.expand("~/.config/leetcode.cookie")
    local dst_dir = vim.fn.stdpath("cache") .. "/leetcode"
    local dst = dst_dir .. "/cookie"

    if vim.fn.filereadable(src) == 1 then
      local content = vim.fn.readfile(src)
      if content[1] and #content[1] > 0 then
        vim.fn.mkdir(dst_dir, "p")
        vim.fn.writefile(content, dst)
      end
    end
  end,
  opts = {
    lang = "javascript",
    picker = { provider = "snacks-picker" },
  },
}
