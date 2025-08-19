local lil = require("lil")
local extern, _ = lil.extern, lil._

lil.map({
  ["<leader>"] = {
    [" "] = function()
      require("fff").find_files()
    end,
  },
  ["<leader>f"] = {
    s = ":w<CR>", -- Save file
    S = function()
      -- TODO: Replace with proper git stage keymap + save
      -- This should call whatever git stage keymap we have, then save
      -- For now, placeholder that does save + basic git add
      vim.cmd("write")
      local file = vim.fn.expand("%:p")
      if file ~= "" then
        vim.fn.system("git add " .. vim.fn.shellescape(file))
        vim.notify("Saved and staged: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
      end
    end,
  },
})
