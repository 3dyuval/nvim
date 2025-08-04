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
      -- diffput rarely works in diffview contexts - most buffers are read-only
      vim.notify(
        "diffput not available: target buffer is typically read-only in diffview",
        vim.log.levels.WARN
      )
    end

    -- Union operation: combine current hunk with hunk from other diff buffer
    -- Based on: https://vi.stackexchange.com/a/36854/38754
    local function pure_diff_union()
      if not vim.bo.modifiable then
        vim.notify("Current buffer is not modifiable", vim.log.levels.WARN)
        return
      end

      -- Helper function to check if line is part of diff
      local function is_diff_line(line_no)
        return vim.fn.diff_hlID(line_no, 1) > 0
      end

      -- Find start and end of current diff hunk
      local function get_hunk_range()
        local line = vim.fn.line(".")
        if not is_diff_line(line) then
          return nil, nil
        end

        local startline = line
        while is_diff_line(startline - 1) do
          startline = startline - 1
        end

        local endline = line
        while is_diff_line(endline + 1) do
          endline = endline + 1
        end

        return startline, endline
      end

      local startline, endline = get_hunk_range()
      if not startline then
        vim.notify("Cursor is not on a diff hunk", vim.log.levels.WARN)
        return
      end

      -- Find the other diff buffer
      local other_win = nil
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if buf ~= vim.api.nvim_get_current_buf() and vim.bo[buf].diff then
          other_win = win
          break
        end
      end

      if not other_win then
        vim.notify("No other diff buffer found", vim.log.levels.WARN)
        return
      end

      -- Get lines from current buffer
      local current_lines = vim.api.nvim_buf_get_lines(0, startline - 1, endline, false)

      -- Get corresponding lines from other buffer
      local other_buf = vim.api.nvim_win_get_buf(other_win)
      local other_lines = vim.api.nvim_buf_get_lines(other_buf, startline - 1, endline, false)

      -- Combine lines (current first, then other)
      local union_lines = {}
      for _, line in ipairs(current_lines) do
        table.insert(union_lines, line)
      end
      for _, line in ipairs(other_lines) do
        table.insert(union_lines, line)
      end

      -- Replace current hunk with union
      vim.api.nvim_buf_set_lines(0, startline - 1, endline, false, union_lines)
      vim.notify("Combined hunk from both buffers", vim.log.levels.INFO)
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
          layout = "diff1_plain",
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
          ["<leader>."] = actions.cycle_layout,
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

          -- Conflict navigation using diffview actions
          { "n", "]]", actions.next_conflict, { desc = "Next conflict" } },
          { "n", "[[", actions.prev_conflict, { desc = "Previous conflict" } },

          -- Diff hunk navigation (Graphite layout: A=down, E=up)
          { "n", "A", "]c", { desc = "Next diff hunk" } },
          { "n", "E", "[c", { desc = "Previous diff hunk" } },

          -- Diff operations (works in working tree buffer)
          { "n", "go", pure_diff_get, { desc = "Get hunk from other buffer" } },

          -- Conflict resolution actions
          -- File-wide: resolve entire file
          { "n", "<leader>gO", git_resolve.resolve_ours, { desc = "Resolve file: OURS" } },
          { "n", "<leader>gP", git_resolve.resolve_theirs, { desc = "Resolve file: THEIRS" } },
          { "n", "<leader>gV", git_resolve.resolve_union, { desc = "Resolve file: UNION" } },

          -- Hunk-level: resolve current conflict hunk only
          { "n", "gho", actions.conflict_choose("ours"), { desc = "Resolve hunk: OURS" } },
          { "n", "ghp", actions.conflict_choose("theirs"), { desc = "Resolve hunk: THEIRS" } },
          { "n", "ghu", actions.conflict_choose("all"), { desc = "Resolve hunk: UNION (both)" } },
        },
        file_panel = {
          ["<leader>."] = actions.cycle_layout,
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
          { "n", "]]", actions.view_windo(actions.next_conflict)({ desc = "Next conflict" }) },
          { "n", "[[", actions.view_windo(actions.prev_conflict), { desc = "Previous conflict" } },
        },
        file_history_panel = {
          ["g<C-x>"] = false, -- Disable default layout cycling
          ["<leader>."] = actions.cycle_layout,
          ["q"] = "<Cmd>DiffviewClose<CR>",
          ["?"] = actions.help("file_history_panel"),
          -- Conflict navigation using diffview actions
          { "n", "]]", actions.view_windo(actions.next_conflict)({ desc = "Next conflict" }) },
          { "n", "[[", actions.view_windo(actions.prev_conflict), { desc = "Previous conflict" } },

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
