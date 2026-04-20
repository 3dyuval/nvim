
  Neovim cmdline = the : bar at the bottom where you type commands. Neovim built-in, always there.

  noice.nvim = a plugin that replaces how that bar looks - turns it into a floating popup in the
  middle/bottom of screen. Same thing, different UI.

  blink.cmp = the autocomplete engine that shows suggestions as you type in that bar.

  So when you type :, all three are involved:
  1. Neovim handles the input
  2. noice renders the floating box
  3. blink shows the suggestion list

  Up/Down is broken because noice and blink both think they own those keys inside that floating box.
  Sometimes noice wins (history navigation), sometimes blink wins (suggestion navigation). That's the
  inconsistency.

● This is a known blink.cmp bug - issue #1328. The root cause: blink registers cmap for Up/Down but
  Neovim's built-in cmdline history maps compete at the same level, and the winner is
  non-deterministic. noice's command_palette preset adds its own keymaps on top, making it worse.

  Fix applied (2026-04-20):
  1. blink-cmp.lua: restored "fallback" on <Up>/<Down> in cmdline keymap so history still works when
     blink menu is not visible:
       ["<Up>"] = { "select_prev", "fallback" },
       ["<Down>"] = { "select_next", "fallback" },
  2. noice.lua: disabled command_palette preset (was conflicting with blink's cmdline keymap handling):
       command_palette = false,
