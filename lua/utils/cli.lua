local M = {}

M.kitty_sent_text_to_pane = function(match_pane, text) end

M.kitty_get_current_and_target = function(match)
  --TODO: check if in pane, othe tab, or nil

  local current_id = os.execute("kitten @ ls | jq .tabs[] | .windows[].id")
  local target_id
end

M.get_kitty_claude_items = function()
  local cmd =
    [[kitty @ ls | jq '.[] | .tabs[] | .windows[] | select(.foreground_processes[0].cmdline[0] == "claude") | {id, title,  cwd: .foreground_processes[0].cwd}']]

  local result = vim.fn.system(cmd)

  local items = {}
  for line in result:gmatch("[^\n]+") do
    local ok, parsed = pcall(vim.json.decode, line)
    if ok then
      table.insert(items, parsed)
    end
  end
  return items
end

local function get_visual_selection()
  local _, ls, cs = unpack(vim.fn.getpos("v"))
  local _, le, ce = unpack(vim.fn.getpos("."))

  -- Ensure start < end
  if ls > le or (ls == le and cs > ce) then
    ls, le = le, ls
    cs, ce = ce, cs
  end

  local lines = vim.api.nvim_buf_get_lines(0, ls - 1, le, false)
  if #lines == 0 then
    return ""
  end

  lines[#lines] = lines[#lines]:sub(1, ce)
  lines[1] = lines[1]:sub(cs)
  return table.concat(lines, "\n")
end

-- Send visual selection to adjacent window
-- Usage: cli.smart_send_selection("l")       -- send left, return focus
--        cli.smart_send_selection("r", true) -- send right, stay there
M.smart_send_selection = function(direction, stay)
  return function()
    local text = get_visual_selection():gsub("'", "'\\''")
    local return_focus = stay and "false" or "true"
    local script = vim.fn.expand("~/.config/kitty/smart_window_send.sh")
    vim.fn.jobstart({ script, text, direction, return_focus }, { detach = true })
  end
end

M.print_items = function()
  local processes = M.get_kitty_claude_items()
  local items = M.get_current_claude_by_cwd()
  print(vim.fn.getcwd(), processes, vim.inspect(items))
end

M.send_to_claude = function(text)
  os.execute(string.format("kitten @ send-text --match:CLD=1 %s", text))
end

return M
