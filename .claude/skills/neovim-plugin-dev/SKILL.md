---
name: neovim-plugin-dev
description: This skill should be used when the user wants to "explore a plugin fork", "review plugin changes", "see what's new in a plugin", "check a plugin's source", "open a plugin in neovim", "set up local dev for a plugin", "clone a plugin for local development", or needs to investigate or set up a locally-installed or dev-checked-out Neovim plugin.
---

## First Step — Identify the Plugin

Before searching for any path, ask:

1. **What is the plugin?** — get the plugin name or GitHub slug. Do NOT assume from context; the config name and the repo name may differ (e.g. a fork named `diffview-plus.nvim` loaded as `diffview` in the spec).
2. **Is it local?** — check the plugin spec in `lua/plugins/` for `dev = true` and note the slug. Read the spec file to confirm the actual repo name used.
3. **Which mode?** — development phase (making changes) or learning/iteration phase (exploring behavior). See body below.

# Neovim Plugin Dev

**Development phase** — wiring a plugin fork or local checkout into lazy for live editing. See `references/mode-setup.md`.

**Learning/iteration phase** — exploring an already-installed plugin's source, reviewing fork changes, or understanding behavior without modifications. See `references/mode-explore.md`. For interacting with internals (implementation, docs, live commands) see `references/mode-explore-internals.md`.
