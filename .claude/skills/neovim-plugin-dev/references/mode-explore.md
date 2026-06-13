---
description: Use this mode when the user is in a learning or iteration phase — exploring current plugin behavior, reviewing what changed in a fork, or understanding source without intending to modify it. The plugin is already installed (dev checkout or lazy cache).
---

# Mode B — Explore

1. **Resolve the plugin's actual repo name** — read `lua/plugins/<plugin>.lua` to get the GitHub slug from the spec (e.g. `"dlyongemallo/diffview-plus.nvim"`). The spec name and the lazy cache directory name derive from this slug, not from what the user called it. Then probe the dev path:
   ```
   mcp__nvim-mcp__send_command: lua =require("lazy.core.config").options.dev.path
   ```
   Use `<dev_path>/<repo-name>` if `dev = true` is set, otherwise `~/.local/share/nvim/lazy/<repo-name>`.
2. **Read the changelog** — `doc/*_changelog.txt` or `CHANGELOG.md`; also skim `README.md` for new commands/config.
3. **Scan the git log** — `git -C <path> log --oneline -30` to see recent commits at a glance.
4. **Compare against current config** — read `lua/plugins/<plugin>.lua` and cross-reference new options, breaking changes, and new commands.
5. **Connect Neovim MCP** — use `mcp__nvim-mcp__connect` (pick the instance whose `cwd` matches the plugin dir) then `mcp__nvim-mcp__send_command` to open files or jump to lines in the live editor.
6. **Jump to a symbol** — `grep -n <symbol> <file>` to find the line, then send `[":N", "normal! zz"]` to center it in Neovim.
