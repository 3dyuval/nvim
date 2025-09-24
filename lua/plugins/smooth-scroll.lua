return {
  "nvim-mini/mini.animate",
  enabled = false,
  event = "VeryLazy",
  opts = {
    scroll = {
      -- Enable smooth scrolling
      enable = true,
      timing = function(_, n)
        return 150 / n
      end,
    },
    resize = {
      enable = false, -- Disable window resize animation
    },
    open = {
      enable = false, -- Disable window open animation
    },
    close = {
      enable = false, -- Disable window close animation
    },
    cursor = {
      enable = false, -- Disable cursor movement animation
    },
  },
  config = function(_, opts)
    require("mini.animate").setup(opts)

    -- Keep your custom Graphite layout keymaps for scrolling
    vim.keymap.set({ "n", "v", "x" }, "ga", function()
      local bufname = vim.api.nvim_buf_get_name(0)
      if not bufname:match("^diffview://") then
        vim.cmd("normal! \\<C-d>")
      end
    end, { desc = "Scroll down (Graphite)" })

    vim.keymap.set({ "n", "v", "x" }, "ge", function()
      local bufname = vim.api.nvim_buf_get_name(0)
      if not bufname:match("^diffview://") then
        vim.cmd("normal! \\<C-u>")
      end
    end, { desc = "Scroll up (Graphite)" })
  end,
}
