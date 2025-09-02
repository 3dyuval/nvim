local M = {}

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

M.get_current_claude_by_cwd = function()
  local items = M.get_kitty_claude_items()
  local cwd = vim.fn.getcwd()
  for _, value in ipairs(items) do
    if value.cwd == cwd then
      return value
    end
  end
end

M.print_items = function()
  local processes = M.get_kitty_claude_items()
  local items = M.get_current_claude_by_cwd()
  print(vim.fn.getcwd(), processes, vim.inspect(items))
end

return M
