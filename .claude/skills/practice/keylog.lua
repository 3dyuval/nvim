-- Practice keylogger: capture keystrokes into a scratch buffer that an
-- agent can read over nvim-mcp (read_full_buf on the buffer name).
-- Invocable, not auto-gating. See SKILL.md "Keylog" for usage.
--
--   :luafile .claude/skills/practice/keylog.lua   (loads _G.PracticeKeylog)
--   :lua PracticeKeylog.start()  -> returns bufnr; records every key
--   :lua PracticeKeylog.stop()   -> unregisters the on_key listener
--   :lua PracticeKeylog.clear()  -> wipe the scratch buffer contents

_G.PracticeKeylog = _G.PracticeKeylog or {}
local K = _G.PracticeKeylog

local function ensure_buf()
  if K.bufnr and vim.api.nvim_buf_is_valid(K.bufnr) then
    return K.bufnr
  end
  K.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(K.bufnr, "practice-keylog")
  vim.bo[K.bufnr].buftype = "nofile"
  vim.bo[K.bufnr].bufhidden = "hide"
  vim.bo[K.bufnr].swapfile = false
  return K.bufnr
end

local function append(line)
  if K.bufnr and vim.api.nvim_buf_is_valid(K.bufnr) then
    vim.api.nvim_buf_set_lines(K.bufnr, -1, -1, false, { line })
  end
end

function K.start()
  ensure_buf()
  if K.ns then
    return K.bufnr
  end
  append("# start " .. os.date("%H:%M:%S"))
  K.ns = vim.on_key(function(key, typed)
    -- typed is pre-mapping input; fall back to key for synthesized input
    local raw = (typed ~= nil and typed ~= "") and typed or key
    local t = vim.fn.keytrans(raw)
    if t == "" then
      return
    end
    local mode = vim.api.nvim_get_mode().mode
    -- on_key runs in a fast context; defer buffer writes
    vim.schedule(function()
      append(string.format("%-5s %s", mode, t))
    end)
  end)
  return K.bufnr
end

function K.stop()
  if K.ns then
    vim.on_key(nil, K.ns)
    K.ns = nil
    append("# stop " .. os.date("%H:%M:%S"))
  end
  return K.bufnr
end

function K.clear()
  if K.bufnr and vim.api.nvim_buf_is_valid(K.bufnr) then
    vim.api.nvim_buf_set_lines(K.bufnr, 0, -1, false, {})
  end
end

return K
