return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  opts = {
    textobjects = {
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]f"] = "@function.outer",
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
          ["rc"] = "@class.inner",
          ["tc"] = "@class.outer",
          ["rp"] = "@parameter.inner",
          ["tp"] = "@parameter.outer",
          ["ro"] = "@loop.inner",
          ["to"] = "@loop.outer",
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
    },
  },
}
