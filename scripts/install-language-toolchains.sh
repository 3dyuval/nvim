#!/usr/bin/env bash
# Install language toolchains for LSP servers

set -e

echo "=== Installing Language Toolchains ==="
echo ""

# Lua & LuaJIT
echo "🌙 Installing Lua..."
if command -v lua &> /dev/null; then
    echo "✓ Lua already installed: $(lua -v 2>&1 | head -n1)"
else
    sudo apt update
    sudo apt install -y lua5.4 luajit luarocks
    echo "✓ Lua installed: $(lua -v 2>&1 | head -n1)"
fi

echo ""

# Ruby
echo "📦 Installing Ruby..."
if command -v ruby &> /dev/null; then
    echo "✓ Ruby already installed: $(ruby --version)"
else
    sudo apt update
    sudo apt install -y ruby-full
    echo "✓ Ruby installed: $(ruby --version)"
fi

# Install solargraph gem
echo "💎 Installing solargraph gem..."
gem install solargraph --user-install
echo "✓ Solargraph installed"

echo ""

# Rust
echo "🦀 Installing Rust..."
if command -v rustc &> /dev/null; then
    echo "✓ Rust already installed: $(rustc --version)"
else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    echo "✓ Rust installed: $(rustc --version)"
fi

# Ensure rust-analyzer is available
rustup component add rust-analyzer 2>/dev/null || echo "✓ rust-analyzer already available"

echo ""

# Go
echo "🐹 Installing Go..."
if command -v go &> /dev/null; then
    echo "✓ Go already installed: $(go version)"
else
    # Get latest Go version
    GO_VERSION=$(curl -sSL https://go.dev/VERSION?m=text | head -n1)
    echo "Installing Go ${GO_VERSION}..."

    curl -sSfL "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz

    # Add to PATH if not already there
    if ! grep -q '/usr/local/go/bin' ~/.bashrc; then
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    fi

    export PATH=$PATH:/usr/local/go/bin
    echo "✓ Go installed: $(go version)"
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "📝 Next steps:"
echo "  1. Restart your shell or run: source ~/.bashrc"
echo "  2. In Neovim, run: :MasonInstall solargraph rust-analyzer gopls"
echo "  3. Verify with: :checkhealth mason"
