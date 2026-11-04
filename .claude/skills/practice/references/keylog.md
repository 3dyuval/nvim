# Keylog — capture keystrokes during a drill

Records every key (with mode) into a scratch buffer named `practice-keylog`
that the agent reads over nvim-mcp. Invocable; not auto-gating. Backed by
`vim.on_key` (see `../keylog.lua`).

## Load + control

```
:luafile .claude/skills/practice/keylog.lua   " defines _G.PracticeKeylog
:lua PracticeKeylog.start()                    " begin capture -> returns bufnr
:lua PracticeKeylog.stop()                     " unregister the on_key listener
:lua PracticeKeylog.clear()                    " wipe the scratch buffer
```

## Agent workflow

1. `send_command("luafile .claude/skills/practice/keylog.lua")` (once per session).
2. `send_command("lua PracticeKeylog.start()")`.
3. User drills in the drill buffer.
4. `read_full_buf("practice-keylog")` — each line is `<mode> <key>`,
   e.g. `n     f`, `n     {`, `n     ;`. Mode is the Neovim mode at keypress.
5. `send_command("lua PracticeKeylog.stop()")` when done; `clear()` before a
   fresh run.

## Notes / caveats

- `on_key` is global — it logs keys from EVERY buffer, not just the drill. Start
  it right before a run and stop right after to keep noise down.
- `typed` (pre-mapping input) is preferred; falls back to `key` for synthesized
  input (e.g. keys sent via `send_keys`, which prepend `<Esc>`).
- Keys consumed by `getchar()` (some plugin prompts) never reach `on_key`.
- The buffer is `nofile`/`bufhidden=hide`; it is not written to disk.
