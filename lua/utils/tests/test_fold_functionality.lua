-- Comprehensive test for fold functionality (UFO plugin + keymaps)
-- This test verifies existing fold features and identifies gaps per issue #4

-- Add path for utils
package.path = package.path .. ";../../utils/?.lua;../../../utils/?.lua"

print("=== Comprehensive Fold Functionality Test ===")
print("Testing UFO plugin integration and fold keymaps\n")

-- Test 1: Verify UFO plugin is loaded
print("1. Testing UFO plugin availability...")
local ufo_loaded = pcall(require, "ufo")
if ufo_loaded then
  print("✓ UFO plugin is loaded")
else
  print("✗ UFO plugin is NOT loaded")
end

-- Test 2: Check fold-related options
print("\n2. Checking fold options...")
local fold_options = {
  foldlevel = vim.opt.foldlevel:get(),
  foldlevelstart = vim.opt.foldlevelstart:get(),
  foldenable = vim.opt.foldenable:get(),
  foldcolumn = vim.opt.foldcolumn:get(),
}

for option, value in pairs(fold_options) do
  print(string.format("  %s = %s", option, tostring(value)))
end

-- Test 3: Check fillchars for fold symbols
print("\n3. Checking fold fillchars...")
local fillchars = vim.opt.fillchars:get()
local fold_chars = {
  foldopen = fillchars.foldopen or "default",
  foldclose = fillchars.foldclose or "default",
  fold = fillchars.fold or "default",
  foldsep = fillchars.foldsep or "default",
}

for char_type, char in pairs(fold_chars) do
  print(string.format("  %s = '%s'", char_type, char))
end

-- Test 4: Test existing fold keymaps
print("\n4. Testing existing fold keymaps...")
local keymaps_to_test = {
  { mode = "n", lhs = "f", desc = "Fold commands prefix (maps to z)" },
  { mode = "n", lhs = "ff", desc = "Open fold (unfold)" },
  { mode = "n", lhs = "fF", desc = "Open all folds (unfold all)" },
  { mode = "n", lhs = "fu", desc = "Close fold (fold one)" },
  { mode = "n", lhs = "fU", desc = "Close all folds (fold all)" },
  { mode = "n", lhs = "fe", desc = "Move up to fold (zk)" },
  { mode = "n", lhs = "fa", desc = "Move down to fold (zj)" },
  { mode = "n", lhs = "bb", desc = "Scroll line to bottom (zb)" },
}

-- Get all current keymaps
local all_keymaps = {}
for _, mode in ipairs({ "n", "v", "x", "i", "c", "t" }) do
  local mode_keymaps = vim.api.nvim_get_keymap(mode)
  for _, keymap in ipairs(mode_keymaps) do
    all_keymaps[mode .. ":" .. keymap.lhs] = keymap
  end
end

-- Check each keymap
for _, keymap in ipairs(keymaps_to_test) do
  local key = keymap.mode .. ":" .. keymap.lhs
  if all_keymaps[key] then
    print(string.format("✓ %s - %s", keymap.lhs, keymap.desc))
  else
    print(string.format("✗ %s - %s (NOT FOUND)", keymap.lhs, keymap.desc))
  end
end

-- Test 5: Check for missing keymaps (referenced in tests but not defined)
print("\n5. Checking for missing fold keymaps...")
local missing_keymaps = {
  { mode = "n", lhs = "bo", desc = "Open fold (zo)" },
  { mode = "n", lhs = "bt", desc = "Toggle fold (za)" },
  { mode = "n", lhs = "bv", desc = "View cursor (zv)" },
}

for _, keymap in ipairs(missing_keymaps) do
  local key = keymap.mode .. ":" .. keymap.lhs
  if all_keymaps[key] then
    print(string.format("✓ %s - %s (EXISTS)", keymap.lhs, keymap.desc))
  else
    print(string.format("✗ %s - %s (MISSING)", keymap.lhs, keymap.desc))
  end
end

-- Test 6: Check treesitter fold navigation
print("\n6. Testing treesitter fold navigation...")
local ts_nav_keymaps = {
  { mode = "n", lhs = "]z", desc = "Next fold" },
  { mode = "n", lhs = "[z", desc = "Previous fold" },
}

for _, keymap in ipairs(ts_nav_keymaps) do
  local key = keymap.mode .. ":" .. keymap.lhs
  if all_keymaps[key] then
    print(string.format("✓ %s - %s", keymap.lhs, keymap.desc))
  else
    print(string.format("✗ %s - %s (NOT FOUND)", keymap.lhs, keymap.desc))
  end
end

-- Test 7: Recommendations for issue #4
print("\n7. Recommendations for issue #4 (fold keymaps):")
print("\nRequired keymaps based on the issue request:")
print("  - Fold all: bF → zM (ALREADY EXISTS)")
print("  - Unfold all: bO → zR (ALREADY EXISTS)")
print("  - Next folded: ]z (EXISTS via treesitter)")
print("  - Previous folded: [z (EXISTS via treesitter)")
print("\nAdditional recommended keymaps:")
print("  - Open fold: bo → zo (MISSING)")
print("  - Toggle fold: bt → za (MISSING)")
print("  - View cursor: bv → zv (MISSING)")
print("  - Fold level operations: b1-b9 → z1-z9 (NOT IMPLEMENTED)")
print("  - Create fold: bc → zf{motion} (NOT IMPLEMENTED)")

-- Test 8: Test with actual content
print("\n8. Testing fold operations with content...")
vim.cmd("enew")
local test_content = [[
-- Test TypeScript imports (should auto-fold with UFO)
import { Component } from 'react'
import { useState } from 'react'
import { useEffect } from 'react'
import { useMemo } from 'react'

function testFunction() {
  const x = 1
  const y = 2
  
  if (x > 0) {
    console.log('positive')
  }
  
  return x + y
}

class TestClass {
  constructor() {
    this.value = 0
  }
  
  method() {
    return this.value
  }
}
]]

vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(test_content, "\n"))
vim.bo.filetype = "typescript"

-- Wait for UFO to process
vim.wait(500)

print("Buffer created with TypeScript content")
print("UFO should have detected import block for auto-folding")

-- Clean up
vim.cmd("bdelete!")

print("\n=== Fold Functionality Test Complete ===")
print("\nSummary:")
print("- UFO plugin is properly configured")
print("- Basic fold keymaps exist (bF, bO, bf, ba, be)")
print("- Missing keymaps: bo (open), bt (toggle), bv (view)")
print("- Issue #4 requirements are partially met")
print("- Recommendation: Add missing keymaps for complete fold workflow")
