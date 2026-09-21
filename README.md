# MYEmacs

This is a custom Emacs configuration for Linux, designed for general-purpose development.

## Overview

Here is a preview of the project:

![preview](screenshot_emacs.png)

---

## 🛠️ Install the Project

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
2. **Install the Tree-sitter grammars**:
   Type M-: and enter this command:
   ```elisp
   (mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist))
   ```

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

### Supported

#### Languages
- C / C++
- Python
- HTML / CSS
- JavaScript
- TypeScript

#### FrameWorks
- React (JSX/TSX)

#### Configuration formats
- JSON
- YAML

#### Containerisation
- Docker

#### Artificial Intelligence
- codeLlama with Ollama (You must install the model yourself)

---

## ShortCuts

### Global Shortcuts

These shortcuts are available across all modes and buffers.
   **Shortcut**       | **Command**               | **Description**                              |
 |--------------------|---------------------------|----------------------------------------------|
 | `C-s`              | `save-buffer`             | Save the current buffer.                     |
 | `C-S-s`            | `isearch-forward`         | Incremental search forward.                  |
 | `C-z`              | `undo`                    | Undo the last action.                         |
 | `C-f`              | `isearch-forward`         | Incremental search forward.                  |
 | `C-S-f`            | `consult-ripgrep`         | Global search in files using `ripgrep`.      |
 | `C-o`              | `find-file`               | Open a file.                                  |
 | `C-b`              | `treemacs`                | Toggle the Treemacs file explorer.           |
 | `C-~`              | `my-toggle-vterm`         | Toggle the integrated terminal (`vterm`).     |
 | `C-S-a`            | `move-beginning-of-line` | Move cursor to the beginning of the line.     |
 | `C-a`              | `mark-whole-buffer`      | Select the entire buffer.                     |
 | `C-S-k`            | `kill-line`               | Delete the current line.                      |
 | `C-\`              | `my-split-right`          | Split the window vertically.                  |
 | `C-<prior>`        | `centaur-tabs-backward`   | Switch to the previous tab.                   |
 | `C-<next>`         | `centaur-tabs-forward`    | Switch to the next tab.                       |
 | `TAB`              | `my-smart-tab`            | Indent or complete with Company.              |

---
### CUA Mode Shortcuts (Copy, Cut, Paste)
These shortcuts are enabled by `cua-mode` for a familiar editing experience.
 | **Shortcut**       | **Command**               | **Description**                              |
 |--------------------|---------------------------|----------------------------------------------|
 | `C-c`              | `kill-ring-save`          | Copy the selected text to the clipboard.      |
 | `C-x`              | `kill-region`             | Cut the selected text.                        |
 | `C-v`              | `yank`                    | Paste the copied/cut text.                    |

---
### Treemacs (File Explorer)
 | **Shortcut**       | **Command**               | **Description**                              |
 |--------------------|---------------------------|----------------------------------------------|
 | `C-c t`            | `treemacs`                | Toggle Treemacs file explorer.               |
 | `C-k C-o`          | `my-open-folder`          | Open a folder in Treemacs.                   |

---

### Terminal (Vterm)
 | **Shortcut**       | **Command**               | **Description**                              |
 |--------------------|---------------------------|----------------------------------------------|
 | `C-S-v`            | `vterm-yank`              | Paste into the terminal.                     |
 | `C-S-c`            | `vterm-copy-mode`         | Enter copy mode in the terminal.              |

---

### LSP (Eglot) and Autocompletion (Company)
 | **Shortcut**       | **Command**                     | **Context**                     |
 |--------------------|---------------------------------|----------------------------------|
 | `TAB`              | `company-complete-selection`   | Complete the selection in Company.|
 | `<up>`             | `company-select-previous`      | Select the previous item in Company. |
 | `<down>`           | `company-select-next`          | Select the next item in Company.     |
 | `RET`              | Disabled in Company.           | Prevents automatic validation.   |

---

### Artificial Intelligence (codeLlama with Ollama)
 | **Shortcut**       | **Command**               | **Description**                              |
 |--------------------|---------------------------|----------------------------------------------|
 | `C-c C-a`          | `gptel`                   | Open the codeLlama interaction buffer.       |
 | `C-c C-l C-r`      | `gptel-send`              | Send selected region to codeLlama. 

---

### Text Editing
 | **Shortcut**       | **Command**               | **Description**                              |
 |--------------------|---------------------------|----------------------------------------------|
 | `C-c C-n`          | `next-buffer`             | Switch to the next buffer.                   |
 | `C-c C-p`          | `previous-buffer`         | Switch to the previous buffer.               |

---
### Git (Magit)
 | **Shortcut**       | **Command**               | **Description**                              |
 |--------------------|---------------------------|----------------------------------------------|
 | `C-c g`            | `magit-status`            | Open the Magit interface.                    |

---
---
### Notes
- **`C-k`** is a prefix for custom commands (e.g., `C-k C-o` to open a folder).
- **VSCode-like shortcuts** (`C-s`, `C-z`, etc.) are inspired by VSCode for a smoother transition.
- **Company** and **Eglot** shortcuts are optimized for autocompletion and code analysis.
- **CUA mode** enables `C-c`, `C-x`, and `C-v` for copy, cut, and paste, respectively.

## Customization

- **Change the theme**: Edit `init.el` and modify the `(load-theme 'doom-one t)` line.
- **Add new packages**: Use `use-package` in `init.el` and run `M-x package-install <package-name>`.

---

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
