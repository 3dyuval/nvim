# Fennel Configuration

This directory contains Fennel source files that are compiled to Lua.

## How It Works

- **Source of Truth**: `.nfnl.fnl` configuration file
- **Compilation**: All `fnl/**/*.fnl` files compile to `lua/**/*.lua`
- **When**: Compilation happens automatically in these scenarios:
  1. When you save a `.fnl` file in Neovim (nfnl ftplugin)
  2. After `git checkout` to a different branch (post-checkout hook)
  3. After `git pull` or `git merge` (post-merge hook)

## Important Notes

- Both `.fnl` and `.lua` files are tracked in git
- The compiled `.lua` files should always match their `.fnl` sources
- Git hooks automatically keep them in sync across machines/branches
- All compilation uses `nfnl` to respect the `.nfnl.fnl` config
- If you clone fresh or switch branches, git hooks will auto-compile
- If `.lua` files are missing, just open any `.fnl` file in Neovim and save it to trigger recompilation

## Manual Compilation

The easiest way to recompile all Fennel files:

1. Open Neovim in this directory
2. Open any `.fnl` file
3. Save it (`:w`) - this triggers nfnl to compile all files

Alternatively, use `--force` mode to remove old `.lua` files and force recompilation:

```bash
make compile-force
# or directly:
./fnl/compile --force
```

This is useful when `.lua` files don't have nfnl headers and can't be overwritten.
