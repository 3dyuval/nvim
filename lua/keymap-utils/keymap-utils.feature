Feature: Smart keymap binding for neovim
  Implementation: ./init.lua
  Usage example: 
  ```lua
    map({
      [mode] = { "n" },
      [ctrl + _] = {
        p = { cmd("BufferLineCyclePrev"), desc = "Previous buffer" },
        ["."] = { cmd("BufferLineCycleNext"), desc = "Next buffer" },
      },
    })
    map({
      ["<leader>r"] = {
        c = { editor.reload_config, desc = "Reload config" },
        r = { editor.reload_keymaps, desc = "Reload keymaps" },
        l = { cmd("Lazy sync"), desc = "Lazy sync plugins" },
      },
    })
  ```
  

 Scenario: Binding a key
   Given any nested table includes [disabled] = true
   Then It should not be mapped in nvim
   And should be printed using "KeymapUtilsPrint" with a '*' prepending it
