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
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      "RRethy/nvim-treesitter-endwise",
    },
    init = function()
      vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
    end,
    config = function()
      vim.filetype.add({ extension = { ab = "amber", heex = "heex" } })

      local ensure_installed = {
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
        "tsx",
        "python",
        "bash",
        "json",
        "yaml",
        "toml",
        "elixir",
        "heex",
        "vue",
        "css",
        "scss",
        "html",
      }

      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })
      local installed = require("nvim-treesitter.config").get_installed("parsers")
      local lookup = {}
      for _, p in ipairs(installed) do
        lookup[p] = true
      end
      local to_install = {}
      for _, p in ipairs(ensure_installed) do
        if not lookup[p] then
          table.insert(to_install, p)
        end
      end
      if #to_install > 0 then
        require("nvim-treesitter").install(to_install)
      end

      local declined = {}
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
          if not lang or lang == "" then
            return
          end

          if not pcall(vim.treesitter.start, ev.buf, lang) then
            local cfg = require("nvim-treesitter.config")
            local installed = {}
            for _, p in ipairs(cfg.get_installed("parsers")) do
              installed[p] = true
            end
            if installed[lang] or declined[lang] then
              return
            end

            local available = {}
            for _, p in ipairs(cfg.get_available("parsers")) do
              available[p] = true
            end
            if not available[lang] then
              return
            end

            vim.schedule(function()
              vim.ui.select({ "Yes", "No" }, {
                prompt = "Install Tree-sitter parser '" .. lang .. "'?",
              }, function(choice)
                if choice == "Yes" then
                  require("nvim-treesitter").install({ lang }):await(function()
                    if vim.api.nvim_buf_is_valid(ev.buf) then
                      pcall(vim.treesitter.start, ev.buf, lang)
                    end
                  end)
                else
                  declined[lang] = true
                end
              end)
            end)
            return
          end

          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    enabled = true,
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
