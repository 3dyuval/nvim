-- This is just an empty plugin spec since the AI functionality is in utils
-- Just checking our new ai commit
return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  config = function()
    require("claude-code").setup({
      keymap = {
        toggle = false, -- Keymaps now handled in keymaps.lua
        window_navigation = false, -- Disable default HJKL navigation
      },
      window = {
        hide_numbers = true, -- Hide line numbers in Claude Code terminal
        hide_signcolumn = true, -- Hide sign column in Claude Code terminal
      },
      terminal = {
        auto_insert = true, -- Always stay in insert/terminal mode
        disable_normal_mode = true, -- Prevent switching to normal mode
      },
    })

    -- Set up autocmd to exclude Claude Code buffers from various operations
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*",
      callback = function(args)
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        local buftype = vim.bo[args.buf].buftype

        -- Check if this is a Claude Code buffer
        if
          buftype == "terminal"
          and (
            bufname:match("claude%-code")
            or bufname:match("claude_code")
            or vim.b[args.buf].terminal_job_id -- Generic terminal check
          )
        then
          -- Mark buffer to exclude from search/replace operations
          vim.b[args.buf].claude_code_terminal = true
          vim.b[args.buf].no_search_replace = true
          -- Also exclude from various other operations
          vim.b[args.buf].miniindentscope_disable = true
          vim.b[args.buf].snacks_indent = false
          vim.b[args.buf].snacks_scope = false

          -- Force terminal mode when entering Claude Code buffer
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].buftype == "terminal" then
              vim.cmd("startinsert")
            end
          end)
        end
      end,
    })

    -- Set up custom HAEI navigation for Claude Code terminal
    local claude_code = require("claude-code")
    local original_setup_terminal_navigation = claude_code.setup_terminal_navigation

    -- Override the terminal navigation setup to disable mode switching and focus on input
    function claude_code.setup_terminal_navigation()
      local current_instance = claude_code.claude_code.current_instance
      local buf = current_instance and claude_code.claude_code.instances[current_instance]
      if buf and vim.api.nvim_buf_is_valid(buf) then
        -- Disable ALL default keymaps that cause mode switching
        -- Keep Claude Code terminal focused on input only

        -- Disable default window navigation (stays in terminal mode)
        vim.api.nvim_buf_set_keymap(buf, "t", "<C-h>", "<Nop>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, "t", "<C-j>", "<Nop>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, "t", "<C-k>", "<Nop>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, "t", "<C-l>", "<Nop>", { noremap = true, silent = true })

        -- Disable scrolling that exits insert mode
        vim.api.nvim_buf_set_keymap(buf, "t", "<C-f>", "<Nop>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, "t", "<C-b>", "<Nop>", { noremap = true, silent = true })

        -- Disable escape sequences that could exit terminal mode
        vim.api.nvim_buf_set_keymap(buf, "t", "<Esc>", "<Nop>", { noremap = true, silent = true })

        -- Disable any other common keys that might switch modes
        vim.api.nvim_buf_set_keymap(
          buf,
          "t",
          "<C-\\><C-n>",
          "<Nop>",
          { noremap = true, silent = true }
        )
      end
    end
  end,
}
