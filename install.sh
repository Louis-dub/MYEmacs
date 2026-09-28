#!/usr/bin/env bash
# ============================================================
# Emacs dev environment setup — Ubuntu/Debian
# Run with: bash setup-emacs.sh
# ============================================================
set -e

echo "==> 1. System packages (Emacs, compiler, git)"
sudo apt update
sudo apt install -y emacs build-essential git curl

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

echo "==> 7. Emacs config directory"
mkdir -p ~/.config/emacs
cp -r init.el ~/.config/emacs/
echo "    On first launch, evaluate this once (M-: or in *scratch* with C-x C-e):"
echo ""
echo "    (mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist))"
echo ""
echo "==> Done. Launch Emacs and install the tree-sitter grammars as shown above."
