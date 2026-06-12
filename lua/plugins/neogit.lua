return {
  "NeogitOrg/neogit",
  dev = true,
  cmd = {"Neogit", "NeogitResetState", "NeogitConflictResolve"},
  -- build = [[
  --     git remote add upstream https://github.com/3dyuval/neogit.git 2>/dev/null
  --     git fetch upstream
  --     git merge upstream/master --no-edit || git merge --abort
  --   ]],
  dependencies = {
    "nvim-lua/plenary.nvim",
    "dlyongemallo/diffview-plus.nvim",
    "folke/snacks.nvim",
    "3dyuval/git-resolve-conflict.nvim"
  },
  config = function(_, opts)
    require("utils.neogit-commands").setup()

vim.api.nvim_create_autocmd(
      "FileType",
      {
        pattern = "NeogitStatus",
        callback = function(args)
          vim.keymap.set(
            "n",
            "D",
            function()
              require("utils.neogit-commands").create_conflict_popup()
            end,
            {
              buffer = args.buf,
              desc = "File resolution popup",
              nowait = true
            }
          )
          -- Force disable 'm' key in Neogit
          pcall(vim.keymap.del, "n", "m", {buffer = args.buf})
        end
      }
    )

    -- HAEI: z = undo in rebase editor
    vim.api.nvim_create_autocmd(
      "FileType",
      {
        pattern = "NeogitRebaseTodo",
        callback = function(args)
          vim.keymap.set("n", "z", "u", {buffer = args.buf, desc = "Undo"})
        end
      }
    )

    require("neogit").setup(opts)
  end,
  opts = {
    graph_style = "kitty",
    console_timeout = 100,
    auto_show_console = true,
    auto_show_console_on = "error",
    auto_close_console = false,
    filewatcher = {
      enabled = true,
      debounce_ms = 500 -- Increased from default 200ms for better performance
    },
    integrations = {
      diffview = true,
      telescope = false,
      snacks = true
    },
    merge_editor = {
      kind = "auto"
    },
    commit_view = {
      kind = "vsplit"
    },
    log_view = {
      kind = "tab"
    },
    autoinstall = true,
    -- Set default popup configurations
    builders = {
      NeogitLogPopup = function(popup)
        -- Enable graph, color, and decorate by default
        for _, arg in ipairs(popup.state.args) do
          if arg.cli == "graph" and arg.type == "switch" then
            arg.enabled = true
          elseif arg.cli == "color" and arg.type == "switch" then
            arg.enabled = true
          elseif arg.cli == "decorate" and arg.type == "switch" then
            arg.enabled = true
          end
        end
      end,
      NeogitCommitPopup = function(popup)
        -- Insert AI Commit into the "Create" column (first action group)
        table.insert(
          popup.state.actions[1],
          {
            keys = {"i"},
            description = "AI Commit",
            callback = function()
              require("utils.ai_popup").create()
            end
          }
        )
      end,
      NeogitRebasePopup = function(popup)
        -- Add strategy options for conflict resolution (-Xtheirs, -Xours)
        popup:switch("g", "Xtheirs", "Accept theirs on conflicts", {cli_prefix = "-"})
        popup:switch("p", "Xours", "Accept ours on conflicts", {cli_prefix = "-"})
      end
    },
    mappings = {
      popup = {
        ["m"] = false,
        ["M"] = "MergePopup"
      },
      status = {
        ["C"] = "YankSelected",
        ["m"] = false, -- disable merge to use your custom binding
        ["s"] = "Stage", -- override 's' key to stage files
        ["<leader>q"] = "Close", -- Close Neogit
        ["I"] = function()
          require("utils.ai_popup").repeat_last()
        end,
        ["D"] = function()
          require("utils.neogit-commands").create_conflict_popup()
        end
      },
      rebase_editor = {
        -- HAEI navigation with Alt
        ["<M-e>"] = "MoveUp",
        ["<M-a>"] = "MoveDown",
        ["gk"] = false,
        ["gj"] = false,
        -- Rebase actions with Alt
        ["<M-p>"] = "Pick",
        ["<M-r>"] = "Reword",
        ["<M-s>"] = "Squash",
        ["<M-f>"] = "Fixup",
        ["<M-x>"] = "Execute",
        ["<M-d>"] = "Drop",
        ["<M-b>"] = "Break",
        -- Disable single-letter defaults (conflict with HAEI)
        ["p"] = false,
        ["r"] = false,
        ["e"] = false,
        ["s"] = false,
        ["f"] = false,
        ["x"] = false,
        ["d"] = false,
        ["b"] = false
      }
    }
  }
}
