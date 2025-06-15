Here’s a detailed report on the relationships and mapping between explorer, picker, item, and types in folke/snacks.nvim, including comprehensive examples.

1. Overview: Explorer, Picker, Item, Types
    Explorer

        Explorer is a file explorer built on top of the picker system (it’s a “picker in disguise”).
        It provides a navigable tree/file browser in Neovim, optionally replacing netrw.
        The explorer is configured as a picker source (picker.sources.explorer).
        The main API is: Snacks.explorer(opts?) which returns a picker, with open() and reveal() helpers.

Picker

    Picker is the core abstraction for fuzzy-finding and selection interfaces in snacks.nvim.
    A picker can have multiple sources (like “files”, “buffers”, or “explorer”).
    Each picker displays a list of items, supports layouts, keybindings, previews, filtering, and sorting.
    The explorer is implemented as a picker source with specialized configuration.

Item

    Items are the entries shown in a picker. Each item is typically a file, buffer, or custom object.
    For the explorer, items represent files/directories and are enriched with extra metadata (type, status, parent, severity, etc.).

Types

    Types are Lua classes and type aliases that describe options, items, layouts, and more.
    Examples: snacks.picker.Item, snacks.picker.explorer.Config, snacks.picker.finder.Item.

2.  Relationships and Mapping
    How They Relate

        The explorer is a specialized picker whose source is a tree of files/folders.
        The explorer picker displays items which represent files or directories, each with a type (file/dir).
        Types describe these items (fields, structure), picker configuration, and explorer-specific settings.

Diagram:
Code

Snacks.explorer()
↳ (returns) Picker (type: 'explorer')
↳ Items (type: snacks.picker.explorer.Item)
↳ Each item: file, dir, status, parent, type, etc.
↳ Config: snacks.picker.explorer.Config (extends picker/files config)

Explorer Picker Item Example

From the explorer source:
Lua

local item = {
file = node.path, -- file path
dir = node.dir, -- is a directory?
open = node.open, -- is directory open?
dir_status = node.dir_status or parent and parent.dir_status,
text = node.path, -- label shown
parent = parent, -- parent item
hidden = node.hidden,
ignored = node.ignored,
status = ... -- git status
type = node.type, -- file/directory type
severity = ... -- diagnostics, if any
}

3. Types Reference
   Key Types
   snacks.picker.Item
   Lua

---@class snacks.picker.Item
---@field idx number
---@field score number
---@field file? string
---@field text string
---@field dir? boolean
---@field parent? snacks.picker.explorer.Item
---@field type? string -- "file", "dir", etc.
---@field status? string -- git or custom status
---@field severity? any -- diagnostics

snacks.picker.explorer.Config
Lua

---@class snacks.picker.explorer.Config : snacks.picker.files.Config
---@field follow_file? boolean
---@field tree? boolean
---@field git_status? boolean
---@field git_status_open? boolean
---@field git_untracked? boolean
---@field diagnostics? boolean
---@field diagnostics_open? boolean
---@field watch? boolean
---@field exclude? string[]
---@field include? string[]

snacks.picker.Config (base picker)

Includes source, items, format, finder, preview, matcher, sort, layout, actions, etc. 4. Example Configurations
A. Basic Explorer Setup
Lua

{
"folke/snacks.nvim",
opts = {
explorer = {}, -- General explorer config (replace netrw, etc.)
picker = {
sources = {
explorer = {
-- Explorer picker config here (see below)
}
}
}
}
}

B. Explorer Picker Source Example
Lua

{
finder = "explorer",
sort = { fields = { "sort" } },
tree = true, -- show as tree
watch = true, -- auto-refresh
diagnostics = true, -- show diagnostics
git_status = true, -- show git status
follow_file = true, -- sync with current file
focus = "list",
layout = { preset = "sidebar", preview = false },
formatters = {
file = { filename_only = true },
severity = { pos = "right" },
},
matcher = { sort_empty = false, fuzzy = false },
win = {
list = {
keys = {
["<BS>"] = "explorer_up",
["l"] = "confirm",
["h"] = "explorer_close",
["a"] = "explorer_add",
["d"] = "explorer_del",
["r"] = "explorer_rename",
["c"] = "explorer_copy",
["m"] = "explorer_move",
["o"] = "explorer_open",
["P"] = "toggle_preview",
["y"] = { "explorer_yank", mode = { "n", "x" } },
["p"] = "explorer_paste",
-- ...and more
},
},
},
}

C. Using the Explorer in Keymaps
Lua

