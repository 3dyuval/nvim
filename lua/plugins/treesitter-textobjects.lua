return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  opts = {
    textobjects = {
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]c"] = "@class.outer",
          ["]a"] = "@parameter.inner",
          ["]o"] = "@loop.*",
          ["]s"] = "@scope",
          ["]z"] = "@fold",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[c"] = "@class.outer",
          ["[a"] = "@parameter.inner",
          ["[o"] = "@loop.*",
          ["[s"] = "@scope",
          ["[z"] = "@fold",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
      },
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          --     ["Tc"] = "@class.outer",
          --     ["Rc"] = "@class.inner",
          --     ["Tp"] = "@parameter.outer",
          --     ["Rp"] = "@parameter.inner",
          --     ["To"] = "@loop.outer",
          --     ["Ro"] = "@loop.inner",
          --     ["Ts"] = "@scope",
          --     ["Rs"] = "@scope",
          --     -- JSX/HTML elements
          --     ["Ty"] = "@element.outer",
          --     ["Ry"] = "@element.inner",
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
