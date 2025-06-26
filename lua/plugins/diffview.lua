return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gw", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diff with main branch" },
    { "<leader>gf", "<cmd>DiffviewFileHistory<cr>", desc = "File History (Diffview)" },
  },
  config = function()
    require("diffview").setup({
      enhanced_diff_hl = true, -- Better word-level diff highlighting
      use_icons = true,
      show_help_hints = true, -- Show keyboard shortcuts
      watch_index = true, -- Update automatically
      view = {
        default = {
          layout = "diff2_horizontal",
          winbar_info = true,
        },
        merge_tool = {
          layout = "diff3_horizontal",
        },
      },
      diff_binaries = false,
      use_icons = true,
      show_help_hints = true,
      watch_index = true,
      hooks = {
        diff_buf_read = function()
          -- Disable folding in diff buffers
          vim.opt_local.foldenable = false
        end,
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 40, -- Slightly wider to show stats
        },
      },
      keymaps = {
        view = {
          ["<leader>co"] = false,
          ["<leader>ct"] = false,
          ["<leader>cb"] = false,
          ["<leader>ca"] = false,
          ["<leader>cO"] = false,
          ["<leader>cT"] = false,
          ["<leader>cB"] = false,
          ["<leader>cA"] = false,
          ["q"] = "<Cmd>DiffviewClose<CR>",
          ["go"] = "<Cmd>diffget<CR>", -- Use go for diffget (take from other)
          ["gp"] = "<Cmd>diffput<CR>", -- Use gp for diffput (put to other)
          ["gO"] = "<Cmd>%diffget<CR>", -- Get ALL hunks from other buffer
          ["gP"] = "<Cmd>%diffput<CR>", -- Put ALL hunks to other buffer
          ["gs"] = function() -- Show diff statistics
            local added, removed, changed = 0, 0, 0
            for i = 1, vim.fn.line('$') do
              local hl = vim.fn.diff_hlID(i, 1)
              if hl == vim.fn.hlID('DiffAdd') then
                added = added + 1
              elseif hl == vim.fn.hlID('DiffDelete') then
                removed = removed + 1
              elseif hl == vim.fn.hlID('DiffChange') then
                changed = changed + 1
              end
            end
            vim.notify(string.format("Stats: +%d -%d ~%d", added, removed, changed))
          end,
        },
        file_panel = {
          ["<leader>cO"] = false,
          ["<leader>cT"] = false,
          ["<leader>cB"] = false,
          ["<leader>cA"] = false,
          ["q"] = "<Cmd>DiffviewClose<CR>",
        },
        file_history_panel = {
          ["q"] = "<Cmd>DiffviewClose<CR>",
        },
      },
    })
  end,
}