return {
  {
    "Cannon07/code-preview.nvim",
    enabled = false,
    config = function()
      require("code-preview").setup(
        {
          debug = false, -- enable debug logging to stdpath("log")/code-preview.log
          diff = {
            layout = "tab", -- "tab" (new tab) | "vsplit" (current tab) | "inline" (GitHub-style)
            labels = {current = "CURRENT", proposed = "PROPOSED"},
            equalize = true, -- 50/50 split widths (tab/vsplit only)
            full_file = true, -- show full file, not just diff hunks (tab/vsplit only)
            visible_only = false, -- skip diffs for files not open in any Neovim buffer
            defer_claude_permissions = false -- for Claude Code: let its own settings decide, don't prompt
          },
          highlights = {
            current = {
              -- CURRENT (original) side - tab/vsplit layouts
              DiffAdd = {bg = "#4c2e2e"},
              DiffDelete = {bg = "#4c2e2e"},
              DiffChange = {bg = "#4c3a2e"},
              DiffText = {bg = "#5c3030"}
            },
            proposed = {
              -- PROPOSED side - tab/vsplit layouts
              DiffAdd = {bg = "#2e4c2e"},
              DiffDelete = {bg = "#4c2e2e"},
              DiffChange = {bg = "#2e3c4c"},
              DiffText = {bg = "#3e5c3e"}
            },
            inline = {
              -- inline layout
              added = {bg = "#2e4c2e"}, -- added line background
              removed = {bg = "#4c2e2e"}, -- removed line background
              added_text = {bg = "#3a6e3a"}, -- changed characters (added)
              removed_text = {bg = "#6e3a3a"} -- changed characters (removed)
            }
          }
        }
      )
    end
  },
  {
    "coder/claudecode.nvim",
    enabled = true,
    config = function()
      require("claudecode").setup(
        {
          terminal = {
            snacks_win_opts = {
              position = "float",
              width = 0.95,
              height = 0.88,
              border = "rounded",
              backdrop = false,
              keys = {
                toggle = {"<C-Space>", function(self)
                    self:hide()
                  end, mode = "t", desc = "Toggle Claude"}
              }
            }
          }
        }
      )

      -- Open Claude Code panel when a diff opens (only if not already open)
      vim.api.nvim_create_autocmd(
        "User",
        {
          pattern = "ClaudeCodeDiffOpened",
          callback = function()
            local terminal = require("claudecode.terminal")
            local active_bufnr = terminal.get_active_terminal_bufnr and terminal.get_active_terminal_bufnr()
            if active_bufnr then
              local bufinfo = vim.fn.getbufinfo(active_bufnr)[1]
              local is_visible = bufinfo and #bufinfo.windows > 0
              if is_visible then
                return  -- Already open
              end
            end
            vim.cmd("ClaudeCode")
          end
        }
      )
      -- Hide Claude Code panel when a diff is accepted
      vim.api.nvim_create_autocmd(
        "User",
        {
          pattern = "ClaudeCodeDiffAccepted",
          callback = function()
            -- Get the snacks terminal and call hide
            local snacks = require("snacks")
            if snacks.terminal then
              local term = snacks.terminal:get()
              if term then
                term:hide()
              end
            end
          end
        }
      )
    end
  },
  {
    name = "run-ai.run",
    dir = "/home/yuv/proj/run-ai.run.nvim",
    enabled = false,
    cmd = {"LlmReplace"},
    dependencies = {
      "3dyuval/colortweak.nvim",
      "nvim-lua/plenary.nvim",
      "folke/noice.nvim",
      "olimorris/codecompanion.nvim"
    },
    opts = {
      skills_path = "/home/yuv/.config/nvim/.claude/skills",
      log_level = "debug",
      notify_level = "warn", -- nil = off, "debug"/"info"/"warn"/"error" = show in noice
      highlights = {
        normal = "ClaudeNormal",
        thinking = "ClaudeThinking"
      }
    },
    config = function(_, opts)
      local tweak = require("colortweak.tweak")

      tweak.hl(
        {
          ClaudeNormal = {"DiagnosticInfo", {h = -5, s = 1}},
          ClaudeThinking = {"DiagnosticHint", {h = 15, s = 1.5}}
        }
      )

      opts.providers = {
        {
          name = "theyuval",
          base_url = "https://api.theyuval.com/ai/v1",
          model_prefixes = {"theyuval/"},
          auth_header = "Bearer"
        }
      }

      opts.liter = {
        api_key = os.getenv("API_KEY"),
        model = "theyuval/qwen3.5-9b:instruct"
      }

      require("run-ai-run").setup(opts)
    end
  },
  {
    enabled = false,
    dir = "/home/yuv/proj/test",
    name = "interview-timer",
    lazy = false,
    dependencies = {"ravsii/timers.nvim"},
    config = function()
      require("timers").setup({})
      require("interview-timer").setup(
        {
          ["time-limit-min"] = 20,
          provider = "claude-acp",
          ["acp-providers"] = {
            ["claude-acp"] = {
              command = "/home/yuv/.nvm/versions/node/v20.19.6/bin/claude-code-acp"
            }
          }
        }
      )
    end
  },
  {
    "yetone/avante.nvim",
    enabled = false,
    version = false,
    build = "make",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "stevearc/dressing.nvim",
      "nvim-tree/nvim-web-devicons",
      "MeanderingProgrammer/render-markdown.nvim"
    },
    opts = {
      provider = "opencode",
      mode = "agentic",
      behaviour = {
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        minimize_diff = true,
        enable_token_counting = true,
        auto_add_current_file = true,
        auto_approve_tool_permissions = true
      },
      acp_providers = {
        ["opencode"] = {
          command = "opencode",
          args = {"acp"},
          env = {
            API_KEY = os.getenv("API_KEY"),
            TAVILY_API_KEY = os.getenv("TAVILY_API_KEY")
          }
        },
        ["claude-code"] = {
          command = "npx",
          args = {"@zed-industries/claude-code-acp"},
          env = {
            NODE_NO_WARNINGS = "1",
            ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")
          }
        }
      },
      web_search_engine = {
        provider = "tavily",
        proxy = nil,
        api_key_name = "TAVILY_API_KEY"
      },
      windows = {
        position = "right",
        wrap = true,
        width = 30
      },
      input = {
        provider = "snacks"
      },
      selector = {
        provider = "snacks"
      }
    }
  }
}
