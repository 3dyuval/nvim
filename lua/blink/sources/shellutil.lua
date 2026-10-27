-- [nfnl] fnl/blink/sources/shellutil.fnl
local function has_command_3f(text, cmd)
  return (nil ~= text:match(("%f[%w]" .. cmd .. "%f[%W]")))
end
local function node_matches_3f(node, cmd, bufnr)
  if node then
    local and_1_ = ((node:type() == "command") or (node:type() == "pipeline"))
    if and_1_ then
      local text = vim.treesitter.get_node_text(node, bufnr)
      and_1_ = (text and has_command_3f(text, cmd) and true)
    end
    if and_1_ then
      return true
    else
      return node_matches_3f(node:parent(), cmd, bufnr)
    end
  else
    return nil
  end
end
local function scan_back_3f(bufnr, row, cmd)
  local floor = math.max(0, (row - 20))
  local function loop(i)
    if (i < floor) then
      return false
    else
      local prev = (vim.api.nvim_buf_get_lines(bufnr, i, (i + 1), false)[1] or "")
      if has_command_3f(prev, cmd) then
        return true
      elseif not prev:match("[\\|]%s*$") then
        return false
      else
        return loop((i - 1))
      end
    end
  end
  return loop((row - 1))
end
local function in_command(ctx, cmd)
  local bufnr = vim.api.nvim_get_current_buf()
  local row = (ctx.cursor[1] - 1)
  local col = ctx.cursor[2]
  local ok, node = pcall(vim.treesitter.get_node, {bufnr = bufnr, pos = {row, col}})
  return ((ok and node_matches_3f(node, cmd, bufnr) and true) or has_command_3f(ctx.line, cmd) or scan_back_3f(bufnr, row, cmd))
end
return {in_command = in_command}
