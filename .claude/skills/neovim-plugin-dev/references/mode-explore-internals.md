---
description: Use this mode when the user asks to "show me usage of", "show me how X works", "open X in the editor", or wants to interact with plugin internals — implementation, docs, or live command execution. Requires the plugin source to already be located (run mode-explore step 1 first).
---

# Mode — Explore Plugin Internals

When the user asks "show me usage of X", clarify intent before acting:

| Intent | Action |
|--------|--------|
| **Highlight implementation** | `grep -n <symbol> <file>` to find the line, then `mcp__nvim-mcp__send_command: [":N", "normal! zz"]` to open and center it in the editor |
| **Open docs** | Find the relevant section in `doc/*.txt`, then open and jump to it via MCP |
| **Execute the command** | Run it directly via `mcp__nvim-mcp__send_command` |
| **Input without executing** | Send the command string to Neovim's cmdline without `<CR>` so the user can review and trigger it themselves |

If the intent is unclear from context, ask before acting.

## Recipes

- **`recipe-diff-range.md`** — pre-fill a `DiffviewFileHistory --range=` command in the Neovim cmdline
