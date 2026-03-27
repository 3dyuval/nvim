return {
  {
    dir = "/home/yuv/proj/claudecode.nvim",
    opts = {
      terminal = {
        snacks_win_opts = {
          position = "float",
          width = 0.95,
          height = 0.88,
          border = "rounded",
          backdrop = false,
          keys = {
            hide = { "<C-r>", function(self) self:hide() end, mode = "t", desc = "Hide Claude" },
          },
        },
      },
    },
    config = function(_, opts)
      require("claudecode").setup(opts)
      local base_win_opts = opts.terminal.snacks_win_opts
      local is_float = true
      vim.api.nvim_create_autocmd("User", {
        pattern = "ClaudeCodeDiffOpened",
        callback = function()
          local term = require("claudecode.terminal")
          if term.get_active_terminal_bufnr() then
            term.simple_toggle()
            is_float = true
          end
        end,
      })
      vim.api.nvim_create_user_command("ClaudeTogglePosition", function()
        local term = require("claudecode.terminal")
        if is_float then
          term.reposition({ snacks_win_opts = vim.tbl_extend("force", base_win_opts, { position = "right", width = 0.4 }) })
        else
          term.reposition({ snacks_win_opts = base_win_opts })
        end
        is_float = not is_float
      end, { desc = "Toggle Claude window between float and side" })
    end,
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
