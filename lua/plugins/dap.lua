return {
  lazy = false,
  {
    "Joakker/lua-json5",
    build = function()
      -- Fallback: if build fails, we'll use regular JSON
      local success = os.execute("./install.sh")
      if success ~= 0 then
        vim.notify("lua-json5 build failed, falling back to regular JSON", vim.log.levels.WARN)
      end
    end,
    lazy = true,
  },
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "Joakker/lua-json5",
    },
    config = function()
      local dap = require("dap")
      local ui = require("dapui")
      local dap_virtual_text = require("nvim-dap-virtual-text")

      -- Enable debug logging
      dap.set_log_level("TRACE")

      local json5_ok, json5 = pcall(require, "json5")
      if json5_ok then
        require("dap.ext.vscode").json_decode = json5.parse
        vim.notify("DAP: Using json5 parser for better launch.json support", vim.log.levels.INFO)
      else
        vim.notify("DAP: json5 not available, using fallback JSON parser", vim.log.levels.WARN)
      end

      -- Dap Virtual Text - shows variable values inline in editor
      dap_virtual_text.setup({
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
      })

      -- Use js-debug (now with RPC fix)
      local js_debug_path = "/home/lab/.local/share/js-debug/src/dapDebugServer.js"

      if vim.fn.filereadable(js_debug_path) == 0 then
        vim.notify("DAP: js-debug not found", vim.log.levels.ERROR)
        return
      end

      -- Configure js-debug adapter
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { js_debug_path, "${port}" },
        },
      }

      -- Chrome debugging configurations (WORKING - restore these)
      local chrome_configs = {
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch & Debug Chrome",
          url = function()
            local co = coroutine.running()
            return coroutine.create(function()
              vim.ui.input({
                prompt = "Enter URL: ",
                default = "http://localhost:3000",
              }, function(url)
                if url == nil or url == "" then
                  return
                else
                  coroutine.resume(co, url)
                end
              end)
            end)
          end,
          webRoot = vim.fn.getcwd(),
          protocol = "inspector",
          sourceMaps = true,
          userDataDir = false,
        },
      }

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
          vim.notify("DAP: No .vscode/launch.json found in " .. vim.fn.getcwd(), vim.log.levels.INFO)
          return
        end

        local ok, err = pcall(function()
          require("dap.ext.vscode").load_launchjs(nil, {
            ["pwa-node"] = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
            ["pwa-chrome"] = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
            ["node"] = { "javascript", "typescript" }, -- Fallback for older configs
          })
        end)

        if not ok then
          local error_msg = tostring(err)
          if error_msg:match("json") or error_msg:match("parse") then
            vim.notify(
              "DAP: JSON parsing error in launch.json. Try using JSON5 syntax or check for syntax errors.\nError: "
                .. error_msg,
              vim.log.levels.ERROR
            )
          else
            vim.notify("DAP: Failed to load launch.json: " .. error_msg, vim.log.levels.WARN)
          end
        end
      end

      load_launch_json()

      -- Override Chrome executable globally for all configurations (WORKING - keep)
      local function override_chrome_executable()
        local chrome_path = "/usr/bin/google-chrome-stable"
        local user_data_dir = vim.fn.expand("~")

        -- Check if Chrome exists
        if vim.fn.executable(chrome_path) == 0 then
          vim.notify("DAP: Chrome not found at " .. chrome_path, vim.log.levels.WARN)
          return
        end

        for _, config in pairs(dap.configurations.javascript or {}) do
          if config.type == "pwa-chrome" and not config.runtimeExecutable then
            config.runtimeExecutable = chrome_path
            config.runtimeArgs = config.runtimeArgs or {}
            vim.list_extend(config.runtimeArgs, { "--user-data-dir=" .. user_data_dir, "--ignore-certificate-errors" })
          end
        end
        for _, config in pairs(dap.configurations.typescript or {}) do
          if config.type == "pwa-chrome" and not config.runtimeExecutable then
            config.runtimeExecutable = chrome_path
            config.runtimeArgs = config.runtimeArgs or {}
            vim.list_extend(config.runtimeArgs, { "--user-data-dir=" .. user_data_dir, "--ignore-certificate-errors" })
          end
        end
      end

      -- Apply after loading launch.json files
      vim.defer_fn(override_chrome_executable, 100)

      -- Dap UI (WORKING - keep as-is)
      ui.setup({
        mappings = {
          edit = "m",
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "g",
          remove = "d",
          repl = "y",
          toggle = "s",
        },
      })

      -- Define DAP signs
      vim.fn.sign_define("DapBreakpoint", { text = "🐞", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "🔶", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "🚫", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "DiagnosticOk", linehl = "DapStoppedLine" })

      -- Create highlight group for current line
      vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2d3748" })

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end

      -- Debug keymaps
      vim.keymap.set("n", "<leader>dt", function()
        dap.toggle_breakpoint()
      end, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", function()
        dap.continue()
      end, { desc = "Continue" })
      vim.keymap.set("n", "<leader>di", function()
        dap.step_into()
      end, { desc = "Step Into" })
      vim.keymap.set("n", "<leader>do", function()
        dap.step_over()
      end, { desc = "Step Over" })
      vim.keymap.set("n", "<leader>du", function()
        dap.step_out()
      end, { desc = "Step Out" })
      vim.keymap.set("n", "<leader>dr", function()
        dap.repl.open()
      end, { desc = "Open REPL" })
      vim.keymap.set("n", "<leader>dl", function()
        dap.run_last()
      end, { desc = "Run Last" })
      vim.keymap.set("n", "<leader>dq", function()
        dap.terminate()
        ui.close()
      end, { desc = "Terminate" })
    end,
  },
}
