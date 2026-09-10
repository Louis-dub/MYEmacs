;; -*- lexical-binding: t; -*-
(require 'treesit)
;; ============================================================
;; PACKAGES
;; ============================================================
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; ============================================================
;; PERFORMANCE (keep this early in the file)
;; ============================================================
(setq read-process-output-max (* 1024 1024)) ;; 1MB
(setq eglot-events-buffer-size 0)
(setq gc-cons-threshold (* 100 1024 1024)) ;; 100MB

;; ============================================================
;; UI
;; ============================================================
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(setq inhibit-startup-message t)

(global-display-line-numbers-mode t)
(column-number-mode t)
(setq visible-bell t)

(setq make-backup-files nil)
(setq auto-save-default nil)
(global-auto-revert-mode t)

(fset 'yes-or-no-p 'y-or-n-p)
(put 'narrow-to-region 'disabled nil)

(when (member "Cascadia Mono" (font-family-list))
  (set-face-attribute 'default nil :font "Cascadia Mono" :height 110))

;; ============================================================
;; THEME + ICONS
;; ============================================================
(use-package all-the-icons
  :if (display-graphic-p))

(use-package doom-themes
  :config
  (load-theme 'doom-one t)
  (doom-themes-org-config))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-icon t))

;; ============================================================
;; FILE EXPLORER (TREEMACS)
;; ============================================================
(use-package treemacs
  :bind
  (:map global-map
        ("C-c t" . treemacs)))

(use-package treemacs-all-the-icons
  :after (treemacs all-the-icons)
  :config
  (treemacs-load-theme "all-the-icons"))

;; ============================================================
;; TREE-SITTER (modern syntax highlighting + web support)
;; ============================================================
(setq treesit-language-source-alist
      '((python "https://github.com/tree-sitter/tree-sitter-python" "v0.23.6")
        (c "https://github.com/tree-sitter/tree-sitter-c" "v0.23.3")
        (cpp "https://github.com/tree-sitter/tree-sitter-cpp" "v0.22.0")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "v0.23.1")
        (css "https://github.com/tree-sitter/tree-sitter-css" "v0.23.1")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "typescript/src")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "v0.23.2" "tsx/src")
        (html "https://github.com/tree-sitter/tree-sitter-html")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (yaml "https://github.com/tree-sitter-grammars/tree-sitter-yaml" "v0.7.2")
        (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
        (bash "https://github.com/tree-sitter/tree-sitter-bash" "v0.23.3")))

