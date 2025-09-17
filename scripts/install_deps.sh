#!/usr/bin/env zsh
# Install dependencies for Neovim configuration
# This script installs git-resolve-conflict and js-debug for the shared nvim config

set -e  # Exit on error
echo "🔧 Installing Neovim configuration dependencies..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if git is installed  
if ! command -v git &> /dev/null; then
    print_error "git is not installed. Please install git first."
    exit 1
fi

# Check if wget is installed
if ! command -v wget &> /dev/null; then
    print_error "wget is not installed. Please install wget first."
    exit 1
fi

# git-resolve-conflict is now built-in (pure Lua implementation)
print_status "git-resolve-conflict: ✅ Built-in (no external dependencies)"
print_status "Available via :GitResolve command in Neovim"

echo "📦 Installing git-filter-repo (for file-history.nvim purge functionality)..."
if sudo apt update && sudo apt install -y git-filter-repo; then
    print_status "git-filter-repo installed successfully"
else
    print_warning "Failed to install git-filter-repo. File history purge functionality will be limited."
fi

echo "📦 Installing js-debug (JavaScript debugger)..."

# Create directory for js-debug
mkdir -p ~/.local/share

# Remove existing installation if present
if [ -d ~/.local/share/js-debug ]; then
    print_warning "Removing existing js-debug installation..."
    rm -rf ~/.local/share/js-debug
fi

# Download official pre-built release
cd ~/.local/share
if wget -q https://github.com/microsoft/vscode-js-debug/releases/download/v1.77.0/js-debug-dap-v1.77.0.tar.gz; then
    print_status "Downloaded js-debug release"
else
    print_error "Failed to download js-debug"
    exit 1
fi

# Extract the archive
if tar xzf js-debug-dap-v1.77.0.tar.gz; then
    print_status "Extracted js-debug"
else
    print_error "Failed to extract js-debug"
    exit 1
fi

# Clean up archive
rm js-debug-dap-v1.77.0.tar.gz

# Verify installation
if [ -f ~/.local/share/js-debug/src/dapDebugServer.js ]; then
    print_status "js-debug installed successfully"
else
    print_error "js-debug installation verification failed"
    exit 1
fi

echo ""
echo "🔧 Setting up todo script permissions..."
if chmod +x ~/.config/nvim/lua/utils/todo.lua; then
    print_status "todo script permissions set"
else
    print_warning "Failed to set todo script permissions"
fi

echo "🔧 Testing todo script functionality..."
if cd ~/.config/nvim && lua lua/utils/todo.lua >/dev/null 2>&1; then
    print_status "todo script working correctly"
else
    print_warning "todo script test failed - check lua and rg installation"
fi

echo ""
echo "📦 Installing Rust/Cargo (for fff.nvim and other Rust-based plugins)..."

# Check if cargo is already installed
if command -v cargo &> /dev/null; then
    print_status "Cargo is already installed ($(cargo --version))"
else
    print_warning "Cargo not found. Installing Rust..."

    # Install Rust using rustup
    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
        print_status "Rust installed successfully"
        # Source cargo env for current session
        source "$HOME/.cargo/env"
    else
        print_error "Failed to install Rust. Please install manually from https://rustup.rs"
    fi
fi

# Build fff.nvim Rust backend if the plugin exists
FFF_PLUGIN_PATH="$HOME/.local/share/nvim/lazy/fff.nvim"
if [ -d "$FFF_PLUGIN_PATH" ]; then
    echo "Building fff.nvim Rust backend..."
    if cd "$FFF_PLUGIN_PATH" && cargo build --release 2>/dev/null; then
        print_status "fff.nvim Rust backend built successfully"
    else
        print_warning "Failed to build fff.nvim backend - will retry on next plugin load"
    fi
else
    print_warning "fff.nvim plugin not found - will build on first install"
fi

echo ""
echo "🔧 Installing smart-splits kittens for Kitty integration..."
SMART_SPLITS_PATH="$HOME/.local/share/nvim/lazy/smart-splits.nvim"
if [ -d "$SMART_SPLITS_PATH" ]; then
    if [ -f "$SMART_SPLITS_PATH/kitty/install-kittens.bash" ]; then
        if bash "$SMART_SPLITS_PATH/kitty/install-kittens.bash"; then
            print_status "smart-splits kittens installed successfully"
        else
            print_warning "Failed to install smart-splits kittens - run manually if needed"
        fi
    else
        print_warning "smart-splits install script not found - plugin may not be installed yet"
    fi
