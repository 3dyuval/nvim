# Surround Practice — Code Fences

Set filetype: `:set ft=markdown`

---

## Wrap word in inline code (`)

- [ ] TODO: cursor on word, `` ysrw` `` → (should wrap the word in inline code)

```
hello world
^
const x = 1
^
```

---

## Wrap line in inline code (yss`)

- [ ] TODO: cursor on line, `` yss` `` → (should wrap the whole line in inline code)

```
npm install something
^
```

---

## Delete inline code (ds`)

- [ ] TODO: cursor inside, `` ds` `` → (should remove the inline code backticks)

````
`const x = 1`
 ^
````

---

## Change inline code to quotes (cs`")

- [ ] TODO: cursor inside, `` cs`" `` → (should change the backticks to double quotes)

````
`inline code`
 ^
````

---

## Visual: wrap selection in inline code (vs`)

- [ ] TODO: select word with `vrw`, then `` s` `` → (should wrap the selection in inline code)

```
hello world
^
```
