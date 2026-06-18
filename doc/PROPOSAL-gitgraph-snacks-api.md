# Proposal: GitGraph Snacks-Style API

## Problem

GitGraph's current API is **render-only**:
- `gitgraph.draw(opts)` — hijacks current window, renders graph
- `gitgraph.core.gitgraph(config, options, args)` — returns raw data (lines, highlights, head_commit)

Users can't interact with the graph without:
1. Parsing rendered output (brittle)
2. Accessing internal data structures (unstable)
3. Managing their own keymaps and state

**Result:** Can't build recipes for interactive graph panels.

---

## Solution: Snacks-Style Interactive List API

Model gitgraph on snacks' list component API—a composable, documented contract for interactive items.

### Current Snacks API Pattern

```lua
local picker = require("snacks.picker")

picker.open({
  sources = { "files" },
  on_select = function(item)
    vim.cmd.edit(item.file)
  end,
  format = function(item, picker)
    return item.file
  end,
})
```

**Key traits:**
- Constructor returns an interactive object
- Data is structured (items array + metadata)
- Keymaps are configurable, not hijacked
- Callbacks (on_select, format) are user-provided
- Window/buffer management is optional (can render to custom buffer)

---

## Proposed GitGraph Snacks-Style API

### Constructor

```lua
local gitgraph = require("gitgraph")

local graph = gitgraph.open({
  -- Data source
  config = gitgraph.config,  -- or custom config
  options = {},
  args = { all = true, max_count = 256 },
  
  -- Rendering
  render_opts = {
    symbols = gitgraph.config.symbols,
    format = { fields = gitgraph.config.format.fields },
  },
  
  -- Window/Buffer (optional)
  win_config = nil,  -- if nil, don't create window; just return data
  
  -- Callbacks
  on_select = function(commit) end,  -- user provides action
  on_focus = function(commit) end,   -- optional
  on_abort = function() end,         -- optional
  
  -- Keymaps
  keymaps = {
    select = "<CR>",
    close = "q",
    next = "A",
    prev = "E",
    -- ... more as needed
  },
})
```

### Return Value

```lua
local graph = gitgraph.open(opts)

-- Structured data
graph.items         -- []{hash, subject, refs, parents, children, ...}
graph.lines         -- rendered lines (strings)
graph.highlights    -- [{hg, row, start, stop}]
graph.head_commit   -- line number of HEAD

-- State management
graph:select(item)           -- programmatically select item
graph:focus(line_index)      -- move cursor to line
graph:render(buf)            -- render to custom buffer
graph:set_cursor(row, col)   -- set cursor position
graph:close()                -- cleanup

-- Event subscriptions
graph:on("select", fn)       -- subscribe to item selection
graph:on("focus", fn)        -- subscribe to cursor movement
```

### Usage: Diffview Integration Recipe

```lua
-- Before: brittle, manual, regex parsing
local function open_graph()
  local gitgraph = require("gitgraph")
  vim.cmd("botright split")
  local win = vim.api.nvim_get_current_win()
  gitgraph.draw({}, { all = true })
  -- No way to bind <CR> to actually do something with the selected commit
end

-- After: clean, composable
local function open_graph(diffview_context)
  local gitgraph = require("gitgraph")
  
  local graph = gitgraph.open({
    config = gitgraph.config,
    args = { all = true, max_count = 256 },
    
    -- Render to custom buffer (not hijack window)
    render_opts = {
      symbols = gitgraph.config.symbols,
    },
    
    -- User-provided action
    on_select = function(commit)
      vim.cmd("DiffviewOpen " .. commit.hash .. "^!")
    end,
    
    -- Read keymaps from diffview config
    keymaps = diffview_context.keymaps,
  })
  
  -- Render to our split
  vim.cmd("botright split")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  graph:render(buf)
  
  return graph
end
```

---

## Benefits

### For Users

✅ **Composable** — Can use gitgraph in custom layouts without forking
✅ **Documented** — Stable, public contract (items, keymaps, callbacks)
✅ **Interactive** — Bind keymaps to actual actions (open, merge, etc.)
✅ **Flexible** — Render to any buffer, custom window management
✅ **Extensible** — Users can hook `on_select`, `on_focus`, etc.

### For Maintainers

✅ **Clear contract** — What's public API vs. internal
✅ **Backward compatible** — Keep `draw()` as legacy
✅ **Testable** — API is small and well-defined
✅ **No duplication** — One data model, multiple rendering backends

---

## Implementation Sketch

