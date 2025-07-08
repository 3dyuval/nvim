-- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md

return {
  "folke/snacks.nvim",
  enabled = true,
  ---@type snacks.Config
  opts = {
    dashboard = {
      enabled = true,
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
      preset = {
        keys = {
          {
            icon = " ",
            key = "e",
            desc = "Explorer",
            action = function()
              -- Set shortmess to avoid swap file prompts
              local old_shortmess = vim.o.shortmess
              vim.o.shortmess = vim.o.shortmess .. "A"

              LazyVim.pick("explorer", {
                root = false,
                auto_close = true,
              })()

              -- Restore shortmess
              vim.o.shortmess = old_shortmess
            end,
          },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "p",
            desc = "Projects",
            action = function()
              LazyVim.pick("projects")()
            end,
          },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
    picker = {
      enabled = true,
      hidden = true,
      ignored = false,
      win = {
        list = {
          keys = {
            ["a"] = "list_down", -- Remap 'a' to down movement (HAEI layout)
            ["c"] = "create", -- Remap 'c' to create file/folder
            ["i"] = function(picker)
              local item = picker:current()
              if item and item.dir then
                -- For directories, use the default confirm behavior
                picker:confirm()
              end
              -- For files, do nothing
            end, -- Expand/collapse directory
            ["h"] = "explorer_close", -- Collapse/close directory
          },
        },
      },
      sources = {
        explorer = {
          auto_close = false,
          hidden = true,
          layout = {
            preset = "default",
            preview = false,
          },
          filter = function(item)
            -- Default explorer behavior - show all files and directories
            return true
          end,
          actions = {
            open_multiple_buffers = {
              action = function(picker)
                local sel = picker.list.selected or {}

                if #sel == 0 then
                  vim.notify("No files selected", vim.log.levels.WARN)
                  return
                end

                picker:close()

                for _, item in ipairs(sel) do
                  if item and item.file then
                    vim.cmd("edit " .. vim.fn.fnameescape(item.file))
                  end
                end

                vim.notify(string.format("Opened %d file(s)", #sel))
              end,
            },
            copy_file_path = {
              action = function(_, item)
                if not item then
                  return
                end
                local vals = {
                  ["PATH"] = item.file,
                  ["FILE CONTENT"] = "file_content",
                  ["PATH (HOME)"] = vim.fn.fnamemodify(item.file, ":~"),
                  ["PATH (CWD)"] = vim.fn.fnamemodify(item.file, ":."),
                  ["BASENAME"] = vim.fn.fnamemodify(item.file, ":t:r"),
                  ["EXTENSION"] = vim.fn.fnamemodify(item.file, ":t:e"),
                  ["FILENAME"] = vim.fn.fnamemodify(item.file, ":t"),
                  ["URI"] = vim.uri_from_fname(item.file),
                }
                local options = vim.tbl_filter(function(val)
                  return vals[val] ~= ""
                end, vim.tbl_keys(vals))
                if vim.tbl_isempty(options) then
                  vim.notify("No values to copy", vim.log.levels.WARN)
                  return
                end
                vim.ui.select(options, {
                  prompt = "Choose to copy to clipboard:",
                  format_item = function(list_item)
                    return ("%s: %s"):format(list_item, vals[list_item])
                  end,
                }, function(choice)
                  local result = vals[choice]
                  if result then
                    if choice == "FILE CONTENT" then
                      if vim.fn.filereadable(item.file) == 0 then
                        vim.notify("File not readable: " .. item.file, vim.log.levels.ERROR)
                        return
                      end
                      local content = vim.fn.readfile(item.file)
                      local content_str = table.concat(content, "\n")
                      vim.fn.setreg("+", content_str)
                      local filename = vim.fn.fnamemodify(item.file, ":t")
                      local line_count = #content
                      Snacks.notify.info(
                        string.format("File content copied to clipboard: %s (%d lines)", filename, line_count)
                      )
                    else
                      vim.fn.setreg("+", result)
                      Snacks.notify.info("Yanked `" .. result .. "`")
                    end
                  end
                end)
              end,
            },
            search_in_directory = {
              action = function(_, item)
                if not item then
                  return
                end
                local dir = vim.fn.fnamemodify(item.file, ":p:h")
                Snacks.picker.grep({
                  cwd = dir,
                  cmd = "rg",
                  args = {
                    "-g",
                    "!.git",
                    "-g",
                    "!node_modules",
                    "-g",
                    "!dist",
                    "-g",
                    "!build",
                    "-g",
                    "!coverage",
                    "-g",
                    "!.DS_Store",
                    "-g",
                    "!.docusaurus",
                    "-g",
                    "!.dart_tool",
                  },
                  show_empty = true,
                  hidden = true,
                  ignored = true,
                  follow = false,
                  supports_live = true,
                })
              end,
            },
            diff = {
              action = function(picker)
                picker:close()
                local sel = picker:selected()
                if #sel > 0 and sel then
                  Snacks.notify.info(sel[1].file)
                  vim.cmd("tabnew " .. sel[1].file)
                  vim.cmd("vert diffs " .. sel[2].file)
                  Snacks.notify.info("Diffing " .. sel[1].file .. " against " .. sel[2].file)
                  return
                end
                Snacks.notify.info("Select two entries for the diff")
              end,
            },
          },
          win = {
            list = {
              keys = {
                ["a"] = "list_down", -- Remap 'a' to down movement (HAEI layout)
                ["/"] = "toggle_focus",
                ["<Esc>"] = { "close", mode = { "n", "i" } },
                ["<C-c>"] = "focus_input",
                ["p"] = "copy_file_path",
                ["g"] = "search_in_directory", -- Opens a grep snacks
                ["a"] = "list_down", -- Remap 'a' to down movement (HAEI layout)
                ["i"] = function(picker)
              local item = picker:current()
              if item and item.dir then
                -- For directories, use the default confirm behavior
                picker:confirm()
              end
              -- For files, do nothing
            end, -- Expand/collapse directory
                ["h"] = "explorer_close", -- Collapse/close directory
                ["D"] = "diff",
                ["r"] = "explorer_add", -- Create file/folder
                ["x"] = false, -- Disable default x binding
                ["R"] = "explorer_rename", -- Rename on 'R',
                ["<C-CR>"] = "open_multiple_buffers", -- This references the action above,
              },
            },
          },
        },
        files = {
          cmd = "fd",
          args = {
            "--color=never",
            "--type",
            "f",
            "--type",
            "l",
            "--hidden",
            "--follow",
            "--exclude",
            ".git",
            "--exclude",
            "node_modules",
          },
        },
        grep = {
          cmd = "rg",
          args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob",
            "!.git/*",
            "--glob",
            "!node_modules/*",
          },
        },
      },
    },
  },
  keys = {
    {
      "<leader>se",
      function()
        -- Get list of currently opened buffer file paths
        local open_files = {}
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
            local file_path = vim.api.nvim_buf_get_name(buf)
            if file_path ~= "" then
              table.insert(open_files, {
                file = file_path,
                text = vim.fn.fnamemodify(file_path, ":t"),
                icon = "󰈔",
                kind = "file",
              })
            end
          end
        end

        -- Create a picker with custom items but explorer behavior
        Snacks.picker.pick("open_files", {
          items = open_files,
          actions = Snacks.config.picker.sources.explorer.actions,
          win = Snacks.config.picker.sources.explorer.win,
        })
      end,
      desc = "Explorer (open files only)",
    },
    {
      "<leader>e",
      function()
        -- Set shortmess to avoid swap file prompts
        local old_shortmess = vim.o.shortmess
        vim.o.shortmess = vim.o.shortmess .. "A"

        LazyVim.pick("explorer", {
          root = false,
          auto_close = true,
        })()

        -- Restore shortmess
        vim.o.shortmess = old_shortmess
      end,
      desc = "Explorer (floating, auto-close)",
    },
    {
      "<leader>E",
      function()
        -- Set shortmess to avoid swap file prompts
        local old_shortmess = vim.o.shortmess
        vim.o.shortmess = vim.o.shortmess .. "A"

        LazyVim.pick("explorer", {
          root = false,
          auto_close = false,
          win = {
            list = {
              keys = {
                ["<C-c>"] = { "close", mode = { "n", "i" } },
                ["<Esc>"] = false,
              },
            },
          },
          layout = {
            preset = "left",
            preview = false,
          },
        })()

        -- Restore shortmess
        vim.o.shortmess = old_shortmess
      end,
      desc = "Explorer (left window, no auto-close)",
    },
  },
}
