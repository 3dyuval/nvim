return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    -- Ensure opts has the required structure
    opts = opts or {}
    opts.inlay_hints = opts.inlay_hints or { enabled = true }
    opts.codelens = opts.codelens or { enabled = false } -- Disabled to prevent LazyVim's auto-refresh
    opts.servers = opts.servers or {}
    opts.servers["*"] = opts.servers["*"] or {}
    opts.servers["*"].keys = opts.servers["*"].keys or {}

    -- Custom function to show references in Snacks picker
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

    -- Function to find containing function/class using Tree-sitter
    local function find_containing_declaration()
      local bufnr = vim.api.nvim_get_current_buf()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local row, col = cursor[1] - 1, cursor[2] -- Convert to 0-indexed

      -- Get Tree-sitter parser
      local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
      if not ok or not parser then
        return nil
      end

      local tree = parser:parse()[1]
      if not tree then
        return nil
      end

      -- Query for function/class/method declarations
      local query_strings = {
        -- TypeScript/JavaScript queries
        [[
        (function_declaration name: (identifier) @name) @declaration
        ]],
        [[
        (method_definition key: (property_identifier) @name) @declaration
        ]],
        [[
        (arrow_function) @declaration
        ]],
        [[
        (function_expression) @declaration
        ]],
        [[
        (class_declaration name: (type_identifier) @name) @declaration
        ]],
        [[
        (interface_declaration name: (type_identifier) @name) @declaration
        ]],
        [[
        (type_alias_declaration name: (type_identifier) @name) @declaration
        ]],
        [[
        (variable_declarator
          name: (identifier) @name
          value: (arrow_function)) @declaration
        ]],
        [[
        (variable_declarator
          name: (identifier) @name
          value: (function_expression)) @declaration
        ]],
      }

      local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
      if not lang then
        return nil
      end

      local containing_nodes = {}

      -- Try each query
      for _, query_string in ipairs(query_strings) do
        local ok_query, query = pcall(vim.treesitter.query.parse, lang, query_string)
        if ok_query then
          for _, match, _ in query:iter_matches(tree:root(), bufnr) do
            for capture_id, node in pairs(match) do
              local capture_name = query.captures[capture_id]
              if capture_name == "declaration" then
                local start_row, start_col, end_row, end_col = node:range()
                -- Check if cursor is within this node
                if start_row <= row and row <= end_row then
                  if start_row == row then
                    -- Same line, check column
                    if start_col <= col and col <= end_col then
                      table.insert(
                        containing_nodes,
                        { node = node, start_row = start_row, priority = end_row - start_row }
                      )
                    end
                  else
                    -- Different line, we're inside
                    table.insert(
                      containing_nodes,
                      { node = node, start_row = start_row, priority = end_row - start_row }
                    )
                  end
                end
              end
            end
          end
        end
      end

      -- Sort by smallest range (most specific)
      table.sort(containing_nodes, function(a, b)
        return a.priority < b.priority
      end)

      return containing_nodes[1] and containing_nodes[1].start_row or nil
    end

    -- Enhanced function to run code lens action
    local function _run_codelens_action() -- Reserved for future use
      local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1
      local lenses = vim.lsp.codelens.get(0)

      if not lenses or #lenses == 0 then
        vim.notify("No code lenses available", vim.log.levels.INFO)
        return
      end

      -- First, try to find lens at current line
      local lens_at_line = nil
      for _, lens in ipairs(lenses) do
        if lens.range.start.line <= current_line and current_line <= lens.range["end"].line then
          lens_at_line = lens
          break
        end
      end

      -- If no lens at current line, try to find containing function using Tree-sitter
      if not lens_at_line then
        local declaration_line = find_containing_declaration()
        if declaration_line then
          -- Look for lenses near the declaration line (usually above or at the declaration)
          for _, lens in ipairs(lenses) do
            local lens_line = lens.range.start.line
            -- Check if lens is within a few lines of the declaration (usually right above)
            if math.abs(lens_line - declaration_line) <= 2 then
              lens_at_line = lens
              break
            end
          end
        end
      end

      if lens_at_line and lens_at_line.command then
        -- Execute the command
        if lens_at_line.command.command then
          vim.lsp.buf.execute_command(lens_at_line.command)
        else
          vim.notify("Code lens has no executable command", vim.log.levels.WARN)
        end
      else
        -- If still no lens found, show all available lenses for user to choose
        local lens_items = {}
        for i, lens in ipairs(lenses) do
          local line_num = lens.range.start.line + 1
          local line_content = vim.api.nvim_buf_get_lines(
            0,
            lens.range.start.line,
            lens.range.start.line + 1,
            false
          )[1] or ""
          local title = lens.command and lens.command.title or "Unknown"

          table.insert(lens_items, {
            text = string.format(
              "Line %d: %s - %s",
              line_num,
              title,
              line_content:gsub("^%s+", "")
            ),
            lens = lens,
            line = line_num,
          })
        end

        if #lens_items > 0 then
          vim.ui.select(lens_items, {
            prompt = "Select Code Lens:",
            format_item = function(item)
              return item.text
            end,
          }, function(selected)
            if selected and selected.lens.command then
              vim.lsp.buf.execute_command(selected.lens.command)
            end
          end)
        else
          vim.notify("No executable code lenses found", vim.log.levels.INFO)
        end
      end
    end

    -- Note: Codelens and reference keymaps have been moved to lua/plugins/lsp-keymaps.lua
    return opts
  end,
  -- Removed vtsls-specific init function to prevent conflicts with typescript-tools
  -- Codelens refresh is now handled by typescript-tools.lua
}
