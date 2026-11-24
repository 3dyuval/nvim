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

Keys to try: `yrw` `ytw` `dr(` `dt(` `vr"` `vt"` `ysrw(` `ystp(`

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
- [x] TODO: cursor on `return`, `ystf(` → (should wrap the whole function)
- [ ] TODO: cursor on `return`, `ysrf(` → (should wrap the body only)
- [ ] TODO: cursor on `return`, `vtf` / `vrf` → (should select the whole function / the body only)

```typescript
(function greet(name: string) {
  return "hello " + name
})
```

---

## Treesitter: parameter (tp=outer, rp=inner)

Cursor on a parameter.
- [ ] TODO: cursor on `a`, `ystp(` → (should wrap the whole parameter)
- [ ] TODO: cursor on `a`, `ysrp"` → (should wrap the param name only)

```typescript
function add(a: number, b: number): number {
  return a + b
}
```

---

## Treesitter: loop (tl=outer, rl=inner)

Cursor inside the loop.
- [ ] TODO: cursor on `console`, `ystl(` → (should wrap the whole loop incl header)
- [ ] TODO: cursor on `console`, `ysrl(` → (should wrap the loop body only)

```typescript
for (const item of items) {
  console.log(item)
}
```

---

## Treesitter: scope (ts=outer, rs=inner)

Cursor inside block.
- [ ] TODO: cursor on `doSomething`, `ysts{` → (should wrap the nearest scope node)
- [ ] TODO: cursor on `doSomething`, `ysrs"` → (should wrap the inner scope content)

```typescript
if (condition) {
  doSomething()
  doMore()
}
```

---

## Treesitter: tag (tt=outer, rt=inner) — set ft=tsx

Cursor on tag content.
- [ ] TODO: cursor on `hello`, `ystt(` → (should wrap the entire tag)
- [ ] TODO: cursor on `hello`, `ysrt"` → (should wrap the inner content only)

```tsx
<div className="container">
  <span>hello world</span>
</div>
```

---

## Treesitter: class (tc=outer, rc=inner)

Cursor inside class.
- [ ] TODO: cursor on `speak`, `ystc(` → (should wrap the entire class declaration)
- [ ] TODO: cursor on `speak`, `ysrc"` → (should wrap the class body)

```typescript
class Animal {
  name: string
  speak() {
    return this.name
  }
}
```
