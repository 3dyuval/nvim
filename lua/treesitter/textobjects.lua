return function()
  local TS = require("nvim-treesitter-textobjects")
  TS.setup({
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]c"] = "@function.outer",
        ["]C"] = "@class.outer",
        ["]p"] = "@parameter.inner",
        ["]l"] = "@loop.*",
        ["]s"] = "@scope",
        ["]u"] = "@fold",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[c"] = "@function.outer",
        ["[C"] = "@class.outer",
        ["[p"] = "@parameter.inner",
        ["[l"] = "@loop.*",
        ["[s"] = "@scope",
        ["[u"] = "@fold",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
      },
    },
    select = {
      enable = true,
      keymaps = {
        ["rf"] = "@function.inner",
        ["tf"] = "@function.outer",
        ["rs"] = "@scope",
        ["rt"] = "@tag.inner",
        ["tt"] = "@tag.outer",
        ["te"] = "@jsx_self_closing_element",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["]P"] = "@parameter.inner",
        ["]F"] = "@function.outer",
      },
      swap_previous = {
        ["[A"] = "@parameter.inner",
        ["[F"] = "@function.outer",
      },
    },
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "NeogitRebaseTodo", "NeogitStatus", "NeogitCommitMessage" },
    callback = function()
    end,
  })
end
