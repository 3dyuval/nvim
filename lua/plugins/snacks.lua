-- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md

-- Shared explorer function
local function open_explorer(opts)
  local old_shortmess = vim.o.shortmess
  vim.o.shortmess = vim.o.shortmess .. "A"

  local config = vim.tbl_deep_extend("force", {
    root = false,
  }, opts or {})

  Snacks.picker.explorer(config)

  vim.o.shortmess = old_shortmess
end

-- Delegate to comprehensive format action from picker-extensions
local function format_current_item(picker, item)
  require("utils.picker-extensions").actions.format_action(picker, item)
end

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
        { section = "header", enabled = true },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup", enabled = false },
        {
          pane = 1,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git diff HEAD --stat",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        },
      },
      preset = {
        keys = {
          {
            icon = "",
            key = "E",
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
          {
            icon = "󰈞",
            key = "/",
            desc = "Find Text",
            action = ":lua Snacks.dashboard.pick('live_grep')",
          },
          { icon = "", key = "n", desc = "Neogit", action = ":Neogit" },
          {
            icon = "",
            key = "r",
            desc = "Recent Files",
            action = ":lua Snacks.dashboard.pick('oldfiles')",
          },
          {
            icon = "󰰶",
            key = "z",
            desc = "Recent Directories",
            action = function()
              Snacks.picker.zoxide()
            end,
          },
          {
            icon = "",
            key = "p",
            desc = "Projects",
            action = function()
              LazyVim.pick("projects")()
            end,
          },
          {
            icon = "",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = "", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "t", desc = "Show todo", action = ":TodoTrouble" },
          {
            icon = "󰒲 ",
            key = "l",
            desc = "Lazy",
            action = ":Lazy",
            enabled = package.loaded.lazy ~= nil,
          },
          { icon = "", key = "q", desc = "Quit", action = ":qa!" },
        },
      },
    },
    picker = {
      enabled = true,
      hidden = true,
      ignored = false,
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "focus_list", mode = { "i" } },
            ["<Bs>"] = false,
          },
        },
        list = {
          keys = {
            ["<Esc>"] = { "close", mode = { "n" } },
            ["<C-p>"] = "toggle_preview", -- Toggle preview globally
            ["a"] = "list_down", -- Remap 'a' to down movement (HAEI layout)
            ["c"] = "create", -- Remap 'c' to create file/folder
            ["<C-a>"] = false, -- Disable select all - it's distracting
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
          },
          win = {
            list = {
              keys = {
                ["<BS>"] = false, -- Disable backspace navigation
                ["a"] = "list_down", -- Remap 'a' to down movement (HAEI layout)
                ["/"] = "toggle_focus",
                ["<C-c>"] = "focus_input",
                ["<C-a>"] = false, -- Disable select all - it's distracting
                ["p"] = function(picker, item)
                  require("utils.picker-extensions").actions.context_menu(picker, item)
                end,
                ["g"] = "search_in_directory", -- Opens a grep snacks
                ["i"] = function(picker)
                  require("utils.picker-extensions").actions.handle_directory_expansion(picker)
                end, -- Expand/collapse directory
                ["h"] = "explorer_close", -- Collapse/close directory
                ["D"] = "diff",
                ["r"] = "explorer_add", -- Create file/folder
                ["x"] = false, -- Disable default x binding
                ["R"] = "explorer_rename", -- Rename on 'R',
                ["<C-CR>"] = "open_multiple_buffers", -- This references the action above,
                ["f"] = function(picker, item)
                  format_current_item(picker, item)
                end,
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
                ["f"] = function(picker, item)
                  format_current_item(picker, item)
                end,
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
                ["f"] = function(picker, item)
                  -- For buffers, format the buffer content directly
                  local items = picker:selected({ fallback = true })
                  local conform = require("conform")
                  local processed = 0

                  for _, buf_item in ipairs(items) do
                    if buf_item.bufnr and vim.api.nvim_buf_is_loaded(buf_item.bufnr) then
                      local success, err = pcall(function()
                        conform.format({ bufnr = buf_item.bufnr, timeout_ms = 5000 })
                        processed = processed + 1
                      end)

                      if not success then
                        vim.notify(
                          "Error formatting buffer: " .. (err or "unknown"),
                          vim.log.levels.WARN
                        )
                      end
                    end
                  end

                  if processed > 0 then
                    vim.notify("Formatted " .. processed .. " buffers")
                  end
                end,
              },
            },
          },
        },
        git_status = {
          focus = "list",
          layout = "sidebar",
          win = {
            list = {
              keys = {
                ["f"] = function(picker, item)
                  format_current_item(picker, item)
                end,
                ["s"] = { "git_stage", mode = { "n", "i" } },
              },
            },
          },
        },
        git_branches = {
          auto_close = false,
          focus = "list",
          win = {
            list = {
              keys = {
                -- Direct access to git branch actions using Snacks built-ins
                ["c"] = { "git_checkout", mode = { "n", "i" } }, -- Checkout branch
                ["d"] = { "git_branch_del", mode = { "n", "i" } }, -- Delete branch
                ["n"] = { "git_branch_add", mode = { "n", "i" } }, -- Create new branch
              },
            },
          },
        },
        git_diff = {
          focus = "list",
        },
        git_log = {
          focus = "list",
          win = {
            list = {
              keys = {
                ["p"] = function(picker, item)
                  require("utils.picker-extensions").actions.context_menu(picker, item)
                end,
              },
            },
          },
        },
        zoxide = {
          -- Configure zoxide picker
          follow = true,
          cmd = "zoxide",
          args = { "query", "-l" },
          actions = {
            zoxide_cd = {
              action = function(picker, item)
                picker:close()
                vim.cmd("cd " .. vim.fn.fnameescape(item.file or item.text))
                vim.notify("Changed directory to: " .. (item.file or item.text))
              end,
            },
            zoxide_explorer = {
              action = function(picker, item)
                picker:close()
                Snacks.picker.explorer({ cwd = item.file or item.text })
              end,
            },
          },
          win = {
            list = {
              keys = {
                ["<CR>"] = "zoxide_cd",
                ["e"] = "zoxide_explorer",
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
      "<leader>E",
      function()
        open_explorer({
          auto_close = false,
          layout = {
            preset = "left",
            preview = false,
          },
        })
      end,
      desc = "Explorer (sidebar)",
    },
    {
      "<leader>e",
      function()
        open_explorer({
          auto_close = true,
          preview = true,
        })
      end,
      desc = "Explorer (window)",
    },
    {
      "<leader>z",
      function()
        Snacks.picker.zoxide()
      end,
      desc = "Zoxide (smart directories)",
    },
  },
}
