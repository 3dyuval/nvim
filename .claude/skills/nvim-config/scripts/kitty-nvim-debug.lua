#!/usr/bin/env lua
-- Kitty-Neovim Debug Script
-- Send commands/keys to Neovim instances via Kitty remote control
--
-- Usage:
--   lua kitty-nvim-debug.lua list              -- List nvim instances
--   lua kitty-nvim-debug.lua send "iHello"     -- Send keys to nvim
--   lua kitty-nvim-debug.lua cmd "w"           -- Send ex command (:w)
--   lua kitty-nvim-debug.lua reload            -- Reload nvim config
--   lua kitty-nvim-debug.lua launch [file]     -- Launch nvim in new tab
--   lua kitty-nvim-debug.lua help              -- Show help
--
-- Prerequisites:
--   - Kitty with: allow_remote_control yes
--   - Running inside Kitty or KITTY_LISTEN_ON set

local SOCKET = os.getenv("KITTY_LISTEN_ON") or "unix:/tmp/kitty"
local INSIDE_KITTY = os.getenv("KITTY_WINDOW_ID") ~= nil

local function exec(cmd)
  local h = io.popen(cmd .. " 2>&1")
  local out = h:read("*a")
  h:close()
  return out
end

local function kitty(cmd)
  local prefix = INSIDE_KITTY and "kitten @" or ("kitten @ --to " .. SOCKET)
  return exec(prefix .. " " .. cmd)
end

local function list_nvim()
  local out = kitty("ls")
  local instances = {}
  -- Parse JSON for nvim windows
  for id, title in out:gmatch('"id":%s*(%d+)[^}]-"title":%s*"([^"]*)"') do
    if title:match("nvim") or title:match("vim") then
      table.insert(instances, { id = id, title = title })
    end
  end
  if #instances == 0 then
    print("No Neovim instances found")
  else
    print("Neovim instances:")
    for _, inst in ipairs(instances) do
      print(string.format("  [%s] %s", inst.id, inst.title))
    end
  end
  return instances
end

local function send_keys(keys, match)
  match = match or "title:nvim"
  local escaped = keys:gsub("'", "'\\''")
  return kitty(string.format("send-text --match '%s' '%s'", match, escaped))
end

local function send_cmd(cmd, match)
  -- Send ex command: Escape + :cmd + Enter
  local keys = string.format("\027:%s\r", cmd)
  return send_keys(keys, match)
end

local function reload_config(match)
  return send_cmd("source $MYVIMRC", match)
end

local function launch_nvim(file)
  local cmd = file and ("nvim " .. file) or "nvim"
  return kitty(string.format('launch --type=tab --tab-title="nvim" %s', cmd))
end

local function help()
  print([[
Kitty-Neovim Debug Script

Commands:
  list              List all Neovim instances
  send <keys>       Send keystrokes (e.g., "iHello<Esc>")
  cmd <command>     Send ex command (e.g., "w" for :w)
  reload            Reload Neovim config (:source $MYVIMRC)
  launch [file]     Launch Neovim in new Kitty tab
  help              Show this help

Options:
  --match <pattern> Target specific window (default: title:nvim)

Examples:
  lua kitty-nvim-debug.lua list
  lua kitty-nvim-debug.lua send "ysiwi"
  lua kitty-nvim-debug.lua cmd "lua print('test')"
  lua kitty-nvim-debug.lua cmd "KMUInspect"
  lua kitty-nvim-debug.lua reload
  lua kitty-nvim-debug.lua launch /tmp/test.lua
]])
end

-- Main
local args = arg or {}
local cmd = args[1]
local match = "title:nvim"

-- Parse --match option
for i, v in ipairs(args) do
  if v == "--match" and args[i + 1] then
    match = args[i + 1]
    table.remove(args, i)
    table.remove(args, i)
    break
  end
end

if cmd == "list" then
  list_nvim()
elseif cmd == "send" and args[2] then
  send_keys(args[2], match)
  print("Sent keys: " .. args[2])
elseif cmd == "cmd" and args[2] then
  send_cmd(args[2], match)
  print("Sent command: :" .. args[2])
elseif cmd == "reload" then
  reload_config(match)
  print("Sent reload config")
elseif cmd == "launch" then
  launch_nvim(args[2])
  print("Launched nvim" .. (args[2] and (" with " .. args[2]) or ""))
elseif cmd == "help" or not cmd then
  help()
else
  print("Unknown command: " .. (cmd or ""))
  print("Use 'help' for usage")
end
