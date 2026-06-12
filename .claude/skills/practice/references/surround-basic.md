# Surround Practice — Basic

Work through each section. Cursor position is noted with `^`.

---

## Add surround: normal mode (ysiw)

Keys to try: `ysiw(` `ysiw)` `ysiw[` `ysiw]` `ysiw{` `ysiw}` `ysiw"` `ysiw'`

```
hello world
^
```

Expected after `ysiw(`: `(hello) world`

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

Keys to try: `ySiw(`

```
hello world
^
```

Expected after `ySiw(`:
```
(
hello
)
 world
```

---

## Delete surround (ds / xs)

Keys to try: `ds(` `ds[` `ds{` `ds"` `ds'` — or Graphite: `xs(` `xs[`

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

## Change surround (cs / ws)

Keys to try: `cs([` `cs("` `cs[{` — or Graphite: `ws([` `ws("`

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

Keys to try: `viws(` `viws"` `viws[` `viws{` `viwb`

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

## Aliases (b B a q)

| Alias | Expands to |
|-------|------------|
| `b`   | `)` parentheses |
| `B`   | `}` braces |
| `a`   | `>` angle brackets |
| `q`   | any quote `"` `'` `` ` `` |

Keys to try: `ysiwb` `ysiwB` `ysiwa` — delete with `dsb` `dsB` `dsa`

```
hello world
^
```

---

## Markdown: bold (*) italic (_) strikethrough (~)

Keys to try: `ysiw*` `ysiw_` `ysiw~`

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

Keys to try: `ysiw i` (prompts for input)

- Enter `<div>` or `div` → wraps with `<div>...</div>`
- Enter `("` → wraps with `("...")`

```
hello world
^
some text
^
```
