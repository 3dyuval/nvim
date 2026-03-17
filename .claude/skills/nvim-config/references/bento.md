# Bento

## Intro: Buffer manager with tabline UI

Bento replaces bufferline with a minimal tabline that shows your open buffers across the top of the screen. It assigns single-character labels to each buffer based on filenames for quick switching.

Open a few buffers first to see it in action — you need at least 2-3 buffers open.

- Try it! Use {{ ; }} to expand the tabline and see buffer labels

## Your setup: Tabline mode with minimal styling

Config: `lua/plugins/bufferline.lua`

Your setup changes from defaults:
- `ui.mode = "tabline"` — horizontal tabline instead of floating sidebar
- `separator_symbol = " "` — space separator instead of `│`
- Highlight overrides: minimal labels use `Comment`, window background uses `Normal`
- Default `main_keymap` is {{ ; }}

## Keymaps

### Toggle and navigate
- {{ ; }} — Expand tabline, show labels next to buffer names
- {{ ; }} {{ ; }} — Quick-switch to last accessed buffer
- {{ ESC }} — Collapse tabline back to minimal state
- {{ [ }} / {{ ] }} — Previous / next page when buffers overflow

### Switch buffer
- {{ ; }} → press label key — Jump to that buffer
- Labels are auto-assigned single characters based on filenames (e.g., `k` for `keymaps.lua`)

### Actions: Delete buffer
- {{ ; }} → {{ BS }} → press label — Delete that specific buffer
- Notification appears confirming deletion

### Actions: Vertical split
- {{ ; }} → {{ | }} → press label — Open that buffer in a vertical split
- Status shows "Action mode: vsplit" while waiting for label

### Actions: Horizontal split
- {{ ; }} → {{ _ }} → press label — Open that buffer in a horizontal split
- Status shows "Action mode: split" while waiting for label

### Actions: Lock buffer
- {{ ; }} → {{ * }} → press label — Toggle lock on a buffer
- Locked buffers show 🔒 and are protected from auto-deletion

### Direct open mode
- {{ ; }} → {{ CR }} → press label — Explicit open mode (same as pressing label directly)

## Notes

- {{ Ctrl+- }} is mapped to `:BentoToggle` in your keymaps
- {{ Ctrl+p }} / {{ Ctrl+. }} navigate previous/next buffer without bento
- Buffer ordering is by last access time (most recent first)
