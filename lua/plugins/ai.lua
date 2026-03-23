return {
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for git operations
    },
    opts = {
      window = {
        position = "float",
        float = {
          width = "90%",
          height = "85%",
        },
      },
      keymaps = {
        toggle = { normal = false, terminal = false },
        window_navigation = false,
        scrolling = false,
      },
    },
  },
  {
    name = "run-ai.run",
    dir = "/home/yuv/proj/run-ai.run.nvim",
    enabled = false,
    dependencies = {
      "3dyuval/colortweak.nvim",
      "nvim-lua/plenary.nvim",
      "folke/noice.nvim",
    },
    opts = {
      skills_path = "/home/yuv/.config/nvim/.claude/skills",
      bin = "/home/yuv/.nvm/versions/node/v20.19.6/bin/claude",
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