(setq major-mode-remap-alist
      (delq nil
            (list
             (when (treesit-ready-p 'python) '(python-mode . python-ts-mode))
             (when (treesit-ready-p 'c) '(c-mode . c-ts-mode))
             (when (treesit-ready-p 'cpp) '(c++-mode . c++-ts-mode))
             (when (treesit-ready-p 'yaml) '(yaml-mode . yaml-ts-mode))
             (when (treesit-ready-p 'json) '(json-mode . json-ts-mode))
             (when (treesit-ready-p 'javascript) '(js-mode . js-ts-mode))
             (when (treesit-ready-p 'css) '(css-mode . css-ts-mode)))))

(when (treesit-ready-p 'typescript)
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode)))
(when (treesit-ready-p 'tsx)
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode)))
(when (treesit-ready-p 'css)
  (add-to-list 'auto-mode-alist '("\\.css\\'" . css-ts-mode)))
(when (and (treesit-ready-p 'html) (fboundp 'html-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.html\\'" . html-ts-mode)))

;; ============================================================
;; DOCKER / YAML
;; ============================================================
(use-package dockerfile-mode
  :mode "Dockerfile\\'")

(use-package yaml-ts-mode
  :ensure nil
  :mode ("\\.ya?ml\\'" . yaml-ts-mode))

;; ============================================================
;; AUTO-FORMATTING (Prettier on save for web files)
;; ============================================================
(use-package apheleia
  :config
  (apheleia-global-mode +1))

;; ============================================================
;; AUTOCOMPLETION / LSP
;; ============================================================
(use-package company
  :hook (prog-mode . company-mode)
  :custom
  (company-idle-delay 0.2)
  (company-minimum-prefix-length 1)
  (company-selection-wrap-around t)
  (company-backends
   '((company-capf :separate)
     company-dabbrev-code
     company-dabbrev
     company-files
     company-keywords))
  :config
  (define-key company-active-map (kbd "<up>") #'company-select-previous)
  (define-key company-active-map (kbd "<down>") #'company-select-next)
  (define-key company-active-map (kbd "TAB") #'company-complete-selection)
  (define-key company-active-map (kbd "<tab>") #'company-complete-selection)
  (define-key company-active-map (kbd "RET") nil))

(use-package eglot
  :hook ((c-mode c-ts-mode
                 c++-mode c++-ts-mode
                 python-mode python-ts-mode
                 js-mode js-ts-mode
                 typescript-ts-mode tsx-ts-mode
                 css-mode css-ts-mode
                 mhtml-mode html-ts-mode
                 dockerfile-mode) . eglot-ensure)
  :config
  (setq eglot-stay-out-of '(eldoc))
  (setq eglot-inlay-hints nil)

  (add-to-list 'eglot-server-programs
               '((js-mode js-ts-mode typescript-ts-mode tsx-ts-mode) . ("typescript-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((mhtml-mode html-ts-mode) . ("vscode-html-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((css-mode css-ts-mode) . ("vscode-css-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(dockerfile-mode . ("docker-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(yaml-ts-mode . ("yaml-language-server" "--stdio"))))

;; ============================================================
;; INTEGRATED TERMINAL
;; ============================================================
(add-to-list 'display-buffer-alist
             '("^\\*vterm\\*"
               (display-buffer-in-side-window)
               (side . bottom)
               (window-height . 0.3)))

(use-package vterm)

(defun my-toggle-vterm ()
  "Open or close the vterm terminal at the bottom of the window."
  (interactive)
  (let ((buf (get-buffer "*vterm*")))
    (if (and buf (get-buffer-window buf))
        (delete-window (get-buffer-window buf))
      (if buf
          (display-buffer buf)
        (vterm)))))

;; ============================================================
;; GIT (MAGIT)
;; ============================================================
(use-package magit
  :bind
  (:map global-map
        ("C-c g" . magit-status)))

;; ============================================================
;; WHICH-KEY
;; ============================================================
(use-package which-key
  :init (which-key-mode)
  :custom
  (which-key-idle-delay 0.3))

;; ============================================================
;; GLOBAL SEARCH + MOVE LINES
;; ============================================================
(use-package consult)

(use-package move-text
  :config
  (move-text-default-bindings))

;; ============================================================
;; SYSTEM COPY / PASTE (CUA)
;; ============================================================
(cua-mode 1)
(setq cua-auto-tabify-rectangles nil)
(setq cua-keep-region-after-copy t)

;; ============================================================
;; VSCODE-STYLE KEYBINDINGS
;; ============================================================
(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key (kbd "C-S-s") 'isearch-forward)
(global-set-key (kbd "C-z") 'undo)
(global-set-key (kbd "C-f") 'isearch-forward)
(global-set-key (kbd "C-S-f") 'consult-ripgrep)
(global-set-key (kbd "C-o") 'find-file)
(global-set-key (kbd "C-b") 'treemacs)
(global-set-key (kbd "C-~") 'my-toggle-vterm)
(global-set-key (kbd "C-S-a") 'move-beginning-of-line)
(global-set-key (kbd "C-a") 'mark-whole-buffer)
(global-set-key (kbd "C-S-k") 'kill-line)

(define-prefix-command 'vscode-prefix-map)
(global-set-key (kbd "C-k") 'vscode-prefix-map)

(defun my-open-folder ()
  "Close all current treemacs projects and open a new folder."
  (interactive)
  (require 'treemacs)
  (unless (treemacs-get-local-window)
    (treemacs))
  (let* ((folder (read-directory-name "Open Folder: "))
         (name (file-name-nondirectory (directory-file-name folder)))
         (old-projects (treemacs-workspace->projects (treemacs-current-workspace))))
    (treemacs-do-add-project-to-workspace folder name)
    (dolist (project old-projects)
      (ignore-errors
        (treemacs-do-remove-project-from-workspace project)))
    (treemacs-select-window)))

(define-key vscode-prefix-map (kbd "C-o") #'my-open-folder)

(with-eval-after-load 'treemacs
  (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action))

;; ============================================================
;; TABS + SPLIT
;; ============================================================
(use-package centaur-tabs
  :demand
  :config
  (centaur-tabs-mode t)
  (setq centaur-tabs-style "bar")
  (setq centaur-tabs-height 32)
  (setq centaur-tabs-set-icons t)
  (setq centaur-tabs-set-modified-marker t)
  (setq centaur-tabs-show-navigation-buttons t)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward))

(defun my-split-right ()
  "Split the window vertically and move focus to the new one."
  (interactive)
  (split-window-right)
  (other-window 1))
(global-set-key (kbd "C-\\") 'my-split-right)

;; ============================================================
;; INDENTATION + MISC
;; ============================================================
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(setq-default c-basic-offset 4)
(setq-default c-ts-mode-indent-offset 4)
(setq-default python-indent-offset 4)
(setq-default typescript-ts-mode-indent-offset 4)
(setq-default js-indent-level 4)
(setq-default css-ts-mode-indent-offset 4)
(setq-default css-indent-offset 4)
(setq-default json-ts-mode-indent-offset 4)
(setq-default sh-basic-offset 4)

(electric-pair-mode 1)

(with-eval-after-load 'treemacs
  (treemacs-git-mode 'extended))

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (diff-hl-flydiff-mode 1))

;; ============================================================
;; TERMINAL (VTERM)
;; ============================================================
(with-eval-after-load 'vterm
  (define-key vterm-mode-map (kbd "C-S-v") #'vterm-yank)
  (define-key vterm-mode-map (kbd "C-S-c") #'vterm-copy-mode)
  (define-key vterm-mode-map (kbd "C-S-v") #'vterm-yank))

;; ============================================================
;; SMART TAB
;; ============================================================
(defun my-smart-tab ()
  "Indent the current line, or accept the Company completion if the
popup is currently visible (so TAB never fights with Company)."
  (interactive)
  (if (and (bound-and-true-p company-mode)
           (company-tooltip-visible-p))
      (company-complete-selection)
    (let ((before (current-indentation)))
      (indent-for-tab-command)
      (when (and (= before (current-indentation))
                 (<= (current-column) (current-indentation)))
        (insert "    ")))))

(global-set-key (kbd "TAB") #'my-smart-tab)

;; ============================================================
;; MARKDOWN
;; ============================================================
(use-package markdown-mode
  :mode ("\\.md\\'" . gfm-mode))

;; ============================================================
;; CUSTOM
;; ============================================================
(custom-set-variables
 '(package-selected-packages
   '(apheleia dockerfile-mode consult move-text which-key magit vterm company eglot treemacs-all-the-icons treemacs doom-modeline doom-themes all-the-icons markdown-mode)))
(custom-set-faces)
