-- Notes utility functions for obsidian.nvim integration

local M = {}

-- Open notes directory in file explorer
function M.open_notes_directory()
  local notes_dir = vim.fn.expand("$CFG/notes")
  vim.cmd("e " .. notes_dir)
end

-- Smart follow link - follow markdown link or fallback to gf
function M.smart_follow_link()
  if require("obsidian").util.cursor_on_markdown_link() then
    return "<cmd>ObsidianFollowLink<cr>"
  else
    return "gf"
  end
end

-- Create new note in inbox with filename prompt
function M.create_inbox_note()
  vim.ui.input({ prompt = "Note filename: " }, function(filename)
    if not filename or filename == "" then
      return
    end

    -- Auto-append .md if not present
    if not filename:match("%.md$") then
      filename = filename .. ".md"
    end

    local inbox_path = vim.fn.expand("$CFG/notes/inbox/" .. filename)
    vim.cmd("e " .. vim.fn.fnameescape(inbox_path))
  end)
end

return M
