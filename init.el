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
;; AUTOCOMPLETION / LSP
;; ============================================================
(use-package company
  :hook (prog-mode . company-mode)
  :custom
  (company-idle-delay 0.2)
  (company-minimum-prefix-length 1)
  (company-backends
   '((company-capf :separate)
     company-dabbrev-code
     company-dabbrev
     company-files
     company-keywords)))

(use-package eglot
  :hook ((c-mode c++-mode
          python-mode
          html-mode) . eglot-ensure)  ;; <--- JS/TS/TSX/JSX RETIRÉS D'ICI
  :config
  (setq eglot-stay-out-of '(flycheck eldoc eglot-flymake))
  (setq eglot-inlay-hints nil)

  (add-to-list 'eglot-server-programs
               '((html-mode)
                 . ("/usr/local/bin/vscode-html-language-server" "--stdio")))
  )
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
;; Indentation JS/TS supprimée, laissera la valeur par défaut d'Emacs

(electric-pair-mode 1)

(with-eval-after-load 'treemacs
  (treemacs-git-mode 'extended))

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (diff-hl-flydiff-mode 1))

;; Sources Tree-sitter pour TS/JS supprimées

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
(custom-set-faces)