# Move

## Intro: Move lines, blocks, words, and characters around

Move.nvim lets you physically relocate text — lines, visual selections, words, or individual characters — using keyboard shortcuts. Lines and blocks auto-indent when moved vertically.

- Try it! Place your cursor on any line and use {{ Alt+a }} to push it down

## Your setup: Graphite layout with Alt key

Config: `lua/plugins/move.lua`

All directions follow your HAEI layout with the Alt modifier:
- {{ Alt+a }} = down, {{ Alt+e }} = up, {{ Alt+h }} = left, {{ Alt+i }} = right
- Word movement uses {{ leader w f }} / {{ leader w b }} instead of Alt

## Keymaps

### Move a line up or down
- Try it! On any line, use {{ Alt+a }} to move it down or {{ Alt+e }} to move it up
- Indentation adjusts automatically (e.g., moving into an if block indents the line)

### Move a character left or right
- Try it! Place your cursor on a character, use {{ Alt+h }} to nudge it left or {{ Alt+i }} to nudge it right
- Useful for swapping characters or fixing typos

### Move a word forward or backward
- Try it! Place your cursor on a word, use {{ leader w f }} to swap it with the next word
- Use {{ leader w b }} to swap it with the previous word

### Move a visual selection (block)
- Try it! Select multiple lines with visual mode, then {{ Alt+a }} / {{ Alt+e }} to move the block up or down
- Use {{ Alt+h }} / {{ Alt+i }} to shift the entire selection left or right
- Indentation adjusts automatically when moving vertically
