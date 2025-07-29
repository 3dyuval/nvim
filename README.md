# Neovim Configuration

Personal Neovim configuration based on LazyVim with custom keymaps for the Graphite keyboard layout.

## Troubleshooting

### ENOSPC Errors (Too Many File Watchers)

If you encounter ENOSPC errors ("Error NO SPaCe" - system file watcher limit reached), this is likely due to LSP servers and plugins watching too many files. 

#### System-level Fix

Increase the file watcher limit on Linux:

```bash
# Temporary (until reboot)
sudo sysctl fs.inotify.max_user_watches=524288

# Permanent
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

#### Configuration Optimizations

This configuration includes several optimizations to reduce file watcher usage:

1. **Diffview.nvim** - Disabled `watch_index` to prevent continuous git monitoring
2. **TypeScript Tools** - Configured to exclude node_modules and build directories
3. **.ignore file** - Excludes large directories from file watching operations

See issue #48 for more details.