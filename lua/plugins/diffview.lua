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
      keys = {
        view = {

          ["gO"] = function()
            local file = vim.fn.expand("%")
            vim.cmd("update") -- Save any changes first
            vim.cmd("!git checkout --theirs -- " .. vim.fn.shellescape(file))
            vim.cmd("edit!")
          end,
          ["gP"] = function()
            local file = vim.fn.expand("%")
            vim.cmd("update")
            vim.cmd("!git checkout --ours -- " .. vim.fn.shellescape(file))
            vim.cmd("edit!")
          end,
          ["gR"] = function()
            -- restore conflict markers
            local file = vim.fn.expand("%")
            vim.cmd("update")
            vim.cmd("!git checkout --merge -- " .. vim.fn.shellescape(file))
            vim.cmd("edit!")
          end,
          ["gp"] = function()
            actions.diffget("local")
          end,
          ["go"] = function()
            actions.diffget("ours")
          end,
          ["gu"] = function()
            actions.diffget("theirs")
          end,
          ["<leader>."] = actions.cycle_layout,
          ["<leader>q"] = actions.close,
          ["<leader>gf"] = actions.goto_file_edit,
          ["]]"] = actions.next_conflict,
          ["[["] = actions.prev_conflict,
          ["A"] = "]c",
          ["E"] = "[c",
          ["<C-s>"] = actions.stage_all,
          ["g<C-x>"] = false,
          ["<leader>co"] = false,
          ["<leader>ct"] = false,
          ["<leader>cb"] = false,
          ["<leader>ca"] = false,
          ["<leader>cO"] = false,
          ["<leader>cT"] = false,
          ["<leader>cB"] = false,
          ["<leader>cA"] = false,
          ["dx"] = false,
          ["dX"] = false,
          ["?"] = actions.help("view"),
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
