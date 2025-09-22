-- DAP customizations that override LazyVim defaults
return {
  -- JSON5 support for better launch.json parsing
  {
    "Joakker/lua-json5",
    build = function()
      local success = os.execute("./install.sh")
      if success ~= 0 then
        vim.notify("lua-json5 build failed, falling back to regular JSON", vim.log.levels.WARN)
      end
    end,
    lazy = true,
  },

  -- Override LazyVim's DAP configuration
  {
    "mfussenegger/nvim-dap",
    opts = function()
      -- Enable debug logging
      require("dap").set_log_level("TRACE")
    end,
    config = function(_, opts)
      local dap = require("dap")

      -- Enable JSON5 support if available
      local json5_ok, json5 = pcall(require, "json5")
      if json5_ok then
        require("dap.ext.vscode").json_decode = json5.parse
      end

      -- Custom DAP signs
      vim.fn.sign_define("DapBreakpoint", { text = "🐞", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "🔶", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "🚫", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "DiagnosticOk", linehl = "DapStoppedLine" })

      -- Create highlight group for current line
      vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2d3748" })

      -- TypeScript configurations with ts-node ESM support
      dap.configurations.typescript = {
        {
          name = "Debug TypeScript with ts-node (ESM)",
          type = "node",
          request = "launch",
          runtimeExecutable = "npx",
          runtimeArgs = { "ts-node", "--transpile-only", "--esm" },
          program = function()
            return vim.fn.input("TypeScript file path: ", vim.fn.expand("%:p"), "file")
          end,
          env = {
            NODE_OPTIONS = "--experimental-specifier-resolution=node --inspect",
            NODE_ENV = "development",
          },
          console = "integratedTerminal",
          internalConsoleOptions = "neverOpen",
          skipFiles = {
            "<node_internals>/**",
            "**/node_modules/**",
          },
          sourceMaps = true,
          cwd = "${workspaceFolder}",
        },
      }

      -- JavaScript configurations (same as TypeScript)
      dap.configurations.javascript = dap.configurations.typescript

      -- Enhanced launch.json loading with better error reporting
      local function load_launch_json()
        local launch_json_path = vim.fn.getcwd() .. "/.vscode/launch.json"
        if vim.fn.filereadable(launch_json_path) == 0 then
          return
        end

        local ok, err = pcall(function()
          require("dap.ext.vscode").load_launchjs(launch_json_path, {
            ["pwa-node"] = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
            ["pwa-chrome"] = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
            ["node"] = { "javascript", "typescript" },
          })
        end)

        if not ok then
          local error_msg = tostring(err)
          if error_msg:match("json") or error_msg:match("parse") then
            vim.notify(
              "DAP: JSON parsing error in launch.json. Try using JSON5 syntax or check for syntax errors.\nError: " .. error_msg,
              vim.log.levels.ERROR
            )
          else
            vim.notify("DAP: Failed to load launch.json: " .. error_msg, vim.log.levels.WARN)
          end
        end
      end

      -- Load launch.json after setup
      vim.defer_fn(load_launch_json, 100)
    end,
  },

  -- Override virtual text configuration
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = false,
      only_first_definition = true,
      all_references = false,
      display_callback = function(variable, buf, stackframe, node, options)
        if options.virt_text_pos == "inline" then
          return " = " .. variable.value
        else
          return variable.name .. " = " .. variable.value
        end
      end,
      virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
      all_frames = false,
      virt_lines = false,
      virt_text_win_col = nil,
    },
  },

  -- Override Mason DAP to ensure specific adapters
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        "js-debug-adapter", -- For JavaScript/TypeScript debugging
      },
    },
  },
}