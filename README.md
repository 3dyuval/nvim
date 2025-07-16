# Becoming Proficient in Neovim

![Test Status](https://github.com/3dyuval/nvim/actions/workflows/test.yml/badge.svg)

## Core Components
- [x] Package Manager: lazy.nvim
- [x] LSP Support: nvim-lspconfig, Mason
- [x] File Explorer: Neo-tree
- [x] Quick Navigation: Flash.nvim
- [x] Commenting: Comment.nvim
- [x] Custom Keymaps: Colemak/Graphite layout

## Learning Path

### Fundamentals
- [ ] Learn basic motions (h/j/k/l or custom mappings)
- [ ] Understand modes (Normal, Insert, Visual, Command)
- [ ] Master basic operations (copy, paste, delete)
- [ ] Learn text objects (word, paragraph, etc.)
- [ ] Practice buffer management

### Intermediate Skills
- [ ] Learn window management
- [ ] Get comfortable with LSP features
- [ ] Use fuzzy finding effectively
- [ ] Configure your colorscheme
- [ ] Create custom snippets

### Advanced Skills
- [ ] Create custom functions
- [ ] Build your own plugins
- [ ] Master macros
- [ ] Use Neovim's API
- [ ] Integrate with external tools

## Alternative Configurations
- NvChad: Fast and visually appealing
- LunarVim: IDE-like experience
- AstroNvim: Aesthetic and feature-rich
- Kickstart.nvim: Minimal starting point

## Alternatives with Vim Keybindings
- VS Code + Vim extension
- JetBrains IDEs + IdeaVim
- Sublime Text + Vintage mode

## Development & Testing

This configuration includes automated testing via GitHub Actions:

### Local Testing
```bash
# Run all tests locally
make test

# Check code quality
make check

# Format code
make format

# Run local CI simulation
./scripts/test-ci.sh
```

### CI Pipeline
- **Triggers**: Push to any branch, PRs to main
- **Tests**: Configuration loading, picker extensions, git functionality, keymap conflicts
- **Quality**: Lua linting with luacheck
- **Dependencies**: Neovim (stable), Plenary, Snacks.nvim