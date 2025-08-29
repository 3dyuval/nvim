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
    input = {
      enabled = true,
      icon = " ",
      win = {
        relative = "editor",
        position = "float",
        row = vim.o.lines - 3, -- Position near bottom like classic cmdline
        height = 1,
        width = vim.o.columns - 4,
        border = "none",
      },
    },
    indent = {
      enabled = function(buf)
        -- Safely get current buffer if none provided
        local bufnr = buf or vim.api.nvim_get_current_buf()

        -- Check if buffer is valid
        if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
          return false
        end

        -- Check if current window is valid to prevent nvim_win_get_cursor errors
        local winid = vim.api.nvim_get_current_win()
        if not winid or not vim.api.nvim_win_is_valid(winid) then
          return false
        end

        -- Check buffer-local disable flags first
        if vim.b[bufnr].snacks_indent == false or vim.b[bufnr].miniindentscope_disable then
          return false
        end

        local ok, buftype = pcall(function()
          return vim.bo[bufnr].buftype
        end)
        if not ok or buftype ~= "" then
          return false
        end

        local ok2, modifiable = pcall(function()
          return vim.bo[bufnr].modifiable
        end)
        if not ok2 or not modifiable then
          return false
        end

        local ok3, bufname = pcall(vim.api.nvim_buf_get_name, bufnr)
        if not ok3 then
          return false
        end

        -- Check for diffview buffers and empty buffers (dashboard/scratch)
        if bufname:match("^diffview://") or bufname:match("^git://") or bufname == "" then
          return false
        end

        return true
      end,
      scope = {
        enabled = function(buf)
          -- Safely get current buffer if none provided
          local bufnr = buf or vim.api.nvim_get_current_buf()

          -- Check if buffer is valid
          if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
            return false
          end

          -- Check buffer-local disable flags first
          if vim.b[bufnr].snacks_scope == false or vim.b[bufnr].miniindentscope_disable then
            return false
          end

          local ok, buftype = pcall(function()
            return vim.bo[bufnr].buftype
          end)
          if not ok or buftype ~= "" then
            return false
          end

          local ok2, modifiable = pcall(function()
            return vim.bo[bufnr].modifiable
          end)
          if not ok2 or not modifiable then
            return false
          end

          local ok3, bufname = pcall(vim.api.nvim_buf_get_name, bufnr)
          if not ok3 then
            return false
          end

          -- Check for diffview buffers and empty buffers (dashboard/scratch)
          if bufname:match("^diffview://") or bufname:match("^git://") or bufname == "" then
            return false
          end

          return true
        end,
      },
    },
    scope = {
      enabled = function(buf)
        -- Safely get current buffer if none provided
        local bufnr = buf or vim.api.nvim_get_current_buf()

        -- Check if buffer is valid
        if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
          return false
        end

        -- Check if current window is valid to prevent nvim_win_get_cursor errors
        local winid = vim.api.nvim_get_current_win()
        if not winid or not vim.api.nvim_win_is_valid(winid) then
          return false
        end

        -- Check buffer-local disable flags first
        if vim.b[bufnr].snacks_scope == false or vim.b[bufnr].miniindentscope_disable then
          return false
        end

        local ok, buftype = pcall(function()
          return vim.bo[bufnr].buftype
        end)
        if not ok or buftype ~= "" then
          return false
        end

        local ok2, modifiable = pcall(function()
          return vim.bo[bufnr].modifiable
        end)
        if not ok2 or not modifiable then
          return false
        end

        local ok3, bufname = pcall(vim.api.nvim_buf_get_name, bufnr)
        if not ok3 then
          return false
        end

        -- Check for diffview buffers and empty buffers (dashboard/scratch)
        if bufname:match("^diffview://") or bufname:match("^git://") or bufname == "" then
          return false
        end

        return true
      end,
    },
    dashboard = {
      enabled = false, -- We'll handle this manually
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

              open_explorer({
                auto_close = false,
                layout = {
                  preset = "left",
                  preview = false,
                },
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
          { key = "o", desc = "Octo Issues", action = ":Octo issue search" },
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
            ["<C-a>"] = false, -- Disable select all - it's distracting
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
            context_menu = {
              action = function(picker, item)
                require("utils.picker-extensions").actions.context_menu(picker, item)
              end,
            },
          },
          win = {
            list = {
              keys = {
                ["<BS>"] = false, -- Disable backspace navigation
                ["a"] = "list_down", -- Remap 'a' to down movement (HAEI layout)
                ["c"] = "create", -- Remap 'c' to create file/folder
                ["/"] = "toggle_focus",
                ["<C-c>"] = "focus_input",
                ["<C-a>"] = false, -- Disable select all - it's distracting
                ["p"] = "copy_file_path",
                ["g"] = "search_in_directory", -- Opens a grep snacks
                ["i"] = function(picker)
                  require("utils.picker-extensions").actions.handle_directory_expansion(picker)
                end, -- Expand/collapse directory
                ["h"] = "explorer_close", -- Collapse/close directory
                -- Git status navigation (Graphite layout: A=down/next, E=up/prev)
                ["A"] = "explorer_git_next", -- Next git status file
                ["E"] = "explorer_git_prev", -- Previous git status file
                -- Conflict navigation (using error navigation as proxy for conflicts)
                ["]]"] = "explorer_warn_next", -- Next conflict/error
                ["[["] = "explorer_error_prev", -- Previous conflict/error
                ["D"] = "diff",
                ["r"] = "explorer_add", -- Create file/folder
                ["x"] = false, -- Disable default x binding
                ["R"] = "explorer_rename", -- Rename on 'R',
                ["<C-CR>"] = "open_multiple_buffers", -- This references the action above,
                ["f"] = "context_menu",
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
          actions = {
            context_menu = {
              action = function(picker, item)
                require("utils.picker-extensions").actions.context_menu(picker, item)
              end,
            },
          },
          win = {
            list = {
              keys = {
                ["f"] = "context_menu",
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
          actions = {
            buffer_context_menu = {
              action = function(picker, item)
                require("utils.picker-extensions").actions.buffer_context_menu(picker, item)
              end,
            },
          },
          win = {
            list = {
              keys = {
                ["f"] = "buffer_context_menu",
              },
            },
          },
        },
        git_status = {
          focus = "list",
          layout = "sidebar",
          actions = {
            git_context_menu = {
              action = function(picker, item)
                require("utils.picker-extensions").actions.git_context_menu(picker, item)
              end,
            },
            toggle_conflict_filter = {
              action = function(picker)
                require("utils.picker-extensions").actions.toggle_conflict_filter(picker)
              end,
            },
          },
          win = {
            list = {
              keys = {
                ["f"] = "git_context_menu",
                ["s"] = { "git_stage", mode = { "n", "i" } },
                ["<M-c>"] = "toggle_conflict_filter",
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
                ["p"] = function(picker, item)
                  -- Show git branch context menu with all git actions
                  local picker_extensions = require("utils.picker-extensions")
                  local current_item, err = picker_extensions.get_current_item(picker)
                  if not err and current_item then
                    picker_extensions.actions.context_menu(picker, current_item)
                  else
                    vim.notify("No branch selected", vim.log.levels.WARN)
                  end
                end,
                ["v"] = function(picker, item)
                  -- Direct diff action
                  local picker_extensions = require("utils.picker-extensions")
                  local current_item, err = picker_extensions.get_current_item(picker)
                  if not err and current_item then
                    local branch = picker_extensions.get_branch_name(current_item)
                    if not branch then
                      vim.notify("No branch selected", vim.log.levels.WARN)
                      return
                    end
                    local cmd = "DiffviewOpen HEAD.." .. vim.fn.shellescape(branch)
                    local ok, error = pcall(vim.cmd, cmd)
                    if not ok then
                      vim.notify("Error opening diff: " .. error, vim.log.levels.ERROR)
                    end
                  else
                    vim.notify("No branch selected", vim.log.levels.WARN)
                  end
                end,
              },
            },
          },
        },
        git_diff = {
          focus = "list",
        },
        git_log = {
          -- TODO <leader>gL showr a git log for commit for current buffer
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
    -- {
    --   "<leader>gC",
    --   function()
    --     require("utils.picker-extensions").actions.git_conflicts()
    --   end,
    --   desc = "Git Conflicts",
    -- },
    {
      "<leader>gC",
      function()
        require("utils.picker-extensions").actions.git_conflicts_explorer()
      end,
      desc = "Git Conflicts Explorer",
    },
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
  config = function(_, opts)
    require("snacks").setup(opts)

    -- Manual dashboard control based on conditions
    vim.api.nvim_create_autocmd("UIEnter", {
      once = true,
      callback = function()
        -- Check conditions for showing dashboard
        local should_show = true

        -- Don't show if there are file arguments
        if vim.fn.argc() > 0 then
          should_show = false
        end

        -- Don't show if NO_DASHBOARD env var is set
        if vim.env.NO_DASHBOARD == "1" then
          should_show = false
        end

        -- Don't show if current buffer already has content
        if vim.api.nvim_buf_get_name(0) ~= "" then
          should_show = false
        end

        if should_show then
          -- Temporarily enable dashboard for this one setup call
          require("snacks").config.dashboard.enabled = true
          require("snacks.dashboard").setup()
          require("snacks").config.dashboard.enabled = false -- Reset
        end
      end,
    })
  end,
}
