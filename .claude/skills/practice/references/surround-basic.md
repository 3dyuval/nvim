# Surround Practice — Basic

Work through each section. Cursor position is noted with `^`.

---

## Add surround: normal mode (ysrw)

In this layout i->l and r->i, so inner-word is `rw` (not `iw`).
Keys to try: `ysrw(` `ysrw)` `ysrw[` `ysrw]` `ysrw{` `ysrw}` `ysrw"` `ysrw'`

```
hello world
^
```

Expected after `ysrw(`: `(hello) world`

---

## Add surround: current line (yss)

Keys to try: `yss(` `yss"` `yss[`

```
hello world
^
```

Expected after `yss(`: `(hello world)`

---

## Add surround: with newlines (yS)

Keys to try: `ySrw(`

```
hello world
^
```

Expected after `ySrw(`:
```
(
hello
)
 world
```

---

## Delete surround (ds)

Keys to try: `ds(` `ds[` `ds{` `ds"` `ds'`

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

Keys to try: `cs([` `cs("` `cs[{` `` cs`' ``

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
Keys to try: `vrws(` `vrws"` `vrws[` `vrws{` `vrwsb`

```
hello world
^
```

---

## Visual line surround (VgS)

Keys to try: `VgS(` `VgS[`

```
hello world
^
```

Expected after `VgS(`:
```
(
hello world
)
```

---

## Alias: b (any bracket)

Only one alias is configured (b/B/a/q were removed as confusing):

| Alias | Expands to |
|-------|------------|
| `b`   | any bracket `( [ { <` — adds tight `(hello)` |

Keys to try: `ysrwb` (add tight parens) — `dsb` / `csb{` match any bracket

```
hello world
^
```

---

## Markdown: bold (*) italic (_) strikethrough (~)

Keys to try: `ysrw*` `ysrw_` `ysrw~`

```
hello world
^
important note
^
deleted text
^
```

Expected: `**hello** world` / `_important_ note` / `~deleted~ text`

Delete: `ds*` (twice for bold) `ds_` `ds~`

---

## Custom delimiter (i)

Keys to try: `ysrwi` (prompts for input)

- Enter `<div>` or `div` → wraps with `<div>...</div>`
- Enter `("` → wraps with `("...")`

```
hello world
^
some text
^
```
