# Surround Practice — Code Fences

Set filetype: `:set ft=markdown`

---

## Wrap word in inline code (`)

Keys: `` ysiw` ``

```
hello world
^
const x = 1
^
```

---

## Wrap line in inline code (yss`)

Keys: `` yss` ``

```
npm install something
^
```

---

## Wrap word in code fence with language prompt (`)

Keys: `` ysiw` `` then enter language at prompt (e.g. `js`, `ts`, `lua`)

```
const x = 1
^
```

Expected after entering `js`:
````
```js
const x
```
````

---

## Wrap paragraph in code fence (ysp`)

Keys: `` ysp` `` then enter language

```
function greet() {
  return "hello"
}
^
```

---

## Delete code fence (ds`)

Keys: `` ds` ``

````
```ts
const x = 1
```
^
````

---

## Change code fence to quotes (cs`")

Keys: `` cs`" ``

````
`inline code`
 ^
````

Expected: `"inline code"`

---

## Visual: wrap selection in fence (vs`)

Keys: `` viws` `` or `` VgS` `` for line

```
hello world
^
```
