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

M.print_items = function()
  local processes = M.get_kitty_claude_items()
  local items = M.get_current_claude_by_cwd()
  print(vim.fn.getcwd(), processes, vim.inspect(items))
end

M.send_to_claude = function(text)
  os.execute(string.format("kitten @ send-text --match:CLD=1 %s", text))
end

return M
