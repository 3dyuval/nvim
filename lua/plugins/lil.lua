return {
  "va9iff/lil",
  config = function()
    -- Load all mappings from keymaps/ directory
    require("keymaps.diff")
    require("keymaps.history")
  end,
}

