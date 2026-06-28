## Neovim Graphite Config

IMPORTANT! DO NOT EDIT lua/ files directly - only fnl/
(auto compiles with nfnl)
See `.claude/skills/nvim-config/SKILL.md` for full context.

### Quick Reference

**Layout:** HAEI navigation (H=left, A=down, E=up, I=right), R=inner, T=around

**Before commits:**
```bash
make format && make test
```

**Keymap syntax:** Use `keymap-utils` with `cmd = "Command"` for vim commands

- After editing `fnl/`, compile with `make compile`
- Do not add comments to source code unless absolutely necessary
