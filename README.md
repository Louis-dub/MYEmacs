# MYEmacs

This is a custom Emacs configuration for Linux, designed for general-purpose development.

---

## 🛠️ Install the Project

### Install Required Tools

#### 1. Install **Emacs**

Choose the appropriate command for your Linux distribution:

**Ubuntu/Debian:**

```bash
sudo apt update && sudo apt install -y emacs
```

**Fedora:**

```bash
sudo dnf install -y emacs
```

**Arch Linux:**

```bash
sudo pacman -S emacs
```

**For GUI support (recommended):**  
If you want to use Emacs with a graphical interface, install the GTK version:

**Ubuntu/Debian:**

```bash
sudo apt install -y emacs-gtk
```

**Fedora:**

```bash
sudo dnf install -y emacs-gtk
```

**Arch Linux:**

```bash
sudo pacman -S emacs-gtk
```

---

#### 2. Install **Node.js and npm**

`npm` is required to install LSP servers like `tsserver` and `vscode-html-language-server`.

**Ubuntu/Debian:**

```bash
sudo apt update && sudo apt install -y nodejs npm
```

**Fedora:**

```bash
sudo dnf install -y nodejs npm
```

**Arch Linux:**

```bash
sudo pacman -S nodejs npm
```

**For the latest Node.js version (recommended):**  
Use `nvm` (Node Version Manager) to install the latest version of Node.js:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts
```

---

### Clone the Repository

#### With HTTPS (URL)

```bash
git clone https://github.com/Louis-dub/MYEmacs.git
```

#### With SSH

```bash
git clone git@github.com:Louis-dub/MYEmacs.git
```

---

### Install Configuration

#### 1. Navigate to the repository

```bash
cd MYEmacs
```

#### 2. Make the installation script executable

```bash
chmod 755 install.sh
```

#### 3. Launch the installation

```bash
./install.sh
```

---

### Post-Installation Steps

1. **Restart Emacs** to apply the configuration:
  ```bash
   emacs
  ```
2. **Verify LSP servers** (optional):
  - Open a TypeScript or HTML file and check that `eglot` starts automatically.
  - Use `M-x eglot-ensure` to manually start the LSP server.

---

### Troubleshooting

#### Emacs GUI does not launch

- Ensure you installed `emacs-gtk` or `emacs` with GUI support.
- Run Emacs with:
  ```bash
  emacs &
  ```

#### LSP servers are not working

- Verify that `tsserver` and `vscode-html-language-server` are installed:
  ```bash
  npm install -g typescript @vscode/html-language-server
  ```

#### Missing packages in Emacs

- Manually refresh and install packages:
  ```bash
  emacs --batch --eval "(package-refresh-contents)" --eval "(package-install 'use-package)"
  ```

---

### Customization

- **Change the theme**: Edit `init.el` and modify the `(load-theme 'doom-one t)` line.
- **Add new packages**: Use `use-package` in `init.el` and run `M-x package-install <package-name>`.

---

### License

MIT
