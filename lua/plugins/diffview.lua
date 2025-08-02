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

    -- Smart conflict detection function for reuse
    local function is_in_conflict()
      local ok, parser = pcall(vim.treesitter.get_parser, 0)
      if not ok then
        return false
      end

      local row = vim.api.nvim_win_get_cursor(0)[1] - 1
      local query = vim.treesitter.query.get(parser:lang(), "conflict")

      if query then
        local tree = parser:parse()[1]
        for _, node in query:iter_captures(tree:root(), 0, row, row + 1) do
          return true
        end
      end
      return false
    end

    -- Smart diff operations that handle both conflicts and regular diffs
    local function smart_get()
      if is_in_conflict() then
        actions.conflict_choose("theirs")()
      else
        -- Try numbered diffget first (for 3-way diffs), fallback to regular
        local ok = pcall(function()
          vim.cmd("diffget 3")
        end)
        if not ok then
          -- This will work in file history with --base=LOCAL
          vim.cmd("diffget")
        end
      end
    end

    local function smart_put()
      -- File history buffers are read-only, diffput doesn't make sense here
      if not vim.bo.modifiable then
        vim.notify("Cannot put changes to historical file versions", vim.log.levels.WARN)
        return
      end

      if is_in_conflict() then
        actions.conflict_choose("ours")()
      else
        -- For 3-way merge, use numbered dp commands
        local ok = pcall(function()
          vim.cmd("diffput 1")
        end)
        if not ok then
          vim.cmd("diffput")
        end
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

          -- Smart diff operations using shared functions
          { "n", "go", smart_get, { desc = "Smart get: conflict or diff" } },
          { "n", "gp", smart_put, { desc = "Smart put: conflict or diff" } },
          { "n", "gO", smart_get_all, { desc = "Get ALL hunks / restore file" } },
          { "n", "gP", "<Cmd>%diffput<CR>", { desc = "Put ALL hunks to theirs" } },

          -- Diff navigation using built-in commands
          { "n", "]c", "]c", { desc = "Next diff hunk" } },
          { "n", "[c", "[c", { desc = "Previous diff hunk" } },

          -- Section navigation mapped to diff navigation
          { "n", "A", "]c", { desc = "Next diff hunk (section)" } },
          { "n", "E", "[c", { desc = "Previous diff hunk (section)" } },

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
          {
            "n",
            "<leader>gr",
            git_resolve.pick_and_resolve,
            { desc = "Resolve file: pick strategy" },
          },
        },
        file_panel = {
          ["<leader>cO"] = false,
          ["<leader>cT"] = false,
          ["<leader>cB"] = false,
          ["<leader>cA"] = false,
          ["q"] = "<Cmd>DiffviewClose<CR>",
          ["?"] = actions.help("file_panel"),

          -- Navigation from file panel using view_windo
          {
            "n",
            "]c",
            actions.view_windo(function()
              vim.cmd("norm! ]c")
            end),
            { desc = "Next diff hunk" },
          },
          {
            "n",
            "[c",
            actions.view_windo(function()
              vim.cmd("norm! [c")
            end),
            { desc = "Previous diff hunk" },
          },

          -- Section navigation mapped to diff navigation from file panel
          {
            "n",
            "A",
            actions.view_windo(function()
              vim.cmd("norm! ]c")
            end),
            { desc = "Next diff hunk (section)" },
          },
          {
            "n",
            "E",
            actions.view_windo(function()
              vim.cmd("norm! [c")
            end),
            { desc = "Previous diff hunk (section)" },
          },

          -- Smart diff operations from file panel using view_windo
          {
            "n",
            "go",
            actions.view_windo(smart_get),
            { desc = "Smart get: conflict or diff" },
          },
          {
            "n",
            "gp",
            actions.view_windo(smart_put),
            { desc = "Smart put: conflict or diff" },
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

          -- Conflict navigation from file panel
          { "n", "]x", actions.next_conflict, { desc = "Next conflict" } },
          { "n", "[x", actions.prev_conflict, { desc = "Previous conflict" } },
        },
        file_history_panel = {
          ["q"] = "<Cmd>DiffviewClose<CR>",
          ["?"] = actions.help("file_history_panel"),
          {
            "n",
            "]c",
            actions.view_windo(function()
              vim.cmd("norm! ]c")
            end),
            { desc = "Next diff hunk" },
          },
          {
            "n",
            "[c",
            actions.view_windo(function()
              vim.cmd("norm! [c")
            end),
            { desc = "Previous diff hunk" },
          },

          -- Section navigation mapped to diff navigation from file history panel
          {
            "n",
            "A",
            actions.view_windo(function()
              vim.cmd("norm! ]c")
            end),
            { desc = "Next diff hunk (section)" },
          },
          {
            "n",
            "E",
            actions.view_windo(function()
              vim.cmd("norm! [c")
            end),
            { desc = "Previous diff hunk (section)" },
          },
        },
      },
    })
  end,
}
