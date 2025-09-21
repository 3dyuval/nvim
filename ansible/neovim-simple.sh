#!/bin/bash
# Download and install latest stable Neovim release (even simpler than building)

# Create directories
mkdir -p ~/.local/bin

# Download latest stable AppImage (x86_64)
echo "Downloading latest Neovim..."
curl -LO https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.appimage
mv nvim-linux-x86_64.appimage nvim.appimage
chmod u+x nvim.appimage

# Extract to local directory
echo "Installing to ~/.local..."
./nvim.appimage --appimage-extract
mv squashfs-root ~/.local/nvim

# Create symlink
ln -sf ~/.local/nvim/AppRun ~/.local/bin/nvim

# Clean up
rm nvim.appimage

echo "Neovim installed successfully!"
~/.local/bin/nvim --version