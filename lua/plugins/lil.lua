return {
  "va9iff/lil",
  config = function()
    local lil = require("lil")
    local extern = lil.extern
    
    -- Define extern functions for code operations
    -- These reference functions from plugin configs
    extern.organize_imports = function()
      local conform_config = require("plugins.conform")
      conform_config.organize_imports()
    end
    
    extern.organize_imports_and_fix = function()
      local conform_config = require("plugins.conform")
      conform_config.organize_imports_and_fix()
    end
    
    -- NOTE: Keymap modules are loaded from lua/config/keymaps.lua
    -- to ensure proper loading order after all plugins are configured
  end,
}
