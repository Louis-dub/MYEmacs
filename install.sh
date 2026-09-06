#!/bin/bash

# ============================================================
# Emacs Configuration Installation Script for Louis
# ============================================================

# Check if the script is run from the correct directory
if [ ! -f "init.el" ]; then
    echo "❌ Error: Run this script from the Emacs configuration directory (where init.el is located)."
    exit 1
fi

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display a success message
echo_success() {
    echo -e "${GREEN}✅${NC} $1"
}

# Function to display an error message
echo_error() {
    echo -e "${RED}❌${NC} $1"
}

# Function to display a warning message
echo_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

# Check dependencies
echo "Checking dependencies..."

# Check Emacs
if ! command -v emacs &> /dev/null; then
    echo_error "Emacs is not installed. Please install it first."
    exit 1
else
    echo_success "Emacs is installed."
fi

# Check Git
if ! command -v git &> /dev/null; then
    echo_error "Git is not installed. Please install it first."
    exit 1
else
    echo_success "Git is installed."
fi

# Check npm (for LSP tools)
if ! command -v npm &> /dev/null; then
    echo_warning "npm is not installed. LSP tools (tsserver, html-language-server) will not be installed automatically."
else
    echo_success "npm is installed."
fi

# Create ~/.config/emacs directory if it doesn't exist
mkdir -p ~/.config/emacs

# Create a symbolic link for init.el
if [ -f "~/.config/emacs/init.el" ]; then
    echo_warning "An init.el file already exists in ~/.config/emacs/. It will be overwritten by a symbolic link."
    rm -f ~/.config/emacs/init.el
fi

ln -sf "$(pwd)/init.el" ~/.config/emacs/init.el
echo_success "Symbolic link created: ~/.config/emacs/init.el -> $(pwd)/init.el"

# Install external tools for LSP (if npm is available)
if command -v npm &> /dev/null; then
    echo "Installing LSP tools..."
    
    # Install tsserver for TypeScript
    if ! command -v tsserver &> /dev/null; then
        echo "Installing tsserver..."
        npm install -g typescript@latest
        echo_success "tsserver installed."
    else
        echo_success "tsserver is already installed."
    fi
    
    # Install vscode-html-language-server for HTML
    if ! command -v html-language-server &> /dev/null; then
        echo "Installing vscode-html-language-server..."
        npm install -g @vscode/html-language-server
        echo_success "vscode-html-language-server installed."
    else
        echo_success "vscode-html-language-server is already installed."
    fi
else
    echo_warning "npm is not available. Manually install tsserver and vscode-html-language-server with:"
    echo "  npm install -g typescript @vscode/html-language-server"
fi

# Install Emacs packages
echo "Installing Emacs packages..."
 emacs --batch \
       --eval "(setq package-archives '((\"melpa\" . \"https://melpa.org/packages/\") (\"elpa\" . \"https://elpa.gnu.org/packages/\") (\"nongnu\" . \"https://elpa.nongnu.org/nongnu/\")))" \
       --eval "(package-initialize)" \
       --eval "(unless (package-installed-p 'use-package) (package-refresh-contents) (package-install 'use-package))" \
       --eval "(require 'use-package)" \
       --eval "(mapc (lambda (pkg) (unless (package-installed-p pkg) (package-install pkg))) \
                 '(use-package all-the-icons doom-themes doom-modeline treemacs treemacs-all-the-icons company eglot vterm magit which-key consult move-text markdown-mode diff-hl))" \
       --eval "(kill-emacs)"

echo_success "Emacs packages installation complete."

echo ""
echo_success "✨ Installation complete! Restart Emacs to apply the changes."
echo ""
echo "To launch Emacs with your new configuration:"
echo "  emacs"
