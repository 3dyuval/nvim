return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  opts = function()
    local actions = require("diffview.actions")
    return {
      enhanced_diff_hl = true, -- Better word-level diff highlighting
      use_icons = true,
      show_help_hints = true, -- Show keyboard shortcuts
      watch_index = false, -- Disabled to reduce file watchers (see issue #48)
      default_args = {
        DiffviewOpen = { "--imply-local" },
        DiffviewFileHistory = { "--base=LOCAL" },
      },
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        merge_tool = {
          layout = "diff1_plain",
          disable_diagnostics = false, -- Keep diagnostics enabled for conflict highlights
        },
        file_history = {
          layout = "diff2_horizontal",
        },
      },
      diff_binaries = false,
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
      },
      keymaps = {
        disable_defaults = true, -- Disable all default keymaps
        view = {
          -- Smart diff operations (consistent with keymaps.lua)
          {
            "n",
            "go",
            function()
              local smart_diff = require("utils.smart-diff")
              smart_diff.smart_diffget()
            end,
            { desc = "Get hunk (smart)" },
          },
          {
            "n",
            "gp",
            function()
              local smart_diff = require("utils.smart-diff")
              smart_diff.smart_diffput()
            end,
            { desc = "Put hunk (smart)" },
          },

          -- Git conflict resolution (consistent with keymaps.lua)
          {
            "n",
            "gO",
            function()
              local smart_diff = require("utils.smart-diff")
              smart_diff.smart_resolve_theirs()
            end,
            { desc = "Resolve file: theirs" },
          },
          {
            "n",
            "gP",
            function()
              local smart_diff = require("utils.smart-diff")
              smart_diff.smart_resolve_ours()
            end,
            { desc = "Resolve file: ours" },
          },
          {
            "n",
            "gU",
            function()
              local smart_diff = require("utils.smart-diff")
              smart_diff.smart_resolve_union()
            end,
            { desc = "Resolve file: union" },
          },
          {
            "n",
            "gR",
            function()
              local smart_diff = require("utils.smart-diff")
              smart_diff.smart_restore_conflicts()
            end,
            { desc = "Restore conflict markers" },
          },

          -- Navigation (HAEI compatible)
          { "n", "]]", actions.next_conflict, { desc = "Next conflict" } },
          { "n", "[[", actions.prev_conflict, { desc = "Previous conflict" } },
          { "n", "A", "]c", { desc = "Next diff hunk" } },
          { "n", "E", "[c", { desc = "Previous diff hunk" } },

          -- Common actions
          { "n", "<leader>.", actions.cycle_layout, { desc = "Cycle layout" } },
          { "n", "q", actions.close, { desc = "Close diffview" } },
          { "n", "<tab>", actions.select_next_entry, { desc = "Open diff for next file" } },
          { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open diff for previous file" } },
          { "n", "<leader>gf", actions.goto_file_edit, { desc = "Go to file" } },
          { "n", "<C-s>", actions.stage_all, { desc = "Stage all" } },
          { "n", "?", actions.help("view"), { desc = "Help" } },
        },
        file_panel = {
          { "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
          { "n", "o", actions.select_entry, { desc = "Open diff" } },
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diffview" } },
          { "n", "?", actions.help("file_panel"), { desc = "Help" } },
        },
        file_history_panel = {
          { "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
          { "n", "o", actions.select_entry, { desc = "Open diff" } },
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diffview" } },
          { "n", "?", actions.help("file_history_panel"), { desc = "Help" } },
        },
        help_panel = {
          { "n", "q", actions.close, { desc = "Close help menu" } },
          { "n", "<esc>", actions.close, { desc = "Close help menu" } },
        },
      },
      hooks = {
        diff_buf_read = function(bufnr)
          -- Disable folding in diff buffers
          vim.opt_local.foldenable = false
          -- Disable snacks scope/indent features for diff buffers to prevent window ID errors
          -- This fixes the known issue: https://github.com/folke/snacks.nvim/issues/1791
          vim.b[bufnr].snacks_indent = false
          vim.b[bufnr].snacks_scope = false
        end,
        view_opened = function()
          -- Additional safety: disable snacks features globally when diffview is active
          vim.g.diffview_active = true
        end,
        view_closed = function()
          -- Re-enable when diffview closes
          vim.g.diffview_active = false
        end,
      },
    }
  end,
}
