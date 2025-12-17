return {
  {
    name = "run-ai.run",
    dir = "/home/yuv/proj/run-ai.run.nvim",
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
}
