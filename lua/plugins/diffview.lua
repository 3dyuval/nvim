return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  config = function()
    local ok, diffview = pcall(require, "diffview")
    if not ok then
      vim.notify("Failed to load diffview.nvim", vim.log.levels.ERROR)
      return
    end

    local actions = require("diffview.actions")

    local keymaps = {
      { "n", "<leader>q", actions.close, { desc = "Close the subject of the context" } },
      { "n", "A", "]c", { desc = "Next diff hunk" } },
      { "n", "E", "[c", { desc = "Previous diff hunk" } },
      { "n", "gp", actions.diffget("ours"), { desc = "Put hunk from ours" } },
      { "n", "go", actions.diffget("theirs"), { desc = "Get hunk from theirs" } },
      { "n", "gu", actions.diffget("all"), { desc = "Get union of both hunks" } },
      {
        "n",
        "j",
        false,
        { desc = "Bring the cursor to the next file entry" },
      },
      {
        "n",
        "<down>",
        false,
        { desc = "Bring the cursor to the next file entry" },
      },
      {
        "n",
        "k",
        false,
        { desc = "Bring the cursor to the previous file entry" },
      },
      {
        "n",
        "<up>",
        false,
        { desc = "Bring the cursor to the previous file entry" },
      },
      {
        "n",
        "<cr>",
        actions.select_entry,
        { desc = "Open the diff for the selected entry" },
      },
      {
        "n",
        "o",
        false,
        { desc = "Open the diff for the selected entry" },
      },
      {
        "n",
        "l",
        false,
        { desc = "Open the diff for the selected entry" },
      },
      {
        "n",
        "<2-LeftMouse>",
        false,
        { desc = "Open the diff for the selected entry" },
      },
      {
        "n",
        "-",
        false,
        { desc = "Stage / unstage the selected entry" },
      },
      {
        "n",
        "s",
        actions.toggle_stage_entry,
        { desc = "Stage / unstage the selected entry" },
      },
      {
        "n",
        "S",
        actions.stage_all,
        { desc = "Stage all entries" },
      },
      {
        "n",
        "U",
        actions.unstage_all,
        { desc = "Unstage all entries" },
      },
      {
        "n",
        "X",
        actions.restore_entry,
        { desc = "Restore entry to the state on the left side" },
      },
      {
        "n",
        "L",
        actions.open_commit_log,
        { desc = "Open the commit log panel" },
      },
      {
        "n",
        "zo",
        actions.open_fold,
        { desc = "Expand fold" },
      },
      { "n", "h", false, { desc = "Collapse fold" } },
      { "n", "zc", false, { desc = "Collapse fold" } },
      { "n", "za", false, { desc = "Toggle fold" } },
      { "n", "zR", false, { desc = "Expand all folds" } },
      {
        "n",
        "ff",
        actions.close_all_folds,
        { desc = "Collapse all folds" },
      },
      {
        "n",
        "<c-b>",
        actions.scroll_view(-0.25),
        { desc = "Scroll the view up" },
      },
      {
        "n",
        "<c-f>",
        actions.scroll_view(0.25),
        { desc = "Scroll the view down" },
      },
      {
        "n",
        "<tab>",
        actions.select_next_entry,
        { desc = "Open the diff for the next file" },
      },
      {
        "n",
        "<s-tab>",
        actions.select_prev_entry,
        { desc = "Open the diff for the previous file" },
      },
      {
        "n",
        "[F",
        actions.select_first_entry,
        { desc = "Open the diff for the first file" },
      },
      {
        "n",
        "]F",
        actions.select_last_entry,
        { desc = "Open the diff for the last file" },
      },
      {
        "n",
        "gf",
        actions.goto_file_edit,
        { desc = "Open the file in the previous tabpage" },
      },
      {
        "n",
        "<C-w><C-f>",
        actions.goto_file_split,
        { desc = "Open the file in a new split" },
      },
      {
        "n",
        "<C-w>gf",
        actions.goto_file_tab,
        { desc = "Open the file in a new tabpage" },
      },
      {
        "n",
        "i",
        actions.listing_style,
        { desc = "Toggle between 'list' and 'tree' views" },
      },
      {
        "n",
        "f",
        actions.toggle_flatten_dirs,
        { desc = "Flatten empty subdirectories in tree listing style" },
      },
      {
        "n",
        "<C-r>",
        actions.refresh_files,
        { desc = "Update stats and entries in the file list" },
      },
      {
        "n",
        "<leader>e",
        actions.focus_files,
        { desc = "Bring focus to the file panel" },
      },
      {
        "n",
        "<leader>b",
        actions.toggle_files,
        { desc = "Toggle the file panel" },
      },
      {
        "n",
        "<leader>.",
        actions.cycle_layout,
        { desc = "Cycle available layouts" },
      },
      {
        "n",
        "[[",
        actions.prev_conflict,
        { desc = "Go to the previous conflict" },
      },
      {
        "n",
        "]]",
        actions.next_conflict,
        { desc = "Go to the next conflict" },
      },
      {
        "n",
        "?",
        actions.help("file_panel"),
        { desc = "Open the help panel" },
      },
      {
        "n",
        "<leader>gO",
        actions.conflict_choose_all("theirs"),
        { desc = "Get THEIRS version for all conflicts" },
      },
      {
        "n",
        "<leader>gP",
        actions.conflict_choose_all("ours"),
        { desc = "Put OURS version for all conflicts" },
      },
      {
        "n",
        "<leader>gU",
        actions.conflict_choose_all("all"),
        { desc = "Choose ALL versions for all conflicts" },
      },
      {
        "n",
        "dX",
        false,
        { desc = "Delete the conflict region for the whole file" },
      },
    }

    diffview.setup({
      enhanced_diff_hl = true, -- Better word-level diff highlighting
      use_icons = true,
      show_help_hints = true, -- Show keyboard shortcuts
      watch_index = false, -- Disabled to reduce file watchers (see issue #48)
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
        view = keymaps,
        file_panel = keymaps,
      },
    })
  end,
}
