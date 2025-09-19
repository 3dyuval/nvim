-- All treesitter related configurations in one place
return {
  -- Main treesitter configuration
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      -- Add parser directory to runtimepath before treesitter loads
      vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
    end,
    opts = {
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
  },

  -- Treesitter textobjects for advanced navigation
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    config = function()
      -- Class member navigation uses @function.outer which includes:
      -- - constructor, regular methods, static methods, getters, setters
      -- - This covers most class member navigation needs

      local TS = require("nvim-treesitter-textobjects")
      TS.setup({
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@function.outer", -- Navigate to next class member (includes all methods)
            ["]C"] = "@class.outer", -- Navigate to next class
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
            ["[c"] = "@function.outer", -- Navigate to previous class member (includes all methods)
            ["[C"] = "@class.outer", -- Navigate to previous class
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
            -- ["rc"] = "@class.inner",
            -- ["tc"] = "@class.outer",
            -- ["rp"] = "@parameter.inner",
            -- ["tp"] = "@parameter.outer",
            -- ["ro"] = "@loop.inner",
            -- ["to"] = "@loop.outer",
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
      -- Unmap the default [c and ]c mappings in Neogit buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "NeogitRebaseTodo", "NeogitStatus", "NeogitCommitMessage" },
        callback = function()
          -- Only unmap in Neogit buffers to preserve diff navigation elsewhere
          -- pcall(vim.keymap.del, { "n", "o", "x" }, "[c", { buffer = true })
          -- pcall(vim.keymap.del, { "n", "o", "x" }, "]c", { buffer = true })
        end,
      })
    end,
  },
}