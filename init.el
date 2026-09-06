;; -*- lexical-binding: t; -*-

;; ============================================================
;; PAQUETS
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
;; INTERFACE
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
;; THEME + ICONES
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
;; EXPLORATEUR DE FICHIERS (TREEMACS)
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
;; AUTOCOMPLETION / LSP (EGLOT POUR REACT/TS + HTML)
;; ============================================================
;; Désactive company-mode et eglot dans node_modules
(defun my-disable-lsp-in-node-modules ()
  (when (string-match-p "/node_modules/" (or buffer-file-name ""))
    (company-mode -1)
    (when (fboundp 'eglot--managed-mode)
      (eglot--managed-mode -1))))

(add-hook 'after-change-major-mode-hook 'my-disable-lsp-in-node-modules)

;; Configuration de company-mode (comme avant)
(use-package company
  :hook (prog-mode . company-mode)
  :custom
  (company-idle-delay 0.2)  ; Reviens à ta valeur initiale
  (company-minimum-prefix-length 1)  ; Reviens à ta valeur initiale
  (company-backends
   '((company-capf :separate)  ; Utilise eglot pour la complétion
     company-dabbrev-code
     company-dabbrev
     company-files
     company-keywords)))

;; Active company-mode pour html-mode
(add-hook 'html-mode-hook 'company-mode)

;; Configuration Eglot (comme avant, mais avec support HTML)
(use-package eglot
  :hook ((c-mode c++-mode
          python-mode
          js-mode typescript-mode
          tsx-ts-mode typescript-ts-mode js-ts-mode
          html-mode) . eglot-ensure)  ; Ajoute html-mode ici
  :config
  ;; Désactive les fonctionnalités lourdes
  (setq eglot-stay-out-of '(flycheck eldoc eglot-flymake))
  (setq eglot-inlay-hints nil)
  (setq eglot-server-programs-timeout 15)

  ;; Utilise tsserver pour TypeScript/JSX (comme avant)
  (add-to-list 'eglot-server-programs
               '((tsx-ts-mode typescript-ts-mode js-ts-mode)
                 . ("/home/louis/.local/share/pi-node/node-v22.23.2-linux-x64/bin/tsserver" "--stdio")))

  ;; Ajoute vscode-html-language-server pour HTML
  (add-to-list 'eglot-server-programs
               '((html-mode) .
                 ("/home/louis/.local/share/pi-node/node-v22.23.2-linux-x64/lib/node_modules/vscode-html-language-server/bin/html-language-server" "--stdio"))))

;; Associer les extensions de fichiers aux modes
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . html-mode))

;; Force tsx-ts-mode pour les fichiers .jsx
(add-hook 'jsx-mode-hook (lambda () (tsx-ts-mode)))

;; ============================================================
;; TERMINAL INTEGRÉ
;; ============================================================
(add-to-list 'display-buffer-alist
             '("^\\*vterm\\*"
               (display-buffer-in-side-window)
               (side . bottom)
               (window-height . 0.3)))

(use-package vterm)

(defun mon-toggle-vterm ()
  "Ouvre ou ferme le terminal vterm en bas de la fenêtre."
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
;; RECHERCHE GLOBALE + DÉPLACER DES LIGNES
;; ============================================================
(use-package consult)

(use-package move-text
  :config
  (move-text-default-bindings))

;; ============================================================
;; COPIER / COLLER SYSTÈME (CUA)
;; ============================================================
(cua-mode 1)
(setq cua-auto-tabify-rectangles nil)
(setq cua-keep-region-after-copy t)

;; ============================================================
;; RACCOURCIS FAÇON VSCODE
;; ============================================================
(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key (kbd "C-S-s") 'isearch-forward)
(global-set-key (kbd "C-z") 'undo)
(global-set-key (kbd "C-f") 'isearch-forward)
(global-set-key (kbd "C-S-f") 'consult-ripgrep)
(global-set-key (kbd "C-o") 'find-file)
(global-set-key (kbd "C-b") 'treemacs)
(global-set-key (kbd "C-~") 'mon-toggle-vterm)
(global-set-key (kbd "C-S-a") 'move-beginning-of-line)
(global-set-key (kbd "C-a") 'mark-whole-buffer)
(global-set-key (kbd "C-S-k") 'kill-line)

(define-prefix-command 'vscode-prefix-map)
(global-set-key (kbd "C-k") 'vscode-prefix-map)

(defun mon-ouvrir-dossier ()
  "Ferme tous les projets treemacs actuels et ouvre un nouveau dossier."
  (interactive)
  (require 'treemacs)
  (unless (treemacs-get-local-window)
    (treemacs))
  (let* ((dossier (read-directory-name "Open Folder : "))
         (nom (file-name-nondirectory (directory-file-name dossier)))
         (anciens-projets (treemacs-workspace->projects (treemacs-current-workspace))))
    (treemacs-do-add-project-to-workspace dossier nom)
    (dolist (projet anciens-projets)
      (ignore-errors
        (treemacs-do-remove-project-from-workspace projet)))
    (treemacs-select-window)))

(define-key vscode-prefix-map (kbd "C-o") #'mon-ouvrir-dossier)

(with-eval-after-load 'treemacs
  (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action))

;; ============================================================
;; ONGLETS + SPLIT
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

(defun mon-split-droite ()
  "Splitte la fenêtre verticalement et déplace le focus dessus."
  (interactive)
  (split-window-right)
  (other-window 1))
(global-set-key (kbd "C-\\") 'mon-split-droite)

;; ============================================================
;; INDENTATION + AUTRES
;; ============================================================
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(setq-default c-basic-offset 4)
(setq-default python-indent-offset 4)
(setq-default js-indent-level 4)
(setq-default css-indent-offset 4)

(with-eval-after-load 'company
  (define-key company-active-map (kbd "TAB") #'company-complete-selection)
  (define-key company-active-map (kbd "<tab>") #'company-complete-selection)
  (define-key company-active-map (kbd "RET") nil)
  (define-key company-active-map (kbd "<return>") nil))

(electric-pair-mode 1)

(with-eval-after-load 'treemacs
  (treemacs-git-mode 'extended))

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (diff-hl-flydiff-mode 1))

(setq treesit-language-source-alist
      '((tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")))

;; ============================================================
;; TERMINAL (VTERM)
;; ============================================================
(with-eval-after-load 'vterm
  (define-key vterm-mode-map (kbd "C-S-v") #'vterm-yank)
  (define-key vterm-mode-map (kbd "C-S-c") #'vterm-copy-mode)
  (define-key vterm-mode-map (kbd "C-S-v") #'vterm-yank))

;; ============================================================
;; TAB INTELLIGENT
;; ============================================================
(defun mon-tab-intelligent ()
  "Indente la ligne ; si déjà indentée, insère 4 espaces."
  (interactive)
  (let ((avant (current-indentation)))
    (indent-for-tab-command)
    (when (and (= avant (current-indentation))
               (<= (current-column) (current-indentation)))
      (insert "    "))))

(global-set-key (kbd "TAB") #'mon-tab-intelligent)

;; ============================================================
;; INDENTATION POUR TS/TSX
;; ============================================================
(setq typescript-ts-mode-indent-offset 4)
(setq js-indent-level 4)

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
   '(consult move-text which-key magit vterm company eglot treemacs-all-the-icons treemacs doom-modeline doom-themes all-the-icons markdown-mode)))
(custom-set-faces
 )
