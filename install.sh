#!/usr/bin/env bash
# ============================================================
# Emacs dev environment setup — Ubuntu/Debian
# Run with: bash setup-emacs.sh
# ============================================================
set -e

echo "==> 1. System packages (Emacs, compiler, git, ripgrep, vterm build deps)"
sudo apt update
sudo apt install -y emacs build-essential git curl ripgrep \
    cmake libtool libtool-bin libvterm-dev python3-pip

# Your config uses treesit, which needs Emacs 29 or newer.
EMACS_MAJOR=$(emacs --version | head -1 | grep -oE '[0-9]+' | head -1)
echo "    $(emacs --version | head -1)"
if [ "$EMACS_MAJOR" -lt 29 ]; then
    echo "ERROR: Emacs $EMACS_MAJOR is too old (29+ required for tree-sitter)."
    echo "       Install a newer Emacs (newer distro release, or: sudo snap install emacs --classic)."
    exit 1
fi

# ------------------------------------------------------------
# IMPORTANT: do NOT compile your own libtree-sitter.so from
# source and do NOT put it in /usr/local/lib. The system's
# default libtree-sitter (from apt) is what Emacs was built
# against and works correctly. Versions 0.22.4+ have a known
# crash bug (treesit-font-lock-fontify-region / stack smashing,
# see github.com/tree-sitter/tree-sitter/issues/3296). Leave the
# system package as-is; only the GRAMMARS need pinning (handled
# by the Emacs config below), not the core library.
# ------------------------------------------------------------

echo "==> 2. Node.js + npm (for JS/TS/HTML/CSS/YAML/Docker language servers)"
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
fi

echo "==> 3. Language servers via npm"
sudo npm install -g \
    typescript-language-server typescript \
    vscode-langservers-extracted \
    dockerfile-language-server-nodejs \
    yaml-language-server

echo "==> 4. C/C++ language server"
sudo apt install -y clangd

echo "==> 5. Python language server"
pip install pyright --break-system-packages

echo "==> 6. Prettier (used by apheleia for auto-format on save)"
sudo npm install -g prettier

echo "==> 7. Font (optional: your config falls back to the default font without it)"
sudo apt install -y fonts-cascadia-code || echo "    Font package not found, skipping."

echo "==> 8. Emacs config directory"
if [ -d "$HOME/.emacs.d" ]; then
    echo "    WARNING: ~/.emacs.d exists and takes priority over ~/.config/emacs."
    echo "             Move or remove it, or your init.el will be ignored."
fi
mkdir -p ~/.config/emacs
cp init.el ~/.config/emacs/

echo ""
echo "==> Done. Remaining manual steps:"
echo ""
echo "  1. In init.el, replace IP_SERVER with the address of your Ollama machine."
echo ""
echo "  2. Launch Emacs, then evaluate once (M-: or in *scratch* with C-x C-e):"
echo "     (mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist))"
echo ""
echo "  3. Install the icon fonts once: M-x all-the-icons-install-fonts"
