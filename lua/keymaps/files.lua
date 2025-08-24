local lil = require("lil")

lil.map({
  ["<leader>"] = {
    [" "] = function()
      require("fff").find_files()
    end,
  },
  ["<leader>f"] = {
    s = ":w<CR>", -- Save file
    S = function()
      vim.cmd("write")
      local file = vim.fn.expand("%:p")
      if file ~= "" then
        vim.fn.system("git add " .. vim.fn.shellescape(file))
        vim.notify("Saved and staged: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
      end
    end,
  },
})
