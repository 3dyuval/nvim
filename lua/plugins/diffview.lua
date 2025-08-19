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

    diffview.setup({
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
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
      },
      keymaps = {
        view = {
          -- Common keys
          ["<leader>."] = actions.cycle_layout,
          ["<leader>q"] = actions.close,
          ["<leader>gf"] = actions.goto_file_edit,
          
          -- Direct vim commands (work in view context)
          ["go"] = "<Cmd>diffget<CR>",
          ["gp"] = "<Cmd>diffput<CR>",

          -- Git resolve operations
          ["gO"] = function() require("git-resolve-conflict").resolve_theirs() end,
          ["gP"] = function() require("git-resolve-conflict").resolve_ours() end,
          ["gR"] = function() require("git-resolve-conflict").restore_file_conflict() end,
          
          -- Diffview actions
          ["ghP"] = function() actions.diffget("LOCAL") end,
          ["ghO"] = function() actions.diffget("OURS") end,
          ["ghU"] = function() actions.diffget("THEIRS") end,

          -- Navigation
          ["]]"] = actions.next_conflict,
          ["[["] = actions.prev_conflict,
          ["A"] = "]c",
          ["E"] = "[c",
          ["<C-s>"] = function() actions.stage_all() end,

          -- Disabled keys
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
        file_panel = {
          -- Common keys
          ["<leader>."] = actions.cycle_layout,
          ["<leader>q"] = actions.close,
          ["<leader>gf"] = actions.view_windo(actions.goto_file_edit),
          
          -- Vim commands (need view_windo wrapper in panel)
          ["go"] = actions.view_windo(function() vim.cmd("diffget") end),
          ["gp"] = actions.view_windo(function() vim.cmd("diffput") end),

          -- Git resolve operations (need view_windo wrapper in panel)
          ["gO"] = actions.view_windo(function() require("git-resolve-conflict").resolve_theirs() end),
          ["gP"] = actions.view_windo(function() require("git-resolve-conflict").resolve_ours() end),
          ["gR"] = actions.view_windo(function() require("git-resolve-conflict").restore_file_conflict() end),
          
          -- Diffview actions (need view_windo wrapper in panel)
          ["ghP"] = actions.view_windo(function() actions.diffget("LOCAL") end),
          ["ghO"] = actions.view_windo(function() actions.diffget("OURS") end),
          ["ghU"] = actions.view_windo(function() actions.diffget("THEIRS") end),

          -- Navigation (need view_windo wrapper in panel)
          ["]]"] = actions.view_windo(actions.next_conflict),
          ["[["] = actions.view_windo(actions.prev_conflict),
          ["A"] = actions.view_windo(function() vim.cmd("norm! ]c") end),
          ["E"] = actions.view_windo(function() vim.cmd("norm! [c") end),
          ["<C-s>"] = actions.view_windo(function() actions.stage_all() end),

          -- Disabled keys
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
          ["?"] = actions.help("file_panel"),
        },
        file_history_panel = {
          -- Common keys
          ["<leader>."] = actions.cycle_layout,
          ["<leader>q"] = actions.close,
          ["<leader>gf"] = actions.view_windo(actions.goto_file_edit),
          
          -- Vim commands (need view_windo wrapper in panel)
          ["go"] = actions.view_windo(function() vim.cmd("diffget") end),
          ["gp"] = actions.view_windo(function() vim.cmd("diffput") end),

          -- Git resolve operations (need view_windo wrapper in panel)
          ["gO"] = actions.view_windo(function() require("git-resolve-conflict").resolve_theirs() end),
          ["gP"] = actions.view_windo(function() require("git-resolve-conflict").resolve_ours() end),
          ["gR"] = actions.view_windo(function() require("git-resolve-conflict").restore_file_conflict() end),
          
          -- Diffview actions (need view_windo wrapper in panel)
          ["ghP"] = actions.view_windo(function() actions.diffget("LOCAL") end),
          ["ghO"] = actions.view_windo(function() actions.diffget("OURS") end),
          ["ghU"] = actions.view_windo(function() actions.diffget("THEIRS") end),

          -- Navigation (need view_windo wrapper in panel)
          ["]]"] = actions.view_windo(actions.next_conflict),
          ["[["] = actions.view_windo(actions.prev_conflict),
          ["A"] = actions.view_windo(function() vim.cmd("norm! ]c") end),
          ["E"] = actions.view_windo(function() vim.cmd("norm! [c") end),
          ["<C-s>"] = actions.view_windo(function() actions.stage_all() end),

          -- Disabled keys
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
          ["?"] = actions.help("file_history_panel"),
        },
      },
    })
  end,
}
