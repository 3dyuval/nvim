return {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "jay-babu/mason-nvim-dap.nvim",
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function()
    local mason_dap = require("mason-nvim-dap")
    local dap = require("dap")
    local ui = require("dapui")
    local dap_virtual_text = require("nvim-dap-virtual-text")

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

    -- Enable debug logging
    dap.set_log_level("DEBUG")

    mason_dap.setup({
      ensure_installed = { "js-debug-adapter" },
      automatic_installation = true,
      handlers = {
        function(config)
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    })

    -- Configure pwa-node adapter (js-debug-adapter)
    local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug-adapter"
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = js_debug_path,
        args = { "${port}" },
      },
    }

    -- Configure pwa-chrome adapter (same js-debug-adapter)
    dap.adapters["pwa-chrome"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = js_debug_path,
        args = { "${port}" },
      },
    }

    -- JavaScript/Node.js configurations
    dap.configurations.javascript = {
      {
        name = "Launch with Bun",
        type = "pwa-node",
        request = "launch",
        program = "${file}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        runtimeExecutable = "bun", -- Use Bun instead of Node
        runtimeArgs = { "run" }, -- Bun's run command
      },
      {
        name = "Launch",
        type = "pwa-node",
        request = "launch",
        program = "${file}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
      },
      {
        name = "Attach to process",
        type = "pwa-node",
        request = "attach",
        processId = require("dap.utils").pick_process,
      },
    }

    -- TypeScript configurations (same as JavaScript)
    dap.configurations.typescript = dap.configurations.javascript

    -- Load project-specific .vscode/launch.json files
    require("dap.ext.vscode").load_launchjs(nil, {
      ["pwa-node"] = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      ["pwa-chrome"] = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    })

    -- Override Chrome executable globally for all configurations
    local function override_chrome_executable()
      for _, config in pairs(dap.configurations.javascript or {}) do
        if config.type == "pwa-chrome" and not config.runtimeExecutable then
          config.runtimeExecutable = "/usr/bin/google-chrome-stable"
          config.runtimeArgs = config.runtimeArgs or {}
          vim.list_extend(config.runtimeArgs, { "--user-data-dir=/home/yuval", "--ignore-certificate-errors" })
        end
      end
      for _, config in pairs(dap.configurations.typescript or {}) do
        if config.type == "pwa-chrome" and not config.runtimeExecutable then
          config.runtimeExecutable = "/usr/bin/google-chrome-stable"
          config.runtimeArgs = config.runtimeArgs or {}
          vim.list_extend(config.runtimeArgs, { "--user-data-dir=/home/yuval", "--ignore-certificate-errors" })
        end
      end
    end

    -- Apply after loading launch.json files
    vim.defer_fn(override_chrome_executable, 100)

    -- Dap UI
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
    vim.keymap.set("n", "<leader>db", function()
      require("dap-snacks").breakpoints.pick()
    end, { desc = "List Breakpoints (Snacks)" })
  end,
}
