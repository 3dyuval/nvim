-- Luacheck configuration for Neovim configuration

-- Global variables that are okay to use
globals = {
  "vim",
  "Snacks",
  "LazyVim",
}

-- Read globals from these standards
std = "lua53+busted"

-- Ignore certain warnings
-- All warnings https://luacheck.readthedocs.io/en/stable/warnings.html
ignore = {
  "211", -- Unused local
  "212", -- Unused argument
  "213", -- Unused loop variable    
  "314", -- Value of a field in a table literal is unused.
  "631", -- Line is too long
  "614", -- Trailing whitespace
  "611", -- Line contains only whitespace
  "421", -- Shadowing definition
  "431", -- Shadowing upvalue
  "113", -- Accessing undefined variable
  "211/_.*", -- Unused variable starting with underscore
  "561", -- Cyclomatic complexity too high (for complex but working functions)
  "512", -- Loop is executed at most once (acceptable patterns)
}

-- Files to exclude from checking
exclude_files = {
  "lazy-lock.json",
  ".luarc.json",
}

-- Maximum line length
max_line_length = 120

-- Maximum cyclomatic complexity
max_cyclomatic_complexity = 15

-- Per-file configurations
files["lua/utils/picker-extensions.lua"] = {
  ignore = {
    "432", -- shadowing upvalue argument 'item' (intentional in format_item callbacks)
  },
}
