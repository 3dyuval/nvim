# Surround Practice

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

Keys to try: `ysiw(` with `yS` variant → `ysiw(` becomes multiline

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

Keys to try: `viws(` `viws"` `viws[` `viws{` `viwb` (alias)

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

## Code fence (`)

Keys to try: `ysiw`` ` (prompts for language)

```
const x = 1
^
```

Expected (entering `js` at prompt):
````
```js
const x = 1
```
````

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

---

## Treesitter surrounds

These require an open buffer with a live TreeSitter parser. Open a real source file to practice.

| Key | Selects |
|-----|---------|
| `ysitf` / `ysirf` | function outer / inner |
| `ysitt` / `ysirt` | tag outer / inner |
| `ysitc` / `ysirc` | class outer / inner |
| `ysitp` / `ysirp` | parameter outer / inner |
| `ysitl` / `ysirl` | loop outer / inner |
| `ysits` / `ysirs` | scope |

---

## Text objects: r=inner, t=around

Used with operators: `y` (yank), `d` (delete), `c` (change), `v` (visual select)

| Key | Action |
|-----|--------|
| `rw` / `tw` | inner/around word |
| `rW` / `tW` | inner/around WORD |
| `rp` / `tp` | inner/around paragraph |
| `r(` / `t(` | inner/around parentheses |
| `r[` / `t[` | inner/around brackets |
| `r{` / `t{` | inner/around braces |
| `r"` / `t"` | inner/around double quotes |
| `r'` / `t'` | inner/around single quotes |
| `r<` / `t<` | inner/around angle brackets |
| `r`` ` / `t`` ` | inner/around backtick quotes |
| `rb` / `tb` | inner/around block `()` |
| `rB` / `tB` | inner/around Block `{}` |

Keys to try: `yrw` `ytw` `dr(` `dt(` `vr"` `vt"`

```
function foo(hello, world) {
              ^
  return "some string here"
          ^
}
```

---

## Text objects: treesitter (select with v)

| Key | Selects |
|-----|---------|
| `tf` | around function |
| `rf` | inner function |
| `tt` | around tag |
| `rt` | inner tag |
| `rs` | inner scope |

Open a real source file and use `vtf` or `vrf` to select.
