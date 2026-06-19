return {
  {
    "rafamadriz/friendly-snippets",
    lazy = true, -- installed but never loaded; paths resolved via search_paths
  },
  {
    "saghen/blink.cmp",
    enabled = true,
    dependencies = {
      "ribru17/blink-cmp-spell",
      "becknik/blink-cmp-luasnip-choice",
      "archie-judd/blink-cmp-words",
      { "saghen/blink.compat", version = "*", opts = {} },
    },

    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          sql = { "dadbod", "buffer" },
          markdown = { "lsp", "buffer", "spell", "thesaurus" },
          elixir = { "lsp", "buffer", "snippets" },
          mysql = { "dadbod", "buffer" },
          plsql = { "dadbod", "buffer" },
          -- Disable snippets for JS/TS/Vue (use LSP completions only)
          javascript = { "lsp", "path", "buffer" },
          javascriptreact = { "lsp", "path", "buffer" },
          typescript = { "lsp", "path", "snippets", "buffer" },
          typescriptreact = { "lsp", "path", "buffer" },
          vue = { "lsp", "path", "snippets", "buffer" }, -- custom snippets only (friendly-snippets disabled)
          html = { "lsp", "path", "buffer" },
          css = { "lsp", "path", "buffer" },
          scss = { "lsp", "path", "buffer" },
          json = { "lsp", "path", "buffer" },
          sh = { "curl", "jq", "yq", "lsp", "path", "snippets", "buffer" },
          bash = { "curl", "jq", "yq", "lsp", "path", "snippets", "buffer" },
          zsh = { "curl", "jq", "yq", "lsp", "path", "snippets", "buffer" },
          amber = { "curl", "jq", "yq", "lsp", "path", "buffer" },
          gitcommit = { "commitlint", "snippets", "buffer", "path" },
          AvanteInput = { "avante_commands", "avante_mentions", "avante_files", "avante_shortcuts" },
        },
        providers = {
          snippets = {
            opts = {
              friendly_snippets = false,
              search_paths = {
                vim.fn.stdpath("config") .. "/snippets",
                vim.fn.stdpath("data") .. "/lazy/friendly-snippets/snippets",
              },
              filter_snippets = function(filetype, file)
                if not file:find("friendly-snippets", 1, true) then
                  return true
                end
                local allowed = {
                  typescript = { "javascript/typescript.json", "javascript/tsdoc.json" },
                  elixir     = { "elixir.json" },
                  sh         = { "shell/shell.json" },
                  bash       = { "shell/shell.json" },
                  zsh        = { "shell/shell.json" },
                  fennel     = { "fennel.json" },
                  lua        = { "lua/lua.json", "lua/luadoc.json" },
                }
                local files = allowed[filetype]
                if not files then return false end
                for _, f in ipairs(files) do
                  if file:find(f, 1, true) then return true end
                end
                return false
              end,
            },
          },
          choice = {
            name = "LuaSnip Choice Nodes",
            module = "blink-cmp-luasnip-choice",
            opts = {},
          },
          lsp = {
            name = "lsp",
            enabled = true,
            module = "blink.cmp.sources.lsp",
            fallbacks = { "buffer" },
          },
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
          },
          curl = {
            name = "curl",
            module = "blink.sources.curl",
          },
          jq = {
            name = "jq",
            module = "blink.sources.jq",
          },
          yq = {
            -- Same module as jq: it self-gates on whether the cursor is in a
            -- `jq` or `yq` command and serves the matching completion set.
            name = "yq",
            module = "blink.sources.jq",
          },
          commitlint = {
            -- Conventional Commit types/scopes from `commitlint --print-config`,
            -- populated into buffer vars by the FileType gitcommit autocmd.
            name = "commitlint",
            module = "blink.sources.commitlint",
          },
          thesaurus = {
            name = "blink-cmp-words",
            module = "blink-cmp-words.thesaurus",
            opts = {
              score_offset = 0,
              definition_pointers = { "!", "&", "^" },
              similarity_pointers = { "&", "^" },
              similarity_depth = 2,
            },
          },
          dictionary = {
            name = "blink-cmp-words",
            module = "blink-cmp-words.dictionary",
            opts = {
              dictionary_search_threshold = 3,
              score_offset = 0,
              definition_pointers = { "!", "&", "^" },
            },
          },
          spell = {
            name = "Spell",
            module = "blink-cmp-spell",
            opts = {},
          },
          avante_commands = {
            name = "avante_commands",
            module = "blink.compat.source",
            score_offset = 90,
            opts = {},
          },
          avante_files = {
            name = "avante_files",
            module = "blink.compat.source",
            score_offset = 100,
            opts = {},
          },
          avante_mentions = {
            name = "avante_mentions",
            module = "blink.compat.source",
            score_offset = 1000,
            opts = {},
          },
          avante_shortcuts = {
            name = "avante_shortcuts",
            module = "blink.compat.source",
            score_offset = 1000,
            opts = {},
          },
        },
      },
      keymap = {
        preset = "default",
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        -- accept the highlighted item if the menu is open; otherwise advance to
        -- the next snippet tabstop (cl* commit skeletons); otherwise a newline.
        ["<CR>"] = { "accept", "snippet_forward", "fallback" },
        ["<C-CR>"] = { "fallback" },
      },
      cmdline = {
        enabled = true,
        keymap = {
          preset = "none",
          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<Tab>"] = { "accept", "fallback" },
          ["<C-e>"] = { "cancel", "fallback" },
          ["<C-p>"] = { "select_prev", "fallback" },
          ["<C-n>"] = { "select_next", "fallback" },
        },
        completion = {
          list = {
            selection = {
              preselect = true,
            },
          },
          menu = {
            auto_show = function(ctx)
              return vim.fn.getcmdtype() == ":"
            end,
          },
        },
      },
      completion = {
        trigger = {
          show_on_insert = true, -- Auto-show on insert enter
          prefetch_on_insert = true,
        },
        keyword = { range = "full" },
        accept = {
          auto_brackets = {
            enabled = true,
            default_brackets = { "(", ")" },
            kind_resolution = {
              enabled = true,
              blocked_filetypes = {
                "typescriptreact",
                "javascriptreact",
                "typescript",
                "javascript",
              },
            },
            semantic_token_resolution = {
              enabled = true,
              blocked_filetypes = {
                "typescriptreact",
                "javascriptreact",
                "typescript",
                "javascript",
              },
              timeout_ms = 400,
            },
          },
        },
      },
    },
  },
}
