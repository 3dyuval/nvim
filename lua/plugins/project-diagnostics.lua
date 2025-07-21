return {
  "artemave/workspace-diagnostics.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local workspace_diagnostics = require("workspace-diagnostics")
    local Job = require("plenary.job")
    local async = require("plenary.async")

    -- Async function to get workspace files
    local function get_workspace_files_async()
      return async.wrap(function(callback)
        Job:new({
          command = "git",
          args = { "ls-files" },
          on_exit = function(job, return_val)
            if return_val ~= 0 then
              callback({})
              return
            end

            local raw_files = job:result()
            -- Process files on main thread to avoid fast event context issues
            vim.schedule(function()
              local files = {}
              for _, file in ipairs(raw_files) do
                if file ~= "" then
                  local abs_path = vim.fn.fnamemodify(file, ":p")
                  table.insert(files, abs_path)
                end
              end
              callback(files)
            end)
          end,
        }):start()
      end, 1)
    end

    -- Setup workspace diagnostics with async git file discovery
    workspace_diagnostics.setup({
      workspace_files = function()
        -- For synchronous calls, use a simple fallback
        local handle = io.popen("git ls-files 2>/dev/null")
        if not handle then
          return {}
        end

        local result = handle:read("*a")
        handle:close()

        if result == "" then
          return {}
        end

        local files = {}
        for file in result:gmatch("[^\r\n]+") do
          local abs_path = vim.fn.fnamemodify(file, ":p")
          table.insert(files, abs_path)
        end

        return files
      end,
    })

    -- Async function to collect and display diagnostics
    local function collect_and_display_diagnostics()
      async.run(function()
        -- Get all diagnostics from all buffers
        local all_diagnostics = {}
        local buffers = vim.api.nvim_list_bufs()

        for _, buf in ipairs(buffers) do
          if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_is_valid(buf) then
            local diagnostics = vim.diagnostic.get(buf)
            for _, diag in ipairs(diagnostics) do
              local filename = vim.api.nvim_buf_get_name(buf)
              if filename ~= "" then
                table.insert(all_diagnostics, {
                  filename = filename,
                  lnum = diag.lnum + 1,
                  col = diag.col + 1,
                  text = diag.message,
                  type = diag.severity == vim.diagnostic.severity.ERROR and "error"
                    or diag.severity == vim.diagnostic.severity.WARN and "warning"
                    or diag.severity == vim.diagnostic.severity.INFO and "info"
                    or "hint",
                })
              end
            end
          end
        end

        -- Format items for picker
        local items = {}
        for _, item in ipairs(all_diagnostics) do
          local filename = vim.fn.fnamemodify(item.filename, ":~:.")
          local icon = item.type == "error" and "󰅚 "
            or item.type == "warning" and "󰀪 "
            or item.type == "info" and "󰋽 "
            or "󰌶 "
          table.insert(items, {
            text = string.format("%s%s:%d:%d: %s", icon, filename, item.lnum, item.col, item.text),
            file = item.filename,
            pos = { item.lnum, item.col },
          })
        end

        -- Open snacks picker on main thread
        vim.schedule(function()
          Snacks.picker.pick("diagnostics", {
            items = items,
            prompt = string.format("Project Diagnostics (%d found)", #items),
            layout = { preset = "bottom" },
            win = {
              list = {
                keys = {
                  ["a"] = "list_down", -- HAEI navigation
                  ["e"] = "list_up",
                  ["i"] = "list_right",
                  ["h"] = "list_left",
                },
              },
            },
          })
        end)
      end)
    end

    -- Async function to populate workspace diagnostics
    local function populate_workspace_diagnostics_async()
      async.run(function()
        local clients = vim.lsp.get_clients()

        if #clients == 0 then
          vim.schedule(function()
            vim.cmd("LspStart")
            vim.defer_fn(function()
              clients = vim.lsp.get_clients()
              if #clients == 0 then
                vim.notify("No LSP clients available", vim.log.levels.WARN)
                return
              end
              populate_workspace_diagnostics_async()
            end, 1000)
          end)
          return
        end

        -- Get workspace files asynchronously
        local workspace_files = get_workspace_files_async()()

        -- Populate diagnostics for all clients
        local file_count = 0
        for _, client in pairs(clients) do
          vim.schedule(function()
            vim.notify(
              "Scanning workspace for " .. client.name .. " diagnostics...",
              vim.log.levels.INFO
            )
          end)

          pcall(workspace_diagnostics.populate_workspace_diagnostics, client)

          -- Count files that would be processed
          local client_files = 0
          for _, file in ipairs(workspace_files) do
            local filetype = vim.filetype.match({ filename = file })
            if client.config.filetypes and vim.tbl_contains(client.config.filetypes, filetype) then
              client_files = client_files + 1
            end
          end
          file_count = file_count + client_files
        end

        if file_count > 0 then
          vim.schedule(function()
            vim.notify(
              string.format("Processing diagnostics for %d files...", file_count),
              vim.log.levels.INFO
            )
          end)
        end

        -- Wait for diagnostics to populate
        async.util.sleep(2000)

        -- Collect and display diagnostics
        collect_and_display_diagnostics()
      end)
    end

    -- Create custom user command
    vim.api.nvim_create_user_command("ProjectDiagnostics", function()
      populate_workspace_diagnostics_async()
    end, { desc = "Show project-wide diagnostics" })

    -- Auto-populate diagnostics when LSP attaches (with error handling)
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("ProjectDiagnostics", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and args.buf and vim.api.nvim_buf_is_valid(args.buf) then
          pcall(workspace_diagnostics.populate_workspace_diagnostics, client)
        end
      end,
    })
  end,
}
