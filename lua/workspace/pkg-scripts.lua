-- [nfnl] fnl/workspace/pkg-scripts.fnl
local M = {}
local function find_package_json(start)
  local found = vim.fs.find("package.json", {upward = true, type = "file", path = start})
  return found[1]
end
local function detect_pm(dir)
  if (1 == vim.fn.filereadable((dir .. "/bun.lockb"))) then
    return {"bun", "run"}
  elseif (1 == vim.fn.filereadable((dir .. "/bun.lock"))) then
    return {"bun", "run"}
  elseif (1 == vim.fn.filereadable((dir .. "/pnpm-lock.yaml"))) then
    return {"pnpm", "run"}
  elseif (1 == vim.fn.filereadable((dir .. "/yarn.lock"))) then
    return {"yarn", "run"}
  else
    return {"npm", "run"}
  end
end
local function read_scripts(pkg_path)
  local ok, data = pcall(vim.fn.readfile, pkg_path)
  if ok then
    local ok2, parsed = pcall(vim.json.decode, table.concat(data, "\n"))
    if (ok2 and parsed and parsed.scripts) then
      return parsed.scripts, vim.fs.dirname(pkg_path)
    else
      return nil
    end
  else
    return nil
  end
end
local efm = table.concat({"%f(%l\\,%c): %t%*[a-z] %m", "%f:%l:%c: %t%*[a-z] %m", "%f:%l:%c %m", "%f:%l:%c", "%-G%.%#"}, ",")
local function anchor_dir(dir, script_cmd)
  local sub = (script_cmd and script_cmd:match("^%s*cd%s+([^%s&|;]+)"))
  if sub then
    return vim.fs.normalize((dir .. "/" .. sub))
  else
    return dir
  end
end
local function run_script(pm, dir, script, script_cmd)
  local cmd = {pm[1], pm[2], script}
  local anchor = anchor_dir(dir, script_cmd)
  local title = table.concat(cmd, " ")
  vim.notify(("Running: " .. title), vim.log.levels.INFO)
  local function _5_(out)
    local lines = vim.split(((out.stdout or "") .. "\n" .. (out.stderr or "")), "\n")
    local save_efm = vim.o.errorformat
    vim.o.errorformat = efm
    vim.cmd(("lcd " .. vim.fn.fnameescape(anchor)))
    vim.fn.setqflist({}, " ", {title = title, lines = lines})
    vim.o.errorformat = save_efm
    local n = vim.fn.getqflist({size = 1}).size
    if (n > 0) then
      vim.cmd("copen")
      return vim.notify((title .. ": " .. n .. " qf entries"))
    else
      local function _6_()
        if (out.code == 0) then
          return vim.log.levels.INFO
        else
          return vim.log.levels.WARN
        end
      end
      return vim.notify((title .. ": done (exit " .. out.code .. ", no matches)"), _6_())
    end
  end
  return vim.system(cmd, {cwd = dir, text = true}, vim.schedule_wrap(_5_))
end
M.pick = function()
  local buf_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local start
  if (buf_dir and (buf_dir ~= "")) then
    start = buf_dir
  else
    start = vim.fn.getcwd()
  end
  local pkg = find_package_json(start)
  if not pkg then
    return vim.notify("No package.json found", vim.log.levels.WARN)
  else
    local scripts, dir = read_scripts(pkg)
    if not scripts then
      return vim.notify("package.json has no scripts", vim.log.levels.WARN)
    else
      local pm = detect_pm(dir)
      local items = {}
      for name, cmd in pairs(scripts) do
        table.insert(items, {text = name, cmd = cmd})
      end
      local function _9_(a, b)
        return (a.text < b.text)
      end
      table.sort(items, _9_)
      local function _10_(item, _)
        return {{item.text, "SnacksPickerLabel"}, {("  " .. (item.cmd or "")), "SnacksPickerComment"}}
      end
      local function _11_(picker, item)
        picker:close()
        if (item and item.text) then
          return run_script(pm, dir, item.text, item.cmd)
        else
          return nil
        end
      end
      return Snacks.picker.pick({source = "pkg_scripts", items = items, format = _10_, confirm = _11_})
    end
  end
end
return M
