-- [nfnl] fnl/picker/grep.fnl
local M = {}
local ignore_globs = {"-g", "!.git", "-g", "!node_modules", "-g", "!dist", "-g", "!build", "-g", "!coverage", "-g", "!.DS_Store", "-g", "!.docusaurus", "-g", "!.dart_tool"}
M["grep-in-dir"] = function(dir)
  if (dir and (dir ~= "")) then
    local rel = vim.fn.fnamemodify(dir, ":~:.")
    local label
    if ((rel == "") or (rel == ".")) then
      label = vim.fn.fnamemodify(dir, ":t")
    else
      label = rel
    end
    return Snacks.picker.grep({cwd = dir, cmd = "rg", args = ignore_globs, title = ("Grep  " .. label), show_empty = true, hidden = true, ignored = true, supports_live = true, follow = false})
  else
    return nil
  end
end
M["search-in-directory"] = function(picker, item)
  if item then
    return M["grep-in-dir"](vim.fn.fnamemodify(item.file, ":p:h"))
  else
    return vim.notify("No item provided", vim.log.levels.WARN)
  end
end
M["grep-current-buffer-dir"] = function()
  local file = vim.api.nvim_buf_get_name(0)
  local dir
  if (file ~= "") then
    dir = vim.fn.fnamemodify(file, ":p:h")
  else
    dir = vim.fn.getcwd()
  end
  return M["grep-in-dir"](dir)
end
return M
