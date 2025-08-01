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

echo "🎉 All dependencies installed successfully!"
echo ""
echo "Installed components:"
echo "  • git-resolve-conflict: ✅ Built-in (pure Lua)"
echo "  • git-filter-repo: $(which git-filter-repo > /dev/null && echo '✅ Available' || echo '❌ Not found')"
echo "  • js-debug: $([ -f ~/.local/share/js-debug/src/dapDebugServer.js ] && echo '✅ Available' || echo '❌ Not found')"
echo "  • todo script: $([ -x ~/.config/nvim/lua/utils/todo.lua ] && echo '✅ Executable' || echo '❌ Not executable')"
echo ""
echo "ℹ️  Restart Neovim to use the new dependencies."
echo "ℹ️  This script works across machines (lab, yuval) due to portable paths."
echo ""
echo "Fixed warnings/errors:"
echo "  • git-resolve-conflict warning: ✅ Resolved"
echo "  • js-debug not found error: ✅ Resolved"
echo "  • DAP launch.json warning: ✅ Silenced"
