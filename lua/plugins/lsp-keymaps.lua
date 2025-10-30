return {
  -- LSP Keymaps Override for LazyVim
  -- Consolidates all LSP keymaps from lsp-keymaps.lua, codelens.lua, and lazyvim-config.lua
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts = opts or {}
      opts.servers = opts.servers or {}
      opts.servers["*"] = opts.servers["*"] or {}
      opts.servers["*"].keys = opts.servers["*"].keys or {}

      -- Custom function to show references in Snacks picker (from codelens.lua)
      local function show_references_picker()
        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, "textDocument/references", params, function(err, result, ctx, config)
          if err or not result or #result == 0 then
            vim.notify("No references found", vim.log.levels.INFO)
            return
          end

          -- Format references for Snacks picker
          local items = {}
          for i, ref in ipairs(result) do
            local filename = vim.fn.fnamemodify(vim.uri_to_fname(ref.uri), ":~:.")
            local line_num = ref.range.start.line + 1
            local col_num = ref.range.start.character + 1

            -- Get the line content
            local line_content = ""
            local bufnr = vim.uri_to_bufnr(ref.uri)
            if vim.api.nvim_buf_is_loaded(bufnr) then
              line_content = vim.api.nvim_buf_get_lines(
                bufnr,
                ref.range.start.line,
                ref.range.start.line + 1,
                false
              )[1] or ""
            end

            table.insert(items, {
              file = vim.uri_to_fname(ref.uri),
              text = string.format(
                "%s:%d:%d %s",
                filename,
                line_num,
                col_num,
                line_content:gsub("^%s+", "")
              ),
              pos = { line_num, col_num },
              idx = i,
              score = 1,
            })
          end

          -- Show in Snacks picker
          Snacks.picker({
            name = "references",
            items = items,
            layout = { preset = "default" },
            format = "file",
            preview = "file",
            actions = {
              confirm = function(picker, item)
                picker:close()
                vim.cmd("edit " .. item.file)
                if item.pos then
                  vim.api.nvim_win_set_cursor(0, { item.pos[1], item.pos[2] - 1 })
                end
              end,
            },
          })
        end)
      end

      local keys = opts.servers["*"].keys

      -- Disable conflicting default keymaps
      keys[#keys + 1] = { "[[", false }
      keys[#keys + 1] = { "]]", false }
      keys[#keys + 1] = { "<leader>cc", false }
      keys[#keys + 1] = { "<leader>cr", false } -- From lazyvim-config.lua

      -- Standard LSP keymaps
      keys[#keys + 1] = { "<leader>cl", vim.lsp.codelens.refresh, desc = "Refresh Codelens" }
      keys[#keys + 1] = { "<leader>cI", "<cmd>LspInfo<cr>", desc = "LSP Info" }
      keys[#keys + 1] = { "<leader>cr", vim.lsp.buf.rename, desc = "Rename Symbol" }
      keys[#keys + 1] = { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" }

      -- Reference keymaps (from codelens.lua)
      keys[#keys + 1] =
        { "<leader>cx", show_references_picker, desc = "Show References (Snacks)", mode = { "n" } }
      keys[#keys + 1] =
        { "<leader>cR", vim.lsp.buf.references, desc = "Show References (LSP)", mode = { "n" } }

      return opts
    end,
  },
}
