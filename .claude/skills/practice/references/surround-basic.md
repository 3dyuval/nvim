# Surround Practice — Basic

Work through each section. Cursor position is noted with `^`.

---

## Add surround: normal mode (ysrw)

In this layout i->l and r->i, so inner-word is `rw` (not `iw`).

- [ ] TODO: cursor on word, `ysrw(` → (should wrap the word in tight parens)
- [ ] TODO: cursor on word, `ysrw)` → (should wrap the word in spaced parens)
- [ ] TODO: cursor on word, `ysrw[` `ysrw{` `ysrw"` `ysrw'` → (should wrap in the given delimiter)

```
hello world
^
```

---

## Add surround: current line (yss)

- [ ] TODO: cursor on line, `yss(` `yss"` `yss[` → (should wrap the whole line)

```
hello world
^
```

---

## Add surround: with newlines (yS)

- [ ] TODO: cursor on word, `ySrw(` → (should wrap the word on its own lines)

```
hello world
^
```

---

## Delete surround (ds)

- [ ] TODO: cursor inside, `ds(` `ds[` `ds{` `ds"` `ds'` → (should remove the surrounding pair)

```
(hello) world
 ^
["bracketed"] text
  ^
{braced} content
 ^
"quoted string" here
 ^
```

---

## Change surround (cs)

- [ ] TODO: cursor inside, `cs([` → (should change parens to brackets)
- [ ] TODO: cursor inside, `cs("` `cs[{` `` cs`' `` → (should change the first delimiter to the second)

```
(hello) world
 ^
[bracketed] text
 ^
"quoted" content
 ^
```

---

## Visual surround (v to select, s to surround)

Select inner-word with `vrw` (r=inner), then `s` triggers surround.

- [ ] TODO: `vrw` then `s(` `s"` `s[` `s{` `sb` → (should wrap the selection in the given delimiter)

```
hello world
^
```

---

## Visual line surround (VgS)

- [ ] TODO: `V` then `gS(` `gS[` → (should wrap the line on its own lines)

```
hello world
^
```

---

## Aliases (b B a q r s)

| Alias | Matches | Add |
|-------|---------|-----|
| `b`   | any bracket `( [ { <` | tight `()` |
| `B`   | `{ }` | spaced `{ }` |
| `a`   | `< >` | `<>` |
| `q`   | any quote `" ' ` ` | — (delete/change only) |
| `r`   | `[ ]` | `[]` |
| `s`   | any of `} ] ) > " ' ` ` | — (delete/change only) |

- [ ] TODO: cursor on word, `ysrwb` → (should add tight parens)
- [ ] TODO: cursor on word, `ysrwB` → (should add spaced braces)
- [ ] TODO: cursor inside any bracket, `dsb` → (should delete it)
- [ ] TODO: cursor inside any bracket, `csb{` → (should change it to braces)

```
hello world
^
```

---

## Markdown: bold (*) italic (_) strikethrough (~)

- [ ] TODO: cursor on word, `ysrw*` `ysrw_` `ysrw~` → (should wrap in bold / italic / strikethrough)
- [ ] TODO: cursor inside, `ds*` `ds_` `ds~` → (should remove the markup)

```
hello world
^
important note
^
deleted text
^
```

---

## Custom delimiter (i)

- [ ] TODO: cursor on word, `ysrwi` → (should prompt for input, then wrap)

- Enter `<div>` or `div` → wraps with `<div>...</div>`
- Enter `("` → wraps with `("...")`

```
hello world
^
some text
^
```
