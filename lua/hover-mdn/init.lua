-- [nfnl] fnl/hover-mdn/init.fnl
local html_fts = {html = true, vue = true, svelte = true, htmldjango = true, php = true}
local js_fts = {javascript = true, javascriptreact = true, typescript = true, typescriptreact = true, vue = true}
local data_path = (vim.api.nvim_get_runtime_file("lua/hover-mdn/mdn-data.json", false)[1] or (vim.fn.stdpath("config") .. "/lua/hover-mdn/mdn-data.json"))
local empty = {tags = {}, globalAttributes = {}, jsGlobals = {}}
local raw = nil
local function load_json()
  if not raw then
    local ok, lines = pcall(vim.fn.readfile, data_path)
    if (ok and (type(lines) == "table")) then
      local ok2, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
      if (ok2 and (type(decoded) == "table")) then
        raw = decoded
      else
        raw = empty
      end
    else
      vim.notify(("hover-mdn: cannot read " .. data_path), vim.log.levels.WARN)
      raw = empty
    end
  else
  end
  return raw
end
local maps = nil
local function description(entry)
  local d = entry.description
  if (type(d) == "table") then
    return d.value
  elseif (type(d) == "string") then
    return d
  else
    return nil
  end
end
local function ref_url(entry)
  local r = (entry.references and entry.references[1])
  return (r and r.url)
end
local function index(arr)
  local m = {}
  for _, e in ipairs((arr or {})) do
    m[e.name] = e
  end
  return m
end
local function get_maps()
  if not maps then
    local j = load_json()
    maps = {elements = index(j.tags), attributes = index(j.globalAttributes), js = index(j.jsGlobals)}
  else
  end
  return maps
end
local function element_name(bufnr)
  local ok, node = pcall(vim.treesitter.get_node, {bufnr = bufnr})
  local name = nil
  if (ok and node) then
    local n = node
    while (n and not name) do
      do
        local t = n:type()
        if (t:find("element") or t:find("tag") or t:find("component")) then
          for child in n:iter_children() do
            if name then break end
            local ct = child:type()
            if ((ct == "tag_name") or ct:find("name")) then
              name = vim.treesitter.get_node_text(child, bufnr)
            else
            end
          end
        else
        end
      end
      n = n:parent()
    end
  else
  end
  return (name or vim.fn.expand("<cword>"))
end
local function lines_for(entry, title)
  local out = {("# " .. title)}
  local desc = description(entry)
  local url = ref_url(entry)
  if desc then
    table.insert(out, "")
    table.insert(out, desc)
  else
  end
  if url then
    table.insert(out, "")
    table.insert(out, ("[MDN](" .. url .. ")"))
  else
  end
  return out
end
local function lookup(bufnr)
  local m = get_maps()
  local ft = vim.bo[bufnr].filetype
  local word = vim.fn.expand("<cword>")
  local el
  if html_fts[ft] then
    el = element_name(bufnr)
  else
    el = nil
  end
  if (el and m.elements[el]) then
    return {m.elements[el], ("<" .. el .. ">")}
  elseif (html_fts[ft] and m.elements[word]) then
    return {m.elements[word], ("<" .. word .. ">")}
  elseif (html_fts[ft] and m.attributes[word]) then
    return {m.attributes[word], (word .. " (attribute)")}
  elseif ((html_fts[ft] or js_fts[ft]) and m.js[word]) then
    return {m.js[word], word}
  else
    return nil
  end
end
local function _13_(bufnr)
  local ft = vim.bo[bufnr].filetype
  return ((html_fts[ft] or js_fts[ft]) and true)
end
local function _14_(params, done)
  local hit = lookup(params.bufnr)
  if hit then
    return done({lines = lines_for(hit[1], hit[2]), filetype = "markdown"})
  else
    return done(false)
  end
end
return {name = "MDN", priority = 175, enabled = _13_, execute = _14_}
