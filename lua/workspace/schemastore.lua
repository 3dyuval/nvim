-- [nfnl] fnl/workspace/schemastore.fnl
local M = {}
local cache_dir = (vim.fn.stdpath("cache") .. "/schemastore")
local mem = {}
local function ensure_cache_dir()
  if (0 == vim.fn.isdirectory(cache_dir)) then
    return vim.fn.mkdir(cache_dir, "p")
  else
    return nil
  end
end
local function cache_path(url)
  return (cache_dir .. "/" .. vim.fn.sha256(url) .. ".json")
end
local function read_file(path)
  local fd, _ = io.open(path, "r")
  if fd then
    local data = fd:read("*a")
    fd:close()
    return data
  else
    return nil
  end
end
local function write_file(path, data)
  local fd, _ = io.open(path, "w")
  if fd then
    fd:write(data)
    return fd:close()
  else
    return nil
  end
end
local function cached_body(url)
  local or_4_ = mem[url]
  if not or_4_ then
    local disk = read_file(cache_path(url))
    if disk then
      mem[url] = disk
      or_4_ = disk
    else
      or_4_ = nil
    end
  end
  return or_4_
end
local function format_body(text)
  if (1 == vim.fn.executable("jq")) then
    local out = vim.fn.system({"jq", "."}, text)
    if (0 == vim.v.shell_error) then
      return out
    else
      return text
    end
  else
    return text
  end
end
local function show_body(ctx, text)
  ctx.preview:reset()
  ctx.preview:set_lines(vim.split(format_body(text), "\n"))
  return ctx.preview:highlight({ft = "json"})
end
local function show_meta(ctx, item, status)
  ctx.preview:reset()
  local fm = item._fileMatch
  local lines
  local _9_
  if (fm and (#fm > 0)) then
    _9_ = table.concat(fm, ", ")
  else
    _9_ = "\226\128\148"
  end
  lines = {("# " .. (item._name or item.text)), "", ("url:         " .. item._url), ("fileMatch:   " .. _9_), ""}
  if item._desc then
    table.insert(lines, item._desc)
    table.insert(lines, "")
  else
  end
  table.insert(lines, ("\226\148\128\226\148\128 " .. status .. " \226\148\128\226\148\128"))
  ctx.preview:set_lines(lines)
  return ctx.preview:highlight({ft = "markdown"})
end
local function fetch_async(ctx, item)
  local url = item._url
  local picker = ctx.picker
  local function _12_(res)
    local function _13_()
      local current = picker:current({resolve = false})
      local still_here_3f = (current and (current._url == url))
      if ((0 == res.code) and res.stdout and (res.stdout ~= "")) then
        ensure_cache_dir()
        write_file(cache_path(url), res.stdout)
        mem[url] = res.stdout
        if still_here_3f then
          return show_body(ctx, res.stdout)
        else
          return nil
        end
      else
        if still_here_3f then
          return show_meta(ctx, item, ("fetch failed (curl " .. res.code .. ")"))
        else
          return nil
        end
      end
    end
    return vim.schedule(_13_)
  end
  return vim.system({"curl", "-sSL", "--max-time", "15", url}, {text = true}, _12_)
end
local function preview(ctx)
  local item = ctx.item
  local body = cached_body(item._url)
  if body then
    return show_body(ctx, body)
  else
    show_meta(ctx, item, "fetching\226\128\166")
    return fetch_async(ctx, item)
  end
end
local function find_schema_line(lines)
  local found = nil
  do
    local n = math.min(#lines, 40)
    for i = 1, n do
      if not found then
        local l = lines[i]
        local s, _, indent = l:find("^(%s*)\"%$schema\"%s*:")
        if s then
          found = {(i - 1), indent}
        else
        end
      else
      end
    end
  end
  return found
end
local function find_open_brace(lines)
  local found = nil
  do
    local n = math.min(#lines, 40)
    for i = 1, n do
      if not found then
        local l = lines[i]
        local s, _, indent = l:find("^(%s*){")
        if s then
          found = {(i - 1), indent}
        else
        end
      else
      end
    end
  end
  return found
end
local function detect_indent(lines)
  local unit = "  "
  local done = false
  for _, l in ipairs(lines) do
    if done then break end
    local s = l:find("^%s+%S")
    if s then
      unit = l:match("^(%s+)")
      done = true
    else
    end
  end
  return unit
end
local function replace_schema(bufnr, row, indent, url)
  local line = (indent .. "\"$schema\": \"" .. url .. "\",")
  return vim.api.nvim_buf_set_lines(bufnr, row, (row + 1), false, {line})
end
local function insert_schema(bufnr, brace_row, brace_indent, unit, url)
  local line = (brace_indent .. unit .. "\"$schema\": \"" .. url .. "\",")
  return vim.api.nvim_buf_set_lines(bufnr, (brace_row + 1), (brace_row + 1), false, {line})
end
local function create_json_file(url)
  local function _23_(name)
    if (name and (name ~= "")) then
      vim.cmd(("edit " .. vim.fn.fnameescape(name)))
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {"{", ("  \"$schema\": \"" .. url .. "\""), "}"})
      vim.bo.filetype = "json"
      return nil
    else
      return nil
    end
  end
  return vim.ui.input({prompt = "New JSON file: ", default = "config.json", completion = "file"}, _23_)
end
local function apply_schema(url)
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo.filetype
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local empty_3f = ((0 == #lines) or ((1 == #lines) and ("" == lines[1])))
  local json_3f = ((ft == "json") or (ft == "jsonc"))
  local existing = find_schema_line(lines)
  if (json_3f and existing) then
    local function _25_(choice)
      if (choice == "Replace") then
        return replace_schema(bufnr, existing[1], existing[2], url)
      else
        return nil
      end
    end
    return vim.ui.select({"Replace", "Cancel"}, {prompt = ("$schema exists. Replace with " .. url .. "?")}, _25_)
  elseif (json_3f and not empty_3f) then
    local brace = find_open_brace(lines)
    local unit = detect_indent(lines)
    if brace then
      return insert_schema(bufnr, brace[1], brace[2], unit, url)
    else
      return vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, {("\"$schema\": \"" .. url .. "\",")})
    end
  else
    return create_json_file(url)
  end
end
M.open = function()
  local schemas = require("schemastore").json.schemas()
  local items = {}
  for _, s in ipairs(schemas) do
    table.insert(items, {text = ((s.name or "") .. " " .. (s.url or "") .. " " .. (s.description or "")), _name = s.name, _url = s.url, _desc = s.description, _fileMatch = s.fileMatch})
  end
  local function _29_(item, _picker)
    return {{(item._name or item.text), "SnacksPickerLabel"}, {("  " .. (item._url or "")), "SnacksPickerComment"}}
  end
  local function _30_(picker, item)
    picker:close()
    if item._url then
      return apply_schema(item._url)
    else
      return nil
    end
  end
  return require("snacks").picker.pick({items = items, title = "SchemaStore", format = _29_, preview = preview, layout = {preset = "default"}, confirm = _30_})
end
M.setup = function()
  local function _32_(_)
    return M.open()
  end
  return vim.api.nvim_create_user_command("SchemaStore", _32_, {desc = "Browse SchemaStore catalog (fetches + caches schema bodies)"})
end
return M
