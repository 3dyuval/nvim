local maps = require("keymaps.maps")
local map = maps.map
local func = maps.func
local desc = maps.desc
local which = maps.which

-- Forward declarations
local go_to_source_definition
local file_references

-- Keymaps
map({
  [func] = which,
  g = {
    D = desc("Go to source definition", go_to_source_definition),
    R = desc("File references", file_references),
  },
})

-- Implementations
go_to_source_definition = "<cmd>TSToolsGoToSourceDefinition<cr>"
file_references = "<cmd>TSToolsFileReferences<cr>"