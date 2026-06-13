---
description: Use this recipe when the user wants to open a git revision range diff or file history in Neovim using diffview-plus. Pre-fills the cmdline so the user can review and trigger it.
---

# Recipe — Open Diff Range in Neovim

**Requires:** `diffview-plus.nvim` installed and `nvim-mcp` connected.

## Pre-fill DiffviewFileHistory for a range

```
mcp__nvim-mcp__send_command:
  lua vim.api.nvim_feedkeys(":DiffviewFileHistory --range=<range>", "n", false)
```

The command lands in the cmdline — user hits `<CR>` to run or `<Esc>` to cancel.

## Common range patterns

| Intent | Range |
|--------|-------|
| Last commit | `HEAD~1..HEAD` |
| Last N commits | `HEAD~N..HEAD` |
| Since a branch diverged | `origin/main..HEAD` |
| Specific commit | `<sha>~1..<sha>` |

## Verify it ran

After the user confirms, use `mcp__nvim-mcp__get_state_brief` to read the active window — it should show `filetype: DiffviewFileHistory` with the revision range and changed files listed.
