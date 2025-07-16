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
ignore = {
  "212", -- Unused argument
  "213", -- Unused loop variable
  "631", -- Line is too long
  "614", -- Trailing whitespace
  "611", -- Line contains only whitespace
  "421", -- Shadowing definition
  "431", -- Shadowing upvalue
  "113", -- Accessing undefined variable
  "211/_.*", -- Unused variable starting with underscore
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