keys = {
{ "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
{ "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
{ "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
}

5. Comprehensive Example: How Mapping Works

Suppose you open the explorer. Here’s what happens:

    Snacks.explorer() is called; this creates a picker with the explorer source.
    The picker config is loaded from opts.picker.sources.explorer.
    The picker displays a tree of items—each item is an object of type snacks.picker.explorer.Item (with fields like file, dir, type, status, etc.).
    Keybindings in win.list.keys allow navigation and actions (open, close, rename, etc.).
    The explorer picker can display extra info (git status, diagnostics) and supports live updates.

6. Summary Table
   Concept Description Key Types / Classes
   Explorer File explorer (tree, files, dirs) snacks.picker.explorer.Config, Item
   Picker Generic fuzzy-finder UI snacks.picker.Config, Picker
   Item Entry in picker (file, dir, buffer, etc.) snacks.picker.Item, .explorer.Item
   Types Lua types/classes describing structure and behavior snacks.picker.Item, .Config, etc.
7. References

   explorer.md
   picker.md
   examples/picker.lua

If you want more concrete code samples or further detail on any specific mapping or type, let me know!
we need a detailed doc on table items types

Certainly! Here’s a detailed documentation on the types related to table items in the context of snacks.nvim, focusing on how items are structured, what fields and types they support, and how they are used within pickers and explorer.
📑 Detailed Documentation: Table Item Types in snacks.nvim

1. Core Item Types
   snacks.picker.Item

This is the base type for any item shown in a picker (including explorer, buffers, files, etc).
Lua

---@class snacks.picker.Item
---@field [string] any -- Items can have arbitrary fields
---@field idx number -- Item index in the list
---@field score number -- Fuzzy match score
---@field frecency? number -- Optional: frequency/recency score
---@field score_add? number -- Optional: additional score
---@field score_mul? number -- Optional: multiplier for score
---@field source_id? number -- Optional: source identification
---@field file? string -- Optional: file path
---@field text string -- Main text to display in the picker
---@field pos? snacks.picker.Pos -- Optional: position (line, col)
---@field loc? snacks.picker.lsp.Loc -- Optional: LSP location object
---@field end_pos? snacks.picker.Pos -- Optional: end position
---@field highlights? snacks.picker.Highlight[][] -- Optional: highlights for display
---@field preview? snacks.picker.Item.preview -- Optional: preview data
---@field resolve? fun(item:snacks.picker.Item) -- Optional: async resolver

Notes:

    Items can be extended with custom fields, especially in custom pickers or explorer sources.
    The text field is what’s shown as the main label.
    file is used for path-based sources (files, explorer).
    score is used for sorting/matching.
    pos, loc, end_pos allow navigation to specific locations (files, buffers, diagnostics).

snacks.picker.finder.Item

This extends snacks.picker.Item for use as raw entries from a finder.
Lua

---@class snacks.picker.finder.Item : snacks.picker.Item
---@field idx? number
---@field score? number

    These are often transformed into snacks.picker.Item for display.

snacks.picker.explorer.Item

Explorer items are a further specialization for the file explorer, with extra metadata.
Lua

-- Not always explicitly defined as a class, but typically:
{
file: string, -- Path to file or directory
dir: boolean, -- Is this a directory?
open: boolean, -- Is the directory expanded/open?
dir_status: string?, -- Git status for directory
text: string, -- Label for display
parent: snacks.picker.explorer.Item?, -- Parent item
hidden: boolean?, -- Is hidden (dotfile/ignored)?
ignored: boolean?, -- Is ignored by VCS?
status: string?, -- Git status for file
last: boolean?, -- Last item in directory
type: string?, -- "file", "dir", or other
severity: any?, -- Diagnostics severity
-- Plus any base snacks.picker.Item fields
}

Example (from source):
Lua

local item = {
file = node.path,
dir = node.dir,
open = node.open,
dir_status = node.dir_status or parent and parent.dir_status,
text = node.path,
parent = parent,
hidden = node.hidden,
ignored = node.ignored,
status = ...,
last = true,
type = node.type,
severity = ...,
}

2. Related Supporting Types
   snacks.picker.Pos
   Lua

---@alias snacks.picker.Pos {[1]:number, [2]:number}
-- Example: {12, 4} -- line 12, column 4

snacks.picker.Highlight
Lua

---@alias snacks.picker.Highlight snacks.picker.Text|snacks.picker.Extmark

    Used for syntax highlighting of items in the picker.

snacks.picker.Item.preview
Lua

---@class snacks.picker.Item.preview
---@field text string -- Text to show in the preview buffer
---@field ft? string -- Optional filetype for preview
---@field extmarks? snacks.picker.Extmark[] -- Additional extmarks
---@field loc? boolean -- Show item location in preview (default true)

3. Example: Table of Items

Suppose you have a picker listing files (for example, in the explorer):
Lua

{
{
idx = 1,
score = 1500,
file = "/home/user/project/init.lua",
text = "init.lua",
dir = false,
type = "file",
status = "M", -- Modified in git
highlights = { ... },
},
{
idx = 2,
score = 1400,
file = "/home/user/project/lua/",
text = "lua/",
dir = true,
open = true,
type = "dir",
status = "A", -- Added in git
highlights = { ... },
},
-- More items...
}

4. How Items Are Used in Pickers

   A picker receives a list (table) of items, each respecting the relevant item type.
   For explorer, each item is a table with at least the base fields (file, text, dir, etc.).
   Custom sources can add or override fields as needed.
   Actions, formatting, preview, and navigation in the picker reference these item fields.

5. Extending Items

You can safely add custom fields to items for use with your own pickers or formatting logic. All items are Lua tables with at least the documented base fields. 6. Reference

    picker.md - Item definitions
    explorer source code

If you need details about a specific item type or an example for a particular picker source, let me k
