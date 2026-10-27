# Multiple Cursors — Practice Playground

Native Neovim **0.13 multicursor** (`:h multicursor`). Requires your updated
nightly (dev-1572+, launched via `~/.local/bin/neovim`). Practice **on this very
file**: each `---` section is self-contained. After an edit, press `u` to reset
that section and try again.

## Cheatsheet — the keys these drills use (your HAEI layout)

| Intent                | Key(s)            | Note                                  |
| --------------------- | ----------------- | ------------------------------------- |
| Insert at cursor      | `s`               | (`i`/`a` are motions here!)           |
| Insert at line start  | `L`               |                                       |
| Insert at end of line | `W` / `S`         |                                       |
| Leave insert          | `<C-n>` or `<Esc>`|                                       |
| Change operator       | `c`               | change inner word = `crw`             |
| Delete operator       | `d`               | delete inner word = `drw` (`x` is off)|
| Inner / around word   | `rw` / `tw`       | `r`=inner, `t`=around                 |
| Word forward          | `w`               | native, unshadowed                    |
| Motions ← ↓ ↑ →       | `h` `a` `e` `i`   |                                       |
| Visual / Visual-line  | `v` / `V`         | native                                |
| Search                | `/pat<CR>` `*` `n`/`N` | `*` = word under cursor          |

### Multicursor commands (the reference — verbatim from `:h multicursor`)

```text
COMMANDS
							*Q*
Q			Toggles a multicursor at the current cursor position.
			Disables follow-mode |q=|.

[count]Q		Places a cursor at every match (|gn|) of the last
			search pattern. Example:
			1. Search for something ("*", "/pattern<CR>", …).
			2. Type "1Q".

							*mcursor-mouse* *<C-LeftMouse>*
<C-LeftMouse>		Toggles a multicursor at the click position, without
			moving the primary cursor (or changing windows). Does
			NOT disable follow-mode |q=|. No-op in Insert-mode.

							*v_Q*
{Visual}Q		Places a cursor on each line of the Visual selection.
			Enables follow-mode |q=|.

							*q=*
q=			Toggles follow-mode: motions (not jumps/scrolls) are
			replayed per-cursor. Cursors arriving at the same
			position (e.g. "G") are merged (deduplicated).

			Use [count] to force the mode instead of toggling:
			"1q=" on, "2q=" off.

							*mcursor-clear*
CTRL-L			Clears multicursors in the current buffer.
			|CTRL-L-default|

			Cursors can also be cleared by clearing the namespace: >lua
			    local mc_ns = vim.api.nvim_create_namespace('nvim.multicursor')
			    vim.api.nvim_buf_clear_namespace(0, mc_ns, 0, -1)
<
							*gQ*
gQ			Restores the previous multicursors.

							*g_CTRL-A*
g CTRL-A		During a multicursor session, inserts an ascending
			number ("counter") at each cursor, so a column of
			cursors becomes 1, 2, 3, …. Use [count] to choose the
			initial number.

							*]C*
]C			Jump to the [count]'th next cursor, leaving a cursor at
			the current position.

							*[C*
[C			Jump to the [count]'th previous cursor, leaving a cursor
			at the current position.
```

---

## Drill 1 — `Q`: toggle cursors by hand

**Do:** cursor on the first `cursor` (col 1). `Q` drops a cursor. `a` moves
down; `Q` again; `a`; `Q`. Three cursors now sit in a column. Change the word
under all of them: `crw` → type `caret` → `<C-n>`.
**Expect:** all three become `caret`. **Reset:** `u`.

```
cursor  one
cursor  two
cursor  three
```

---

## Drill 2 — `[count]Q`: a cursor at every search match

**Do:** put the cursor on any `cursor` below and press `*` (search word under
cursor). Then type `1Q` — a cursor lands on *every* match. `crw` → `caret` →
`<C-n>`.
**Expect:** every `cursor` → `caret`. **Reset:** `u`, then `<C-L>` if a stray
cursor remains, `:noh` to drop the search highlight.

```
let cursor = 0
let other  = 1
let cursor = 2
let cursor = 3
```

---

## Drill 3 — `<C-LeftMouse>`: drop cursors with the mouse

**Do:** hold **Ctrl** and left-click a few spots in the block below. Each click
toggles a cursor there **without** moving your primary cursor. Then `s` → type
`X ` → `<C-n>`.
**Expect:** an `X ` appears at each clicked spot. **Reset:** `u`. (No-op in
insert mode; Ctrl-click a cursor again to remove it.)

