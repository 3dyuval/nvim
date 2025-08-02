return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "3dyuval/git-resolve-conflict.nvim",
  },
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  config = function()
    local ok, diffview = pcall(require, "diffview")
    if not ok then
      vim.notify("Failed to load diffview.nvim", vim.log.levels.ERROR)
      return
    end

    local actions = require("diffview.actions")
    local git_resolve = require("git-resolve-conflict")
    local git_conflict = require("utils.git-conflict")

    -- Pure diff operations (no conflict handling)
    local function pure_diff_get()
      -- Try numbered diffget first (for 3-way diffs), fallback to regular
      local ok = pcall(function()
        vim.cmd("diffget 3")
      end)
      if not ok then
        -- This will work in file history with --base=LOCAL
        vim.cmd("diffget")
      end
    end

    local function pure_diff_put()
      -- File history buffers are read-only, diffput doesn't make sense here
      if not vim.bo.modifiable then
        vim.notify("Cannot put changes to historical file versions", vim.log.levels.WARN)
        return
      end

      -- For 3-way merge, use numbered dp commands
      local ok = pcall(function()
        vim.cmd("diffput 1")
      end)
      if not ok then
        vim.cmd("diffput")
      end
    end

    -- Smart get all hunks - uses restore_entry in file history mode
    local function smart_get_all()
      if not vim.bo.modifiable then
        -- In file history mode, use restore_entry
        local view = require("diffview.lib").get_current_view()
        if
          view
          and view:instanceof(
            require("diffview.scene.views.file_history.file_history_view").FileHistoryView
          )
        then
          actions.restore_entry()
          return
        end
      end
      -- Normal mode: get all hunks
      vim.cmd("%diffget")
    end

    diffview.setup({
      enhanced_diff_hl = true, -- Better word-level diff highlighting
      use_icons = true,
      show_help_hints = true, -- Show keyboard shortcuts
      watch_index = true, -- Update automatically
      -- Default args to ensure proper merge conflict handling
      default_args = {
        DiffviewOpen = { "--imply-local" },
        DiffviewFileHistory = { "--base=LOCAL" },
      },
      view = {
        default = {
          layout = "diff2_horizontal",
          winbar_info = true,
        },
        merge_tool = {
          layout = "diff3_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          winbar_info = false,
        },
      },
      diff_binaries = false,
      hooks = {
        diff_buf_read = function()
          -- Disable folding in diff buffers
          vim.opt_local.foldenable = false
          -- Disable snacks scope/indent features for diff buffers
          vim.b.snacks_indent = false
          vim.b.snacks_scope = false
        end,
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
      },
      keymaps = {
        view = {
          ["<leader>gV"] = actions.cycle_layout,
          ["g<C-x>"] = false, -- Disable default layout cycling
          -- Disable default leader mappings
          ["<leader>co"] = false,
          ["<leader>ct"] = false,
          ["<leader>cb"] = false,
          ["<leader>ca"] = false,
          ["<leader>cO"] = false,
          ["<leader>cT"] = false,
          ["<leader>cB"] = false,
          ["<leader>cA"] = false,
          ["dx"] = false, -- Disable default conflict delete
          ["dX"] = false, -- Disable default conflict delete all

          ["q"] = "<Cmd>DiffviewClose<CR>",
          ["?"] = actions.help("view"),
          {
            "n",
            "A",
            actions.view_windo(function()
              vim.cmd("norm! ]c")
            end),
            { desc = "Next diff hunk" },
          },
          {
            "n",
            "E",
            actions.view_windo(function()
              vim.cmd("norm! [c")
            end),
            { desc = "Previous diff hunk" },
          },
          -- Pure diff operations (no conflict handling)
          { "n", "go", pure_diff_get, { desc = "Diff get from theirs" } },
          { "n", "gp", pure_diff_put, { desc = "Diff put to theirs" } },
          { "n", "gO", smart_get_all, { desc = "Get ALL hunks / restore file" } },
          { "n", "gP", "<Cmd>%diffput<CR>", { desc = "Put ALL hunks to theirs" } },

          -- Discrete conflict resolution hunk bindings
          { "n", "gho", actions.conflict_choose("ours"), { desc = "Resolve hunk: OURS" } },
          { "n", "ghp", actions.conflict_choose("theirs"), { desc = "Resolve hunk: THEIRS" } },
          { "n", "ghu", actions.conflict_choose("all"), { desc = "Resolve hunk: UNION (both)" } },

          -- Diff navigation using built-in commands
          { "n", "]c", "]c", { desc = "Next diff hunk" } },
          { "n", "[c", "[c", { desc = "Previous diff hunk" } },

          -- Conflict navigation using diffview actions
          { "n", "]x", actions.next_conflict, { desc = "Next conflict" } },
          { "n", "[x", actions.prev_conflict, { desc = "Previous conflict" } },

          -- Conflict resolution actions (hunk-level)
          { "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose OURS (hunk)" } },
          {
            "n",
            "<leader>ct",
            actions.conflict_choose("theirs"),
            { desc = "Choose THEIRS (hunk)" },
          },
          { "n", "<leader>cb", actions.conflict_choose("base"), { desc = "Choose BASE (hunk)" } },
          { "n", "<leader>ca", actions.conflict_choose("all"), { desc = "Choose ALL (hunk)" } },
          {
            "n",
            "<leader>cn",
            actions.conflict_choose("none"),
            { desc = "Delete conflict (hunk)" },
          },

          -- File-wide conflict resolution using git-resolve-conflict
          { "n", "<leader>gO", git_resolve.resolve_ours, { desc = "Resolve file: OURS" } },
          { "n", "<leader>gT", git_resolve.resolve_theirs, { desc = "Resolve file: THEIRS" } },
          { "n", "<leader>gU", git_resolve.resolve_union, { desc = "Resolve file: UNION" } },
        },
        file_panel = {
          ["<leader>gV"] = actions.cycle_layout,
          ["g<C-x>"] = false, -- Disable default layout cycling
          ["<leader>cO"] = false,
          ["<leader>cT"] = false,
          ["<leader>cB"] = false,
          ["<leader>cA"] = false,
          ["q"] = "<Cmd>DiffviewClose<CR>",
          ["?"] = actions.help("file_panel"),

          -- Navigation from file panel using view_windo
          {
            "n",
            "A",
            actions.view_windo(function()
              vim.cmd("norm! ]c")
            end),
            { desc = "Next diff hunk" },
          },
          {
            "n",
            "E",
            actions.view_windo(function()
              vim.cmd("norm! [c")
            end),
            { desc = "Previous diff hunk" },
          },

          -- Pure diff operations from file panel using view_windo
          {
            "n",
            "go",
            actions.view_windo(pure_diff_get),
            { desc = "Diff get from theirs" },
          },
          {
            "n",
            "gp",
            actions.view_windo(pure_diff_put),
            { desc = "Diff put to theirs" },
          },
          {
            "n",
            "gO",
            actions.view_windo(smart_get_all),
            { desc = "Get ALL hunks / restore file" },
          },
          {
            "n",
            "gP",
            actions.view_windo(function()
              vim.cmd("%diffput")
            end),
            { desc = "Put ALL hunks to theirs" },
          },

          -- Discrete conflict resolution hunk bindings from file panel
          {
            "n",
            "gho",
            actions.view_windo(actions.conflict_choose("ours")),
            { desc = "Resolve hunk: OURS" },
          },
          {
            "n",
            "ghp",
            actions.view_windo(actions.conflict_choose("theirs")),
            { desc = "Resolve hunk: THEIRS" },
          },
          {
            "n",
            "ghu",
            actions.view_windo(actions.conflict_choose("all")),
            { desc = "Resolve hunk: UNION (both)" },
          },
          -- Conflict navigation from file panel
          { "n", "]x", actions.next_conflict, { desc = "Next conflict" } },
          { "n", "[x", actions.prev_conflict, { desc = "Previous conflict" } },
        },
        file_history_panel = {
          ["<leader>gV"] = actions.cycle_layout,
          ["g<C-x>"] = false, -- Disable default layout cycling
          ["q"] = "<Cmd>DiffviewClose<CR>",
          ["?"] = actions.help("file_history_panel"),
          {
            "n",
            "A",
            actions.view_windo(function()
              vim.cmd("norm! ]c")
            end),
            { desc = "Next diff hunk" },
          },
          {
            "n",
            "E",
            actions.view_windo(function()
              vim.cmd("norm! [c")
            end),
            { desc = "Previous diff hunk" },
          },
        },
      },
    })
  end,
}
