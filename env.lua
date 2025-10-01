local M = {}

function M.get_platform()
  if vim.fn.has("mac") == 1 then
    return "darwin"
  elseif vim.fn.has("linux") == 1 then
    return "linux"
  elseif vim.fn.has("win32") == 1 then
    return "win32"
  end
end

-- Platform-specific configurations
M.chrome = {
  executable = {
    darwin = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    linux = "/usr/bin/google-chrome-stable",
    win32 = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
  },
  user_data_dir = {
    darwin = "/tmp/chrome-debug-profile",
    linux = function()
      return os.getenv("XDG_DATA_HOME") and (os.getenv("XDG_DATA_HOME") .. "/chrome-debug") or "/tmp/chrome-debug-profile"
    end,
    win32 = function()
      return os.getenv("TEMP") .. "\\chrome-debug-profile"
    end
  }
}

M.stylua = {
  config_path = {
    darwin = vim.fn.stdpath("config") .. "/stylua.toml",
    linux = vim.fn.stdpath("config") .. "/stylua.toml",
    win32 = vim.fn.stdpath("config") .. "\\stylua.toml"
  }
}

M.mason = {
  install_root_dir = {
    darwin = vim.fn.stdpath("data") .. "/mason",
    linux = vim.fn.stdpath("data") .. "/mason",
    win32 = vim.fn.stdpath("data") .. "\\mason"
  }
}

M.terminals = {
  default = {
    darwin = "kitty",
    linux = "kitty",
    win32 = "powershell"
  }
}

M.fff = {
  lib_extension = {
    darwin = "dylib",
    linux = "so",
    win32 = "dll"
  }
}

-- Helper function to get platform-specific config for a dependency
function M.get(dep_name)
  local platform = M.get_platform()
  local dep = M[dep_name]

  if not dep then
    return nil
  end

  local result = {}
  for key, platforms in pairs(dep) do
    local value = platforms[platform]
    -- Handle function values (for dynamic paths)
    if type(value) == "function" then
      result[key] = value()
    else
      result[key] = value
    end
  end
  return result
end

-- Convenience functions for common use cases
function M.get_chrome_path()
  local chrome = M.get("chrome")
  return chrome and chrome.executable
end

function M.get_chrome_user_data_dir()
  local chrome = M.get("chrome")
  return chrome and chrome.user_data_dir
end

function M.get_stylua_config()
  local stylua = M.get("stylua")
  return stylua and stylua.config_path
end

function M.get_fff_lib_extension()
  local fff = M.get("fff")
  return fff and fff.lib_extension
end

return M