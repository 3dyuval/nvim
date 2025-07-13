-- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    indent = {
      enabled = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        return not bufname:match("^diffview://")
      end,
      scope = {
        enabled = function()
          local bufname = vim.api.nvim_buf_get_name(0)
          return not bufname:match("^diffview://")
        end,
      },
    },
    scope = {
      enabled = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        return not bufname:match("^diffview://")
      end,
    },
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

              Snacks.picker.explorer({
                root = false,
                auto_close = true,
              })

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
            -- Remove global "b" keymap - it will be defined per-source
          },
        },
      },
      sources = {
        explorer = {
          auto_close = false,
          hidden = true,
          git = {
            enabled = true, -- Enable git status display (enabled by default in 2.18.0+)
          },
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
                require("utils.picker-extensions").actions.open_multiple_buffers(picker)
              end,
            },
            copy_file_path = {
              action = function(picker, item)
                require("utils.picker-extensions").actions.copy_file_path(picker, item)
              end,
            },
            search_in_directory = {
              action = function(picker, item)
                require("utils.picker-extensions").actions.search_in_directory(picker, item)
              end,
            },
            diff = {
              action = function(picker)
                require("utils.picker-extensions").actions.diff_selected(picker)
              end,
            },
            show_context_menu = {
              action = function(picker)
                require("utils.picker-extensions").show_menu(picker)
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
                  require("utils.picker-extensions").actions.handle_directory_expansion(picker)
                end, -- Expand/collapse directory
                ["h"] = "explorer_close", -- Collapse/close directory
                ["D"] = "diff",
                ["r"] = "explorer_add", -- Create file/folder
                ["x"] = false, -- Disable default x binding
                ["R"] = "explorer_rename", -- Rename on 'R',
                ["<C-CR>"] = "open_multiple_buffers", -- This references the action above,
                ["b"] = "show_context_menu",
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
          win = {
            list = {
              keys = {
                ["b"] = "show_context_menu",
              },
            },
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
        buffers = {
          win = {
            list = {
              keys = {
                ["b"] = "show_context_menu",
              },
            },
          },
        },
        git_status = {
          win = {
            list = {
              keys = {
                ["b"] = "show_context_menu",
              },
            },
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

        Snacks.picker.explorer({
          root = false,
          auto_close = true,
        })

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

        Snacks.picker.explorer({
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
        })

        -- Restore shortmess
        vim.o.shortmess = old_shortmess
      end,
      desc = "Explorer (left window, no auto-close)",
    },
  },
}
