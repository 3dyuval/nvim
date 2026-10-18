---
name: practice
description: Interactive practice playground for Neovim keymaps (HAEI/Graphite layout). Use when the user wants to practice surround operations, text objects, or any keymap muscle memory. Contains labeled exercise sections separated by --- delimiters — open the file in Neovim and work through each section.
---

# Practice Playground

> **Layout is NOT vanilla vim.** Before writing any drill hint, read
> [`SPEC.md`](../../../SPEC.md) (repo root) — the authoritative HAEI/Graphite
> movement model. Vanilla keys (`j`/`k`, `t`, `iw`) are remapped and will be
> wrong. Quick reference:
> - Direction: `h` left, `a` down, `e` up, `i` right (NOT `hjkl`; `j` = open-line).
> - `k` = till (native `t`), `K` = reverse till (native `T`).
> - `t` = around text-object prefix (`tw`, `t(`); `r` = inner (`rw`, `r(`).
> - `f`/`F` and `;`/`,` are native (`,` freed from bento → `\`).
>
> Verify any uncertain key with `:nmap <key>` / `:omap <key>` via nvim-mcp
> `send_command` before baking it into a hint.

Open a reference file in Neovim and work through each `---` delimited section.

Each section has:
- A header describing the operation and the keys to press
- Example text to operate on — cursor placement is noted inline

## Creating a drill

Two kinds of drill reference exist:

1. **Markdown drills** (`surround-*.md`) — `---`-delimited sections, each with a
   header, keys-to-try, `^` cursor marker, and expected result inline. Self-contained.

2. **Code drills** (dated `.vue`/`.ts`/… files) — a real, comment-free buffer to
   operate on. Hints are NOT written into the file; they are applied as eol
   **virtual text** per session (via nvim-mcp `add_virtual_texts`). The hint
   mapping (line → keys) lives in the matching log, so it is recreatable.

Workflow for a code drill:
- Name the file `YYYY-MM-DD-<subject>.<ext>` under `references/`.
- Keep it pure code — no instructional comments.
- Create a matching log `logs/YYYY-MM-DD-<subject>.md` holding the concepts,
  config notes, a `Hints` table (`line | anchor | keys`), and a `Sessions` section.
- On open: read the log's Hints table and call `add_virtual_texts` to render
  each line's keys as eol virtual text with `color: "DiagnosticInfo"`.

## Keylog

Capture a user's keystrokes during a drill to review their technique. See
[references/keylog.md](references/keylog.md). Invocable via
`_G.PracticeKeylog` (start/stop/clear); the agent reads the `practice-keylog`
scratch buffer with `read_full_buf`.

## Code Drills

- [references/2026-10-18-repeat-f-t-dot.vue](references/2026-10-18-repeat-f-t-dot.vue) —
  repeat patterns: `;`/`,` (find-repeat) vs `.` (change-repeat). Log:
  [logs/2026-10-18-repeat-f-t-dot.md](logs/2026-10-18-repeat-f-t-dot.md)

## Surround Practice

- [references/surround-basic.md](references/surround-basic.md) — `ys`, `ds`, `cs`, visual, aliases, markdown
- [references/surround-fences.md](references/surround-fences.md) — inline code, code fences, language prompt
- [references/surround-textobjects.md](references/surround-textobjects.md) — built-in `r`/`t` objects + treesitter (`tf`, `rf`, `tp`, `tl`, `tt`, `tc`…)

**Layout reminders:**
- `r` = inner (instead of `i`) — `rw` = inner word
- `t` = around (instead of `a`) — `tw` = around word
- `ds` = delete surround, `cs` = change surround, `ys` = add surround (vanilla nvim-surround defaults)
- Visual: `v` to select, `S` to surround (e.g. `viwS(`); `gS` surrounds on new lines
