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

        -- Dap Virtual Text
        dap_virtual_text.setup()

        -- Enable debug logging
        dap.set_log_level('DEBUG')

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
            }
        }

        -- Configure pwa-chrome adapter (same js-debug-adapter)
        dap.adapters["pwa-chrome"] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = {
                command = js_debug_path,
                args = { "${port}" },
            }
        }

        -- JavaScript/Node.js configurations
        dap.configurations.javascript = {
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
        require('dap.ext.vscode').load_launchjs(nil, { 
            ['pwa-node'] = {'javascript', 'typescript', 'javascriptreact', 'typescriptreact'},
            ['pwa-chrome'] = {'javascript', 'typescript', 'javascriptreact', 'typescriptreact'}
        })
        
        -- Override Chrome executable globally for all configurations
        local function override_chrome_executable()
            for _, config in pairs(dap.configurations.javascript or {}) do
                if config.type == "pwa-chrome" and not config.runtimeExecutable then
                    config.runtimeExecutable = "/usr/bin/google-chrome-stable"
                    config.runtimeArgs = config.runtimeArgs or {}
                    vim.list_extend(config.runtimeArgs, {"--user-data-dir=DEFAULT", "--ignore-certificate-errors"})
                end
            end
            for _, config in pairs(dap.configurations.typescript or {}) do
                if config.type == "pwa-chrome" and not config.runtimeExecutable then
                    config.runtimeExecutable = "/usr/bin/google-chrome-stable"
                    config.runtimeArgs = config.runtimeArgs or {}
                    vim.list_extend(config.runtimeArgs, {"--user-data-dir=DEFAULT", "--ignore-certificate-errors"})
                end
            end
        end
        
        -- Apply after loading launch.json files
        vim.defer_fn(override_chrome_executable, 100)

        -- Dap UI
        ui.setup()
        
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
        vim.keymap.set("n", "<leader>dt", function() dap.toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
        vim.keymap.set("n", "<leader>dc", function() dap.continue() end, { desc = "Continue" })
        vim.keymap.set("n", "<leader>di", function() dap.step_into() end, { desc = "Step Into" })
        vim.keymap.set("n", "<leader>do", function() dap.step_over() end, { desc = "Step Over" })
        vim.keymap.set("n", "<leader>du", function() dap.step_out() end, { desc = "Step Out" })
        vim.keymap.set("n", "<leader>dr", function() dap.repl.open() end, { desc = "Open REPL" })
        vim.keymap.set("n", "<leader>dl", function() dap.run_last() end, { desc = "Run Last" })
        vim.keymap.set("n", "<leader>dq", function() 
            dap.terminate()
            ui.close()
        end, { desc = "Terminate" })
        vim.keymap.set("n", "<leader>db", function() 
          require("dap-snacks").breakpoints.pick() 
        end, { desc = "List Breakpoints (Snacks)" })
    end,
}

