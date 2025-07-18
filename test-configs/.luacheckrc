-- Test luacheck configuration
globals = {
  "vim",
  "test_global"
}

std = "lua53"

ignore = {
  "211", -- Unused variable
  "212", -- Unused argument
}

max_line_length = 100