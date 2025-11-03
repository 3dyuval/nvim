-- Notes Management: Marksman LSP + obsidian.nvim
-- Storage: $CFG/notes (expandable to any directory)

local notes_dir = vim.fn.expand("$CFG/notes")

-- Ensure notes directory exists
vim.fn.mkdir(notes_dir, "p")

return {
  -- Marksman LSP for markdown
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {
          -- Marksman auto-detects markdown vaults
          filetypes = { "markdown" },
        },
      },
    },
  },

  -- obsidian.nvim for note-taking workflows
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "notes",
          path = notes_dir,
        },
      },

      -- Notes configuration
      notes_subdir = "inbox", -- New notes go to inbox/

      -- Daily notes
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        template = nil, -- Can add template later
      },

      -- Templates
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },

      -- Note ID generation (filename)
      note_id_func = function(title)
        -- Create slug from title
        local suffix = ""
        if title ~= nil then
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          -- Use timestamp if no title
          suffix = tostring(os.time())
        end
        return suffix
      end,

      -- Disable wiki links in favor of markdown links
      preferred_link_style = "markdown",

      -- Completion settings (disable nvim-cmp if not installed)
      completion = {
        nvim_cmp = false,
        min_chars = 2,
      },

      -- Disable frontmatter
      disable_frontmatter = false,

      -- Follow link configuration
      follow_url_func = function(url)
        -- Open URLs in browser
        vim.fn.jobstart({ "xdg-open", url })
      end,
    },

    -- Keymaps are defined in lua/config/keymaps.lua under <leader>n
  },
}