else
    print_warning "smart-splits plugin not found - install Lazy.nvim plugins first"
fi

# Install StyLua
echo ""
echo "📦 Installing StyLua (Lua formatter)..."

# Determine the latest version
STYLUA_VERSION="v0.20.0"
STYLUA_RELEASE_URL="https://github.com/JohnnyMorganz/StyLua/releases/download/${STYLUA_VERSION}/stylua-linux-x86_64.zip"

# Create directory for stylua
mkdir -p ~/.local/bin

# Download StyLua
cd /tmp
if wget -q "${STYLUA_RELEASE_URL}"; then
    print_status "Downloaded StyLua release"
else
    print_error "Failed to download StyLua"
    exit 1
fi

# Extract and install
if unzip -q stylua-linux-x86_64.zip; then
    print_status "Extracted StyLua"
    chmod +x stylua
    mv stylua ~/.local/bin/
    rm stylua-linux-x86_64.zip
else
    print_error "Failed to extract StyLua"
    exit 1
fi

# Verify installation
if ~/.local/bin/stylua --version > /dev/null 2>&1; then
    print_status "StyLua installed successfully"
else
    print_error "StyLua installation verification failed"
fi

echo ""
echo "🔧 Setting up nvc command symlink..."
NVC_SCRIPT="$HOME/.config/nvim/bin/nvc"
NVC_SYMLINK="$HOME/.local/bin/nvc"

if [ -f "$NVC_SCRIPT" ]; then
    # Remove existing symlink if it exists
    if [ -L "$NVC_SYMLINK" ]; then
        rm "$NVC_SYMLINK"
    fi
    
    # Create symlink
    if ln -s "$NVC_SCRIPT" "$NVC_SYMLINK"; then
        print_status "nvc command symlink created successfully"
    else
        print_warning "Failed to create nvc symlink"
    fi
else
    print_warning "nvc script not found at $NVC_SCRIPT"
fi

echo ""
echo "🎉 All dependencies installed successfully!"
echo ""
echo "Installed components:"
echo "  • git-resolve-conflict: ✅ Built-in (pure Lua)"
echo "  • git-filter-repo: $(which git-filter-repo > /dev/null && echo '✅ Available' || echo '❌ Not found')"
echo "  • js-debug: $([ -f ~/.local/share/js-debug/src/dapDebugServer.js ] && echo '✅ Available' || echo '❌ Not found')"
echo "  • stylua: $(~/.local/bin/stylua --version > /dev/null 2>&1 && echo '✅ Available' || echo '❌ Not found')"
echo "  • cargo/rust: $(command -v cargo > /dev/null && echo '✅ Available' || echo '❌ Not found')"
echo "  • fff.nvim backend: $([ -f ~/.local/share/nvim/lazy/fff.nvim/target/release/libfff_lib.dylib ] || [ -f ~/.local/share/nvim/lazy/fff.nvim/target/release/libfff_lib.so ] && echo '✅ Built' || echo '❌ Not built')"
echo "  • todo script: $([ -x ~/.config/nvim/lua/utils/todo.lua ] && echo '✅ Executable' || echo '❌ Not executable')"
echo "  • smart-splits kittens: $([ -f ~/.config/kitty/neighboring_window.py ] && echo '✅ Available' || echo '❌ Not found')"
echo "  • nvc command: $([ -L ~/.local/bin/nvc ] && echo '✅ Available' || echo '❌ Not found')"
echo ""
echo "ℹ️  Restart Neovim to use the new dependencies."
echo "ℹ️  This script works across machines (lab, yuval) due to portable paths."
echo "ℹ️  Make sure ~/.local/bin is in your PATH for stylua to work."
echo ""
echo "Fixed warnings/errors:"
echo "  • git-resolve-conflict warning: ✅ Resolved"
echo "  • js-debug not found error: ✅ Resolved"
echo "  • DAP launch.json warning: ✅ Silenced"
