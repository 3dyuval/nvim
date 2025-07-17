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

This configuration includes automated testing via GitHub Actions and comprehensive keymap health checking:

### Local Testing
```bash
# Run all tests locally
make test

# Check code quality
make check

# Format code
make format

# Check keymap conflicts and health
make check-keymaps

# Run comprehensive health check
make health-check

# Run local CI simulation
./scripts/test-ci.sh
```

### Keymap Management

#### Health Check System
```bash
# Run comprehensive keymap analysis
:checkhealth config

# Check which-key specific conflicts
:checkhealth which-key

# Test specific keymaps for conflicts
echo 'keymaps_table' | lua lua/config/test-utils/test_keymaps.lua
```

#### Conflict Resolution
- **Documentation**: See `KEYMAP_CONFLICTS.md` for detailed resolution strategies
- **Graphite Layout**: Custom HAEI navigation (h=left, a=down, e=up, i=right)
- **Text Objects**: RT system (r=inner, t=around) instead of standard ia
- **Safety**: Critical built-in commands are protected from override

#### Key Features
- **Automated Detection**: Identifies overlapping patterns, critical overrides, and Graphite violations
- **Health Integration**: Seamless `:checkhealth config` integration
- **CI Testing**: Keymap conflicts checked in GitHub Actions
- **Resolution Guide**: Comprehensive strategies for fixing conflicts

### CI Pipeline
- **Triggers**: Push to any branch, PRs to main
- **Tests**: Configuration loading, picker extensions, git functionality, keymap conflicts, health checks
- **Quality**: Lua linting with luacheck, keymap conflict detection
- **Dependencies**: Neovim (stable), Plenary, Snacks.nvim

### Testing Infrastructure
- **Picker Extensions**: `lua/utils/tests/test_picker_extensions.lua`
- **Git Functionality**: `lua/plugins/tests/test_snacks_git_branches.lua`
- **Keymap Conflicts**: `lua/config/test-utils/test_keymaps.lua`
- **Health Checks**: `lua/config/health.lua`