```
. . . . . . . .
. . . . . . . .
. . . . . . . .
```

---

## Drill 4 — `{Visual}Q`: one cursor per selected line

**Do:** cursor on `alpha`. `V` then `a a a` (down 3) to select all four lines.
`Q` → a cursor per line (follow-mode turns **on**). `L` (insert at line start) →
type `// ` → `<C-n>`.
**Expect:** every line gets a `// ` prefix. **Reset:** `u`.

```
alpha
beta
gamma
delta
```

---

## Drill 5 — `q=`: follow-mode (replay motions per cursor)

**Do:** set a cursor column first — cursor on line-1 `x`, then `Q a Q a Q`.
Toggle follow-mode: `q=`. Now press `w` — each cursor jumps a word *on its own
line* (not in lockstep). Press `G` — cursors merge (dedup) onto one line. `q=`
again turns it off.
**Expect:** motions apply per-cursor; `G` collapses them. **Reset:** `<C-L>`.

```
x  aaa bbb ccc
x  ddd eee fff
x  ggg hhh iii
```

---

## Drill 6 — `CTRL-L`: clear cursors

**Do:** drop a few cursors (`Q a Q a Q`). Then press `<C-L>`. All extra cursors
vanish. Prove it: `s` → `Z` → `<C-n>` now edits only the primary line.
**Expect:** `<C-L>` removes the multicursors. **Reset:** `u`.

```
one
two
three
```

---

## Drill 7 — `gQ`: restore the cleared cursors

**Do:** repeat Drill 6 up to `<C-L>`. Now press `gQ` — the previous cursor set
comes back. `crw` → `done` → `<C-n>`.
**Expect:** the cleared cursors return and edit together. **Reset:** `u`.

```
alpha
alpha
alpha
```

---

## Drill 8 — `g CTRL-A`: insert an ascending counter

**Do:** column-align cursors right after `row ` — cursor on line-1 just past the
space, then `Q a Q a Q` (same column each line). Press `g<C-A>`.
**Expect:** `row 1`, `row 2`, `row 3`. Try `3g<C-A>` next time to start at 3.
**Reset:** `u`.

```
row 
row 
row 
```

---

## Drill 9 — `]C` / `[C`: hop between cursors

> ⚠️ In your config `]C`/`[C` are bound to `@class.outer` textobject nav (see
> the TODO in `fnl/treesitter/textobjects.fnl`), so they currently do **not**
> jump cursors. Resolve that TODO first (e.g. move class-nav to `]K`/`[K`) to
> practice this drill natively.

**Do (once freed):** drop cursors with `Q a Q a Q`, then `]C` / `[C` to move the
primary between them (leaving a cursor behind each time).
**Expect:** the active cursor walks the set. **Reset:** `<C-L>`.

```
mark
mark
mark
```

---

# Combination drills — increasing difficulty

Fenced blocks in your languages. Same reset rule: `u` after each.

## Combo 1 (easy) — TypeScript · rename via `*` + `[count]Q`

**Do:** cursor on `count`, `*`, `1Q`, `crw` → `total` → `<C-n>`.

```ts
let count = 0;
count += 1;
console.log(count);
return count;
```

## Combo 2 (easy–medium) — Lua · prefix a block with `{Visual}Q`

**Do:** `V a a` to select all three, `Q`, `L` → `local ` → `<C-n>`.

```lua
foo = 1
bar = 2
baz = 3
```

## Combo 3 (medium) — Elixir · number the steps with `g CTRL-A`

**Do:** column-align cursors right after `step` (`Q a Q a Q`), then `g<C-A>`.
Turns `step` into `step1 / step2 / step3`.

```elixir
def step, do: run()
def step, do: run()
def step, do: run()
```

## Combo 4 (medium–hard) — Vue/TS · two edits in one session

**Do:** rename the prop *and* append a type. `*` on `title`, `1Q`, `crw` →
`heading` → `<C-n>` (all `title` renamed). Then, still on the column, `W`
(insert at end of line) → type ` // renamed` → `<C-n>`.

```ts
const title = props.title;
watch(title, () => render(title));
emit("update", title);
```

## Combo 5 (hard) — Lua · mixed search + counter + trim

**Do:**
1. `*` on `key`, `1Q` — cursor at every `key`.
2. `crw` → `field` → `<C-n>` (rename).
3. New session: column-align after `field` on each line (`Q a Q a Q`),
   `g<C-A>` → `field1/2/3`.
4. `<C-L>` to clear, `:noh` to clean up.

```lua
local key = t.key
local key = t.key
local key = t.key
```
