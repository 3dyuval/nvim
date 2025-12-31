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
          winbar_info = true, -- Show commit hash and info in window bar
          win_config = { position = "bottom" },
        },
        merge_tool = {
          layout = "diff1_plain",
          disable_diagnostics = false, -- Keep diagnostics enabled for conflict highlights
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          winbar_info = true,
          win_config = { position = "bottom" },
        },
      },
      diff_binaries = false,
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = false,
          folder_statuses = "only_folded",
        },
      },
      keymaps = {
        disable_defaults = true,
        view = {
          -- Smart diff get/put
          {
            "n",
            "dr",
            function()
              if vim.opt_local.diff:get() then
                vim.cmd("diffget")
              else
                actions.conflict_choose("theirs")
              end
            end,
            { desc = "Get from right" },
          },
          {
            "n",
            "dl",
            function()
              if vim.opt_local.diff:get() then
                vim.cmd("diffput")
              else
                actions.conflict_choose("ours")
              end
            end,
            { desc = "Put to left" },
          },

          -- Navigation (HAEI compatible)
          { "n", "]]", actions.next_conflict, { desc = "Next conflict" } },
          { "n", "[[", actions.prev_conflict, { desc = "Previous conflict" } },
          { "n", "m", "]c", { desc = "Next diff hunk" } },
          { "n", "M", "[c", { desc = "Previous diff hunk" } },

          -- Common actions
          { "n", "<leader>.", actions.cycle_layout, { desc = "Cycle layout" } },
          -- { "n", "<leader>f", actions., { desc = "Toggle File Panel" } },
          { "n", "q", actions.close, { desc = "Close diffview" } },
          { "n", "<tab>", actions.select_next_entry, { desc = "Open diff for next file" } },
          { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open diff for previous file" } },
          { "n", "<leader>gf", actions.goto_file_edit, { desc = "Go to file" } },
          { "n", "<C-s>", actions.stage_all, { desc = "Stage all" } },
          { "n", "?", actions.help("view"), { desc = "Help" } },
        },
        file_panel = {
          {
            "n",
            "dr",
            actions.restore_entry,
            { desc = "Restore file (get from right)" },
          },
          {
            "n",
            "dl",
            function()
              actions.toggle_stage_entry()
            end,
            { desc = "Stage file (get from left)" },
          },
          {
            "n",
            "<C-R>",
            actions.refresh_files,
            { desc = "Refresh Files" },
          },
          {
            "n",
            "m",
            "<Cmd>windo normal! ]c<Cr>",
            { desc = "Next hunk" },
          },
          {
            "n",
            "M",
            "<Cmd>windo normal! [c<Cr>",
            { desc = "Prev hunk" },
          },
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