### Phase 1: Data Layer (No Breaking Changes)

```lua
-- lua/gitgraph/list.lua (new file)

local M = {}

function M.create(config, options, args)
  local graph, lines, highlights, head_loc = 
    require("gitgraph.core").gitgraph(config, options, args)
  
  return {
    items = extract_items(graph),      -- commits + metadata
    lines = lines,
    highlights = highlights,
    head_commit = head_loc,
  }
end

function extract_items(graph)
  local items = {}
  for i, row in ipairs(graph) do
    if row.commit then
      table.insert(items, {
        line = i - 1,  -- 0-indexed
        hash = row.commit.hash,
        subject = row.commit.msg,
        refs = row.commit.refs,
        parents = row.commit.parents,
        children = row.commit.children,
      })
    end
  end
  return items
end

return M
```

### Phase 2: Interactive Wrapper (New)

```lua
-- lua/gitgraph/interactive.lua (new file)

local EventEmitter = require("diffview.events").EventEmitter

local M = {}
M.__index = M

function M.new(opts)
  local self = setmetatable({
    config = opts.config or require("gitgraph").config,
    options = opts.options or {},
    args = opts.args or {},
    render_opts = opts.render_opts or {},
    keymaps = opts.keymaps or {},
    callbacks = {
      on_select = opts.on_select,
      on_focus = opts.on_focus,
      on_abort = opts.on_abort,
    },
    state = {},
    emitter = EventEmitter(),
  }, M)
  
  self:_load_data()
  return self
end

function M:_load_data()
  local list = require("gitgraph.list").create(
    self.config, self.options, self.args
  )
  self.items = list.items
  self.lines = list.lines
  self.highlights = list.highlights
  self.head_commit = list.head_commit
end

function M:render(buf)
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, self.lines)
  
  for _, hl in ipairs(self.highlights) do
    vim.api.nvim_buf_add_highlight(
      buf, -1, hl.hg, hl.row, hl.start, hl.stop
    )
  end
  
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  self:_setup_keymaps(buf)
end

function M:_setup_keymaps(buf)
  for key, action in pairs(self.keymaps) do
    vim.keymap.set("n", action, function()
      if key == "select" then
        self:_on_select()
      elseif key == "close" then
        self:close()
      end
    end, { buffer = buf })
  end
end

function M:select(item)
  self.state.selected = item
  if self.callbacks.on_select then
    self.callbacks.on_select(item)
  end
  self.emitter:emit("select", item)
end

function M:_on_select()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local item = self:_item_at_line(cursor_line)
  if item then
    self:select(item)
  end
end

function M:_item_at_line(line)
  for _, item in ipairs(self.items) do
    if item.line == line then
      return item
    end
  end
  return nil
end

function M:on(event, fn)
  self.emitter:on(event, fn)
end

function M:close()
  if self.callbacks.on_abort then
    self.callbacks.on_abort()
  end
end

return M
```

### Phase 3: Public Entry Point (Backward Compatible)

```lua
-- lua/gitgraph.lua (updated)

local M = {
  config = ...,
  -- legacy
  setup = ...,
  draw = ...,
  
  -- new snacks-style API
  open = function(opts)
    return require("gitgraph.interactive").new(opts)
  end,
}

return M
```

---

## Migration Path

**Users of `gitgraph.draw()`:**
- Keep working, no changes needed
- Long-term: mark as legacy in docs

**New recipes (like diffview integration):**
- Use `gitgraph.open()` instead
- Stable contract, zero regex parsing

**Internal uses:**
- Gradually migrate to new API as convenient
- No forced rewrites

---

## Open Questions

1. **Event API** — Should gitgraph use a custom EventEmitter or snacks' event system?
2. **Window management** — Should gitgraph auto-create windows, or always require explicit `render(buf)`?
3. **Async loading** — Should `gitgraph.open()` return immediately, or handle async git operations?
4. **Filtering/search** — Should the interactive list support live filtering (`on_input`)?
5. **Backwards compat** — How long to maintain `draw()` as the legacy API?

---

## Expected Outcome

Once `gitgraph.open()` is stable:
- ✅ Recipes (like diffview-gitgraph) become clean, maintainable
- ✅ No regex parsing or internal API access needed
- ✅ Keymaps, selection, focus are all documented
- ✅ Can be used in other plugins (status line, sidebar, etc.)
- ✅ Gitgraph becomes a composable Neovim primitive, not just a renderer

This is what would make the GitHub issue response honest: "Here's the minimal change that would make integration recipes work."
