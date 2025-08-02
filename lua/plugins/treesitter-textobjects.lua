return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  opts = {
    textobjects = {
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]C"] = "@class.outer",
          ["]a"] = "@parameter.inner",
          ["]o"] = "@loop.*",
          ["]s"] = "@scope",
          ["]z"] = "@fold",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          -- ["[]"] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[C"] = "@class.outer",
          ["[a"] = "@parameter.inner",
          ["[o"] = "@loop.*",
          ["[s"] = "@scope",
          ["[z"] = "@fold",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          -- ["]["] = "@class.outer",
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
          ["ts"] = "@scope",
          -- JSX/HTML elements
          ["ry"] = "@element.inner",
          ["ty"] = "@element.outer",
          ["rt"] = "@tag.inner",
          ["tt"] = "@tag.outer",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["]A"] = "@parameter.inner",
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
