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
(when (treesit-ready-p 'javascript)
  (add-to-list 'auto-mode-alist '("\\.cjs\\'" . js-ts-mode)))
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

(use-package web-mode
  :mode "\\.ejs\\'")

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
(global-set-key (kbd "C-c a") 'gptel)
(global-set-key (kbd "C-c RET") 'gptel-send)
(global-set-key (kbd "C-c m") 'gptel-switch-model)
(global-set-key (kbd "C-c f") 'gptel-add-file)
(global-set-key (kbd "C-c r") 'gptel-context-remove-all)
(global-set-key (kbd "C-c d") 'my-cycle-gptel-directives)

(define-prefix-command 'vscode-prefix-map)
(global-set-key (kbd "C-k") 'vscode-prefix-map)

(defvar my-project-path nil "Open project path")

(defun my-open-folder ()
  "Close all current treemacs projects and open a new folder."
  (interactive)
  (require 'treemacs)
  (unless (treemacs-get-local-window)
    (treemacs))
  (let* ((folder (read-directory-name "Open Folder: "))
         (name (file-name-nondirectory (directory-file-name folder)))
         (old-projects (treemacs-workspace->projects (treemacs-current-workspace))))
    (setq my-project-path folder)
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
;; GPTEL (LLM via Ollama)
;; ============================================================
(use-package gptel
  :config
  (setq gptel-backend
        (gptel-make-ollama "OLlama"
          :host "IP_SERVER:11434"
          :stream t
          :models '((devstral :capabilities (tool-use)) codellama))
        gptel-model 'devstral))

(defun gptel-switch-model ()
  "Switch to the following gptel backend model"
  (interactive)
  (let* ((models (gptel-backend-models gptel-backend))
         (next (or (cadr (memq gptel-model models))
                   (car models))))
    (setq-default gptel-model next)
    (setq gptel-model next)
    (message "gptel : model -> %s" next))
  )

;; ----- Read project -----
(defun my-require-project ()
  "Check open project"
  (if (null my-project-path)
      (user-error "No project open")
    my-project-path))

(defun my-project-full-path (path)
  "Find full path for a file / folder"
  (let ((file (expand-file-name path (my-require-project))))
    (unless (file-in-directory-p file my-project-path)
      (user-error "File not in Project"))
    file))

(defun my-tool-list-directory (path)
  "Return list of project files / folder"
  (let ((full-path (my-project-full-path path)))
    (mapconcat #'(lambda (file)
                   (if (file-directory-p file)
                       (concat (file-name-nondirectory file) "/")
                     (file-name-nondirectory file)))
               (directory-files full-path t directory-files-no-dot-files-regexp)
               "\n")))

(gptel-make-tool
 :name "list_directory"
 :function #'my-tool-list-directory
 :description "Lists the files and subfolders of a folder in the project. Folders end with a slash."
 :args '((:name "path"
                :type string
                :description "Path of the folder, relative to the project root. Use \".\" for the root itself."))
 :category "Tool")


;; ----- Read file -----
(defun my-tool-read-file (path)
  "Read file."
  (let ((full-path (my-project-full-path path)))
    (with-temp-buffer
      (insert-file-contents full-path)
      (buffer-string))))

(gptel-make-tool
 :name "read_file"
 :function #'my-tool-read-file
 :description "Reads and returns the full text content of a file in the project. Use list_directory first to find file paths."
 :args '((:name "path"
                :type string
                :description "Path of the file, relative to the project root, for example \"src/main.c\"."))
 :category "Tool")

;; ----- Search in project -----
(defun my-tool-search-project (pattern)
  "Search pattern in project"
  (let ((default-directory (my-require-project)))
    (mapconcat 'identity
               (process-lines-ignore-status
                "rg"
                "--line-number"
                "--no-heading"
                "-e"
                pattern
                ".")
               "\n")))

(gptel-make-tool
 :name "search_project"
 :function #'my-tool-search-project
 :description "Searches the project for a regular expression and returns matching lines, one per line, formatted as file:line:text. Use short word stems that cover variants (for example \"rotat\" matches both \"rotate\" and \"rotation\", \"iso\" matches \"isometric\"). To find where a function is called, search its exact name. These lines are only excerpts: you MUST use read_file on the relevant files before answering anything about how the code works."
 :args '((:name "pattern"
                :type string
                :description "A regular expression to search for in file contents."))
 :category "Tool")

(setq gptel-tools (list (gptel-get-tool "list_directory") (gptel-get-tool "read_file") (gptel-get-tool "search_project")))


;; =========================================================
;; Directives système pour Devstral
;; =========================================================
(defvar my-current-directive-key 'default
  "Key of the directive currently used by gptel.")

(defun my-cycle-gptel-directives ()
  "Switch the gptel system prompt to the next directive in gptel-directives."
  (interactive)
  (let* ((keys (mapcar #'car gptel-directives))
         (next (or (cadr (memq my-current-directive-key keys))
                   (car keys))))
    (setq my-current-directive-key next)
    (setq-local gptel--system-message (alist-get next gptel-directives))
    (message "gptel directive -> %s" next)))

(setf (alist-get 'default gptel-directives)
      "You are a code assistant for the project open in Emacs. Use your tools to explore it.
1. Search with short English word stems that cover variants (\"rotat\" rather than \"rotate\" or \"rotation\"), even if the question is in French. If nothing is found, try other stems.
2. Never guess a path: call list_directory on \".\" first, then on the relevant subfolders.
3. Search results are only excerpts: after every search, call read_file on the relevant files before answering.
4. After reading a file, search for the exact name of its main functions to find who calls them (for example \"apply_rotation\"), and read those files too: callers show what triggers the code (events, initialization).
5. For a calculation, write the formula, then explain each term using the real code.
6. Describe only what the code you read actually does. Do not add textbook explanations, general properties or definitions (for example \"this algorithm is stable\" or \"isometric means...\"): if it is not visible in the code, leave it out. If a step is in a file you have not read, read it first.
7. Answer in the language of the question.")

(setf (alist-get 'tutor gptel-directives)
      "You are a coding tutor. The user learns a technology by building a project and wants YOU to explain the notions and functions so they can write the code themselves, without reading the docs.
CODE RULE: never write a program, a function or a solution for the user's project. You may show a small example of ONE notion, 5 lines of code at most, on a different subject than the user's step. When the user asks you to write it, explain the notion and list in plain words what to write, step by step.
Method: at the start, if the user gave no level, ask what they already know. Break the project into medium-sized steps. For each step: explain every new notion and the functions to use (name, role, arguments, a short example), describe in plain words what to write, then stop and wait. If the user says they want to go fast, make the steps bigger, but still write no code.
Tools: use list_directory, search_project and read_file through the tool-calling mechanism. Never guess a path: if a file is not found, list the subfolders or search. At the start of a session, read PROGRESS.md in the project root if it exists.
Review: when the user shows their work, read their files first, then check everything: does it work, naming, structure, edge cases. Give specific feedback.
After each step, ask one short question to check understanding.
If the user is stuck, ask a guiding question. After 5 failed attempts on the same problem, you may show the solution with a full explanation.
At the end of a session, give the user 3 or 4 plain lines for PROGRESS.md: what is done, decisions taken, next step.
The user may paste a project statement that contains code: do not reuse that code in your answers.
Explain in detail when a notion is new. Reply in the language of the user's message. Names in code are in English.
Reminder: no complete code for the user's project.")

(setq-default gptel--system-message (alist-get 'default gptel-directives))

;; ============================================================
;; CUSTOM
;; ============================================================
(custom-set-variables
 '(package-selected-packages
   '(all-the-icons apheleia company consult dockerfile-mode doom-modeline doom-themes eglot gptel magit markdown-mode move-text treemacs treemacs-all-the-icons vterm web-mode which-key)))
(custom-set-face)
