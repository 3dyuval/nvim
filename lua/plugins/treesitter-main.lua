return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- Ensure JSX/TSX parsers are installed
    opts.ensure_installed = opts.ensure_installed or {}
    vim.list_extend(opts.ensure_installed, {
      "javascript",
      "typescript",
      "tsx",
      "html",
      "css",
    })

    -- Enable autotag integration (Takuya's way)
    opts.autotag = {
      enable = true,
    }

    -- Add error handling for highlighting
    opts.highlight = opts.highlight or {}
    opts.highlight.additional_vim_regex_highlighting = false
    opts.highlight.disable = function(lang, buf)
      -- Disable for large files or if buffer is invalid
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end

      -- Check if buffer is valid
      return not vim.api.nvim_buf_is_valid(buf)
    end

    -- Add textobjects configuration
    opts.textobjects = {
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]C"] = "@class.outer",
          ["]p"] = "@parameter.inner",
          ["]l"] = "@loop.*",
          ["]s"] = "@scope",
          ["]u"] = "@fold",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[C"] = "@class.outer",
          ["[p"] = "@parameter.inner",
          ["[l"] = "@loop.*",
          ["[s"] = "@scope",
          ["[u"] = "@fold",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
        },
      },
      select = {
        enable = true,
        keymaps = {
          ["rf"] = "@function.inner",
          ["tf"] = "@function.outer",
          ["rc"] = "@class.inner",
          ["tc"] = "@class.outer",
          ["rp"] = "@parameter.inner",
          ["tp"] = "@parameter.outer",
          ["ro"] = "@loop.inner",
          ["to"] = "@loop.outer",
          ["rs"] = "@scope",
          ["rt"] = "@tag.inner",
          ["tt"] = "@tag.outer",
          ["te"] = "@jsx_self_closing_element",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["]P"] = "@parameter.inner",
          ["]F"] = "@function.outer",
        },
        swap_previous = {
          ["[A"] = "@parameter.inner",
          ["[F"] = "@function.outer",
        },
      },
    }

    return opts
  end,
  init = function()
    -- Unmap the default [c and ]c mappings in Neogit buffers
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "NeogitRebaseTodo", "NeogitStatus", "NeogitCommitMessage" },
      callback = function()
        -- Only unmap in Neogit buffers to preserve diff navigation elsewhere
        -- pcall(vim.keymap.del, { "n", "o", "x" }, "[c", { buffer = true })
        -- pcall(vim.keymap.del, { "n", "o", "x" }, "]c", { buffer = true })
      end,
    })
  end,
}
