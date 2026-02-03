-- Treesitter related configurations
-- Note: nvim-surround is now in lua/plugins/surround.lua
return {
  {
    "aaronik/treewalker.nvim",
    opts = {
      highlight = true,
      highlight_duration = 250,
      highlight_group = "CursorLine",
      jumplist = true,
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "RRethy/nvim-treesitter-endwise", -- Auto-insert 'end' in Ruby, Lua, etc.
    },
    init = function()
      -- Add parser directory to runtimepath before treesitter loads
      vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
    end,
    opts = function(_, opts)
      vim.filetype.add({ extension = { ab = "amber" } })

      opts.ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
        "go",
        "rust",
        "ruby",
        "javascript",
        "typescript",
        "python",
        "bash",
        "json",
        "yaml",
        "toml",
      }
      opts.auto_install = true
      opts.highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      }
      opts.indent = { enable = true }
      opts.endwise = { enable = true }
      opts.incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      }
    end,
  },
  {
    "amber-lang/tree-sitter-amber",
    build = function()
      local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
      vim.fn.mkdir(parser_dir, "p")
      local src = vim.fn.stdpath("data") .. "/lazy/tree-sitter-amber/src"
      vim.fn.system({
        "cc", "-shared", "-fPIC", "-o",
        parser_dir .. "/amber.so",
        "-I" .. src, src .. "/parser.c",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    config = function()
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
