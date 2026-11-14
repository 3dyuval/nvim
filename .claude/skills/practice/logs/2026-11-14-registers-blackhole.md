# Drill: register-safe paste + black-hole delete

## Concepts

- `""` unnamed register — the default target of `y`, `d`, `c`, `x`, and
  visual-mode `p`. This is the leaky one: a delete/change after a yank
  overwrites it, so a later `p` pastes the deleted text, not the yank.
- `"0` yank register — holds only the **last `y`**. Untouched by `d`/`c`/`x`.
  The zero-config escape hatch: `"0p` always pastes your last yank.
- `"_` black-hole register — writes go nowhere. `"_d` / `"_c` / `"_dd`
  delete/change without disturbing `""` or `"0`.
- Visual paste-over: `p` on a selection swaps the selection into `""`. The
  fix pattern is `"_dP` (delete selection to void, then paste before).

## Config notes

- Operators are **vanilla** on this layout — verified live `2026-11-14`:
  `nmap d`, `xmap p`, `xmap d` → no HAEI remap (only `ds` = surround-delete).
  So `d{motion}`, `p`, `v`, `"{reg}` all behave as stock Vim.
- No clipboard=unnamedplus, no black-hole mappings installed — the drill is
  practicing the raw register discipline, not a remap.

## Hints

| line | anchor            | keys                                             |
|------|-------------------|--------------------------------------------------|
| S1   | the bug           | `yiw` on apple · `diw` on banana · `viwp` cherry |
| S2   | fix via "0        | `yiw` apple · `diw` banana · `viw"0p` cherry     |
| S3   | visual no-clobber | `yiw` keep · `viw` cherry · `"_dP`               |
| S4   | line to void      | `yiw` keep · `"_dd` trash · `p` target           |
| S5   | change to void    | `yiw` keep · `"_ciw` + type · then `p` to verify |

## Sessions

_(none yet)_
