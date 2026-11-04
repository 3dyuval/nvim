-- Scan the current buffer for `Section N:` comments and render each as eol
-- virtual text, then (optionally) strip the comment so the buffer stays clean.
--
-- A "section comment" is any line whose comment body matches:
--     Section <n>: <instruction>
-- The leading comment marker is language-agnostic: we take everything after
-- the first `:` that follows `Section <n>`.
--
-- Usage (nvim-mcp send_command, or `nvim --server <sock> --remote-expr`):
--   :luafile .claude/skills/practice/section-hints.lua   " defines the fns
--   :lua PracticeHints.render()                          " draw virtual text
--   :lua PracticeHints.render({ strip = true })          " draw + remove comment
--   :lua PracticeHints.clear()                           " remove virtual text

local M = {}
-- Shared with workspace/mcp-virtual-text.lua so `]i` / `[i` navigate the hints.
local NS = vim.api.nvim_create_namespace("mcp_virtual_text")

-- Match "...Section 3: dk= then a . a ..." -> n="3", hint="dk= then a . a ..."
local function parse(line)
  local n, hint = line:match("[Ss]ection%s+(%d+)%s*:%s*(.+)$")
  if n and hint then
    return n, (hint:gsub("%s+$", ""))
  end
end

function M.clear()
  vim.api.nvim_buf_clear_namespace(0, NS, 0, -1)
end

-- opts.strip (bool): delete the matched comment line's text after a section
--   marker, leaving bare code. Default false (keep the one-line comment).
function M.render(opts)
  opts = opts or {}
  M.clear()
  local buf = 0
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local count = 0
  for i, line in ipairs(lines) do
    local n, hint = parse(line)
    if n then
      count = count + 1
      -- anchor the hint on the first non-blank code line after the comment,
      -- falling back to the comment line itself at end-of-buffer.
      local anchor = i - 1
      if opts.strip then
        for j = i + 1, #lines do
          if lines[j]:match("%S") then anchor = j - 1 break end
        end
        vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { "" })
      end
      vim.api.nvim_buf_set_extmark(buf, NS, anchor, 0, {
        virt_text = { { ("S%s: %s"):format(n, hint), "DiagnosticInfo" } },
        virt_text_pos = "eol",
      })
    end
  end
  vim.notify(("practice: rendered %d section hint(s)"):format(count))
  return count
end

_G.PracticeHints = M
return M
