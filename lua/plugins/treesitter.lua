-- All treesitter related configurations in one place
return {
  {
    "kylechui/nvim-surround",
    version = "^3.0.0",
    event = "VeryLazy",
    config = function()
      local surround = require("utils.surround")
      require("nvim-surround").setup(surround.opts)

      -- Disable nvim-surround for non-modifiable and special buffers
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        pattern = "*",
        callback = function()
          local bufname = vim.api.nvim_buf_get_name(0)
          local should_disable = not vim.bo.modifiable
            or vim.bo.buftype ~= ""
            or bufname:match("^diffview://")
            or (bufname:match("^git://") and not bufname:match("^neogit://"))
            or bufname == ""

          if should_disable then
            -- Unmap nvim-surround keymaps for this buffer
            local keymaps_to_disable = { "s", "S", "ks", "kss", "kS", "kSS", "xs", "ws", "cS" }
            for _, key in ipairs(keymaps_to_disable) do
              pcall(vim.keymap.del, "v", key, { buffer = 0 })
              pcall(vim.keymap.del, "n", key, { buffer = 0 })
            end
          end
        end,
      })
    end,
  },
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
