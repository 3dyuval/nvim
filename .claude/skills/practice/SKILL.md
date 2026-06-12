---
name: practice
description: Interactive practice playground for Neovim keymaps (HAEI/Graphite layout). Use when the user wants to practice surround operations, text objects, or any keymap muscle memory. Contains labeled exercise sections separated by --- delimiters — open the file in Neovim and work through each section.
---

# Practice Playground

Open a reference file in Neovim and work through each `---` delimited section.

Each section has:
- A header describing the operation and the keys to press
- Example text to operate on — cursor placement is noted inline

## Surround Practice

Open [references/surround.md](references/surround.md) for surround + text-object exercises.

**Layout reminders:**
- `r` = inner (instead of `i`) — `rw` = inner word
- `t` = around (instead of `a`) — `tw` = around word
- `xs` = delete surround (Graphite `x`=delete)
- `ws` = change surround (Graphite `w`=change)
- Visual: `v` to select, `s` to surround (e.g. `viws(`)
