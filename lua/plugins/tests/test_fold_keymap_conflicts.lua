#!/usr/bin/env lua
-- Test fold keymaps for conflicts using the test_keymaps.lua utility
-- This test can be run headlessly to check for keymap conflicts

-- Define proposed fold keymaps for issue #4
local fold_keymaps = {
  -- Existing keymaps (should not conflict)
  { mode = "n", lhs = "b", rhs = "z", desc = "Fold commands" },
  { mode = "n", lhs = "bb", rhs = "zb", desc = "Scroll line to bottom" },
  { mode = "n", lhs = "be", rhs = "zk", desc = "Move up to fold" },
  { mode = "n", lhs = "ba", rhs = "zj", desc = "Move down to fold" },
  { mode = "n", lhs = "bf", rhs = "zc", desc = "Close fold" },
  { mode = "n", lhs = "bF", rhs = "zM", desc = "Fold entire buffer" },
  { mode = "n", lhs = "bO", rhs = "zR", desc = "Open all folds" },
  
  -- Missing keymaps to add for issue #4
  { mode = "n", lhs = "bo", rhs = "zo", desc = "Open fold" },
  { mode = "n", lhs = "bt", rhs = "za", desc = "Toggle fold" },
  { mode = "n", lhs = "bv", rhs = "zv", desc = "View cursor" },
  
  -- Additional fold level keymaps (optional)
  { mode = "n", lhs = "b1", rhs = "z1", desc = "Fold level 1" },
  { mode = "n", lhs = "b2", rhs = "z2", desc = "Fold level 2" },
  { mode = "n", lhs = "b3", rhs = "z3", desc = "Fold level 3" },
}

-- Output the keymap table for piping to test_keymaps.lua
-- Format: mode|lhs|rhs|desc with proper escaping
for _, keymap in ipairs(fold_keymaps) do
  io.write(string.format("%s|%s|%s|%s\n", 
    keymap.mode, 
    keymap.lhs, 
    keymap.rhs, 
    keymap.desc or ""
  ))
end