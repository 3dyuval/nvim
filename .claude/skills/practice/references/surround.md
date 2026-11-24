# Surround Practice

Work through each section. Cursor position is noted with `^`.

---

## Add surround: normal mode (ysrw)

- [ ] TODO: cursor on word, `ysrw(` → (should wrap in tight parens)
- [ ] TODO: cursor on word, `ysrw)` → (should wrap in spaced parens)
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

- [ ] TODO: `vrw` then `s(` `s"` `s[` `s{` `sb` → (should wrap the selection)

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
- [ ] TODO: cursor inside any bracket, `dsb` `csb{` → (should delete / change it)

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

## Inline code (`)

- [ ] TODO: cursor on word, `` ysrw` `` → (should wrap the word in inline code)
- [ ] TODO: cursor inside, `` ds` `` → (should remove the backticks)

```
const x = 1
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

---

## Treesitter surrounds

Set filetype first: `:set ft=typescript` or open a `.ts` file.

### function outer (`tf`) / inner (`rf`)

- [ ] TODO: cursor inside fn, `ystf(` → (should wrap the whole function)
- [ ] TODO: cursor inside fn, `ysrf(` → (should wrap the body only)

```typescript
function greet(name: string) {
  return "hello " + name
}
```

### parameter (`tp` / `rp`)

- [ ] TODO: cursor on param, `ystp(` → (should wrap the whole parameter)
- [ ] TODO: cursor on param, `ysrp"` → (should wrap the param name only)

```typescript
function add(a: number, b: number): number {
  return a + b
}
```

### loop (`tl` / `rl`)

- [ ] TODO: cursor inside loop, `ystl(` → (should wrap the whole loop)
- [ ] TODO: cursor inside loop, `ysrl(` → (should wrap the loop body only)

```typescript
for (const item of items) {
  console.log(item)
}
```

### scope (`ts` / `rs`)

- [ ] TODO: cursor inside block, `ysts{` → (should wrap the nearest scope)
- [ ] TODO: cursor inside block, `ysrs"` → (should wrap the inner scope content)

```typescript
if (condition) {
  doSomething()
  doMore()
}
```

### tag outer (`tt`) / inner (`rt`) — needs HTML/TSX filetype

- [ ] TODO: cursor on tag content, `ystt(` → (should wrap the entire tag)
- [ ] TODO: cursor on tag content, `ysrt"` → (should wrap the inner content only)

```tsx
<div className="container">
  <span>hello world</span>
</div>
```

### class outer (`tc`) / inner (`rc`)

- [ ] TODO: cursor inside class, `ystc(` → (should wrap the entire class)
- [ ] TODO: cursor inside class, `ysrc"` → (should wrap the class body)

```typescript
class Animal {
  name: string
  speak() {
    return this.name
  }
}
```

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
| `` r` `` / `` t` `` | inner/around backtick quotes |
| `rb` / `tb` | inner/around block `()` |
| `rB` / `tB` | inner/around Block `{}` |

- [ ] TODO: `yrw` `ytw` `dr(` `dt(` `vr"` `vt"` → (should operate on the inner/around object)

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

- [ ] TODO: open a source file, `vtf` / `vrf` → (should select the function / its body)
