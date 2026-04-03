return {
  {
    "coder/claudecode.nvim",
    dev = true,
    opts = {
      focus_after_send = false,
      terminal = {
        provider = "none",
      },
    },
    config = function(_, opts)
      require("claudecode").setup(opts)
    end,
  },
  {
    name = "run-ai.run",
    dir = "/home/yuv/proj/run-ai.run.nvim",
    enabled = true,
    cmd = { "Claude", "ClaudeSkillClaude", "LlmReplace" },
    dependencies = {
      "3dyuval/colortweak.nvim",
      "nvim-lua/plenary.nvim",
      "folke/noice.nvim",
    },
    opts = {
      skills_path = "/home/yuv/.config/nvim/.claude/skills",
      log_level = "debug",
      notify_level = "warn", -- nil = off, "debug"/"info"/"warn"/"error" = show in noice
      highlights = {
        normal = "ClaudeNormal",
        thinking = "ClaudeThinking",
      },
    },
    config = function(_, opts)
      local tweak = require("colortweak.tweak")

      tweak.hl({
        ClaudeNormal = { "DiagnosticInfo", { h = -5, s = 1 } },
        ClaudeThinking = { "DiagnosticHint", { h = 15, s = 1.5 } },
      })

      opts.on_sent = function() require("summon").open("claude") end

      opts.providers = {
        {
          name = "theyuval",
          base_url = "https://api.theyuval.com/ai/v1",
          model_prefixes = { "theyuval/" },
          auth_header = "Bearer",
        },
      }

      opts.liter = {
        api_key = os.getenv("API_KEY"),
        model = "theyuval/qwen3-14b",
      }

      require("run-ai-run").setup(opts)
    end,
  },
  {
    enabled = false,
    dir = "/home/yuv/proj/test",
    name = "interview-timer",
    lazy = false,
    dependencies = { "ravsii/timers.nvim" },
    config = function()
      require("timers").setup({})
      require("interview-timer").setup({
        ["time-limit-min"] = 20,
        provider = "claude-acp",
        ["acp-providers"] = {
          ["claude-acp"] = {
            command = "/home/yuv/.nvm/versions/node/v20.19.6/bin/claude-code-acp",
          },
        },
      })
    end,
  },
}
