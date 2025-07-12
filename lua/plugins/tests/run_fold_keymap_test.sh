#!/bin/bash
# Script to test fold keymaps for conflicts

echo "=== Testing Fold Keymaps for Conflicts ==="
echo ""

# Generate keymap table and test for conflicts
echo "Testing proposed fold keymaps..."
lua /home/lab/Dropbox/config/nvim/lua/plugins/tests/test_fold_keymap_conflicts.lua | lua /home/lab/Dropbox/config/nvim/utils/test_keymaps.lua

echo ""
echo "If no conflicts were reported above, the fold keymaps are safe to implement."
echo ""

# Also test with direct table format
echo "Alternative test with table format:"
echo '{ 
  { mode = "n", lhs = "bo", rhs = "zo", desc = "Open fold" },
  { mode = "n", lhs = "bt", rhs = "za", desc = "Toggle fold" },
  { mode = "n", lhs = "bv", rhs = "zv", desc = "View cursor" }
}' | lua /home/lab/Dropbox/config/nvim/utils/test_keymaps.lua