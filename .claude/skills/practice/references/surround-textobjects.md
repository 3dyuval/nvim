# Surround Practice — Text Objects

Set filetype before playing with treesitter sections: `:set ft=typescript`

---

## Built-in text objects (r=inner, t=around)

Used with any operator: `y` yank, `d` delete, `c` change, `v` select, `ys` surround

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

Keys to try: `yrw` `ytw` `dr(` `dt(` `vr"` `vt"` `ysiwr(` `ysitp(`

```
function foo(hello, world) {
              ^
  return "some string here"
          ^
}
```

---

## Treesitter: function (tf=outer, rf=inner)

Cursor inside the function.
- `ysitf(` wraps entire function including signature
- `ysirf(` wraps body only (between braces)
- `vtf` selects outer, `vrf` selects inner

```typescript
function greet(name: string) {
  return "hello " + name
}
```

---

## Treesitter: parameter (tp=outer, rp=inner)

Cursor on a parameter.
- `ysitp(` wraps `name: string` (outer includes type)
- `ysirp"` wraps just the param name

```typescript
function add(a: number, b: number): number {
  return a + b
}
```

---

## Treesitter: loop (tl=outer, rl=inner)

Cursor inside the loop.
- `ysitl(` wraps entire for block including header
- `ysirl(` wraps loop body only

```typescript
for (const item of items) {
  console.log(item)
}
```

---

## Treesitter: scope (ts=outer, rs=inner)

Cursor inside block.
- `ysits{` wraps the nearest scope node
- `ysirs"` wraps inner scope content

```typescript
if (condition) {
  doSomething()
  doMore()
}
```

---

## Treesitter: tag (tt=outer, rt=inner) — set ft=tsx

Cursor on tag content.
- `ysitt(` wraps entire `<div>...</div>`
- `ysirt"` wraps inner content only

```tsx
<div className="container">
  <span>hello world</span>
</div>
```

---

## Treesitter: class (tc=outer, rc=inner)

Cursor inside class.
- `ysitc(` wraps entire class declaration
- `ysirc"` wraps class body

```typescript
class Animal {
  name: string
  speak() {
    return this.name
  }
}
```
