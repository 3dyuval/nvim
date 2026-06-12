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

- [references/surround-basic.md](references/surround-basic.md) — `ys`, `ds`, `cs`, visual, aliases, markdown
- [references/surround-fences.md](references/surround-fences.md) — inline code, code fences, language prompt
- [references/surround-textobjects.md](references/surround-textobjects.md) — built-in `r`/`t` objects + treesitter (`tf`, `rf`, `tp`, `tl`, `tt`, `tc`…)

**Layout reminders:**
- `r` = inner (instead of `i`) — `rw` = inner word
- `t` = around (instead of `a`) — `tw` = around word
- `xs` = delete surround (Graphite `x`=delete)
- `ws` = change surround (Graphite `w`=change)
- Visual: `v` to select, `s` to surround (e.g. `viws(`)
