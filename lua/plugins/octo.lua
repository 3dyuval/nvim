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
      enable_builtin = true,
      default_to_projects_v2 = false,
      default_merge_method = "squash",
      picker = "snacks",
      picker_config = {
        mappings = {
          open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
        },
        snacks = {
          focus = "input",
        },
      },
    }
  end,
  config = function(_, opts)
    require("octo").setup(opts)
    vim.cmd([[hi OctoEditable guibg=none]])

    -- Disable swap files for Octo buffers
    vim.api.nvim_create_autocmd("BufReadPre", {
      pattern = "octo://*",
      callback = function()
        vim.opt_local.swapfile = false
      end,
    })

    -- Keep some empty windows in sessions
    vim.api.nvim_create_autocmd("ExitPre", {
      group = vim.api.nvim_create_augroup("octo_exit_pre", { clear = true }),
      callback = function(ev)
        local keep = { "octo" }
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.tbl_contains(keep, vim.bo[buf].filetype) then
            vim.bo[buf].buftype = ""
          end
        end
      end,
    })
  end,
  keys = {
    {
      "<leader>go",
      function()
        require("utils.octo-menu").show()
      end,
      desc = " Octo Menu",
    },
    {
      "<leader>gi",
      "<cmd>Octo issue search<CR>",
      desc = "List Issues",
    },
    { "<leader>gI", "<cmd>Octo issue search<CR>", desc = "Search Issues" },
    { "<leader>gP", "<cmd>Octo pr search<CR>", desc = "Search PRs" },
    { "<leader>gR", "<cmd>Octo repo list<CR>", desc = "List Repos" },
    { "<leader>gS", "<cmd>Octo search<CR>", desc = "Search" },

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
    { "@", "@<C-x><C-o>", mode = "i", ft = "octo", silent = true },
    { "#", "#<C-x><C-o>", mode = "i", ft = "octo", silent = true },
  },
}
