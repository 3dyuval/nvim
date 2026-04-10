return {
  -- Disable friendly-snippets (use only custom snippets)
  {
    "rafamadriz/friendly-snippets",
    enabled = false
  }, {
  "saghen/blink.cmp",
  dependencies = {
    "ribru17/blink-cmp-spell",
    "becknik/blink-cmp-luasnip-choice",
    "archie-judd/blink-cmp-words"
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
        typescript = { "lsp", "path", "buffer" },
        typescriptreact = { "lsp", "path", "buffer" },
        vue = { "lsp", "path", "snippets", "buffer" }, -- custom snippets only (friendly-snippets disabled)
        html = { "lsp", "path", "buffer" },
        css = { "lsp", "path", "buffer" },
        scss = { "lsp", "path", "buffer" },
        json = { "lsp", "path", "buffer" },
        sh = { "curl", "jq", "lsp", "path", "buffer" },
        bash = { "curl", "jq", "lsp", "path", "buffer" },
        zsh = { "curl", "jq", "lsp", "path", "buffer" },
        amber = { "curl", "jq", "lsp", "path", "buffer" }
      },
      providers = {
        choice = {
          name = "LuaSnip Choice Nodes",
          module = "blink-cmp-luasnip-choice",
          opts = {}
        },
        lsp = {
          name = "lsp",
          enabled = true,
          module = "blink.cmp.sources.lsp",
          fallbacks = { "buffer" }
        },
        dadbod = {
          name = "Dadbod",
          module = "vim_dadbod_completion.blink"
        },
        curl = {
          name = "curl",
          module = "blink.sources.curl"
        },
        jq = {
          name = "jq",
          module = "blink.sources.jq"
        },
        thesaurus = {
          name = "blink-cmp-words",
          module = "blink-cmp-words.thesaurus",
          opts = {
            score_offset = 0,
            definition_pointers = { "!", "&", "^" },
            similarity_pointers = { "&", "^" },
            similarity_depth = 2
          }
        },
        dictionary = {
          name = "blink-cmp-words",
          module = "blink-cmp-words.dictionary",
          opts = {
            dictionary_search_threshold = 3,
            score_offset = 0,
            definition_pointers = { "!", "&", "^" }
          }
        },
        spell = {
          name = "Spell",
          module = "blink-cmp-spell",
          opts = {}
        }
      }
    },
    keymap = {
      preset = "default",
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-CR>"] = { "fallback" }
    },
    cmdline = {
      enabled = true,
      keymap = {
        preset = "none",
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<Tab>"] = { "accept", "fallback" },
        ["<C-e>"] = { "cancel", "fallback" }
      },
      completion = {
        list = {
          selection = {
            preselect = false
          }
        },
        menu = {
          auto_show = function(ctx) return vim.fn.getcmdtype() == ":" end


        }
      }
    },
    completion = {
      trigger = {
        show_on_insert = true, -- Auto-show on insert enter
        prefetch_on_insert = true
      },
      keyword = { range = "full" },
      accept = {
        auto_brackets = {
          enabled = true,
          default_brackets = { "(", ")" },
          kind_resolution = {
            enabled = true,
            blocked_filetypes = {
              "typescriptreact", "javascriptreact",
              "typescript", "javascript"
            }
          },
          semantic_token_resolution = {
            enabled = true,
            blocked_filetypes = {
              "typescriptreact", "javascriptreact",
              "typescript", "javascript"
            },
            timeout_ms = 400
          }
        }
      }
    }
  }
}
}
