return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  event = { { event = "BufReadCmd", pattern = "octo://*" } },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = function()
    vim.treesitter.language.register("markdown", "octo")

    return {

      picker = "snacks",
      picker_config = {
        snacks = {
          layout = {
            preset = "sidebar",
          },
        },
      },
      enable_builtin = true,
      default_to_projects_v2 = false,
      default_merge_method = "squash",
      -- Note: Octo doesn't support global layout configuration in picker_config
      -- Each picker inherits from Snacks global config or needs manual override
    }
  end,
  config = function(_, opts)
    require("octo").setup(opts)
    vim.cmd([[hi OctoEditable guibg=none]])

    -- Disable swap files for Octo buffers - but NOT for picker buffers
    vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile", "BufEnter" }, {
      pattern = "octo://*",
      callback = function(ev)
        -- Only apply to actual octo:// buffers, not picker-related buffers
        local bufname = vim.api.nvim_buf_get_name(ev.buf)
        if bufname:match("^octo://") and vim.bo[ev.buf].buftype == "" then
          vim.opt_local.swapfile = false
          vim.opt_local.backup = false
          vim.opt_local.writebackup = false
        end
      end,
    })

    -- Also disable swap files for Octo picker buffers - but be more specific
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "OctoPanel",
      callback = function(ev)
        -- Add a check to prevent conflicts with Snacks picker
        if vim.bo[ev.buf].filetype == "OctoPanel" and vim.bo[ev.buf].buftype == "" then
          vim.opt_local.swapfile = false
          vim.opt_local.backup = false
          vim.opt_local.writebackup = false
        end
      end,
      -- })
      --
      -- -- Keep some empty windows in sessions
      -- vim.api.nvim_create_autocmd("ExitPre", {
      --   group = vim.api.nvim_create_augroup("octo_exit_pre", { clear = true }),
      --   callback = function(ev)
      --     local keep = { "octo" }
      --     for _, win in ipairs(vim.api.nvim_list_wins()) do
      --       local buf = vim.api.nvim_win_get_buf(win)
      --       if vim.tbl_contains(keep, vim.bo[buf].filetype) then
      --         vim.bo[buf].buftype = ""
      --       end
      --     end
      --   end,
    })
  end,
  keys = {
    { "<localleader>a", "", desc = "+assignee", ft = "octo" },
    { "<localleader>c", "", desc = "+comment/code", ft = "octo" },
    { "<localleader>l", "", desc = "+label", ft = "octo" },
    { "<localleader>i", "", desc = "+issue", ft = "octo" },
    { "<localleader>r", "", desc = "+react", ft = "octo" },
    { "<localleader>p", "", desc = "+pr", ft = "octo" },
    { "<localleader>pr", "", desc = "+rebase", ft = "octo" },
    { "<localleader>ps", "", desc = "+squash", ft = "octo" },
    { "<localleader>v", "", desc = "+review", ft = "octo" },
    { "<localleader>g", "", desc = "+goto_issue", ft = "octo" },
    { "<localleader>b", "<cmd>Octo issue browser<cr>", desc = "Open in browser", ft = "octo" },
    { "@", "@<C-x><C-o>", mode = "i", ft = "octo", silent = true }, -- auto complete for @
    { "#", "#<C-x><C-o>", mode = "i", ft = "octo", silent = true }, -- autocompletion for #
  },
}
