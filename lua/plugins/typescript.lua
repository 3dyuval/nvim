-- TypeScript LSP Configuration
-- Toggle between typescript-tools and vtsls
local USE_TYPESCRIPT_TOOLS = true -- Set to false to use vtsls instead

local ts_filetypes = {
  "javascript",
  "javascriptreact",
  "javascript.jsx",
  "typescript",
  "typescriptreact",
  "typescript.tsx",
  "vue",
}

if USE_TYPESCRIPT_TOOLS then
  -- typescript-tools configuration
  return {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = ts_filetypes,
    opts = {
      filetypes = ts_filetypes,
      settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",
        expose_as_code_action = "all",
        tsserver_path = nil,
        tsserver_plugins = {
          "@vue/typescript-plugin",
        },
        tsserver_max_memory = "auto",
        tsserver_format_options = function(ft)
          return {
            allowRenameOfImportPath = true,
          }
        end,
        tsserver_file_preferences = {
          importModuleSpecifier = "relative",
          includeInlayParameterNameHints = "literals",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = false,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayEnumMemberValueHints = true,
        },
        tsserver_locale = "en",
        complete_function_calls = false,
        include_completions_with_insert_text = true,
        code_lens = "off",
        disable_member_code_lens = true,
        jsx_close_tag = {
          enable = false,
          filetypes = { "javascriptreact", "typescriptreact" },
        },
      },
    },
    config = function(_, opts)
      require("typescript-tools").setup(opts)

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.name == "typescript-tools" then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
          end
        end,
      })
    end,
    keys = {
      { "gD", "<cmd>TSToolsGoToSourceDefinition<cr>", desc = "Goto Source Definition", ft = ts_filetypes },
      { "gR", "<cmd>TSToolsFileReferences<cr>", desc = "File References", ft = ts_filetypes },
    },
  }
else
  -- vtsls configuration (via lsp/setup.lua)
  -- Enable vtsls in lua/lsp/setup.lua and configure keybindings here
  return {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts = opts or {}
      opts.servers = opts.servers or {}
      opts.servers["*"] = opts.servers["*"] or {}
      opts.servers["*"].keys = opts.servers["*"].keys or {}

      local keys = opts.servers["*"].keys

      -- Helper to execute vtsls-specific commands
      local function vtsls_execute(command, args)
        local clients = vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })
        if #clients == 0 then
          vim.notify("vtsls client not attached", vim.log.levels.WARN)
          return
        end

        clients[1].request("workspace/executeCommand", {
          command = command,
          arguments = args,
        }, function(err, result)
          if err then
            vim.notify("vtsls command error: " .. vim.inspect(err), vim.log.levels.ERROR)
            return
          end
          if result then
            local locations = vim.islist(result) and result or { result }
            if #locations > 0 then
              vim.lsp.util.jump_to_location(locations[1], "utf-8", true)
            end
          end
        end, 0)
      end

      -- vtsls-specific keybindings
      keys[#keys + 1] = {
        "gd",
        function()
          vtsls_execute("typescript.goToSourceDefinition", {
            vim.uri_from_bufnr(0),
            vim.lsp.util.make_position_params().position,
          })
        end,
        desc = "Go to Definition (TS/Vue)",
        ft = { "vue" },
      }
      keys[#keys + 1] = {
        "gD",
        function()
          vtsls_execute("typescript.goToSourceDefinition", {
            vim.uri_from_bufnr(0),
            vim.lsp.util.make_position_params().position,
          })
        end,
        desc = "Goto Source Definition (TS/Vue)",
        ft = ts_filetypes,
      }
      keys[#keys + 1] = {
        "gR",
        function()
          vtsls_execute("typescript.findAllFileReferences", { vim.uri_from_bufnr(0) })
        end,
        desc = "File References (TS/Vue)",
        ft = ts_filetypes,
      }

      return opts
    end,
  }
end
