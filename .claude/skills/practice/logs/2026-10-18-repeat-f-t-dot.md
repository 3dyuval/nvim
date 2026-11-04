# Drill Log — Repeat patterns (f/t/F/T, dot)

- Date: 2026-10-18
- Subject: base repetition — `;` `,` (find-repeat) vs `.` (change-repeat)
- Drill file: `references/2026-10-18-repeat-f-t-dot.vue`

## Concepts drilled

- `;` / `,` repeat **only** `f` `t` `F` `T` — a motion, pure cursor move, no edit.
  - `;` same direction, `,` reverse direction.
- `.` repeats the last **change** — operator + target (`diw`, `ct{`, `dt=`).
  - Replays the whole edit at the cursor. Independent of `;` `,`.
- Operator = verb (`d` `c` `y` `>` `p`); target = motion or text object.
- `y` (yank) is an operator but makes no change → not dot-repeatable.
- Text objects (`rw`/`tw`/`i{`) never repeat standalone; only the operation does, via `.`.

## Hints (eol virtual text — recreate each session)

The drill file is kept comment-free; render these as eol virtual text via
`add_virtual_texts` when the drill is opened.

Layout note (HAEI): movement is `h` left, `a` down, `e` up, `i` right (j = `o`
open-line, NOT down). `t` = around (text object), NOT till — till is `k`
(= native `t`), reverse-till `K` (= native `T`). `r` = inner (`rw` = inner word).

| line | anchor | keys |
|------|--------|------|
| 5  | `const a = {...}`   | `f{ then ; ; ;  (then , , ,)` |
| 7  | `const nums = [...]` | `k, then ; ;` |
| 10 | `const alpha = ref(1)` | `dk= then a . / a .` |
| 14 | `const dog = 1`      | `crwfoo<Esc> then w w .` |
| 19 | `const labels = [...]` | `cr"NEW<Esc> then f" ; . / f" ; .` (cr" = change inner quotes, keeps `"`) |

## Config notes

- RESOLVED (2026-11-02): bento's expand key is `<C-;>`, not plain `;`
  (fnl/plugins/bento.fnl:26, compiled lua/plugins/bento.lua:6; changed in
  commit 9fe6def). Plain `;` is unbound — native find-repeat is clean
  everywhere. No unbinding needed.

## Sessions

<!-- append one line per run: date — what went well / what to retry -->
