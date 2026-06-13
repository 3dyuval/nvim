---
description: Use this mode when the user is in a development phase — making changes to a plugin's implementation, working on a fork, or needs a local dev checkout wired into lazy so edits are reflected live.
---

# Mode A — Set Up Local Dev Checkout

## Requirements

**nvim-mcp** must be active in the Claude Code session. If missing, add to `.mcp.json` in the repo root:

```json
{
  "mcpServers": {
    "nvim-mcp": {
      "enabled": true,
      "command": "uvx",
      "args": ["nvim-mcp"]
    }
  }
}
```

Then restart Claude Code.

**Lazy dev path** must be configured (e.g. `lua/config/lazy.lua`):

```lua
require("lazy").setup({
  dev = { path = "~/proj" },
})
```

If missing, add it before proceeding.

## Steps

1. **Get lazy's dev path** — probe at runtime via Neovim MCP:
   ```
   mcp__nvim-mcp__send_command: lua =require("lazy.core.config").options.dev.path
   ```
2. **Check if a dev checkout exists** — `ls <dev_path>/<repo-name>` (strip `user/` prefix from the plugin slug).
3. **If missing — find and clone** — locate the upstream or preferred fork on GitHub, then:
   ```
   git clone https://github.com/<user>/<repo> <dev_path>/<repo-name>
   ```
4. **Enable dev mode in the plugin spec** — open `lua/plugins/<plugin>.lua` and add `dev = true` to the spec table. Lazy will now load from `<dev_path>/<repo-name>` instead of the cache.
5. **Restart or `:Lazy reload <plugin>`** — apply the change.
