-- [nfnl] fnl/picker/schemastore.fnl
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
M.open = function()
  local schemas = require("schemastore").json.schemas()
  local items = {}
  for _, s in ipairs(schemas) do
    table.insert(items, {text = ((s.name or "") .. " " .. (s.url or "") .. " " .. (s.description or "")), _name = s.name, _url = s.url, _desc = s.description, _fileMatch = s.fileMatch})
  end
  local function _18_(item, _picker)
    return {{(item._name or item.text), "SnacksPickerLabel"}, {("  " .. (item._url or "")), "SnacksPickerComment"}}
  end
  local function _19_(picker, item)
    picker:close()
    local body = cached_body(item._url)
    if body then
      vim.cmd("enew")
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(format_body(body), "\n"))
      vim.bo.filetype = "json"
      vim.bo.buftype = "nofile"
      return vim.api.nvim_buf_set_name(0, ("schemastore://" .. (item._name or item.text)))
    else
      return nil
    end
  end
  return require("snacks").picker.pick({items = items, title = "SchemaStore", format = _18_, preview = preview, layout = {preset = "default"}, confirm = _19_})
end
M.setup = function()
  local function _21_(_)
    return M.open()
  end
  return vim.api.nvim_create_user_command("SchemaStore", _21_, {desc = "Browse SchemaStore catalog (fetches + caches schema bodies)"})
end
return M
