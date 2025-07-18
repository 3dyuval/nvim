#!/usr/bin/env lua

-- Simple CLI wrapper for formatter.lua
-- Usage: lua format.lua [files or directories...]

-- Add neovim lua path
local nvim_config = os.getenv("HOME") .. "/.config/nvim"
package.path = nvim_config .. "/lua/?.lua;" .. nvim_config .. "/lua/?/init.lua;" .. package.path

-- Mock minimal vim API for standalone usage
if not vim then
  vim = {
    fn = {
      expand = function(path)
        return path:gsub("^~", os.getenv("HOME"))
      end,
      shellescape = function(str)
        return "'" .. str:gsub("'", "'\\''") .. "'"
      end,
      filereadable = function(path)
        local f = io.open(path, "r")
        if f then
          f:close()
          return 1
        else
          return 0
        end
      end,
      isdirectory = function(path)
        local f = io.popen("test -d " .. vim.fn.shellescape(path) .. " && echo 1 || echo 0")
        local result = f:read("*a"):gsub("%s+", "")
        f:close()
        return tonumber(result) or 0
      end,
      systemlist = function(cmd)
        local result = {}
        local f = io.popen(cmd)
        for line in f:lines() do
          table.insert(result, line)
        end
        f:close()
        return result
      end,
      fnamemodify = function(path, mod)
        if mod == ":t" then
          return path:match("([^/]+)$") or path
        end
        return path
      end,
    },
    log = { levels = { INFO = 1, WARN = 2, ERROR = 3 } },
    notify = function(msg, level)
      local prefix = level == vim.log.levels.ERROR and "[ERROR]"
        or level == vim.log.levels.WARN and "[WARN]"
        or "[INFO]"
      print(prefix .. " " .. msg)
    end,
  }
end

-- Use the sandboxed batch formatter for CLI usage
local function format_cli(args)
  local script_path = nvim_config .. "/scripts/batch-formatter"

  -- Check if script exists
  if vim.fn.filereadable(script_path) == 0 then
    vim.notify("Batch formatter script not found: " .. script_path, vim.log.levels.ERROR)
    os.exit(1)
  end

  -- Build command
  local cmd = script_path
  for _, arg in ipairs(args) do
    cmd = cmd .. " " .. vim.fn.shellescape(arg)
  end

  -- Execute
  local exit_code = os.execute(cmd)
  os.exit(exit_code)
end

-- Main
local args = { ... }
if #args == 0 then
  args = { "." }
end

format_cli(args)
